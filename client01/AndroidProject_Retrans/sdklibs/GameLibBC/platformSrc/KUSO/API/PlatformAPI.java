package API;

import android.content.Context;

import com.chance.allsdk.SDKService;
import com.nuclear.bean.PayInfo;

import com.kusoplay.sdk.*;

import org.cocos2dx.lib.Cocos2dxHelper;
import org.json.JSONObject;
import org.json.JSONException;

public class PlatformAPI extends SDKService {

	/**
	 * SDK單例
	 */
	private static PlatformAPI instance = null;

	public static PlatformAPI getInstance() {
		if (instance == null){
			instance = new PlatformAPI();
		}
		return instance;
	}

	private final static String appId = "APPncbR1hdPgUIjSKt";//"APPDZnofBIY5b64jHC";
	private final static String subId = "NG24";
	public static String kusotoken = "";
	private static boolean dologout = false;

	@Override
	public void onCreateSDK(){
		// 設定 KUSO SDK 遊戲資訊.
		PlayCenterConfig config = new PlayCenterConfig(appId, APP_DBG, subId);
		PlayCenter.shared.setup(home_activity, config);

		aTag = "TEST_KUSO";
		showlog("onCreate KUSO");
		isCreate = true ;

	}

	public String gettoken(){
		return kusotoken;
	}

	public boolean getdologout(){
		return dologout;
	}

	@Override
	public void initAdjustSDK(Context context){
		super.initAdjustSDK(context);
	}

	@Override
	public  void initTabDB()
	{
		if (isSetTabDB)
		{
			showlog("KUSO Api repeat set");
			return;
		}

		if (APP_DBG)
		{
			tabDBId = "nzh5yq3ncmpf4gbb"; // chance use
			channel = "quanta";
		} else
		{
			tabDBId = "h4rj7bbhehxks2ml";//""ojd31nr7523qt1pq";
			channel = "KUSO69";
		}
		super.initTabDB();
	}

	public void toPay(PayInfo pay_info) throws JSONException{
		JSONObject obj = new JSONObject();
		obj.put("puid", uuid);
		obj.put("orderSerial", pay_info.order_serial);
		obj.put("platform", "android_kuso");
		obj.put("payMoney", Double.toString(pay_info.price)); // cny
		obj.put("goodsId", pay_info.name);
		obj.put("goodsCount", pay_info.count);
		obj.put("serverId", Svrid);
		obj.put("test", "false");
		String callbackurl = payurl + escape(obj.toString()) + "&user=kuso";
		showlog("callbackurl: " + callbackurl);
		//金額單位:分 (1人民幣=10平台幣)
		showlog("pay order_serial: " + pay_info.order_serial);
		String nonce = pay_info.order_serial;
		String goodsId = pay_info.product_id;
		PlayCenter.shared.payOrder((int)pay_info.price, Currency.CNY, GatewayCode.ALL, callbackurl/*"chance.ninja.girl://chance"*/, pay_info.description,
				pay_info.order_serial, obj.toString(), new PlayCenterPayOrderListener() {
					@Override
					public boolean onPaymentReady(boolean success,
												  String url,
												  String orderId,
												  PlayCenterError error) {
						if (success && orderId.contains("act")) {
							orderId = orderId.replace("\"", "");
							Cocos2dxHelper.nativeSendMessageP2G("onKusoPay", orderId + "|" + kusotoken + "|" + nonce + "|" + goodsId);
						}
						return !success;
					}
				}
		);
	}

	public void onShowProfile(){
		PlayCenter.shared.profile();
	}

	@Override
	public void sdkLogin() {
		if (isCreate) {
			dologout = false;
			PlayCenter.shared.login(new PlayCenterLoginListener() {
				@Override
				public void onLogin(boolean success, String id, String token,PlayCenterError error) {
					if (success){
						uuid = id;
						showlog("login  KUSO uuid: " + uuid);
						kusotoken = token;
						showlog("login  KUSO token: " + kusotoken);
					}
				}
			});

		}
		else
		{
			showlog("sdkapi is null");
		}
	}

	@Override
	public void  sdkLogout() {
		if (isCreate) {
			if (PlayCenter.shared.isLoggedIn()) {
				PlayCenter.shared.logout(new PlayCenterLogoutListener() {
					@Override
					public void onLogout(boolean success) {
						if (success) {
							kusotoken = "";
							uuid = "";
							dologout = true;
							showlog("logout KUSO success");
							Cocos2dxHelper.nativeSendMessageP2G("P2G_PLATFORM_LOGOUT", "1");
						}
					}
				});
			} else {
				showlog("not login status");
			}
		}
		else
		{
			showlog("sdkapi is null");
		}
	}

	public void onAttachedToWindow() {

	}

	public void onDetachedFromWindow() {

	}

	private void getPlayerInfo(){

	}

}