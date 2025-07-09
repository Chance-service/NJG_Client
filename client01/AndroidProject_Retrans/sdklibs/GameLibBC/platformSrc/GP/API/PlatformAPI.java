// PlatformAPI.java
package API;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.widget.FrameLayout;

import com.chance.allsdk.SDKService;
import com.nuclear.bean.PayInfo;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.util.UUID;
import android.view.ViewGroup;
import  org.json.JSONArray;
import android.webkit.ValueCallback;
import android.app.Dialog;

public class PlatformAPI extends SDKService {
	private static final String TAG = "PlatformAPI";

	private static final String PREF_NAME   = "oauth_pref";
	private static final String KEY_ACCESS  = "access_token";
	private static final String KEY_REFRESH = "refresh_token";
	private static final String KEY_EXPIRES = "expires_at";

	private static final String CLIENT_ID     = "hxckSLaLDkoEuQRT";
	private static final String GAME_ID     = "624";
	private static final String GAME_VERSION = "1.4.5.6";
	private static final String CLIENT_SECRET = "84tD7sLx55q0dgXpGiUgeesUXZQz6aWjtD8hILjX";
	private static final String REDIRECT_URI  = "chance.release.ninja.girl://chance";
	private static final String AUTH_URL      = "https://www.game-park.co/oauth/login";
	private static final String TOKEN_URL     = "https://api.game-park.co/oauth2/getToken";
	private static final String PROFILE_URL   = "https://openapi.game-park.co/v1/user/profile";

	private static final String PAY_URL   = "https://openapi.game-park.co/v1/pay";



	private WebView currentWebView = null;


	private String playerId   = "";

	private boolean isSandBox = APP_DBG;

	private static PlatformAPI instance;
	private FrameLayout webContainer;

	private Dialog authDialog;

	public static PlatformAPI getInstance() {
		if (instance == null) instance = new PlatformAPI();
		return instance;
	}

	@Override
	public void onCreateSDK() {
		Activity act = home_activity;

		authDialog = new Dialog(act, android.R.style.Theme_Translucent_NoTitleBar_Fullscreen);

		webContainer = new FrameLayout(act);
		webContainer.setLayoutParams(new FrameLayout.LayoutParams(
				FrameLayout.LayoutParams.MATCH_PARENT,
				FrameLayout.LayoutParams.MATCH_PARENT
		));

		authDialog.setContentView(webContainer);

		authDialog.hide();
	}

	@Override
	public void sdkLogin() {
		SharedPreferences sp = home_activity.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
		String token   = sp.getString(KEY_ACCESS, "");
		Log.d(TAG, "Login token=" + token);
		String refresh = sp.getString(KEY_REFRESH, "");
		Log.d(TAG, "Login refresh=" + refresh);
		long expires   = sp.getLong(KEY_EXPIRES, 0);
		Log.d(TAG, "Login expires=" + expires);
		platformtoken = token;
		if (token != null && System.currentTimeMillis() < expires) {
			authDialog.hide();
			fetchUserProfile(token);
		} else if (refresh != null) {
			refreshAccessToken(refresh);
		} else {
			authDialog.show();
			startOAuthFlow();
		}
	}

	@Override
	public void sdkLogout() {
		SharedPreferences.Editor editor = home_activity.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE).edit();
		editor.clear();
		editor.apply();

