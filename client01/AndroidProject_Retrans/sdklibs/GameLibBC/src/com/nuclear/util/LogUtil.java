package com.nuclear.util;

import android.util.Log;

public class LogUtil {
	
	public static boolean LogSwitch = true;
	public static boolean IsTestLogin = false;
	
    public static  void  LOGD(String tag , String msg)
    {
    	if(LogSwitch)
    	{
        	Log.d(tag, "--Log---" +msg);
    	}

    }
    public static  void  LOGE(String tag , String msg)
    {
    	if(LogSwitch)
    	{
    		Log.e(tag, "--Log---" + msg);
    	}
    	
    }
    public static  void  LOGI(String tag , String msg)
    {
    	if(LogSwitch)
    	{
    		Log.i(tag,"--Log---" + msg);
    	}
    }
    public static  void  LOGW(String tag , String msg)
    {
    	if(LogSwitch)
    	{
    		Log.w(tag,"--Log---" + msg);
    	}
    }
}
