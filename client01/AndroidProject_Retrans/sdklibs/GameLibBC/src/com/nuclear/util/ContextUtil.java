package com.nuclear.util;

import java.util.Locale;

import com.nuclear.manager.MessageManager;
import com.nuclear.manager.MessageManager.MessageListener;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;

public class ContextUtil {
	public static Context mContext;
	private static Handler handler = new Handler(){
		public void handleMessage(Message msg) {
			
		};
	};
	public static void setContext(Context context){
		mContext = context;
		handler = new Handler(context.getMainLooper());
		
		MessageListener listener = new MessageListener() {
			@Override
			public void registerMsg(){
				MessageManager.getInstance().setMsgHandler("requestRestart",this);
				MessageManager.getInstance().setMsgHandler("getCurrentCountry",this);
			}
			
			@Override
			public void unregisterMsg(){
				MessageManager.getInstance().removeMsgHandler("requestRestart");
				MessageManager.getInstance().removeMsgHandler("getCurrentCountry");
			}
			
			public String requestRestart(String msg){
				ContextUtil.requestRestart();
				return null;
			}
			
			public String getCurrentCountry(String msg) {
				return ContextUtil.getCurrentCountry();
			}
		};
		listener.registerMsg();
	}

	public static void requestRestart() {
		AlarmManager alm = (AlarmManager) mContext
				.getSystemService(Context.ALARM_SERVICE);
		alm.set(AlarmManager.RTC, System.currentTimeMillis() + 1000,
				PendingIntent.getActivity(mContext, 0, new Intent(mContext,
						mContext.getClass()), 0));
		android.os.Process.killProcess(android.os.Process.myPid());
	}

	public static String getCurrentCountry() {
		Locale locale = Locale.getDefault();
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
			locale = mContext.getApplicationContext().getResources().getConfiguration().getLocales().get(0);
		} else {
			locale = mContext.getApplicationContext().getResources().getConfiguration().locale;
		}
		return locale.getCountry().toLowerCase();
	}
	
	public static boolean checkNetworkStatus() {
		// 检查网络状态。
		ConnectivityManager cm = (ConnectivityManager) mContext
				.getSystemService(Context.CONNECTIVITY_SERVICE);
		NetworkInfo niWiFi = cm.getNetworkInfo(ConnectivityManager.TYPE_WIFI);
		NetworkInfo niMobile = cm.getNetworkInfo(ConnectivityManager.TYPE_MOBILE);

		if(niWiFi!=null&&niWiFi.isAvailable()&&niWiFi.isConnected()){
			return true;
		}else if(niMobile!=null&&niMobile.isAvailable()&&niMobile.isConnected()){
			return true;
		}else{
			return false;
		}
	}
	public static String getSPConfig(String key,String defValue){
		SharedPreferences sharedPreferences = mContext.getSharedPreferences("config", Context.MODE_PRIVATE);
		String string = sharedPreferences.getString(key, defValue);
		return string;
	}
	public static boolean getSPConfig(String key,boolean defValue){
		SharedPreferences sharedPreferences = mContext.getSharedPreferences("config", Context.MODE_PRIVATE);
		boolean value = sharedPreferences.getBoolean(key, defValue);
		return value;
	}

	public static void setSPConfig(String key, boolean b) {
		SharedPreferences sharedPreferences = mContext.getSharedPreferences("config", Context.MODE_PRIVATE);
		sharedPreferences.edit().putBoolean(key, b).commit();
		
	}
	public static void setSPConfig(String key, String defValue) {
		SharedPreferences sharedPreferences = mContext.getSharedPreferences("config", Context.MODE_PRIVATE);
		sharedPreferences.edit().putString(key, defValue).commit();
		
	}
	public static void postDelay(Runnable r,long delayMillis){
		handler.postDelayed(r, delayMillis);
	}

	public static void requestDestroy() {
		
	}
}
