package com.nuclear.gjwow.platform;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

//import org.apache.http.HttpResponse;
//import org.apache.http.NameValuePair;
//import org.apache.http.client.ClientProtocolException;
//import org.apache.http.client.HttpClient;
//import org.apache.http.client.entity.UrlEncodedFormEntity;
//import org.apache.http.client.methods.HttpPost;
//import org.apache.http.conn.ssl.AllowAllHostnameVerifier;
//import org.apache.http.conn.ssl.SSLSocketFactory;
//import org.apache.http.impl.client.DefaultHttpClient;
//import org.apache.http.message.BasicNameValuePair;
//import org.apache.http.protocol.HTTP;
//import org.apache.http.util.EntityUtils;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.guajibase.gamelib.BuildConfig;
import com.tds.tapdb.sdk.TapDB;

//import com.adjust.sdk.Adjust;
//import com.adjust.sdk.AdjustEvent;
//import com.dosdk.share.FacebookPlugin;
//import com.dosdk.share.FbICallback;
//import com.facebook.CallbackManager;
//import com.google.android.gms.analytics.GoogleAnalytics;
//import com.google.android.gms.plus.Plus;
import com.chance.allsdk.SDKFactory;
import com.nuclear.bean.LoginInfo;
import com.nuclear.gjwow.GameActivity;
//import com.nuclear.gjwow.LastLoginHelp;
import com.nuclear.manager.MessageManager;
import com.nuclear.manager.MessageManager.MessageListener;
import com.nuclear.state.UzipState;
import com.nuclear.util.DeviceUtil;
import com.nuclear.util.IniFileUtil;
import com.nuclear.util.LogUtil;
import com.nuclear.util.URLConst;
//import com.tencent.android.tpush.XGIOperateCallback;
//import com.tigerto.xgpush.XGPushApi;
import com.nuclear.util.WaitView;
//import com.studioirregular.libinappbilling.PurchasedItem;
//import com.studioirregular.libinappbilling.PurchasedItem.PurchaseState;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.DialogInterface;
import android.content.DialogInterface.OnClickListener;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.content.res.AssetFileDescriptor;
import android.graphics.drawable.Drawable;
import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.provider.Settings.Secure;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import android.text.TextUtils;
//import android.util.Base64;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
//import android.widget.EditText;
import android.widget.FrameLayout;
import android.widget.RelativeLayout;
import android.widget.Toast;
import android.widget.VideoView;
import chance.ninja.girl.R;

public class PlatformSDKActivity extends GameActivity {
	private static final String TAG = "PlatformSDKActivity";
	//private static final int RC_SIGN_IN = 0;
	public static final int PURCHASE_ACITIVITY_CODEUEST = 10001;
	//private String Recharge_URL;
	private String filesPath;
	private String base64EncodedPublicKey;
	private VideoView videoView = null;
	private int mVideoCurrPos = 0;
	private int mVideoLoop = 0;
	private boolean mVideoPause = false;
	//public CallbackManager callbackManager;
	public String mUserCode;

	private static final int BILLING_PAY_RESULT_ERR = 1001;
	private static final int BILLING_PAY_ERR = 1002;
	private static final int BILLING_PAY_RESULT_OK = 1000;
	private static final int BILLING_RESPONSE_RESULT_OK = 0;
	private static final int BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED = 7;
	private static final int BILLING_NOT_SUPPORT = 9;
	private static final int BILLING_NOT_Ready = 10;
	private static final int BILLING_RUNTIME_EXCEPTION = 11;
	private static final int BILLING_IAB_EXCEPTION = 12;
	private static final int BILLING_SENDINTENT_EXCEPTION = 13;
	//protected FacebookPlugin mFBPlugin = null;
	protected WaitView 	mWaitView = null;
	//protected String	mGpUid = "";//账户中心返回的当前puid 已经绑定的 gpid
	protected boolean	mIsEnterGame = false;
	protected boolean	mIsNeedShowWaitView = false;//支付时的菊花分两段显示控制  从点点击商品->购买成功（onresume）购买成功->物品到账
	Timer mTimer = null;
	TimerTask mTimetask = null;
//	protected String mTrackingId = "UA-1";
	/*mIsEnterGame
	 *  账户中心返回的当前puid 已经绑定的 gpid
		是否已进入游戏  进入游戏之前的google登录：视为 账号登录
		进入游戏之后的google登录：视为账号绑定
	 */
	protected boolean	mWasBindGP = false;//是否已经绑定 google paly or game center
	protected String	mCurDeviceId = null;
//	private String security= "3d1b05aee18b9870a52b733ccedc11bf";

