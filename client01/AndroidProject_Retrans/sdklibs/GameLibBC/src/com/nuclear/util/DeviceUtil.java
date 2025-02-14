package com.nuclear.util;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.text.DecimalFormat;
import java.util.Properties;
import java.util.UUID;
import java.util.regex.Pattern;

import android.content.Context;
import android.os.Build;
import android.os.Environment;
import android.provider.Settings.Secure;
import android.telephony.TelephonyManager;
import android.text.TextUtils;
import android.util.Log;

public class DeviceUtil {

	private static final String TAG = DeviceUtil.class.getSimpleName();
	
	public static String getDeviceId(Context context) {
//		TelephonyManager telephonyManager = (TelephonyManager) context
//				.getSystemService(Context.TELEPHONY_SERVICE);
//		String imei = telephonyManager.getDeviceId();
//		if (!TextUtils.isEmpty(imei)) {
//			return imei;
//		} else {
//			String androidId = Secure.getString(context.getContentResolver(),
//					Secure.ANDROID_ID);
//			return androidId;
//		}
		
		String androidId = "";
		androidId = Secure.getString(context.getContentResolver(),Secure.ANDROID_ID);
		if(androidId.equals("9774d56d682e549c")){
			androidId = generateUUID();
			if (TextUtils.isEmpty(androidId) || "".equals(androidId) ) 
			{
				androidId = getUniquePsuedoID();
			}
		}
		return androidId;
	}

	/*
	 * 
	 * */
	public static String generateUUID() {
		return UUID.randomUUID().toString();
	}

	/*
	 * 
	 * */
	public static String getDeviceProductName(Context context) {

		String temp = Build.MODEL.replaceAll(" ", "-");
		return Build.MANUFACTURER + "_" + temp;
	}
	
