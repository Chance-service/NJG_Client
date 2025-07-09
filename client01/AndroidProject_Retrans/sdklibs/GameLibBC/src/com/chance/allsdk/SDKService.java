package com.chance.allsdk;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.util.Log;

import com.nuclear.bean.PayInfo;
import com.nuclear.gjwow.GameActivity;
import com.tds.tapdb.*;
import com.tds.tapdb.sdk.TapDB;

import org.json.JSONException;

/**
 * 主要實現SDK預設
 */
public abstract class SDKService implements ISDKService {
    protected static GameActivity home_activity = null;
    protected static boolean APP_DBG = false; // 是否是debug模式
    protected static boolean isCreate = false;
    public static String payurl = "";
    protected static String uuid = "";
    protected static String platformtoken = "";
    protected static int Svrid = 0;
    protected static String aTag = "";
    protected static boolean isSetTabDB = false;
    protected static String channel = "";
    protected static String tabDBId = "";
    protected static String gameVersion = "";
    //private static boolean dologout = false;


    private static void initVer(Context context){
        APP_DBG = isApkDebugable(context);
    }

    @Override
    public void sdkLogin() {
    }
    @Override
    public void sdkLogout() {

    }

    @Override
    public void onResume(){

    }

    @Override
    public void onCreateSDK(){

    }

    public boolean onBackPressed() {
        return false; // 預設不處理返回
    }

    @Override
    public void initTabDB(){
        showlog(tabDBId);
        showlog(channel);
        TapDB.init(home_activity,tabDBId, channel,gameVersion);
        showlog("TapDB init");
        isSetTabDB = true;
    }

    public void initAdjustSDK(Context context){
    }

    public void initHyenaSDK(){
    }

    @Override
    public void init(GameActivity activity) {
        home_activity = activity;
        //Log.d(aTag, "setActivity");
        home_activity = activity;
        initVer(home_activity);
        onCreateSDK();
        initTabDB();
        initAdjustSDK(home_activity);
        initHyenaSDK();
    }

    private static boolean isApkDebugable(Context context) {
        try {
            ApplicationInfo info= context.getApplicationInfo();
            return (info.flags&ApplicationInfo.FLAG_DEBUGGABLE)!=0;
        } catch (Exception e) {

        }
        return false;
    }

    public static String escape(String src) {
        int i;
        char j;
        StringBuffer tmp = new StringBuffer();
        tmp.ensureCapacity(src.length() * 6);
        for (i = 0; i < src.length(); i++) {
            j = src.charAt(i);
            if (Character.isDigit(j) || Character.isLowerCase(j)
                    || Character.isUpperCase(j))
                tmp.append(j);
            else if (j < 256) {
                tmp.append("%");
                if (j < 16)
                    tmp.append("0");
                tmp.append(Integer.toString(j, 16));
            } else {
                tmp.append("%u");
                tmp.append(Integer.toString(j, 16));
            }
        }
        return tmp.toString();
    }

    public static void showlog(String logmsg){
        Log.d(aTag, logmsg);
    }

    public static void setPayUrl(String url){
        payurl = url;
        showlog("setPayUrl ==" + payurl);
    }

    public static void setServerId(int aid){
        Svrid = aid ;
        showlog("ServerId :"+Integer.toString(Svrid));
    }

    public static String getuuid(){
        showlog("uid javareturn: " + uuid);
        return uuid;
    }

    public static String getToken(){
        showlog("token javareturn: " + platformtoken);
        return platformtoken;
    }

    public void toPay(PayInfo pay_info) throws JSONException{

    }

    public void onShowProfile(){

    }

    /**
     * 回傳平台報告(1.註冊 2.登入遊戲)
     */
    public void Report_Handler(String msg){

    }

}
