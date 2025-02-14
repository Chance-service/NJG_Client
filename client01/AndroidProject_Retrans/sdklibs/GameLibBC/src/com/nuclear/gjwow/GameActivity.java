package com.nuclear.gjwow;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.UUID;
import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxHandler;
import org.cocos2dx.lib.Cocos2dxHelper;
import org.cocos2dx.lib.Cocos2dxHandler.PayRechargeMessage;
import org.cocos2dx.lib.Cocos2dxHandler.ShareMessage;
import org.cocos2dx.lib.Cocos2dxHandler.ShowWaitingViewMessage;
import org.json.JSONException;

import com.nuclear.bean.LoginInfo;
import com.nuclear.bean.PayInfo;
import com.nuclear.bean.ShareInfo;
import com.nuclear.manager.MessageManager;
import com.nuclear.manager.StateManager;
import com.nuclear.state.GameAppState;
import com.nuclear.state.SplashState;
import com.nuclear.util.ContextUtil;
import com.nuclear.util.DeviceUtil;
//import com.nuclear.util.DownloadApk;
import com.nuclear.util.LogUtil;
import com.guajibase.gamelib.R;
import ConstValue.PlatformConst;

import android.annotation.SuppressLint;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.ClipboardManager;
import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.os.StrictMode;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;

import com.chance.allsdk.E_PLATFORM;
import com.chance.allsdk.SDKFactory;

@SuppressLint("NewApi")
public abstract class GameActivity extends Cocos2dxActivity {
	private static final String TAG = GameActivity.class.getSimpleName();
	protected LoginInfo login_info;
	private long mLastMenuKeyDownTimeMillis;
	private int mRecentPressMenuKeyDownCount;
	//public static JSGAPI jsgsdk  = null;
	//public static H365API h365sdk  = null;
	//public static LSJAPI lsjsdk = null;
	//private DownloadApk updateApk;
	private static boolean mFlag;
	private ClipboardManager clipManager = null;
	static int mState = 0;// mState = 1 gameappstate 当前状态
	public static final String appId = "6sbh7xa1jjkmrs11";
	public static String channel = "Third-party";
	public static String gameVersion = "";
	static {
		System.loadLibrary("Game");
	}

	@SuppressLint("HandlerLeak")
	private class GameAppStateHandler extends Handler {
		public void handleMessage(Message msg) {
			//
			if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformLogin) {
				notifyOnTempShortPause();

				callLogin();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformLogout) {
				Log.d(TAG, "callLogout0");
				callLogout();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPlayMovie) {
				Log.d(TAG, "callPlayMovie");
				notifyOnTempShortPause();
				callPlayMovie((String) msg.obj, msg.arg1, msg.arg2);
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformCloseMovie) {
				notifyOnTempShortPause();
				callCloseMovie();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPauseMovie) {
				notifyOnTempShortPause();
				callPauseMovie();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformResumeMovie) {
				notifyOnTempShortPause();
				callResumeMovie();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformAccountManage) {
				notifyOnTempShortPause();
				callAccountManage();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPayRecharge) {
				notifyOnTempShortPause();// 支付有的activity跳activity，容易把我们的游戏activity搞的自动重启！
				//
				PayRechargeMessage obj = (PayRechargeMessage) msg.obj;
				//
				PayInfo pay_info = new PayInfo();
				pay_info.productType = obj._productType;
				pay_info.name = obj._name;
				pay_info.order_serial = obj.serial;
				pay_info.product_id = obj.productId;
				pay_info.product_name = obj.productName;
				pay_info.price = obj.price;
				pay_info.orignal_price = obj.orignalPrice;
				pay_info.count = obj.count;
				pay_info.description = obj.description;
				pay_info.serverTime = obj.serverTime;
				pay_info.extras = obj.extras;
				if (pay_info.order_serial.isEmpty())
					pay_info.order_serial = generateNewOrderSerial();
				//
				callPayRecharge(pay_info);
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformFeedback) {
				notifyOnTempShortPause();
				callFeedback();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformThirdShare) {
				notifyOnTempShortPause();
				//
				ShareMessage obj = (ShareMessage) msg.obj;
				//
				ShareInfo share_info = new ShareInfo();
				share_info.img_path = obj.imgPath;
				share_info.content = obj.content;
				//
				callPlatformSupportThirdShare(share_info);
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformBBS) {
				notifyOnTempShortPause();
				callGameBBS();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_ShowWaitingView) {
				ShowWaitingViewMessage obj = (ShowWaitingViewMessage) msg.obj;
				showWaitingViewImp(obj.show, obj.progress, obj.text);
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnActivityPause) {
				onGamePause();
			} else if (msg.what == Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnActivityResume) {
				// mCallback.notifyOnTempShortPause();
				onGameResume();
			} else if (msg.what == Cocos2dxHandler.HANDLER_SHOW_DIALOG) {
				// DialogMessage dialogMessage = (DialogMessage) msg.obj;
				// showQuestionDialog(1,dialogMessage.message);
			}
		}

	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
				
