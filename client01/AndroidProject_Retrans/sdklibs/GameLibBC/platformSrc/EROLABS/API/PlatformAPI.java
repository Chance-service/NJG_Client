package API;

import android.content.Context;

import com.chance.allsdk.SDKService;
import com.nuclear.bean.PayInfo;
import com.adjust.sdk.*;

import org.json.*;

import com.hyena.sdk.android.*;


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

    public static Tracker tracker;
    //public static String h365token ="";

	@Override
	public void onCreateSDK(){
		aTag = "TEST_EROLABS";
	}

	@Override
	public void initHyenaSDK(){
		String appKey = "70A857C60DF94AACB8C48D6EE6A5C594";

		tracker = AnalyticsBuilder.Companion.build(home_activity,appKey);

		//tracker.login("123","244");

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
			tabDBId = "hskrojuyh6ysndd1"; // chance use
	    	channel = "quanta";
	    } else
	    {
			tabDBId = "nzh5yq3ncmpf4gbb";
	    	channel = "EROLABS";
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
		JSONObject msgJsonObj;
		try {
			msgJsonObj = new JSONObject(msg);
			int eventId = msgJsonObj.getInt("eventId");

			if (eventId == 2){  // report hyena login
				String userId = msgJsonObj.getString("userId");
				String platformUserId = msgJsonObj.getString("userId");
				boolean isok =  tracker.login(userId,platformUserId);
				showlog("tracker login report: " + String.valueOf(isok));
			}
		}catch(Exception e){
			showlog("JsonError: " + e.getMessage());
		}
	}

}