		// 清除暫存變數
		platformtoken = null;
		playerId = null;
		uuid = null;
		sdkLogin();
	}

	private void startOAuthFlow() {
		Activity act = home_activity;

		String state = UUID.randomUUID().toString();
		act.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
				.edit().putString("oauth_state", state).apply();

		String authUrl = AUTH_URL + "?response_type=code"
				+ "&redirect_uri=none"
				+ "&client_id=" + CLIENT_ID
				+ "&game_id=" + GAME_ID
				+"&game_version=" + GAME_VERSION
				+ "&state=" + state
				+ (APP_DBG ? "&environment=sandbox" : "");
		Log.d(TAG, "Login authUrl=" + authUrl);
		WebView webView = new WebView(act);
		webView.getSettings().setJavaScriptEnabled(true);
		webView.getSettings().setDomStorageEnabled(true);
		CookieManager.getInstance().setAcceptCookie(true);
		currentWebView = webView;
		webView.setWebChromeClient(new WebChromeClient());
		webView.setWebViewClient(new WebViewClient());
		CookieManager.getInstance().removeAllCookies(null);
		authDialog.show();

		webView.setWebViewClient(new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				if (url.startsWith(REDIRECT_URI)) {
					Uri uri = Uri.parse(url);
					String code = uri.getQueryParameter("code");
					String returnedState = uri.getQueryParameter("state");
					String expected = act.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
							.getString("oauth_state", "");
					Log.d(TAG, "Login code=" + code);
					Log.d(TAG, "Login returnedState=" + returnedState);
					Log.d(TAG, "Login expected=" + expected);
					if (expected.equals(returnedState)) {
						webContainer.removeAllViews();
						authDialog.hide();
						exchangeCodeForToken(code);
					}
					return true;
				}
				return false;
			}
		});

		webContainer.removeAllViews();
		webContainer.addView(webView);
		webView.loadUrl(authUrl);
	}

	private void exchangeCodeForToken(String code) {
		new Thread(() -> {
			try {
				String body = "grant_type=authorization_code"
						+ "&code=" + URLEncoder.encode(code, "UTF-8")
						+ "&redirect_uri=none"// + URLEncoder.encode(REDIRECT_URI, "UTF-8")
						+ "&client_id=" + URLEncoder.encode(CLIENT_ID, "UTF-8")
						+ "&client_secret=" + URLEncoder.encode(CLIENT_SECRET, "UTF-8")
						+ (APP_DBG ? "&environment=sandbox" : "");
				Log.d(TAG, "Login body=" + body);
				HttpURLConnection conn = (HttpURLConnection) new URL(TOKEN_URL).openConnection();
				conn.setRequestMethod("POST");
				conn.setDoOutput(true);
				conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

				authDialog.hide();

				try (OutputStream os = conn.getOutputStream()) {
					os.write(body.getBytes("UTF-8"));
				}

				BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
				StringBuilder resp = new StringBuilder();
				String line;
				while ((line = br.readLine()) != null) resp.append(line);
				br.close();
				Log.d(TAG, "Login resp=" + resp.toString());
				JSONObject json = new JSONObject(resp.toString());
				String token   = json.getString("access_token");
				String refresh = json.optString("refresh_token", null);
				long expires   = json.optLong("expires_in", 0);
				Log.d(TAG, "Login token2=" + token);
				Log.d(TAG, "Login refresh2=" + refresh);
				Log.d(TAG, "Login expires2=" + expires);

				SharedPreferences sp = home_activity.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
				sp.edit()
						.putString(KEY_ACCESS, token)
						.putString(KEY_REFRESH, refresh)
						.putLong(KEY_EXPIRES, System.currentTimeMillis() + expires * 1000L)
						.apply();

				authDialog.hide();
				new Handler(Looper.getMainLooper()).post(() -> fetchUserProfile(token));
				platformtoken = token;
			} catch (Exception e) {
				Log.e(TAG, "OAuth token exchange failed", e);
			}
		}).start();
	}

	private void refreshAccessToken(String refreshToken) {
		new Thread(() -> {
			try {
				String body = "grant_type=refresh_token"
						+ "&refresh_token=" + URLEncoder.encode(refreshToken, "UTF-8")
						+ "&client_id=" + URLEncoder.encode(CLIENT_ID, "UTF-8")
						+ "&client_secret=" + URLEncoder.encode(CLIENT_SECRET, "UTF-8")
						+ "&redirect_uri=none"
						+ (APP_DBG ? "&environment=sandbox" : "");

				HttpURLConnection conn = (HttpURLConnection) new URL(TOKEN_URL).openConnection();
				conn.setRequestMethod("POST");
				conn.setDoOutput(true);
				conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");

				try (OutputStream os = conn.getOutputStream()) {
					os.write(body.getBytes("UTF-8"));
				}

				BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream()));
				StringBuilder resp = new StringBuilder();
				String line;
				while ((line = br.readLine()) != null) resp.append(line);
				br.close();

				JSONObject json = new JSONObject(resp.toString());
				String token   = json.getString("access_token");
				String refresh = json.optString("refresh_token", null);
				long expires   = json.optLong("expires_in", 0);

				SharedPreferences sp = home_activity.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
				sp.edit()
						.putString(KEY_ACCESS, token)
						.putString(KEY_REFRESH, refresh)
						.putLong(KEY_EXPIRES, System.currentTimeMillis() + expires * 1000L)
						.apply();

				new Handler(Looper.getMainLooper()).post(() -> fetchUserProfile(token));
				platformtoken = token;
				authDialog.hide();
			} catch (Exception e) {
				Log.e(TAG, "refreshAccessToken error", e);
				new Handler(Looper.getMainLooper()).post(this::startOAuthFlow);
			}
		}).start();
	}

	private void fetchUserProfile(String accessToken) {
		new Thread(() -> {
			HttpURLConnection conn = null;
			try {
				// game_id 是放在 URL 上
				String urlWithGameId = PROFILE_URL + "?game_id=" + GAME_ID;
				URL url = new URL(urlWithGameId);
				conn = (HttpURLConnection) url.openConnection();
				conn.setRequestMethod("GET");
				conn.setRequestProperty("Authorization", "Bearer " + accessToken);
				conn.setRequestProperty("Content-Type", "application/json");

				int code = conn.getResponseCode();
				Log.d(TAG, "HTTP code: " + code);

				InputStream is = (code >= 200 && code < 300)
						? conn.getInputStream()
						: conn.getErrorStream();

				BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
				StringBuilder resp = new StringBuilder();
				String line;
				while ((line = br.readLine()) != null) resp.append(line);
				br.close();

				Log.d(TAG, "Profile API response: " + resp);

				JSONObject obj = new JSONObject(resp.toString());
				JSONObject data = obj.optJSONObject("data");
				if (data != null) {
					String uid = data.optString("id", "");
					String nick = data.optString("nickname", "");
					playerId = uid;
					uuid = "gameparkuser_" + uid;
					Log.d(TAG, "Login success: uid=" + uid + ", nick=" + nick);
				}

			} catch (Exception e) {
				Log.e(TAG, "fetchUserProfile error", e);
			} finally {
				if (conn != null) conn.disconnect();
			}
		}).start();
	}


	@Override
	public void toPay(PayInfo info) {
		new Thread(() -> {
			try {

				Cocos2dxHelper.nativeSendMessageP2G("GPStatus", "startLoading");
				URL url = new URL(PAY_URL);
				HttpURLConnection conn = (HttpURLConnection) url.openConnection();
				conn.setRequestMethod("POST");
				conn.setDoOutput(true);
				conn.setRequestProperty("Authorization", "Bearer " + platformtoken);
				conn.setRequestProperty("Content-Type", "application/json");

				// 建立支付 payload
				JSONObject payload = new JSONObject();
				payload.put("user_id", playerId);
				payload.put("game_id", GAME_ID);
				payload.put("game_version", GAME_VERSION);
				payload.put("redirect_uri", REDIRECT_URI);

				JSONObject item = new JSONObject();
				item.put("title", info.product_name);
				item.put("price", info.price);  // 單位為元
				item.put("quantity", info.count);
				item.put("type", "道具");

				payload.put("item", new JSONArray().put(item));

				// 發送請求
				OutputStream os = conn.getOutputStream();
				os.write(payload.toString().getBytes("UTF-8"));
				os.flush();
				os.close();
				int code = conn.getResponseCode();
				InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();

				BufferedReader reader = new BufferedReader(new InputStreamReader(is, "UTF-8"));
				StringBuilder resp = new StringBuilder();
				String line;
				while ((line = reader.readLine()) != null) resp.append(line);
				reader.close();

				Log.d(TAG, "Pay response (" + code + "): " + resp);

				if (code == 200 ) {

					JSONObject obj = new JSONObject(resp.toString());
					JSONObject data = obj.optJSONObject("data");
					String payUrl = data != null ? data.optString("url", "") : "";

					if (!payUrl.isEmpty()) {
						new Handler(Looper.getMainLooper()).post(() -> {
							WebView payWebView = new WebView(home_activity);
							payWebView.getSettings().setJavaScriptEnabled(true);
							payWebView.getSettings().setDomStorageEnabled(true);
							payWebView.getSettings().setUseWideViewPort(true);
							payWebView.getSettings().setLoadWithOverviewMode(true);
							payWebView.setWebChromeClient(new WebChromeClient());
							currentWebView = payWebView;

							CookieManager cookieManager = CookieManager.getInstance();
							cookieManager.setAcceptCookie(true);
							cookieManager.setAcceptThirdPartyCookies(payWebView, true);

							// URL 監控回傳
							payWebView.setWebViewClient(new WebViewClient() {
								@Override
								public void onPageFinished(WebView view, String url) {
									// 嘗試取出整個 body 裡面的文字
									view.evaluateJavascript(
											"(function() { return document.body.innerText; })();",
											new ValueCallback<String>() {
												@Override
												public void onReceiveValue(String value) {
													if (value.contains("余额不足") || value.contains("ERR_UNKNOWN_URL_SCHEME")) {
														Log.d(TAG, "偵測到餘額不足");
														webContainer.removeAllViews();
														authDialog.hide();
														Cocos2dxHelper.nativeSendMessageP2G("GPStatus", "noMoney");
													} else {
														if (url.startsWith(REDIRECT_URI)) {
															Uri uri = Uri.parse(url);
															String orderNo = uri.getQueryParameter("order_no");
															Log.d(TAG, "支付完成，訂單號: " + orderNo);
															authDialog.hide();
															// 清空畫面
															webContainer.removeAllViews();
															// 傳回 Lua
															Cocos2dxHelper.nativeSendMessageP2G("onGPPay", orderNo + "|" + platformtoken + "|" + info.product_id);
														}
													}
												}
											}
									);
								}
							});

							payWebView.loadUrl(payUrl);
							webContainer.removeAllViews();
							webContainer.addView(payWebView);
							authDialog.show();
							Cocos2dxHelper.nativeSendMessageP2G("GPStatus", "endLoading");
						});
					}
				} else {
					Log.e(TAG, "Payment failed HTTP " + code + ": " + resp);
					if (code==500){
						Cocos2dxHelper.nativeSendMessageP2G("GPStatus", "noMoney");
					}
				}

			} catch (Exception e) {
				Log.e(TAG, "Payment Error", e);
			}
		}).start();
	}

	// 補充方法：清理 WebView
	private void clearWebView(WebView view) {
		new Handler(Looper.getMainLooper()).post(() -> {
			try {
				ViewGroup parent = (ViewGroup) view.getParent();
				if (parent != null) parent.removeView(view);
				view.stopLoading();
				view.clearHistory();
				view.removeAllViews();
				view.destroy();
				authDialog.hide();
			} catch (Exception e) {
				Log.e(TAG, "WebView clear error", e);
			}
		});
	}
	@Override
	public boolean onBackPressed() {
		if (currentWebView != null) {
			clearWebView(currentWebView);
			webContainer.removeAllViews();
			authDialog.hide();
			currentWebView = null;
			Log.d(TAG, "WebView closed on back press");
			return true; // 攔截成功
		}
		return false; // 沒攔截，Activity 再做處理
	}



}
