// API/PlatformAPI.java
package API;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.widget.TextView;

import com.chance.allsdk.SDKService;
import com.jgg18.androidsdk.Environment;
import com.jgg18.androidsdk.JGGSDK;
import com.jgg18.androidsdk.callbacks.ResultListener;
import com.jgg18.androidsdk.dataclasses.PaymentItem;
import com.jgg18.androidsdk.dataclasses.PurchaseRequest;
import com.jgg18.androidsdk.dataclasses.PurchaseResult;
import com.jgg18.androidsdk.dataclasses.Session;
import com.jgg18.androidsdk.dataclasses.TransactionStatus;
import com.jgg18.androidsdk.networking.results.JGGError;
import com.nuclear.bean.PayInfo;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

public class PlatformAPI extends SDKService {
	private static PlatformAPI instance;
	private boolean isCreate = false;
	private static boolean dologout = false;
	private static boolean isLogin = false;

	private TextView txt;
	private String cachedTransactionId = "";
	public static String jggToken = "";

	private PlatformAPI() {}

	public static PlatformAPI getInstance() {
		if (instance == null) {
			instance = new PlatformAPI();
		}
		return instance;
	}
	@Override
	public void initTabDB()
	{
		if (isSetTabDB)
		{
			showlog("OP Api repeat set");
			return;
		}

		if (APP_DBG)
		{
			tabDBId = "nzh5yq3ncmpf4gbb"; // chance use
			channel = "quanta";
		} else
		{
			tabDBId = "0qr1rqt9bqhqt8hy";
			channel = "OP";
		}

		super.initTabDB();
	}

	@Override
	public void onCreateSDK() {
		final Activity act = home_activity;
		final String gameId = "a8f40cd6-d0f0-47ca-b378-205f6cd372fe";
		final String channelId = "0";

		if (!isCreate) {
			try {
				JGGSDK.init(gameId, channelId, Environment.PRODUCTION, act);
				//JGGSDK.hideFloatBall();
			} catch (Exception e) {
				Log.e(aTag, "JGGSDK init/show 出错", e);
				showlog("JGGSDK 出错：" + e.getMessage());
			}
			isCreate = true;
		}
	}


	@Override
	public void initAdjustSDK(Context context) {
		super.initAdjustSDK(context);
	}

	@Override
	public void sdkLogin() {
		if (!isLogin) {
			dologout = false;
			JGGSDK.login(new ResultListener<Session>() {
				@Override
				public void callback(Session result) {
					if (result.isQuickSignUp) {
						Log.d(aTag, "Quick login");
					} else {
						Log.d(aTag, "Account login");
					}
					isLogin = true;
					jggToken = result.accessToken;
					uuid = result.userId;
					Log.d(aTag, result.debugString());
				}
			}, new ResultListener<JGGError>() {
				@Override
				public void callback(JGGError err) {
					isLogin = false;
					Log.e(aTag, "Login failed: " + err.debugString());
				}
			}, home_activity);
		}
	}

	@Override
	public void sdkLogout() {
		Log.d(aTag, "logout");
		JGGSDK.logout(home_activity);
		jggToken = "";
		uuid = "";
		dologout = true;
		isLogin = false;
		Log.d(aTag, "logout2");
	}

	@Override
	public void onResume() {
		super.onResume();
	}

	@Override
	public void toPay(PayInfo pay_info) throws JSONException {
		PurchaseRequest req = new PurchaseRequest();
		req.products = new ArrayList<>();

		String imageurl = "https://s3-ap-northeast-1.amazonaws.com/file.idleparadise.com/idleparadise/icon/idleparadise.png";
		PaymentItem item = new PaymentItem(pay_info.name, pay_info.product_name,
				Math.round(pay_info.price), pay_info.count, imageurl, pay_info.description);
		req.products.add(item);

		JSONObject obj = new JSONObject();
		obj.put("puid", uuid);
		obj.put("orderSerial", pay_info.order_serial);
		obj.put("platform", "android_op");
		obj.put("payMoney", Double.toString(pay_info.price));
		obj.put("goodsId", pay_info.name);
		obj.put("goodsCount", pay_info.count);
		obj.put("serverId", Svrid);
		obj.put("test", "false");


	// 組 JSON 並做 URL encoding
		String jsonStr = obj.toString();
		String encodedJson = "";


		req.callbackUrl = payurl + escape(obj.toString()) + "&user='op'";
		showlog(payurl + escape(obj.toString()) + "&user='op'");
		JGGSDK.makePurchase(req, new ResultListener<PurchaseResult>() {
			@Override
			public void callback(PurchaseResult result) {
				showlog("toJggPay1");
				cachedTransactionId = result.transactionId;
				showlog("result.transactionId: " + result.transactionId);
			}
		}, new ResultListener<JGGError>() {
			@Override
			public void callback(JGGError err) {
				showlog("JGG err.statusCode: " + err.statusCode);
				showlog("JGG err.message: " + err.message);
				showlog("toJggPay2");
			}
		}, home_activity);

		showlog("toJggPay3");
	}

	public void verifyPurchase(View view) {
		if (cachedTransactionId != null && !cachedTransactionId.isEmpty()) {
			JGGSDK.verifyPurchase(cachedTransactionId, new ResultListener<TransactionStatus>() {
				@Override
				public void callback(TransactionStatus result) {
					if (txt != null) txt.setText(result.debugString());
					else Log.w(aTag, "txt is null");

					if ("Completed".equals(result.debugString())) {
						// 處理已完成購買的邏輯
					}
				}
			}, new ResultListener<JGGError>() {
				@Override
				public void callback(JGGError err) {
					if (txt != null) txt.setText(err.debugString());
					else Log.w(aTag, "txt is null");
				}
			});
		} else {
			if (txt != null) txt.setText("Please make a transaction first!");
			else Log.w(aTag, "txt is null");
		}
	}
}