	public static String getAccountId() {
		String accountid = "";
		LogUtil.LOGE(TAG, "-getDeviceFromFileUUID----step2");
		
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + "/tigerto/account_tiger.properties");
		if (uFile.exists()) {
			LogUtil.LOGE(TAG, "-getDeviceFromFileUUID----step3");
			Properties cfgIni = new Properties();
			try {
				cfgIni.load(new FileInputStream(uFile));
				accountid = cfgIni.getProperty("accountid", null);
				LogUtil.LOGE(TAG, "-getDeviceFromFileUUID----step4" + accountid);
			} catch (FileNotFoundException e) {

			} catch (IOException e) {

			}
			cfgIni = null;
			if (accountid != null && !("".equals(accountid))) {
				uFile = null;
				Log.w(TAG, accountid);
				return accountid;
			}
		} 
		return accountid;
	}
	public static void  SetAccountId(String  AccountID)
	{
		
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + "/tigerto/account_tiger.properties");
		
		Properties cfgIni = new Properties();
		cfgIni.setProperty("accountid", AccountID);
		
		LogUtil.LOGE(TAG, "SetAccountId ---accountid---" + AccountID);
		
		try {
			cfgIni.store(new FileOutputStream(uFile),
					"auto save, default none str");
		} catch (FileNotFoundException e) {

			LogUtil.LOGE(TAG, "SetAccountId accountid---step2");
			
		} catch (IOException e) {

			LogUtil.LOGE(TAG, "SetAccountId accountid---step3");
		}
		//
		cfgIni = null;
	}
	
	public static void  SetDeviceID(String  uuid)
	{
		
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + "/tigerto/uuid_tiger.properties");
		
		Properties cfgIni = new Properties();
		cfgIni.setProperty("uuid", uuid);
		
		LogUtil.LOGE(TAG, "SetDeviceID ---uuid---" + uuid);
		
		try {
			cfgIni.store(new FileOutputStream(uFile),
					"auto save, default none str");
		} catch (FileNotFoundException e) {

			LogUtil.LOGE(TAG, "SetDeviceID uuid---step2");
			
		} catch (IOException e) {

			LogUtil.LOGE(TAG, "SetDeviceID uuid---step3");
		}
		//
		cfgIni = null;
	}
	
	/*
	 * 
	 * */
	public static String getDeviceFromFileUUID(Context context) {
		String uuid = "";
		LogUtil.LOGE(TAG, "-getDeviceFromFileUUID----step2");
		
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + "/tigerto/uuid_tiger.properties");
		if (uFile.exists()) {
			LogUtil.LOGE(TAG, "-getDeviceFromFileUUID----step3");
			Properties cfgIni = new Properties();
			try {
				cfgIni.load(new FileInputStream(uFile));
				uuid = cfgIni.getProperty("uuid", null);
				LogUtil.LOGE(TAG, "-getDeviceFromFileUUID----step4" + uuid);
			} catch (FileNotFoundException e) {

			} catch (IOException e) {

			}
			cfgIni = null;
			if (uuid != null && !("".equals(uuid))) {
				uFile = null;
				Log.w(TAG, uuid);
				return uuid;
			}
		} else {
			Properties cfgIni = new Properties();
			cfgIni.setProperty("uuid", "");
			
			LogUtil.LOGE(TAG, "-getDeviceUUID----step4" + uuid);
			
			
			try {
				cfgIni.store(new FileOutputStream(uFile),
						"auto save, default none str");
			} catch (FileNotFoundException e) {

			} catch (IOException e) {

			}
			//
			cfgIni = null;
		}
		
		 uuid = getUniquePsuedoID();
		 
	     if(uuid.equals("")){
				
			uuid = Secure.getString(context.getContentResolver(),Secure.ANDROID_ID);
			
			if (TextUtils.isEmpty(uuid)) 
			{
				uuid = generateUUID();
			}
			
		}
		Properties cfgIni = new Properties();
		cfgIni.setProperty("uuid", uuid);
			
		try {
			cfgIni.store(new FileOutputStream(uFile), "auto save, generateUUID");
		} catch (FileNotFoundException e) {

		} catch (IOException e) {

		}
		uFile = null;
		cfgIni = null;
		Log.w("getDeviceUUID", uuid);
		return uuid;
	}
	
	/*
	 * 
	 * */
	public static String getDeviceUUID(Context context) {
		String uuid = "";
		LogUtil.LOGE(TAG, "-getDeviceUUID----step2");
		
		File uFile = new File(Environment.getExternalStorageDirectory()
				.getAbsoluteFile() + "/tigerto/uuid_tiger.properties");
		if (uFile.exists()) {
			LogUtil.LOGE(TAG, "-getDeviceUUID----step3");
			Properties cfgIni = new Properties();
			try {
				cfgIni.load(new FileInputStream(uFile));
				uuid = cfgIni.getProperty("uuid", null);
				LogUtil.LOGE(TAG, "-getDeviceUUID----step4" + uuid);
			} catch (FileNotFoundException e) {

			} catch (IOException e) {

			}
			cfgIni = null;
			if (uuid != null && !("".equals(uuid))) {
				uFile = null;
				Log.w(TAG, uuid);
				return uuid;
			}
		} else {
			Properties cfgIni = new Properties();
			cfgIni.setProperty("uuid", "");
			try {
				cfgIni.store(new FileOutputStream(uFile),
						"auto save, default none str");
			} catch (FileNotFoundException e) {

			} catch (IOException e) {

			}
			//
			cfgIni = null;
		}
		uuid = getUniquePsuedoID();
		 
		if(uuid.equals("")){
			
		    uuid = Secure.getString(context.getContentResolver(),Secure.ANDROID_ID);
			if (TextUtils.isEmpty(uuid)) 
			{
				uuid = generateUUID();
			}
			
		}
		Properties cfgIni = new Properties();
		cfgIni.setProperty("uuid", uuid);
	
		try {
			cfgIni.store(new FileOutputStream(uFile), "auto save, generateUUID");
		} catch (FileNotFoundException e) {

		} catch (IOException e) {

		}
		uFile = null;
		cfgIni = null;
		Log.w(TAG, uuid);
		return uuid;
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
	
	public static String getTotalMemory(Context context) {
		String str1 = "/proc/meminfo";// 系统内存信息文件
		String str2;
		String[] arrayOfString;
		double initial_memory = 0;
		DecimalFormat df = null;
		try {
			FileReader localFileReader = new FileReader(str1);

			BufferedReader localBufferedReader = new BufferedReader(
					localFileReader, 8192);
			str2 = localBufferedReader.readLine();
			if (str2 == null) {
				localBufferedReader.close();
				return "";
			}
			arrayOfString = str2.split("\\s+");
			for (String num : arrayOfString) {
				Log.i(str2, num + "\t");
			}

			initial_memory = Integer.valueOf(arrayOfString[1]).intValue() / 1024;// *
			initial_memory = initial_memory / 1024;
			df = new DecimalFormat("##.##");

			localBufferedReader.close();

		} catch (Exception e) {
			return "";
		}
		return df.format(initial_memory);// String.valueOf(initial_memory);//Formatter.formatFileSize(getBaseContext(),
											// initial_memory);//
		// return Formatter.formatFileSize(getBaseContext(), initial_memory);
	}

	public static int getNumCores() {
		// Private Class to display only CPU devices in the directory listing
		class CpuFilter implements FileFilter {
			@Override
			public boolean accept(File pathname) {
				// Check if filename is "cpu", followed by a single digit number
				if (Pattern.matches("cpu[0-9]", pathname.getName())) {
					return true;
				}
				return false;
			}
		}

		try {
			// Get directory containing CPU info
			File dir = new File("/sys/devices/system/cpu/");
			if (dir.exists()) {
				// Filter to only list the devices we care about
				File[] files = dir.listFiles(new CpuFilter());
				Log.d(TAG, "CPU Count: " + files.length);
				// Return the number of cores (virtual CPU devices)
				return files.length;
			} else {
				return 1;
			}
		} catch (Exception e) {
			// Print exception
			Log.d("MainActivity", "CPU Count: Failed.");
			e.printStackTrace();
			// Default to return 1 core
			return 1;
		}
	}

	public static String getMaxCpuFreq() {
		String result = "";
		ProcessBuilder cmd;
		try {
			String[] args = { "/system/bin/cat",
					"/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq" };
			cmd = new ProcessBuilder(args);
			Process process = cmd.start();
			InputStream in = process.getInputStream();
			byte[] re = new byte[24];
			while (in.read(re) != -1) {
				result = result + new String(re);
			}
			in.close();
		} catch (Exception ex) {
			ex.printStackTrace();
			result = ""; // 1.5 1572864
		}
		return result.trim();
	}
}
