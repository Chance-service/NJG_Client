package API;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.util.Log;
import android.os.Handler;

import com.chance.allsdk.SDKService;
import com.nuclear.bean.PayInfo;
import com.nuclear.gjwow.GameActivity;
import com.xindong.tyrantdb.TyrantdbGameTracker;

import com.jsgame.sdk.JsGameSDKAppService;
import com.jsgame.sdk.JsGameSDKManager;
import com.jsgame.sdk.domain.LoginErrorMsg;
import com.jsgame.sdk.domain.LogincallBack;
import com.jsgame.sdk.domain.LogoutErrorMsg;
import com.jsgame.sdk.domain.LogoutcallBack;
import com.jsgame.sdk.domain.OnLoginListener;
import com.jsgame.sdk.domain.OnLogoutListener;
import com.jsgame.sdk.domain.OnPaymentListener;
import com.jsgame.sdk.domain.OnRecycleListener;
import com.jsgame.sdk.domain.PaymentCallbackInfo;
import com.jsgame.sdk.domain.PaymentErrorMsg;
import com.jsgame.sdk.util.Logger;
import com.jsgame.sdk.util.MResource;
import com.jsgame.sdk.util.OrientationSensorListener;

import org.json.JSONException;
import org.json.JSONObject;

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

	public static JsGameSDKManager jsGameSDKManager = null;

	private OnLogoutListener onlogoutlistener = new OnLogoutListener() {
		@Override
		public void logoutSuccess(LogoutcallBack logoutncallback) {
			String username = logoutncallback.username;

		}

		@Override
		public void logoutError(LogoutErrorMsg errorMsg) {
			Log.d(aTag, "logoutError:" + errorMsg.msg);
		}
	};

	@Override
	public void onCreateSDK(){
    	if ((jsGameSDKManager == null)) {
			aTag = "TEST_JSG";
			jsGameSDKManager = JsGameSDKManager.getInstance(home_activity);
			showlog("onCreate JSG");
			isCreate = true ;
		}
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
	    	channel = "R18";
	    }
	    super.initTabDB();
    }

	@Override
    public void toPay(PayInfo pay_info) throws JSONException{
/*			double usd = Math.round(pay_info.price / 100);
			String imageurl = "https://s3-ap-northeast-1.amazonaws.com/file.idleparadise.com/idleparadise/icon/idleparadise.png";
			//PaymentItem aItem = new PaymentItem(pay_info.product_id, pay_info.product_name, usd, pay_info.count, imageurl, pay_info.description);
			JSONObject obj = new JSONObject();
			obj.put("puid", uuid);
			obj.put("orderSerial", pay_info.order_serial);
			obj.put("platform", "android_h365");
			obj.put("payMoney", Double.toString(pay_info.price)); // H.必
			obj.put("goodsId", pay_info.name);
			obj.put("goodsCount", pay_info.count);
			obj.put("serverId", Svrid);
			obj.put("test", "false");
			String callbackurl = "";
			showlog("callbackurl: " + callbackurl);

			callbackurl = payurl + escape(obj.toString()) + "&user='h365'";

			showlog("escape callbackurl: " + callbackurl);
			//PaymentData apayData = new PaymentData(pay_info.order_serial, callbackurl, "", aItem, "USD");
			//h365api.pay(apayData, h365token, PayCallback);
			showlog("toH365Pay");
*/
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
	public void onShowProfile(){

	}
    @Override
    public void sdkLogin() {
		if (jsGameSDKManager != null) {

			if (JsGameSDKAppService.isLogin) {
				return;
			}

			jsGameSDKManager.showLogin(home_activity,true,loginlistener);
		}
		else
		{
			showlog("sdkapi is null");
		}
	}

	OnLoginListener loginlistener = new OnLoginListener() {
		@Override
		public void loginSuccess(LogincallBack logincallback) {
			String sign = logincallback.sign;//登入成功返回的签名
			//String Msign = convertMD5(sign);
			double RealNameType = logincallback.RealNameType;//用户实名信息
			long logintime = logincallback.logintime;//登入回调时间戳
			uuid = logincallback.username;//登入的用户名
		}

		@Override
		public void loginError(LoginErrorMsg errorMsg) {
			int code = errorMsg.code;//登入失败错误码
			String msg = errorMsg.msg;//登入失败的消息提示
		}
	};

    public static String convertMD5(String instr){
    	char[] a = instr.toCharArray();
    	for(int i = 0 ; i < a.length ; i++){
    		a[i] = (char) (a[i] ^ 't');
		}
    	String s = new String(a);

    	return s;
	}

	@Override
    public void sdkLogout() {
    	if ((jsGameSDKManager != null)) {

			jsGameSDKManager.recycle(new OnRecycleListener() {
				@Override
				public void recycleSuccess() {
					showlog("logout call sdk");
					uuid = "";
					//jsGameSDKManager.showLogin(home_activity,true,loginlistener);
				}

				@Override
				public void recycleError() {
					showlog("logout call sdk Error");
				}
			});
    	}
		else
		{
			showlog("sdkapi is null");
		}
	}

	@Override
	public void onResume() {
		Handler handler = new Handler();
		handler.postDelayed(new Runnable() {
			@Override
			public void run() {
				if (jsGameSDKManager != null) {
					jsGameSDKManager.showFloatView(onlogoutlistener);
				}
			}
		}, 1000);
	}
}