    protected List<String> mPermissionList = new ArrayList();
    protected String[] permissions = { "android.permission.WRITE_EXTERNAL_STORAGE", "android.permission.READ_EXTERNAL_STORAGE" };
    protected boolean mNeedCallLogin = false;
	private MessageListener listener = new MessageListener() {

		@Override
		public void unregisterMsg() {
			MessageManager.getInstance().removeMsgHandler("facebookShare");
			MessageManager.getInstance().removeMsgHandler("G2P_ENTER_MAINSCENE_PAGE");
			MessageManager.getInstance().removeMsgHandler("G2P_ENTER_RECHARGE_PAGE");
			MessageManager.getInstance().removeMsgHandler("G2P_SEND_EMAIL");
			MessageManager.getInstance().removeMsgHandler("G2P_FACEBOOK_SHARE");
			MessageManager.getInstance().removeMsgHandler("G2P_BIND_GC_GP");
			MessageManager.getInstance().removeMsgHandler("G2P_GET_BIND_STATE");
			MessageManager.getInstance().removeMsgHandler("G2P_SHOW_NOTIFICATION");
			MessageManager.getInstance().removeMsgHandler("G2P_CLEAN_NOTIFICATION_LOOP");
			MessageManager.getInstance().removeMsgHandler("G2P_RECORDING_ADJUST_EVENT");
			MessageManager.getInstance().removeMsgHandler("G2P_CLEAN_NOTIFICATION_ONCE");
			MessageManager.getInstance().removeMsgHandler("G2P_SHOW_WAITVIEW");
			MessageManager.getInstance().removeMsgHandler("G2P_SET_ADJUST_CROPRO");
			MessageManager.getInstance().removeMsgHandler("G2P_RECORDING_ADJUST_EVENT_FIRST_RECHARGE");
			MessageManager.getInstance().removeMsgHandler("G2P_GET_VERSION_TAG");
			MessageManager.getInstance().removeMsgHandler("G2P_CHANGE_PWD");
			MessageManager.getInstance().removeMsgHandler("G2P_DATA_TRANSFER");
			MessageManager.getInstance().removeMsgHandler("G2P_SHOW_TOAST");
			MessageManager.getInstance().removeMsgHandler("G2P_GET_PUSH_STATE");
			MessageManager.getInstance().removeMsgHandler("G2P_REPORT_HANDLER");
			MessageManager.getInstance().removeMsgHandler("G2P_TAPDB_HANDLER");
		}

		@Override
		public void registerMsg() {
			MessageManager.getInstance().setMsgHandler("facebookShare", listener);
			MessageManager.getInstance().setMsgHandler("G2P_ENTER_MAINSCENE_PAGE", listener);
			MessageManager.getInstance().setMsgHandler("G2P_ENTER_RECHARGE_PAGE", listener);
			MessageManager.getInstance().setMsgHandler("G2P_SEND_EMAIL", listener);
			MessageManager.getInstance().setMsgHandler("G2P_FACEBOOK_SHARE", listener);
			MessageManager.getInstance().setMsgHandler("G2P_BIND_GC_GP",listener);
			MessageManager.getInstance().setMsgHandler("G2P_GET_BIND_STATE",listener);
			MessageManager.getInstance().setMsgHandler("G2P_SHOW_NOTIFICATION",listener);
			MessageManager.getInstance().setMsgHandler("G2P_CLEAN_NOTIFICATION_LOOP",listener);
			MessageManager.getInstance().setMsgHandler("G2P_CLEAN_NOTIFICATION_ONCE",listener);
			MessageManager.getInstance().setMsgHandler("G2P_SHOW_WAITVIEW",listener);
			MessageManager.getInstance().setMsgHandler("G2P_RECORDING_ADJUST_EVENT",listener);
			MessageManager.getInstance().setMsgHandler("G2P_RECORDING_ADJUST_EVENT_FIRST_RECHARGE",listener);
			MessageManager.getInstance().setMsgHandler("G2P_SET_ADJUST_CROPRO", listener);
			MessageManager.getInstance().setMsgHandler("G2P_GET_VERSION_TAG", listener);
			MessageManager.getInstance().setMsgHandler("G2P_CHANGE_PWD",listener);
			MessageManager.getInstance().setMsgHandler("G2P_DATA_TRANSFER",listener);
			MessageManager.getInstance().setMsgHandler("G2P_SHOW_TOAST",listener);
			MessageManager.getInstance().setMsgHandler("G2P_GET_PUSH_STATE",listener);
			MessageManager.getInstance().setMsgHandler("G2P_REPORT_HANDLER", listener);
			MessageManager.getInstance().setMsgHandler("G2P_TAPDB_HANDLER", listener);
		}

		public String G2P_TAPDB_HANDLER(String msg)
		{
			JSONObject msgJsonObj;
			try {
				msgJsonObj = new JSONObject(msg);
				String funStr = msgJsonObj.getString("funtion");
				if (funStr.equals("setUser")){
					String useId = msgJsonObj.getString("param");
					if (msgJsonObj.has("properties")){
						String jsonStr = msgJsonObj.getString("properties");
						JSONObject properties = new JSONObject(jsonStr);
						TapDB.setUser(useId,properties);
					} else {
						TapDB.setUser(useId);
					}
				}
				if (funStr.equals("setName")){
					String name = msgJsonObj.getString("param");
					TapDB.setName(name);
				}
				if (funStr.equals("setServer")){
					String server = msgJsonObj.getString("param");
					TapDB.setServer(server);
				}
				if (funStr.equals("setLevel")){
					int level = msgJsonObj.getInt("param");
					TapDB.setLevel(level);
				}

				if (funStr.equals("trackEvent")){
					String  eventName = msgJsonObj.getString("param");
					String jsonStr = msgJsonObj.getString("properties");
					JSONObject properties = new JSONObject(jsonStr);
					TapDB.trackEvent(eventName,properties);
				}

				if (funStr.equals("deviceUpdate")){
					String  jsonStr = msgJsonObj.getString("param");
					JSONObject properties = new JSONObject(jsonStr);
					TapDB.deviceUpdate(properties);
				}

				if (funStr.equals("deviceInitialize")){
					String  jsonStr = msgJsonObj.getString("param");
					JSONObject properties = new JSONObject(jsonStr);
					TapDB.deviceInitialize(properties);
				}

				if (funStr.equals("deviceAdd")){
					String  jsonStr = msgJsonObj.getString("param");
					JSONObject properties = new JSONObject(jsonStr);
					TapDB.deviceAdd(properties);
				}

				if (funStr.equals("userUpdate")){
					String  jsonStr = msgJsonObj.getString("param");
					JSONObject properties = new JSONObject(jsonStr);
					TapDB.userUpdate(properties);
				}

				if (funStr.equals("userInitialize")){
					String  jsonStr = msgJsonObj.getString("param");
					JSONObject properties = new JSONObject(jsonStr);
					TapDB.userInitialize(properties);
				}

				if (funStr.equals("userAdd")){
					String  jsonStr = msgJsonObj.getString("param");
					JSONObject properties = new JSONObject(jsonStr);
					TapDB.userAdd(properties);
				}

			} catch (JSONException e) {
				e.printStackTrace();
			}
			return null;
		}

		public String G2P_REPORT_HANDLER(String msg)
		{
			SDKFactory.getInstance().getSDKHandler().Report_Handler(msg);
			return null;
		}

		public String G2P_ENTER_MAINSCENE_PAGE(String msg)
		{
			//SendGpAnalytics("Event","Action",msg);
			return null;
		}
		public String G2P_ENTER_RECHARGE_PAGE(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
			//SendGpAnalytics("Event","Action",msg);
			return null;
		}
		public String G2P_SEND_EMAIL(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
			JSONObject msgJsonObj;
			try {
				msgJsonObj = new JSONObject(msg);
				SendEmail(
						msgJsonObj.getString("serverid"),
						msgJsonObj.getString("playerid"),
						msgJsonObj.getString("time"),
						msgJsonObj.getString("version"),
						msgJsonObj.getString("url"));

			} catch (JSONException e) {
				e.printStackTrace();
			}
			return null;
		}
		public String G2P_FACEBOOK_SHARE(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
			JSONObject msgJsonObj;
			try {
				msgJsonObj = new JSONObject(msg);
				OnFaceBookShare(
						msgJsonObj.getString("picture"),
						msgJsonObj.getString("caption"));

			} catch (JSONException e) {
				e.printStackTrace();
			}
			return null;
		}
		public String G2P_BIND_GC_GP(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")

			//BindGooglePlus();
			return null;
		}
		public String G2P_GET_BIND_STATE(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
			Cocos2dxHelper.nativeSendMessageP2G("P2G_GET_BIND_STATE", ""+mWasBindGP);
			return null;
		}
		public String G2P_SHOW_NOTIFICATION(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
			//System.out.println("*********______msg"+msg);
			JSONObject msgJsonObj;
			try {
				msgJsonObj = new JSONObject(msg);
				if (msgJsonObj.has("title")){
					if(msgJsonObj.getBoolean("dayloop"))
					{
						sendBroadcastAtTimeRepeat(msgJsonObj.getString("gamemsg"),msgJsonObj.getString("title"),
							msgJsonObj.getInt("timeleft"),msgJsonObj.getString("action"));
					}
					else//离线24h
					{
						sendBroadcastAtTime(msgJsonObj.getString("gamemsg"),msgJsonObj.getString("title"),
							msgJsonObj.getInt("timeleft"));
					}
				}
				//LogUtil.LOGE("PlatformSDKActivity", "G2P_SHOW_NOTIFICATION= :" + msg);

			} catch (JSONException e) {
				e.printStackTrace();
			}
			return null;
		}
		public String G2P_CLEAN_NOTIFICATION_ONCE(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
//			LogUtil.LOGE("PlatformSDKActivity", "G2P_CLEAN_NOTIFICATION_ONCE= :" + msg);
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER");
			return null;
		}
		public String G2P_SHOW_WAITVIEW(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
			JSONObject msgJsonObj;
			try {
				msgJsonObj = new JSONObject(msg);
				if (msgJsonObj.has("show")){//
					boolean visible = msgJsonObj.getBoolean("show");
					showView(visible);
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
			return null;
		}

		public String G2P_CLEAN_NOTIFICATION_LOOP(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
//			LogUtil.LOGE("PlatformSDKActivity", "G2P_CLEAN_NOTIFICATION_LOOP= :" + msg);
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER8");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER20");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_01");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_02");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_03");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_04");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_05");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_06");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_07");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_08");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_09");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_10");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_11");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_12");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_13");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_14");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_15");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_16");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_17");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_18");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_19");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_20");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_21");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_22");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_23");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_24");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_25");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_26");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_27");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_28");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_29");
			CleanBroadcastAtTimeRepeat("android.intent.action.MY_ALERT_RECEIVER_30");
			return null;
		}
		public String G2P_RECORDING_ADJUST_EVENT(String msg)
		{
			return null;
		}
		public String G2P_SET_ADJUST_CROPRO(String msg)
		{
			return null;
		}
		public String G2P_GET_VERSION_TAG(String msg)
		{
			Cocos2dxHelper.nativeSendMessageP2G("P2G_GET_VERSION_TAG", "true");
			return null;
		}
		public String G2P_RECORDING_ADJUST_EVENT_FIRST_RECHARGE(String msg)
		{
			return null;
		}
		public String G2P_CHANGE_PWD(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")

			JSONObject msgJsonObj;
			try {
				msgJsonObj = new JSONObject(msg);
				if (msgJsonObj.has("pwd")){//
					String pwd = msgJsonObj.getString("pwd");
					DataTransferChangePwd(pwd);
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
			return null;
		}
		public String G2P_DATA_TRANSFER(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")

			JSONObject msgJsonObj;
			try {
				msgJsonObj = new JSONObject(msg);
				if (msgJsonObj.has("code") && msgJsonObj.has("pwd")){//
					String code = msgJsonObj.getString("code");
					String pwd = msgJsonObj.getString("pwd");
					moveAccountEnter(code, pwd);
				}
			} catch (JSONException e) {
				e.printStackTrace();
			}
			return null;
		}
		public String G2P_SHOW_TOAST(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")
			showToast(msg);
			return null;
		}

		public String G2P_GET_PUSH_STATE(String msg)
		{//libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_RECHARGE_PAGE","G2P_Invild_Friend")

			//Cocos2dxHelper.nativeSendMessageP2G("P2G_GET_PUSH_STATE", XGPushApi.msReceiverPushMsg);
			//XGPushApi.msReceiverPushMsg = "";
			return null;
		}
	};

	Handler handler = new Handler() {
		@SuppressLint({"NewApi", "HandlerLeak"})
		public void handleMessage(android.os.Message msg) {
			switch (msg.what) {
			case BILLING_PAY_ERR:
//				SharedPreferences sharePre = getSharedPreferences("recharge", 0);
//				Editor editor = sharePre.edit();
//
//				editor.putString("inapp_purchase_data", purchase.mOriginalJson);
//				editor.putString("inapp_data_signature",purchase.mSignature);
//				editor.putBoolean("result", false);
//				editor.apply();
//				editor.commit();
//
//				Toast.makeText(PlatformSDKActivity.this,
//						getResources().getString(R.string.paygoodserr),
//						Toast.LENGTH_SHORT).show();
				break;
			case BILLING_RESPONSE_RESULT_OK:
				Toast.makeText(PlatformSDKActivity.this,
						getResources().getString(R.string.payok),
						Toast.LENGTH_SHORT).show();
				break;
			case BILLING_PAY_RESULT_OK:

				Toast.makeText(PlatformSDKActivity.this,
						getResources().getString(R.string.paygoodsok),
						Toast.LENGTH_SHORT).show();
				break;
			case BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED:
				Toast.makeText(PlatformSDKActivity.this,
						getResources().getString(R.string.payok),
						Toast.LENGTH_SHORT).show();
				break;
			case BILLING_PAY_RESULT_ERR:
				Toast.makeText(PlatformSDKActivity.this,
						getResources().getString(R.string.paygoodserr),
						Toast.LENGTH_SHORT).show();
				break;
			case BILLING_NOT_SUPPORT:
				Toast.makeText(PlatformSDKActivity.this,
						getResources().getString(R.string.paynotsuport),
						Toast.LENGTH_SHORT).show();
				break;
			case BILLING_NOT_Ready:
			case BILLING_RUNTIME_EXCEPTION:
			case BILLING_IAB_EXCEPTION:
			case BILLING_SENDINTENT_EXCEPTION:
				Toast.makeText(PlatformSDKActivity.this,
						getResources().getString(R.string.payggerr),
						Toast.LENGTH_SHORT).show();
				break;
			default:
				break;
			}
		}

	};

	private static void copy(InputStream is, OutputStream out) throws IOException{
        byte[] buffer = new byte[1024];
        int n = 0;
        while(-1 != (n = is.read(buffer))){
            out.write(buffer,0,n);
        }
    }

	/*
	 *
	 * */
	public PlatformSDKActivity() {
	}

	@Override
	public void init() {

		UzipState.allowStorage = isStoragePermissionGranted(10001);
		LogUtil.LOGE("googlelogin","platformSdk init");


		//filesPath = Environment.getExternalStorageDirectory().getAbsolutePath()
		//		+ "/Android/data/" + getPackageName() + "/files/assets";
		//Log.d(TAG,"Environment " + filesPath);
		filesPath = getContext().getFilesDir().getAbsolutePath() + "/assets";
				//+ "/Android/data/" + getPackageName() + "/files/assets";

		Log.d(TAG,"Context " + filesPath);
		UzipState.newPath = getContext().getFilesDir().getAbsolutePath();


		try {
			base64EncodedPublicKey = getPackageManager().getApplicationInfo(
					getPackageName(), PackageManager.GET_META_DATA).metaData
					.getString("publickey");
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		LogUtil.LOGE("googlelogin","base64EncodedPublicKey" + base64EncodedPublicKey);

		listener.registerMsg();

	    mWaitView = new WaitView(PlatformSDKActivity.this);
	}
	  public boolean isStoragePermissionGranted(int paramInt)
	  {
	    if (Build.VERSION.SDK_INT >= 23)
	    {
	      this.mPermissionList.clear();
	      int i = 0;
	      while (i < this.permissions.length)
	      {
	        if (ContextCompat.checkSelfPermission(this, this.permissions[i]) != 0)
	          this.mPermissionList.add(this.permissions[i]);
	        i += 1;
	      }
	      if (this.mPermissionList.isEmpty())
	        return true;
	      ActivityCompat.requestPermissions(this, (String[])this.mPermissionList.toArray(new String[this.mPermissionList.size()]), paramInt);
	      return false;
	    }
	    Log.v(TAG, "WRITE_EXTERNAL_STORAGE Permission is granted");
	    return true;
	  }


	  public void onRequestPermissionsResult(int paramInt, String[] paramArrayOfString, int[] paramArrayOfInt)
	  {
		  switch (paramInt) {
          case 10001:
              if (paramArrayOfInt[0] == PackageManager.PERMISSION_GRANTED && paramArrayOfInt[1] ==PackageManager.PERMISSION_GRANTED) {
                  // Permission Granted 授予权限
                //处理授权之后逻辑
            	  UzipState.allowStorage = true;
              } else {
                  // Permission Denied 权限被拒绝
            	  finish();
            	  android.os.Process.myPid();
              }

              break;
          default:
              break;
      }

	 }

	  private void goIntentSetting()
	  {
	    Intent localIntent = new Intent();
	    localIntent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
	    //localIntent.setFlags(268435456);
	    localIntent.setData(Uri.parse("package:" + getContext().getPackageName()));
	    startActivity(localIntent);
	  }

	public void doLogin(String mUid) {
		if (mUid == null||mUid.equals("") || mUid.equals("-1") || mUid.equals("-2")) {
			new AlertDialog.Builder(this)
					.setMessage(
							"Oops, a parameter error occured. Please try again.")
					.setPositiveButton("Retry", new OnClickListener() {

						@Override
						public void onClick(DialogInterface arg0, int arg1) {
							callLogin();
						}
					}).setCancelable(false).show();
			return;
		}
		LogUtil.LOGE("zzz", mUid);
		getSharedPreferences("config", Context.MODE_PRIVATE).edit()
				.putString("lastUid", mUid).commit();
		final LoginInfo login_info = new LoginInfo();
		login_info.account_nick_name = mUid+"";
		login_info.account_uid_str = mUid;
		login_info.login_session = mUserCode;
		login_info.login_result = 0;

		notifyLoginResut(login_info);

		// add by DuanGuangxiang
		// 注册信鸽推送并且 绑定
		String puid = getPrefixion() + mUid;
		// the end
		mIsEnterGame = true;
	}

	public static String GetMd5(String string) {
	    byte[] hash;
	    try {
	        hash = MessageDigest.getInstance("MD5").digest(string.getBytes("UTF-8"));
	    } catch (NoSuchAlgorithmException e) {
	        throw new RuntimeException("Huh, MD5 should be supported?", e);
	    } catch (UnsupportedEncodingException e) {
	        throw new RuntimeException("Huh, UTF-8 should be supported?", e);
	    }

	    StringBuilder hex = new StringBuilder(hash.length * 2);
	    for (byte b : hash) {
	        if ((b & 0xFF) < 0x10) hex.append("0");
	        hex.append(Integer.toHexString(b & 0xFF));
	    }
	    return hex.toString();
	}
	public void callUserSeverLogin(){

		String tempgpid = "";
		//tempgpid = getProfileIDInformation(mGoogleApiClient);//屏蔽google登录
		LogUtil.LOGE("googleLogin", "call mWaitView= : show");
		showView(true);
		LogUtil.LOGE("googleLogin", "gpid1= :"+tempgpid);
		UidBindMange.getInstance().QueryUid(mCurDeviceId,tempgpid,new BindCallBack<String>() {
			@Override
			public void onSuccess(String success) {
				LogUtil.LOGE(TAG, "call mWaitView= : remove");
				showView(false);
				JSONObject msgJsonObj;
				String callResult[] = success.split("\\|");
				String result = callResult[0];
				/*
				 * 成功标识|原因|是否为新账号|gcid|gpid，
				 * 成功标识：1成功0为失败
				 * 原因：0为没有原因，一般代表成功，1代表puid不合法；
				 * 是否为新账号1是，0非；
				 * gcid（可以为空字符串，代表没有绑定过）；
				 * gpid（可以为空字符串，代表没有绑定过）
				 */
				LogUtil.LOGE(TAG, "QueryUid onSuccess= :"+success);
				LogUtil.LOGE(TAG, "callResult :"+ callResult.toString());
				LogUtil.LOGE(TAG, "callResult :"+ callResult.length);


				if(callResult.length>=6)
				{

					if(result.equals("1")){

						String tmpmUserCode    =  mUserCode;
						mUserCode = callResult[5];
						if(tmpmUserCode.equals(mUserCode))//相同代表没有移行过账号
						{
							Cocos2dxHelper.nativeSendMessageP2G("P2G_DATATRANSFER_SHOW", "0");//是否移行过
						}else
						{
							Cocos2dxHelper.nativeSendMessageP2G("P2G_DATATRANSFER_SHOW", "1");//是否移行过
						}
						mWasBindGP = !callResult[4].equals("");
						LogUtil.LOGE(TAG, "QueryUid mUserCode= :"+mUserCode);
						LogUtil.LOGE(TAG, "QueryUid mWasBindGP= :"+mWasBindGP);

						//DeviceUtil.SetDeviceID(mUserCode);
						doLogin(mUserCode);
					}
					else
					{
						Toast.makeText(PlatformSDKActivity.this, "puid is null", Toast.LENGTH_LONG).show();
					}
				}else
				{
					mUserCode = DeviceUtil.getAccountId();
					//Toast.makeText(PlatformSDKActivity.this, getResources().getString(R.string.login_failed), Toast.LENGTH_LONG).show();
				}
			}

			@Override
			public void onError(String error) {
				String tmpmUserCode = mUserCode;
				mUserCode = DeviceUtil.getAccountId();
				if(mUserCode.equals(""))
				{
					mUserCode = tmpmUserCode;
				}
				LogUtil.LOGE(TAG, "QueryUid  failed :" + mUserCode);
				doLogin(mUserCode);
				//Toast.makeText(PlatformSDKActivity.this, getResources().getString(R.string.login_timeout), Toast.LENGTH_LONG).show();
				LogUtil.LOGE(TAG, "call mWaitView= : remove");
				showView(false);
			}
		});
	}
	@Override
	public void callPlayMovie(String fileName, int isLoop, int autoScale) {
		FrameLayout videoMask = (FrameLayout)findViewById(R.id.videoMask);
		videoMask.setVisibility(View.VISIBLE);
		videoView = (VideoView)findViewById(R.id.videovideo);
		videoView.setVisibility(View.VISIBLE);
		String fullVideoPath = filesPath + "/Video/" + fileName + ".mp4";
		String fullHotUpdateVideoPath = getContext().getFilesDir().getAbsolutePath() + "/hotUpdate/Video/" + fileName + ".mp4";
		File file1 = new File(fullVideoPath);
		File file2 = new File(fullHotUpdateVideoPath);
		//if (fileName.contains("op")){
		//	int rawId = getResources().getIdentifier(fileName,  "raw", getPackageName());
		//	videoView.setVideoPath("android.resource://" + getPackageName() + "/" + rawId);
		//}
		//else {
			if (file2.exists())
				videoView.setVideoPath(fullHotUpdateVideoPath);
			else if (file1.exists())
				videoView.setVideoPath(fullVideoPath);
			else {
				videoView.setOnTouchListener(null);
				videoView = null;
				return;
			}
		//}
		mVideoLoop = isLoop;
//
		videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
			@Override
			public void onPrepared(MediaPlayer mp) {
				int videoWidth = mp.getVideoWidth();
				int videoHeight = mp.getVideoHeight();
				RelativeLayout layout = findViewById(R.id.GameApp_LogoRelativeLayout);
				int height = layout.getMeasuredHeight();
				int width = layout.getMeasuredWidth();
				float videoRatio = (float)videoHeight / videoWidth;
				float layoutRatio = (float)height / width;
				float scale = 1.0f;
				if (videoRatio > layoutRatio) {	// 影片比例比裝置長 -> 放大填滿寬度
					if (videoRatio <= 1.78f) {	// 1280*720
						scale = 1.0f;
					}
					else if (videoHeight >= 2.22f) {	//1600*720
						scale = (float)height / 1280;
					}
					else {
						scale = (float)height / 1280;
					}
				}
				if (layoutRatio > videoRatio) {	// 裝置比例比影片長 -> 檢查是否要自適應
					if (autoScale == 1) {	// 需要自適應 -> 放大填滿高度
						scale = layoutRatio / videoRatio;
					}
				}
				videoView.setScaleX(scale);
				videoView.setScaleY(scale);
				Log.d(TAG, "Video scale: " + scale);
				Log.d(TAG, "Video width: " + videoWidth + ", height: " + videoHeight);
				Log.d(TAG, "Layout width: " + width + ", height: " + height);
				videoView.seekTo(0);
				videoView.start();
			}
		});

		videoView.setOnInfoListener(new MediaPlayer.OnInfoListener() {
			@Override
			public boolean onInfo(MediaPlayer mp, int what, int extra) {
				if (what == MediaPlayer.MEDIA_INFO_VIDEO_RENDERING_START) {
					Log.d(TAG, "Video rendering started – hide mask now");
					FrameLayout videoMask = (FrameLayout) findViewById(R.id.videoMask);
					videoMask.setVisibility(View.GONE);
					return true;
				}
				return false;
			}
		});

        videoView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
        	 @Override
        	 public void onCompletion(MediaPlayer mp) {
        		 LogUtil.LOGE(TAG,"VideoView Notice: onCompletion");
        		 if (videoView != null)
        		 {
					 if (mVideoLoop == 1) {
						 Cocos2dxHelper.nativeSendMessageP2G("onPlayMovieLoop", "");
						 videoView.seekTo(0);
						 videoView.start();
					 }
					 else {
						 Cocos2dxHelper.nativeSendMessageP2G("onPlayMovieEnd", "");
						 videoView.stopPlayback();
						 videoView.setOnTouchListener(null);
					 }
        		 }

        	 }
        });

        videoView.setOnErrorListener(new MediaPlayer.OnErrorListener() {
        	@Override
        	public boolean onError(MediaPlayer mp, int what, int extra){
				LogUtil.LOGE(TAG,"VideoView Notice: onError");
				if (videoView != null)
				{
					videoView.setOnTouchListener(null);
				}
				mVideoLoop = 0;
        		return true;
        	}
        });
	}

	public void callCloseMovie() {
		LogUtil.LOGE(TAG,"VideoView Notice: callClose");
		if (videoView != null)
		{
			videoView.suspend();
			Cocos2dxHelper.nativeSendMessageP2G("onPlayMovieEnd","");
			videoView.setOnTouchListener(null);
		}
		mVideoLoop = 0;
	}

	public void callPauseMovie() {
		if (videoView != null) {
			videoView.pause();
			mVideoCurrPos = videoView.getCurrentPosition();
			mVideoPause = true;
		}
	}

	public void callResumeMovie() {
		if (videoView != null/* && mVideoPause*/) {
			videoView.seekTo(mVideoCurrPos);
			videoView.start();
			mVideoPause = false;
		}
	}
	
	@Override
	public void callLogin() {

		SDKFactory.getInstance().getSDKHandler().sdkLogin();

		if (!UzipState.allowStorage) {
			this.mNeedCallLogin = true;
			return;
		}

		
	}

	
	@SuppressLint("NewApi") @Override
	public void onLoginGame() {

	}

	@Override
	public void callLogout() {
		mIsEnterGame = false;

		SDKFactory.getInstance().getSDKHandler().sdkLogout();
	}

	@Override
	public void callAccountManage() {
		
	}

	@Override
	public String sendMessageP2G(String tag, String msg) {
		return null;
	}

	@Override
	public String getClientChannel() {
		switch (getPlatformName()){
			case H365:
				Log.d(TAG,"ClientChannel is android_h365");
				return "android_h365";
			case EROR18:
				Log.d(TAG,"ClientChannel is android_r18");
				return "android_r18";
			case JSG:
				Log.d(TAG,"ClientChannel is android_jsg");
				return "android_jsg";
			case LSJ:
				Log.d(TAG,"ClientChannel is android_lsj");
				return "android_lsj";
			case MURA:
				Log.d(TAG,"ClientChannel is android_mura");
				return "android_mura";
			case KUSO:
				Log.d(TAG,"ClientChannel is android_kuso");
				return "android_kuso";
			case EROLABS:
				Log.d(TAG,"ClientChannel is android_erolabs");
				return "android_erolabs";
			case APLUS:
				Log.d(TAG,"ClientChannel is android_aplus");
				return "android_aplus";
			case OP:
				Log.d(TAG,"ClientChannel is android_op");
				return "android_op";
			default:
				Log.d(TAG,"ClientChannel is NULL");
				return "android_h365";
		}
	}

	public String getClientCps() {
		return "#" + getCpsName().getValue();
	}

	public String getBuildType() {
		return BuildConfig.BUILD_TYPE;
	}
		
	@Override
	public void callFeedback() {
		
	}

	@Override
	public Drawable getSplashDrawable() {
		return getResources().getDrawable(R.drawable.splash);
	}
	@Override
	public Drawable getLogoDrawable() {
		return getResources().getDrawable(R.drawable.logo);
	}
	@Override
	public Drawable getLogo69Drawable() {
		return getResources().getDrawable(R.drawable.logo69);
	}
	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if (requestCode == PURCHASE_ACITIVITY_CODEUEST) {
			LogUtil.LOGE(TAG, "" + resultCode);
			if (resultCode == Activity.RESULT_OK) {
				try {

				} catch (RuntimeException e) {
					e.printStackTrace();
				} catch (Exception e) {
					e.printStackTrace();
				}

			} else if (resultCode == Activity.RESULT_CANCELED) {
				LogUtil.LOGW("facebook", "onActivityResult: user canceled purchasing.");
				// Toast.makeText(context, "支付取消", Toast.LENGTH_LONG).show();
			}

		} else {
		}
		//callbackManager.onActivityResult(requestCode, resultCode, data);
		LogUtil.LOGW("facebook", "onActivityResult: platfromsdkactivity");
		//mFBPlugin.onActivityResult(requestCode, resultCode, data);
	}

	
	private void WriteRechargeData(final String mSignature,final String mOriginalJson, final Bundle _bundle) {
		SharedPreferences sharePre = getSharedPreferences(getClientChannel()
				+ "_recharge", 0);
		try {
			String failedList = sharePre.getString("failedList", "[]");
			JSONArray failedArr = new JSONArray(failedList);
			JSONObject msg = new JSONObject();
			msg.put("googleSignature", mSignature);
			msg.put("googleOriginalJson", mOriginalJson);
			msg.put("uid", _bundle.getString("uid"));
			msg.put("sid", _bundle.getString("sid"));
			msg.put("amount", _bundle.getString("amount"));
			
			failedArr.put(msg);

			Editor editor = sharePre.edit();
			editor.putString("failedList", failedArr.toString());
			editor.apply();
			editor.commit();
		} catch (JSONException e) {
			e.printStackTrace();
		} 
	}
	
	@Override
	protected void onPause() {
		callPauseMovie();
		super.onPause();
		//Adjust.onPause();
		
		//LogUtil.LOGD("TalkingData", "onPause");
		//TalkingDataInit.onPause(this);
	}

	@Override
	protected void onResume() {

		showView(false);
		if(mIsNeedShowWaitView)
		{
			mIsNeedShowWaitView = false;
			showView(true);
			TimerTick();//如果未到账 通过此定时器控制关闭
		}
		callResumeMovie();
		super.onResume();
		//Adjust.onResume();
		
		//LogUtil.LOGD("TalkingData", "onResume");
		//TalkingDataInit.onResume(this);
	}
	
	@Override
	protected void onStart() {

		super.onStart();
		hideBottomUIMenu();
		//GoogleAnalytics.getInstance(PlatformSDKActivity.this).reportActivityStart(this);
		//XGPushApi.getInstance().start();
		
		LogUtil.LOGD("XGPushApi", "start");
		
		//LogUtil.LOGD("TalkingData", "onCreate");
		//TalkingDataInit.Init(PlatformSDKActivity.this, "23A150610FCF4FC887D4207BD0411CC5", "CHANNEL_ID");
	}
	@Override
	public void onWindowFocusChanged(boolean hasFocus) {
	    super.onWindowFocusChanged(hasFocus);
	    //根据焦点隐藏状态栏，标题栏
	  if (hasFocus) {

		  hideBottomUIMenu();

	  }
	  
	
	}
	
	protected void hideBottomUIMenu() {
		 Window window;
		    window = getWindow();
		    WindowManager.LayoutParams params = window.getAttributes();
		    params.systemUiVisibility = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION | View.SYSTEM_UI_FLAG_IMMERSIVE|View.SYSTEM_UI_FLAG_FULLSCREEN;
		    window.setAttributes(params);


		    int uiFlags = View.SYSTEM_UI_FLAG_LAYOUT_STABLE
		            | View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
		            | View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
		            | View.SYSTEM_UI_FLAG_HIDE_NAVIGATION // hide nav bar
		            | View.SYSTEM_UI_FLAG_FULLSCREEN; // hide status bar

		    if (android.os.Build.VERSION.SDK_INT >= 19) {
		        uiFlags |= 0x00001000;    //SYSTEM_UI_FLAG_IMMERSIVE_STICKY: hide navigation bars - compatibility: building API level is lower thatn 19, use magic number directly for higher API target level
		    } else {
		        uiFlags |= View.SYSTEM_UI_FLAG_LOW_PROFILE;
		    }

		    getWindow().getDecorView().setSystemUiVisibility(uiFlags);


		}
	
	protected void onStop() {

		super.onStop();
		//GoogleAnalytics.getInstance(PlatformSDKActivity.this).reportActivityStop(this);
		//XGPushApi.getInstance().stop();
		LogUtil.LOGD("XGPushApi", "stop");
		
		
	}
	@Override
	protected void onDestroy() {
		super.onDestroy();
	}
	
	@Override
	public String getPrefixion(){
		return "sg_";
	}
	public void OnFaceBookShare(final String picture, final String caption) {
		
		String path = Environment.getExternalStorageDirectory().getAbsolutePath()
				+ "/Android/data/" + getPackageName() + "/files/Cache/144.png";
	}
	@SuppressWarnings("deprecation")
	public void SendEmail(String serverid,String playerid,String time,String version, String url)
	{
		LogUtil.LOGW("SendEmail", "SendEmail = "+version);
		String TargetMail = "mailto:" + url;
		String Title = "性奴调教疑惑咨询";
		String Content = "";
		String lineSeparator = System.getProperty("line.separator", "\n");
		Content = lineSeparator + lineSeparator + lineSeparator + lineSeparator;
		Content = "※请不要删除下列内容" + lineSeparator;
		Content = Content + "伺服器ID:" + serverid + lineSeparator;
		Content = Content + "用户ID:" + playerid + lineSeparator;
		Content = Content + "最后上线时间:" + time + lineSeparator;
		Content = Content + "版本号:" + version + lineSeparator;
		Content = Content + "用户装置:" + lineSeparator;
		Content = Content + ("Product Model:" + android.os.Build.MODEL + ","
                + android.os.Build.VERSION.SDK + ","
                + android.os.Build.VERSION.RELEASE);
		try{
		// you email code here
			Intent it=new Intent(Intent.ACTION_SEND);
			//it.setData(Uri.parse(TargetMail));
			String[] tos={url};
			//String[] ccs={"you@abc.com"};
			it.putExtra(Intent.EXTRA_EMAIL, tos);
			//it.putExtra(Intent.EXTRA_CC, ccs);
			it.putExtra(Intent.EXTRA_TEXT, Content);
			it.putExtra(Intent.EXTRA_SUBJECT, Title);
			it.setType("message/rfc822");
			startActivity(Intent.createChooser(it, "Choose Email Client"));
		} catch (ActivityNotFoundException e) {
		// show message to user
			 Toast.makeText(PlatformSDKActivity.this, "There is no email client installed.", Toast.LENGTH_SHORT).show();
		}
	}
	public static void FBCallBackToLua(String state)
	{
		JSONObject item = new JSONObject();
		try {
			item.put("ret", "");
			item.put("state", state);
			
		} catch (JSONException e) {
			e.printStackTrace();
		}
		Cocos2dxHelper.nativeSendMessageP2G("P2G_FACEBOOK_SHARE", item.toString());
	}
	
	public static String getDeviceInfo(Context context) {
		return "android";
		
	}
	public static String getDeviceId(Context context) {
		//注释掉需要READ_PHONE_STATE权限才能获取的Deviceid方法
//		TelephonyManager telephonyManager = (TelephonyManager) context
//				.getSystemService(Context.TELEPHONY_SERVICE);
//		String imei = telephonyManager.getDeviceId();
//		if (!TextUtils.isEmpty(imei)) {//获取imei失败
//			return imei;
//		} 
//		else{
		
		String androidId = Secure.getString(context.getContentResolver(),Secure.ANDROID_ID);
		if(androidId.equals("9774d56d682e549c")){
			return getUUIDFromCfgFile();
		}
		else{
			
			return androidId;
		}
		//}
	}
	public static String getUUIDFromCfgFile() {
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + File.separator + "tigerto" + File.separator + "SchoolUserData.properties");
		Properties cfgIni = new Properties();
		
		LogUtil.LOGE("googleLogin", "-getUUIDFromCfgFile---step1----" + uFile.getAbsolutePath());
		
		
		if(uFile.exists()){
			try {  
				cfgIni.load(new FileInputStream(uFile));
				String uuid = cfgIni.getProperty("uuid", null);
				
				LogUtil.LOGE("googleLogin", "-getUUIDFromCfgFile---step2----" + uuid);
				
				if(uuid == null)
				{
					uuid = UUID.randomUUID().toString();
					if (TextUtils.isEmpty(uuid)) 
					{
						uuid = getUniquePsuedoID();
					}
					cfgIni.setProperty("uuid", uuid);  
					cfgIni.store(new FileOutputStream(uFile),"user_id");
				}
				return uuid;
	        } catch (IOException e) {  
	            e.printStackTrace();  
	        }  
		}else{
			try {
				
			
				String uuid = UUID.randomUUID().toString();
				
				LogUtil.LOGE("googleLogin", "-getUUIDFromCfgFile---step3----" + uuid);
				
				
				
				if (TextUtils.isEmpty(uuid)) 
				{
					uuid = getUniquePsuedoID();
				}
				cfgIni.setProperty("uuid", uuid);  
				cfgIni.store(new FileOutputStream(uFile),"user_id");
				return uuid;
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return "";
	}
	
	//获得独一无二的Psuedo ID
	public static String getUniquePsuedoID() {
	       String serial = null;

	       String m_szDevIDShort = "35" + 
	            Build.BOARD.length()%10+ Build.BRAND.length()%10 + 

	            Build.CPU_ABI.length()%10 + Build.DEVICE.length()%10 + 

	            Build.DISPLAY.length()%10 + Build.HOST.length()%10 + 

	            Build.ID.length()%10 + Build.MANUFACTURER.length()%10 + 

	            Build.MODEL.length()%10 + Build.PRODUCT.length()%10 + 

	            Build.TAGS.length()%10 + Build.TYPE.length()%10 + 

	            Build.USER.length()%10 ; //13 位

	    try {
	        serial = android.os.Build.class.getField("SERIAL").get(null).toString();
	       //API>=9 使用serial号
	        return new UUID(m_szDevIDShort.hashCode(), serial.hashCode()).toString();
	    } catch (Exception exception) {
	        //serial需要一个初始化
	        serial = "serial"; // 随便一个初始化
	    }
	    //使用硬件信息拼凑出来的15位号码
	    return new UUID(m_szDevIDShort.hashCode(), serial.hashCode()).toString();
	}
	    
	public static boolean getIsFirstRecharge(String userPuid) {
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + File.separator + "tigerto" + File.separator + "SchoolUserData.properties");
		Properties cfgIni = new Properties();
		if(uFile.exists()){
			try {  
				cfgIni.load(new FileInputStream(uFile));
				String uuid = cfgIni.getProperty("Recharge_"+userPuid, "");
				if(uuid.equals(""))
				{
					return true;
				}
				return false;
	        } catch (IOException e) {  
	            e.printStackTrace();  
	        }  
		}else{
			return true;
		}
		return false;
	}
	public static boolean setFirstRechargeStatus(String userPuid) {
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + File.separator + "tigerto" + File.separator + "SchoolUserData.properties");
		Properties cfgIni = new Properties();
		if(uFile.exists()){
			try {  
				cfgIni.load(new FileInputStream(uFile));
				String uuid = cfgIni.getProperty("Recharge_"+userPuid, "");
				if(uuid.equals(""))
				{//node不存在
					cfgIni.setProperty("Recharge_"+userPuid, userPuid);  
					cfgIni.store(new FileOutputStream(uFile),"user_id");
				}
				return true;
	        } catch (IOException e) {  
	            e.printStackTrace();  
	        }  
		}else{
			cfgIni.setProperty("Recharge_"+userPuid, userPuid);  
			try {
				cfgIni.store(new FileOutputStream(uFile),"user_id");
			} catch (FileNotFoundException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
		}
		return false;
	}
		private void InitAddress() {

		
		Object localObject1 = new File(this.filesPath);
	    Object localObject3 = new File(((File)localObject1).getAbsoluteFile() + File.separator + "dynamic.ini");
	    
	    
	    
	    if ((((File)localObject3).exists()) && (((File)localObject3).isFile()))
	    {
	      String bindurl = IniFileUtil.GetPrivateProfileString(((File)localObject3).getAbsolutePath(), "Account", "bindingGameCenterRequestAndroid", URLConst.bindingGameCenterRequest);
	      String queryurl = IniFileUtil.GetPrivateProfileString(((File)localObject3).getAbsolutePath(), "Account", "accountEnterRequestAndroid",  URLConst.accountEnterRequest);
	      String changePwdUrl = IniFileUtil.GetPrivateProfileString(((File)localObject3).getAbsolutePath(), "Account", "dataTransferChangePwdUrlAndroid", URLConst.dataTransferChangePwdUr);
	      String transferUrl = IniFileUtil.GetPrivateProfileString(((File)localObject3).getAbsolutePath(), "Account", "dataTransferUrlAndroid", URLConst.dataTransferUrl);
	      UidBindMange.getInstance().InitServerAddress(bindurl, queryurl, changePwdUrl, transferUrl);
	    }else
	    { 
	    	String bindurl =      URLConst.bindingGameCenterRequest;
	    	String queryurl =     URLConst.accountEnterRequest;
	    	String ChangePwdUrl = URLConst.dataTransferChangePwdUr;
	    	String transferUrl =  URLConst.dataTransferUrl;
			
			UidBindMange.getInstance().InitServerAddress(bindurl, queryurl,ChangePwdUrl,transferUrl);
	    }
	    
	    
	    
	}

	private void BindGooglePlusToServer(String uid,String gpid) {
		UidBindMange.getInstance().BindUid(uid, gpid, new BindCallBack<String>() {

			@Override
			public void onSuccess(String success) {
				String result[] = success.split("\\|");
				String code = "";
				String state = "";
				/*
				 * 成功标识|原因“ 成功标识为1，或者0；1代表成功，0代表失败，失败原因为0，没有原因，一般代表成功；
					1此gp账号已经绑定过其他puid账号了，3//已存在的puid中，但是没有找到gpid的字段（没有初始化）4//该puid已经绑定了gp账号
				 */
				if(result.length == 2){
					mWasBindGP = result[0].equals("1");
					if(mWasBindGP){
						//通知 lua 绑定成功
						code = "success";
					}
					else{
						code = "failed";
						state = result[1];
					}
					JSONObject item = new JSONObject();
					try {
						item.put("code", code);
						item.put("state", state);
						
					} catch (JSONException e) {
						e.printStackTrace();
					}
					Cocos2dxHelper.nativeSendMessageP2G("P2G_BIND_GC_GP", item.toString());
				}
				else{
					Toast.makeText(PlatformSDKActivity.this, "bound data error!", Toast.LENGTH_LONG).show();
				}
			}

			@Override
			public void onError(String error) {
				Toast.makeText(PlatformSDKActivity.this, "bound ,time out", Toast.LENGTH_SHORT).show();
				JSONObject item = new JSONObject();
				try {
					item.put("code", "failed");
					item.put("state", "5");
					
				} catch (JSONException e) {
					e.printStackTrace();
				}
				Cocos2dxHelper.nativeSendMessageP2G("P2G_BIND_GC_GP", item.toString());
			}
		});
	}
	private void showView(final boolean vis){

		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				if(vis){
					mWaitView.show();
				}else{
					mWaitView.remove();
				}
			}
		});
	}
	private void TimerTick(){
		  if (mTimetask != null){
			  mTimetask.cancel();  //将原任务从队列中移除
		  }
		 mTimetask = new TimerTask() {
				@Override
				public void run() {
					showView(false);
					mTimer.cancel();
					mTimer = null;
				}
			};
		if(mTimer ==null){
			mTimer = new Timer(true);
			mTimer.schedule(mTimetask,5000, 5000);//5秒后执行
		}else
		{
			mTimer.schedule(mTimetask,5000, 5000);//5秒后执行
		}
	}

	public void DataTransferChangePwd(final String strPwd){
		//mCurDeviceId
		showView(true);
		UidBindMange.getInstance().changePassWord(mUserCode, strPwd,new BindCallBack<String>() {

			@Override
			public void onSuccess(String success) {
				showView(false);
				LogUtil.LOGE("UidBindMange", "changePassWord - callback onSuccess = "+success);
				LogUtil.LOGE("UidBindMange", "moveAccountEnter - callback onSuccess = "+success);
				String result[] = success.split("\\|");
				if(result.length != 2){
					Toast.makeText(PlatformSDKActivity.this, getResources().getString(R.string.changepwd_failed), Toast.LENGTH_LONG).show();
					return ;
				}
				JSONObject item = new JSONObject();
				try {
					item.put("result", result[0]);
					item.put("code", result[1]);
					item.put("pwd", strPwd);
					
				} catch (JSONException e) {
					e.printStackTrace();
				}
				Cocos2dxHelper.nativeSendMessageP2G("P2G_CHANGE_PWD", item.toString());
			}

			@Override
			public void onError(String error) {
				showView(false);
				LogUtil.LOGE("UidBindMange", "changePassWord - callback onError = "+error);
				
				runOnUiThread(new Runnable() {
					@Override
					public void run() {
						Toast.makeText(PlatformSDKActivity.this, getResources().getString(R.string.changepwd_timeout), Toast.LENGTH_LONG).show();
					}
				});
			}
		});
	}
	public void moveAccountEnter(String strCode,String strPwd){
		//mCurDeviceId
		showView(true);
		UidBindMange.getInstance().moveAccountEnter(strCode, strPwd,mCurDeviceId,new BindCallBack<String>() {

			@Override
			public void onSuccess(String success) {
				showView(false);
				LogUtil.LOGE("UidBindMange", "moveAccountEnter - callback onSuccess = "+success);
				String result[] = success.split("\\|");
				if(result.length != 2){
					Toast.makeText(PlatformSDKActivity.this, getResources().getString(R.string.moveaccount_failed), Toast.LENGTH_LONG).show();
					return ;
				}
				JSONObject item = new JSONObject();
				try {
					item.put("result", result[0]);
					item.put("code", result[1]);
					
				} catch (JSONException e) {
					e.printStackTrace();
				}
				if(result[0].equals("1")){//移行成功
					callLogin();
				}
				Cocos2dxHelper.nativeSendMessageP2G("P2G_DATA_TRANSFER", item.toString());
			}

			@Override
			public void onError(String error) {
				showView(false);
				LogUtil.LOGE("UidBindMange", "moveAccountEnter - callback onError = "+error);
				runOnUiThread(new Runnable() {
					@Override
					public void run() {
						Toast.makeText(PlatformSDKActivity.this, getResources().getString(R.string.moveaccount_timeout), Toast.LENGTH_LONG).show();
					}
				});
				
			}
		});
	}
	public void showToast(final String msg){
		//mCurDeviceId
		
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				Toast.makeText(PlatformSDKActivity.this, msg, Toast.LENGTH_LONG).show();
			}
		});
	}
}
