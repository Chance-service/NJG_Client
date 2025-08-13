package API;

import android.content.Context;

import com.chance.allsdk.SDKService;
import com.nuclear.bean.PayInfo;
import games.h365.sdk.*;
import games.h365.sdk.payment.PaymentData;
import games.h365.sdk.payment.PaymentItem;

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

    public static H365SDK h365sdk;
    //public static String h365token ="";

	@Override
	public void onCreateSDK(){
    	if ((h365sdk == null)) {
			String merchantId = "SSP";
			String serviceId = "NJG";
			String environment = (APP_DBG) ? "sandbox" : "production";

			H365SDKParameterData parameterData = new H365SDKParameterData(
				merchantId,
				serviceId,
				environment,
				"zh-CN",
				false
			);
			aTag = "TEST_H365";
			h365sdk = new H365SDK(home_activity, parameterData);
			showlog("onCreate H356");
			isCreate = true ;
		}
	}

	@Override
	public void initAdjustSDK(Context context){
		super.initAdjustSDK(context);
	}

    @Override
    public void initTabDB()
    {
    	if (isSetTabDB)
    	{
    		showlog("H365 Api repeat set");
    		return;
    	}

	    if (APP_DBG)
	    {
			tabDBId = "hskrojuyh6ysndd1"; // chance use
	    	channel = "quanta";
	    } else
	    {
			tabDBId = "kad6kdj4p1vjwuzg";
	    	channel = "H365";
	    }

		super.initTabDB();
    }
	@Override
    public void toPay(PayInfo pay_info) throws JSONException{
    	double usd = Math.round(pay_info.price/100);
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

/*    	JSONObject jsonData = new JSONObject();
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
	@Override
	public void onShowProfile(){

	}
	@Override
    public void sdkLogin() {
		if (h365sdk != null)
		{
			showlog("login_H365 call sdk");
			h365sdk.login(loginCallback);
		}
		else
		{
			showlog("sdkapi is null");
		}
	}
	@Override
	public void onResume() {

	}
	@Override
	public void sdkLogout() {
		if (h365sdk != null)
		{
			showlog("logout H365 call sdk" );
			h365sdk.logout(logoutCallback);
		}
		else
		{
			showlog("sdkapi is null");
		}
	}

	@Override
	public void Report_Handler(String msg){

		JSONObject msgJsonObj;
		try {
			msgJsonObj = new JSONObject(msg);
			int eventId = msgJsonObj.getInt("eventId");
			if (eventId == 1) {
				h365sdk.getDataAnalystManager().completedRegistrationEvent();
			}

			if (eventId == 2){
				h365sdk.getDataAnalystManager().loginEvent();
			}
		}catch(Exception e){
			showlog("JsonError: " + e.getMessage());
		}
	}

    public void validate() {
		if ((h365sdk != null)) {
			h365sdk.validate(platformtoken, httpCallback);
			showlog("validate H365");
		}
	}

    public void openPaymentURL(String url, String paymentId){
		if ((h365sdk != null)) {
    		h365sdk.openPaymentURL(url, paymentId);
    		showlog("openPaymentURL H365");
		}
    }

    LoginCallback loginCallback = new LoginCallback() {

	    @Override
	    public void onSuccess(String token,boolean callbool) {
	    	showlog("login H365 onSuccess");
			platformtoken = token;
	        showlog("login  H365 h365token: " + platformtoken);
	        validate();
	    }

	    @Override
	    public void onFailure(String message) {

	    	showlog("login H365 fail: " + message);
	    }
    };

    LogoutCallback logoutCallback = new LogoutCallback() {

	    @Override
	    public void onSuccess() {
			platformtoken = "";
	        uuid ="";
			sdkLogin();
	        showlog("logout H365 success");
	    }

	    @Override
	    public void onFailure(String message) {

	    	showlog("logout H365 fail: " + message);
	    }
    };

    HttpCallback httpCallback = new HttpCallback() {

	    @Override
	    public void onCallback(HttpResult result) {
	    	showlog("H365 statusCode: " + result.statusCode);
	    	showlog("H365 data: " + result.data);
	    	showlog("H365 exception: " + result.exception);

	        if (result.statusCode == 200)
	        {
            	 JSONObject jtmp;
            	 try{
            		 jtmp = new JSONObject(result.data);
            		 int acode = jtmp.getInt("code");
            		 if (acode == 0)
            		 {
            			 uuid = jtmp.getJSONObject("data").getString("uuid");

            		 }
            		 else
            		 {
            			 showlog("H365Http_ErrorCode:" + Integer.toString(acode));
            		 }
            	 }catch(Exception e){
            		 showlog("JsonError: " + e.getMessage());
            	 }
            }
	    }
    };

    HttpCallback PayCallback = new HttpCallback() {

	    @Override
	    public void onCallback(HttpResult result) {
	    	showlog("H365Pay statusCode: " + result.statusCode);
	    	showlog("H365Pay data: " + result.data);
	    	showlog("H365Pay exception: " + result.exception);

	        if ((result.statusCode >= 200) && (result.statusCode <= 300))
	        {
            	 JSONObject jtmp;
            	 try{
            		 jtmp = new JSONObject(result.data);
            		 int acode = jtmp.getInt("code");
            		 if (acode == 1)
            		 {
            			 String paymentId = jtmp.getJSONObject("data").getString("paymentId");
            			 int paymentStatus = jtmp.getJSONObject("data").getInt("paymentStatus");
            			 long orderTime = jtmp.getJSONObject("data").getLong("orderTime");
            			 String transactionUrl =  jtmp.getJSONObject("data").getString("transactionUrl");
            			 showlog("H365Pay paymentStatus: " + Integer.toString(paymentStatus));
            			 if (paymentStatus == 0)
            			 {
            				 openPaymentURL(transactionUrl,paymentId);
            				 showlog("H365Pay openPaymentURL");
            			 }
            		 }
            		 else
            		 {
            			 showlog("PayH365Http_ErrorCode:" + Integer.toString(acode));
            		 }
            	 }catch(Exception e){
            		 showlog("PayJsonError: " + e.getMessage());
            	 }
            }

	    }
    };
}