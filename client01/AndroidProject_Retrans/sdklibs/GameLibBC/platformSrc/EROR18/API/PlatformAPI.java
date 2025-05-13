package API;

import android.content.Context;

import com.chance.allsdk.SDKService;
import com.nuclear.bean.PayInfo;
import com.adjust.sdk.*;

import org.json.*;


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

    //public static H365SDK h365sdk;
    //public static String h365token ="";

	@Override
	public void onCreateSDK(){
	}
	@Override
	public void initAdjustSDK(Context context){
		String appToken = "l8p87lid1rsw";
		String environment = "";
		if (APP_DBG) {
			environment = AdjustConfig.ENVIRONMENT_SANDBOX;
		}
		else {
			environment = AdjustConfig.ENVIRONMENT_PRODUCTION;
		}
		AdjustConfig config = new AdjustConfig(context, appToken, environment);
		config.setLogLevel(LogLevel.VERBOSE);
//
		Adjust.initSdk(config);
//
		super.initAdjustSDK(context);
	}

    @Override
    public void initTabDB()
    {
    	if (isSetTabDB)
    	{
    		showlog("EROR18 Api repeat set");
    		return;
    	}

	    if (APP_DBG)
	    {
			tabDBId = "nzh5yq3ncmpf4gbb"; // chance use
	    	channel = "quanta";
	    } else
	    {
			tabDBId = "08seaj07xvubjqph";
	    	channel = "EROR18";
	    }

		super.initTabDB();
    }
	@Override
    public void toPay(PayInfo pay_info) throws JSONException{
/*    	double usd = Math.round(pay_info.price/100);
    	String imageurl = "https://s3-ap-northeast-1.amazonaws.com/file.idleparadise.com/idleparadise/icon/idleparadise.png";
    	PaymentItem aItem = new PaymentItem(pay_info.product_id, pay_info.product_name, usd, pay_info.count, imageurl, pay_info.description);
    	JSONObject obj = new JSONObject();
    	obj.put("puid", uuid);
    	obj.put("orderSerial", pay_info.order_serial);
    	obj.put("platform", "android_h365");
    	obj.put("payMoney", Double.toString(pay_info.price)); // h365幣
    	obj.put("goodsId", pay_info.name);
    	obj.put("goodsCount", pay_info.count);
    	obj.put("serverId", Svrid);
    	obj.put("test", "false");
    	String callbackurl = "";
    	showlog("callbackurl: "+callbackurl);

    	callbackurl = payurl+escape(obj.toString())+"&user='h365'";

    	showlog("escape callbackurl: "+callbackurl);
    	PaymentData apayData = new PaymentData(pay_info.order_serial, callbackurl, "", aItem,"USD");
		h365sdk.pay(apayData, platformtoken, PayCallback);
    	showlog("toH365Pay");

    	JSONObject jsonData = new JSONObject();
    	jsonData.put("ordid", pay_info.order_serial);
    	jsonData.put("callbackurl", callbackurl);
    	jsonData.put("message", "");

    	jsonData.put("ItemId", pay_info.product_id);
    	jsonData.put("ItemName", pay_info.product_name);
    	jsonData.put("unitPrice", usd);
    	jsonData.put("quantity", pay_info.count);
    	jsonData.put("imageUrl", imageurl);
    	jsonData.put("discription", pay_info.description);

    	jsonData.put("currency", "USD");
    	showlog("JsonData: "+ jsonData.toString());*/
    }
	public void onShowProfile(){

	}
	@Override
    public void sdkLogin() {
/* 		if (h365sdk != null)
		{
			showlog("login_H356 call sdk");
			h365sdk.login(loginCallback);
		}
		else
		{
			showlog("sdkapi is null");
		} */
	}
	@Override
	public void onResume() {

	}
	@Override
	public void sdkLogout() {
/* 		if (h365sdk != null)
		{
			showlog("logout H365 call sdk" );
			h365sdk.logout(logoutCallback);
		}
		else
		{
			showlog("sdkapi is null");
		} */
	}

	@Override
	public void Report_Handler(String msg){
/* 		if (eventId == 1) {
			h365sdk.getDataAnalystManager().completedRegistrationEvent();
		}

		if (eventId == 2){
			h365sdk.getDataAnalystManager().loginEvent();
		} */
	}

}