		mState = 0;
		StrictMode.setThreadPolicy(new StrictMode.ThreadPolicy.Builder()
		/* .detectDiskReads().detectDiskWrites() */.detectNetwork()
		/* .penaltyLog() */.build());
		ContextUtil.setContext(this);
		init();
		setContentView(R.layout.activity_main);
		ViewGroup container = (ViewGroup) findViewById(R.id.container);
		StateManager manager = StateManager.getInstance();
		manager.setActivity(this);
		manager.setViewContainer(container);
		manager.changeState(SplashState.class);
		// VoiceChat.getInstance().init(this);
		LastLoginHelp.setActivity(this);
		clipManager = (ClipboardManager) this
				.getSystemService(Context.CLIPBOARD_SERVICE);
		super.setGameAppStateHandler(new GameAppStateHandler());

//		if (PlatformConst.platform == E_PLATFORM.H365) {
//			h365sdk = new H365API(this);
//		}
//
//		if (PlatformConst.platform == E_PLATFORM.JSG) {
//			jsgsdk = new JSGAPI(this);
//		}

		SDKFactory.getInstance().getSDKHandler().init(this);

//		if (PlatformConst.platform == E_PLATFORM.LSJ) {
//			lsjsdk = new LSJAPI(this);
//		}

	}

	public static String getPackageNameToLua() {
		if (ContextUtil.mContext != null) {
			return ContextUtil.mContext.getPackageName();
		} else {
			return "";
		}
	}
	
	@Override
	protected void onResume()
	{
		Log.d(TAG, "call GemeActivity.onResume");	
		super.onResume();

		SDKFactory.getInstance().getSDKHandler().onResume();

//		if ((PlatformConst.platform == E_PLATFORM.H365) && (h365sdk != null)){
//			Log.d(TAG, "call GemeActivity onResume h365relogin again");
//			h365sdk.relogin();
//		}

//		if ((PlatformConst.platform == E_PLATFORM.JSG) && (jsgsdk != null)) {
//			if (jsgsdk != null) {
//				Log.d(TAG, "call jsgskd GemeActivity Resume");
//				jsgsdk.doResume();
//			}
//		}
	}

	@Override
	public String getDeviceID() {
		return DeviceUtil.getDeviceUUID(this);
	}
	
	public  String getDeviceInfo() {
		return "android";
		
	}
	
	public void setLanguageName(String lang) {
		String language = lang;
	}

	public String getClipboardText() {
		String text = "";
		if (clipManager != null) {
			CharSequence cs = clipManager.getText();
			if (cs != null) {
				text = cs.toString();
			}
		}
		return text;
	}

	public void setClipboardText(String text) {
		if (clipManager != null) {
			clipManager.setText(text);
		}
	}

	@Override
	public String getPlatformInfo() {
		String temp = Build.MANUFACTURER + Build.MODEL;
		temp = temp.replaceAll(" ", "-");
		String ret = temp + "#" + Build.VERSION.SDK_INT;
		ret = ret + "#sSystemName#Android";
		return ret;

	}

	@Override
	public String getPlatformToken()
	{
		return SDKFactory.getInstance().getSDKHandler().getToken();
	}

	@Override
	public void showPlatformProfile()
	{
		SDKFactory.getInstance().getSDKHandler().onShowProfile();
	}

	@Override
	public void notifyEnterGame() {

	}

	@Override
	public int getPlatformId() {
		return PlatformConst.platform.getValue();
	}

	@Override
	public void pushSysNotification(String pTitle, String msg,
			int pInstantMinite) {
		// String strTitle = getString(R.string.app_name);
		// sendBroadcastAtTime(msg, strTitle, pInstantMinite);
	}

	public void sendBroadcastAtTime(String msg, String strTitle,
			int pInstantMinite) {
		AlarmManager am = null;
		PendingIntent pi = null;
		am = (AlarmManager) this.getSystemService(ALARM_SERVICE);
		Intent myIntent = new Intent(this,NotificationReceive.class);// 创建Intent对象
		myIntent.setAction("android.intent.action.MY_ALERT_RECEIVER");
		myIntent.putExtra("message", msg);
		myIntent.putExtra("title", getString(R.string.app_name));
		myIntent.putExtra("delayminite", pInstantMinite);
		LogUtil.LOGE(TAG, "pushSysNotification");
		pi = PendingIntent.getBroadcast(this, 0, myIntent,
				PendingIntent.FLAG_UPDATE_CURRENT);
		long time = System.currentTimeMillis();
		if (null == am || pi == null) {
			System.out.println("arm exit");
			return;
		}
		//呼び出す日時を設定する
		Calendar triggerTime = Calendar.getInstance();
		triggerTime.add(Calendar.SECOND, 1);	//今から5秒後
		
		//pInstantMinite =30;
		//am.set(AlarmManager.RTC_WAKEUP, triggerTime.getTimeInMillis(), pi);
		//long time_triger = time + pInstantMinite * 1000;
		//System.out.println("*****time_triger:"+time_triger +"time:"+pInstantMinite);
		
		am.set(AlarmManager.RTC_WAKEUP, time + pInstantMinite * 1000, pi);
		//am.set(AlarmManager.RTC_WAKEUP, time_triger, pi);
//		 am.setRepeating(AlarmManager.RTC_WAKEUP,System.currentTimeMillis()+pInstantMinite
//		 * 60 * 1000,pInstantMinite * 60 * 1000,pi);

	}

	public void sendBroadcastAtTimeRepeat(String msg, String strTitle,
			int pInstantMinite, String Action) {
		AlarmManager am = null;
		PendingIntent pi = null;
		am = (AlarmManager) this.getSystemService(ALARM_SERVICE);
		Intent myIntent = new Intent(this,NotificationReceive.class);// 创建Intent对象
		myIntent.setAction(Action);
		myIntent.putExtra("message", msg);
		myIntent.putExtra("title", getString(R.string.app_name));
		myIntent.putExtra("delayminite", pInstantMinite);
		LogUtil.LOGE(TAG, "pushSysNotification");
		pi = PendingIntent.getBroadcast(this, 0, myIntent,
				PendingIntent.FLAG_UPDATE_CURRENT);
		long time = System.currentTimeMillis();
		if (null == am || pi == null) {
			return;
		}
		am.setRepeating(AlarmManager.RTC_WAKEUP, System.currentTimeMillis()
				+ pInstantMinite * 1000, 24 * 60 * 60 * 1000, pi);
		// am.set(AlarmManager.RTC_WAKEUP, time + pInstantMinite * 60 * 1000,
		// pi);
		// am.setRepeating(AlarmManager.RTC_WAKEUP,System.currentTimeMillis()+pInstantMinite
		// * 60 * 1000,pInstantMinite * 60 * 1000,pi);

	}

	public void CleanBroadcastAtTimeRepeat(String Action) {
		AlarmManager am = null;
		PendingIntent pi = null;
		am = (AlarmManager) this.getSystemService(ALARM_SERVICE);
		Intent myIntent = new Intent(this,NotificationReceive.class);// 创建Intent对象
		myIntent.setAction(Action);
		myIntent.putExtra("message", "");
		myIntent.putExtra("title", "");
		myIntent.putExtra("delayminite", 10);
		LogUtil.LOGE(TAG, "pushSysNotification");
		pi = PendingIntent.getBroadcast(this, 0, myIntent,
				PendingIntent.FLAG_UPDATE_CURRENT);
		long time = System.currentTimeMillis();
		if (null == am || pi == null) {
			return;
		}
		am.cancel(pi);
		// am.set(AlarmManager.RTC_WAKEUP, time + pInstantMinite * 60 * 1000,
		// pi);
		// am.setRepeating(AlarmManager.RTC_WAKEUP,System.currentTimeMillis()+pInstantMinite
		// * 60 * 1000,pInstantMinite * 60 * 1000,pi);

	}

	@Override
	public void ShowAnnounce(String pAnnounceUrl) {

	}

	@Override
	public void clearSysNotification() {

	}

	@Override
	public void initAndroidContext(View glView, View editText) {
		super.initAndroidContext(glView, editText);
	}

	@Override
	public void onTimeToShowCocos2dxContentView() {
		runOnUiThread(new Runnable() {

			@Override
			public void run() {
				StateManager.getInstance().changeState(GameAppState.class);
				mState = 1;
			}
		});
	}

	public void setAppPath(String path) {
		mAppDataExternalStorageFullPath = path;
	}

	public void setGameAppStateHandler() {
		super.setGameAppState();
	}

	public void notifyOnTempShortPause() {

		super.setOnTempShortPause(true);
	}

	public void showWaitingViewImp(boolean show, int progress, String text) {
		super.showWaitingView(show, progress, text);
	}

	public void onGameResume() {

	}

	public void onGamePause() {

	}

	public void callGameBBS() {

	}

	public void callFeedback() {
		mFlag = true;
	}

	private void callPlatformSupportThirdShare(ShareInfo share_info) {

	}

	public int callPayRecharge(PayInfo pay_info) {
		try {
			SDKFactory.getInstance().getSDKHandler().toPay(pay_info);
		} catch (JSONException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return 0;
	}
	
	public void callPlayMovie(String fileName, int isLoop, int autoScale) {
		
	}

	public void callCloseMovie() {

	}

	public void callPauseMovie() {

	}

	public void callResumeMovie() {

	}

	public void callLogin() {
		// 已經被platformSDKActivity繼承覆寫了
//		LoginInfo result = new LoginInfo();
//		result.account_uid_str = "123";
//		result.account_user_name = "213";
//		notifyLoginResut(result);
	}

	public void callLogout() {		
		// 已經被platformSDKActivity繼承覆寫了
	}

	public void callAccountManage() {

	}

	public void init() {
	}

	public String getAppFilesResourcesPath() {
		return this.mAppDataExternalStorageResourcesFullPath;
	}

	public void setAppFilesResourcesPath(String path) {
		this.mAppDataExternalStorageResourcesFullPath = path;
	}

	@Override
	public String generateNewOrderSerial() {
		return UUID.randomUUID().toString().replace("-", "");
	}

	public void uncompressTTFFile()
	{
		final String packageName = this.getPackageName();

		String pathDir = Environment.getExternalStorageDirectory()
				.getAbsolutePath() + "/Android/data/" + packageName;
		
		Log.e("PlatformSDKActivity", pathDir  + "" );
		
		File fileF = new File(pathDir + "/files");
		if (fileF.mkdir()) {
			Log.e("PlatformSDKActivity", "fileF.mkdir()" );
		} else {
		}

		File fileAss = new File(pathDir + "/files/assets");
		if (fileAss.mkdir()) {
			Log.e("PlatformSDKActivity", "fileAss.mkdir");
		} else {
			
		}
        boolean isFileExsist = false  ;
		File fileTtf = new File(pathDir + "/files/assets/FOT-Skip Std D.ttf");
		if (fileTtf.exists()) {
			Log.e("PlatformSDKActivity", "fileTtf.exists()");
			isFileExsist = true ;
		} else {
			
		}
		
		if(!isFileExsist)
		{
			FileOutputStream fos = null;
			try {
				fos = new FileOutputStream(pathDir + "/files/assets/FOT-Skip Std D.ttf");
				
				Log.e("PlatformSDKActivity", fos.toString());
				
			} catch (FileNotFoundException e) {
				
				e.printStackTrace();
			}

			InputStream inputStream1 = null;
			try {
				inputStream1 = getResources().getAssets().open("FOT-Skip Std D.ttf");
				int len;// 常规的读写复制
				byte[] b = new byte[1024];
				while ((len = inputStream1.read(b)) != -1) {
					Log.e("PlatformSDKActivity", "---write");
					fos.write(b, 0, len);
					fos.flush();
				}// 关闭资源
				inputStream1.close();
				fos.close();
			} catch (IOException e2) {
				
				e2.printStackTrace();
			}
		}
		
	}
	public void notifyLoginResut(final LoginInfo result) {
		super.setOnTempShortPause(false);
		login_info = result;
		login_info.account_uid_str = getPrefixion()
				+ login_info.account_uid_str;
		LogUtil.LOGE(TAG, result.account_uid_str);
		LogUtil.LOGE(TAG, result.account_uid + "");
		LogUtil.LOGE(TAG, result.login_session);
		LogUtil.LOGE(TAG, result.account_nick_name);

		//uncompressTTFFile();
	
//         new Thread(new Runnable() {
//             @Override
//              public void run() {
//                  try {
//                      Thread.sleep(5000);//延时1s
//                      sendLoginResult(result);
//                  } catch (InterruptedException e) {
//                      e.printStackTrace();
//                 }
//             }
//         }).start();
		 
		 
//		new Handler().postDelayed(new Runnable() {
//			 
//			         @Override
//			         public void run() {
//			        	 sendLoginResult(result);
//			           }
//			        }, 1000);    //延时1s执行
		
		

//		Handler handler = new Handler() {
//			          @Override
//			         public void handleMessage(Message msg) {
//			              if (msg.what == 1){
//			            	  sendLoginResult(result);
//			              }
//			              super.handleMessage(msg);
//			  
//			          }
//		};
//			
//		 Message msg = new Message();
//		 msg.what = 1;
//		 handler.sendMessage(msg);
//		 
		 
		Cocos2dxHelper.nativeNotifyPlatformLoginResult(0,
				String.valueOf(result.account_uid), result.login_session,
				result.account_nick_name);
	}

	public void sendLoginResult(LoginInfo result)
	{
		Cocos2dxHelper.nativeNotifyPlatformLoginResult(0,
				String.valueOf(result.account_uid), result.login_session,
				result.account_nick_name);
	}
	public static void copyAssetFileToFiles(Context context, String filename)
			throws IOException {
		InputStream is = context.getAssets().open(filename);
		LogUtil.LOGE("filesPath----", "size--" + is.available());
		byte[] buffer = new byte[is.available()];
		is.read(buffer);
		is.close();
		try {
			File of = new File(context.getFilesDir() + "/assets/" + filename);
			of.createNewFile();
			LogUtil.LOGE("filesPath----", "of--getpath--" + of.getPath());
			LogUtil.LOGE("filesPath----",
					"of--getabsoultepath---" + of.getAbsolutePath());
			LogUtil.LOGE("filesPath----", "of--toString ---" + of.toString());
			LogUtil.LOGE("filesPath----", "of--length--" + of.length());
			FileOutputStream os = new FileOutputStream(of);
			os.write(buffer);
			os.close();

			File file2 = new File(context.getFilesDir() + "/assets/" + filename);
			LogUtil.LOGE("filesPath----", "of--toString ---" + file2.toString());
			LogUtil.LOGE("filesPath----", "of--length--" + file2.length());
		} catch (IOException e) {
			LogUtil.LOGE("filesPath---exception-", e.toString());
		}

	}

	@Override
	public boolean getPlatformLoginStatus() {
		if (login_info == null)
			return false;

		if (login_info.login_result == 0)
			return true;
		else
			return false;
	}

	@Override
	public String getPlatformLoginUin() {
		String auuId = SDKFactory.getInstance().getSDKHandler().getuuid();
		LogUtil.LOGD(TAG, "UUID = " + auuId);
		return auuId;
	}

	@Override
	public String getPlatformLoginSessionId() {
		if (login_info == null) {
			return DeviceUtil.generateUUID();
		}
		return login_info.login_session;
	}

	@Override
	public String getPlatformUserNickName() {
		if (login_info == null) {
			return DeviceUtil.getDeviceProductName(this);
		}
		return login_info.account_nick_name;
	}

	public void callPlatformInit() {

	}

	public void onLoginGame() {

	}

	@Override
	public void openUrlOutside(String url) {

		if (url.isEmpty())
			return;
		if (url.endsWith(".apk")) {
			//updateApk = new DownloadApk(this, url);
		} else {
			super.openUrlOutside(url);
		}
	}

	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
//		if (keyCode == KeyEvent.KEYCODE_POWER) {
//			if (event.isLongPress()) {
//				if (!mIsCocos2dxSurfaceViewCreated)
//					super.onLowMemory();
//
//				return true;
//			}
//		} else if (keyCode == KeyEvent.KEYCODE_MENU) {
//
//			if (mIsTempShortPause || mIsOnPause
//					|| !mIsCocos2dxSurfaceViewCreated)
//				return super.onKeyDown(keyCode, event);
//
//			final long nowtime = android.os.SystemClock.elapsedRealtime();
//
//			if ((nowtime - mLastMenuKeyDownTimeMillis) < 3000 // 3秒之内再按第2�?
//					&& mRecentPressMenuKeyDownCount > 0) {
//
//				mRecentPressMenuKeyDownCount = 0;
//				Toast.makeText(this, R.string.screen_capture,
//						Toast.LENGTH_SHORT).show();
//
//				// if (repeatCount == 1) {
//				super.runOnGLThread(new Runnable() {
//
//					@Override
//					public void run() {
//
////						String png_file = Cocos2dxHelper.nativeGameSnapshot();
////						//
////						ShareInfo share = new ShareInfo();
////						share.content = "#" + getString(R.string.app_name)
////								+ "##Gjwow#@" + getString(R.string.app_name)
////								+ "Online";
////						share.img_path = png_file;
////						// share.bitmap = bmp;
////						callSystemShare(share);
//					}
//
//				});
//				// }
//				//
//				return true;
//			}
//
//			if ((nowtime - mLastMenuKeyDownTimeMillis) < 3000)// 两次截屏之间�?�?
//				return super.onKeyDown(keyCode, event);
//
//			mLastMenuKeyDownTimeMillis = nowtime;
//
//			if (mRecentPressMenuKeyDownCount < 1) {
//
//				//Toast.makeText(this, R.string.screen_capture_again,
//						//Toast.LENGTH_SHORT).show();
//				// mLastMenuKeyDownTimeMillis -= 2500;
//				mRecentPressMenuKeyDownCount++;
//				//
//				return super.onKeyDown(keyCode, event);
//			} else {
//				//Toast.makeText(this, R.string.screen_capture_again,
//						//Toast.LENGTH_SHORT).show();
//				return super.onKeyDown(keyCode, event);
//			}
//		} else if (keyCode == KeyEvent.KEYCODE_BACK) {
//			if (mState == 1) {// game state
//				if (getClientChannel().equals("android_entermate_kr")) {// 韩国
//					if (mFlag) {
//						mFlag = false;
//						OnLuaExitGame();
//						return true;
//					}
//					nativeOnBack();
//					return true;
//				}
//				// showQuestionDialog(2,R.string.app_exit_msg);
//			} else {//
//					// showQuestionDialog(2,R.string.app_exit_msg);
//			}
//
//			return true;
//		}
		return super.onKeyDown(keyCode, event);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		super.onDestroy();
//		if (updateApk != null) {
//			updateApk.onDestroy();
//			updateApk = null;
//		}
		// CleanBroadcastAtTimeRepeat("每隔1小时响应一次","0000000000000",60);
		// sendBroadcastAtTimeRepeat("每隔1小时响应一次","0000000000000",60);
		// sendBroadcastAtTimeRepeat("每隔2小时响应一次","1111111111111",120);
		// sendBroadcastAtTime("离开游戏1小时01分后响应","111111",61);
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	private void showQuestionDialog(int type, int msg) {
//		final CustomDialog.Builder builder = new CustomDialog.Builder(this);
//		builder.setDlgType(type);
//		builder.setMessage(msg);
//		builder.setTitle(R.string.app_name);
//		builder.setPositiveButton(R.string.confirm,
//				new DialogInterface.OnClickListener() {
//					public void onClick(DialogInterface dialog, int which) {
//						if (builder.getDlgType() == 1) {
//							dialog.dismiss();
//						} else {
//							GameActivity.this.finish();
//						}
//
//						// 设置你的操作事项
//					}
//				});
//		builder.setNegativeButton(R.string.cancel,
//				new android.content.DialogInterface.OnClickListener() {
//					public void onClick(DialogInterface dialog, int which) {
//						dialog.dismiss();
//					}
//				});
//
//		builder.create().show();
		/*
		 * AlertDialog dlg = new AlertDialog.Builder(this)
		 * .setTitle(R.string.app_name) .setMessage(R.string.app_exit_msg)
		 * .setPositiveButton(R.string.cancel, new
		 * DialogInterface.OnClickListener() {
		 * 
		 * @Override public void onClick(DialogInterface dialog, int which) {
		 * 
		 * } }) .setNegativeButton(R.string.confirm, new
		 * DialogInterface.OnClickListener() {
		 * 
		 * @Override public void onClick(DialogInterface dialog, int which) {
		 * GameActivity.this.finish(); } }) .setOnCancelListener(new
		 * DialogInterface.OnCancelListener() {
		 * 
		 * @Override public void onCancel(DialogInterface dialog) {
		 * 
		 * }
		 * 
		 * }).create(); dlg.setCanceledOnTouchOutside(false);
		 * WindowManager.LayoutParams lp = dlg.getWindow().getAttributes();
		 * dlg.getWindow().setAttributes(lp); dlg.show();
		 */
	}

	private void showQuestionDialog(int type, String msg) {
//		final CustomDialog.Builder builder = new CustomDialog.Builder(this);
//		builder.setDlgType(type);
//		builder.setMessage(msg);
//		builder.setTitle(R.string.app_name);
//		builder.setPositiveButton(R.string.confirm,
//				new DialogInterface.OnClickListener() {
//					public void onClick(DialogInterface dialog, int which) {
//						if (builder.getDlgType() == 1) {
//							dialog.dismiss();
//						} else {
//							GameActivity.this.finish();
//						}
//
//						// 设置你的操作事项
//					}
//				});
//		builder.setNegativeButton(R.string.cancel,
//				new android.content.DialogInterface.OnClickListener() {
//					public void onClick(DialogInterface dialog, int which) {
//						dialog.dismiss();
//					}
//				});
//
//		builder.create().show();
	}

	public void callSystemShare(final ShareInfo share) {

		if (share == null)
			return;

		super.setOnTempShortPause(true);

		new Thread(new Runnable() {

			@Override
			public void run() {
				Intent intent1 = new Intent(Intent.ACTION_SEND);// 微信的单张图片分享失败，报读取资源失败，没找到解决方�?
				Intent intent = new Intent(Intent.ACTION_SEND_MULTIPLE);
				intent.setType("image/png");
				intent1.setType("image/png");
				// intent.setType("text/plain");
				intent.putExtra(Intent.EXTRA_SUBJECT, getString(R.string.share)
						+ getString(R.string.app_name));
				intent.putExtra(Intent.EXTRA_TEXT, share.content);
				//
				intent1.putExtra(Intent.EXTRA_SUBJECT,
						getString(R.string.share)
								+ getString(R.string.app_name));
				intent1.putExtra(Intent.EXTRA_TEXT, share.content);

				intent1.putExtra(Intent.EXTRA_STREAM,
						Uri.parse("file:///" + share.img_path));

				{
					ArrayList<Uri> arrayUri = new ArrayList<Uri>();
					arrayUri.add(Uri.parse("file:///" + share.img_path));

					intent.putExtra(Intent.EXTRA_STREAM, arrayUri);
				}

				intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				intent1.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
				Cocos2dxActivity.getContext()
						.startActivity(
								Intent.createChooser(intent1,
										getString(R.string.share)));
				//
				LogUtil.LOGE(TAG, "android.intent.action.SEND");

			}

		}).start();
	}

	private void OnLuaExitGame() {
		callPlatformSendMessageG2P("OnLuaExitGame", "");
	}

	public String sendMessageP2G(String tag, String msg) {

		return callPlatformSendMessageG2P(tag, msg);
	}

	@Override
	public String callPlatformSendMessageG2P(String tag, String msg) {
		LogUtil.LOGD(TAG, "callPlatformSendMessageG2P tag=" + tag + ",msg="
				+ msg);
		if ("OnEntermateEvent".equals(tag) || "OnEntermateHomepage".equals(tag)) {
			mFlag = true;
		}
		return MessageManager.getInstance().sendMessageG2P(tag, msg);
	}

	public void setBackPressed(boolean flag) {
		mFlag = flag;
	}

	public static native void nativeNotifyTryUserRegistSuccess();

	public static native void nativeOnShareEngineMessage(boolean _result,
			String _resultStr);

	public static native void nativeOnPlayMovieEnd();

	public static native void nativeOnMotionShake();

	public static native void nativeFBShareBack(boolean result);

	public static native void nativeOnBack();

	public static native void nativeOnEnterMateShowLoginPage();

	public static native void nativeOnKrCouponsBack(String StrResult);

	public static native void nativeOnKrGetInviteCount(int nCount);

	public static native void nativeOnKrGetInviteLists(String strInviteInfo);

	public static native void nativeOnKrGetFriendLists(String strFriendInfo);

	public static native void nativeOnKrSendInvite(String result);

	public static native void nativeOnKrGetGiftLists(String strGiftList);

	public static native void nativeOnKrReceiveGift(boolean result);

	public static native void nativeOnKrGetGiftCount(int nCount);

	public static native void nativeOnKrSendGift(String result);

	public static native void nativeOnKrGiftBlock(String result);

	public static native void nativeOnKrGetKakaoIdBack(String strId);

	public static native void nativeOnAndroidDeviceMessage(
			String _deviceIdMessage, String _deviceNameMessage);

	public static native void nativeRequestGameSvrBindTryToOkUser(
			String tryUser, String okUser);

	abstract public Drawable getSplashDrawable();

	abstract public Drawable getLogoDrawable();

	abstract public Drawable getLogo69Drawable();

	abstract public String getPrefixion();

	@Override
	public void onAttachedToWindow() {
		Log.d("PlatformSDKActivity", "onAttachedToWindow1" );
		super.onAttachedToWindow();
		Log.d("PlatformSDKActivity", "onAttachedToWindow2" );
	}
	/**
	 * 重写onDetachedFromWindow方法，调用JGGSDK.hideFloatBallFromAttach();
	 */
	@Override
	public void onDetachedFromWindow() {
		super.onDetachedFromWindow();
	}
	// form c++
	public static void setPlatformName(int platformNum) {
		//PlatformConst.platform = PlatformConst.E_PLATFORM.valueOf(platformNum);
	}

	public static E_PLATFORM getPlatformName() {
		return PlatformConst.platform;
	}

	// form c++
	public static void setPayUrl(String url) {
			SDKFactory.getInstance().getSDKHandler().setPayUrl(url);
	}
}
