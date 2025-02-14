package com.nuclear.gjwow.platform;

import java.io.BufferedReader;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.UUID;

import chance.ninja.girl.R;

//import org.apache.http.HttpClientConnection;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Intent;
import android.net.Uri;
import android.os.Environment;
import android.util.Log;
import android.widget.Toast;

import com.nuclear.manager.MessageManager;
import com.nuclear.util.DeviceUtil;
import com.nuclear.util.LogUtil;
import com.nuclear.util.RSAUtil;
//import com.dosdk.share.FbFriend;
public class UidBindMange {
	
	private static final String TAG = UidBindMange.class.getSimpleName();
	
	static UidBindMange instance = new UidBindMange();
	private String mBindAddress = "";
	private String mQueryAddress = "";
	private String mDataTransferChangePwdAddress = "";
	private String mDataTransferAddress = "";
	public static UidBindMange getInstance(){
		return instance;
	}
	public boolean IsNeedInitUrl()
	{
		if(mBindAddress.equals("")||mQueryAddress.equals(""))
		{
			return true;
		}
		return false;
	}
	public void InitServerAddress(String strBindAddress,String strQueryAddress,String strDataTransferChangePwdAddress,String strDataTransferAddress)
	{
		mBindAddress = strBindAddress;
		mQueryAddress = strQueryAddress;
		mDataTransferChangePwdAddress = strDataTransferChangePwdAddress;
		mDataTransferAddress = strDataTransferAddress;
	}
	    //private static final String TAG = "uploadFile";
	    private static final int TIME_OUT = 10*1000;   //超时时间
	    private static final String CHARSET = "utf-8"; //设置编码
/**
 * android上传文件到服务器
 * @param filePath  需要上传的文件
 * @param RequestURL  请求的rul
 * @return  返回响应的内容
 */
    public	String uploadFile(String filePath,String RequestURL){
        String result = null;
        String  BOUNDARY =  UUID.randomUUID().toString();  //边界标识   随机生成
        String PREFIX = "--" , LINE_END = "\r\n"; 
        String CONTENT_TYPE = "multipart/form-data";   //内容类型
        File file = new File(filePath);
        try {
            URL url = new URL(RequestURL);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setReadTimeout(TIME_OUT);
            conn.setConnectTimeout(TIME_OUT);
            conn.setDoInput(true);  //允许输入流
            conn.setDoOutput(true); //允许输出流
            conn.setUseCaches(false);  //不允许使用缓存
            conn.setRequestMethod("POST");  //请求方式
            conn.setRequestProperty("Charset", CHARSET);  //设置编码
            conn.setRequestProperty("connection", "keep-alive");   
            conn.setRequestProperty("Content-Type", CONTENT_TYPE + ";boundary=" + BOUNDARY); 
            conn.connect();
            
            if(file!=null){
                /**
                 * 当文件不为空，把文件包装并且上传
                 */
                DataOutputStream dos = new DataOutputStream( conn.getOutputStream());
                StringBuffer sb = new StringBuffer();
                sb.append(PREFIX);
                sb.append(BOUNDARY);
                sb.append(LINE_END);
                /**
                 * 这里重点注意：
                 * name里面的值为服务器端需要key   只有这个key 才可以得到对应的文件
                 * filename是文件的名字，包含后缀名的   比如:abc.png  
                 */
                
                sb.append("Content-Disposition: form-data; name=\"img\"; filename=\""+file.getName()+"\""+LINE_END); 
                sb.append("Content-Type: application/octet-stream; charset="+CHARSET+LINE_END);
                sb.append(LINE_END);
                dos.write(sb.toString().getBytes());
                InputStream is = new FileInputStream(file);
                byte[] bytes = new byte[1024];
                int len = 0;
                while((len=is.read(bytes))!=-1){
                    dos.write(bytes, 0, len);
                }
                is.close();
                dos.write(LINE_END.getBytes());
                byte[] end_data = (PREFIX+BOUNDARY+PREFIX+LINE_END).getBytes();
                dos.write(end_data);
                dos.flush();
                /**
                 * 获取响应码  200=成功
                 * 当响应成功，获取响应的流  
                 */
                int res = conn.getResponseCode();  
                if(res==200){
                    InputStream input =  conn.getInputStream();
                    StringBuffer sb1= new StringBuffer();
                    int ss ;
                    while((ss=input.read())!=-1){
                        sb1.append((char)ss);
                    }
                    result = sb1.toString();
                }
            }
        } catch (MalformedURLException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return result;
}
	public void BindUid(String code, String gpid ,BindCallBack callback)
	{
		LogUtil.LOGE(TAG, "mBindAddress" + mBindAddress);
		if (mBindAddress.equals("")){
			callback.onError("mBindAddress is null");
			return ;
		}
		URL url = null;
		HttpURLConnection url_con = null;
		try {
			url  = new URL(mBindAddress);
			url_con = (HttpURLConnection) url.openConnection();
			url_con.setRequestMethod("POST");
			url_con.setDoOutput(true);  
			url_con.setDoInput(true);
			url_con.setConnectTimeout(15000);
			url_con.setReadTimeout(15000);
			String param = "googlePlayId=" + gpid+"&accode="+code;
			url_con.getOutputStream().write(param.getBytes());
			url_con.getOutputStream().flush();
			url_con.getOutputStream().close();
			
			LogUtil.LOGE(TAG, "bind uid:" + code);
			LogUtil.LOGE(TAG, "bind fbid:" + gpid);
			LogUtil.LOGE(TAG, "bind status" + url_con.getResponseCode());
			
			if (url_con.getResponseCode() == 200) {
				InputStream in = url_con.getInputStream();
				BufferedReader bufferRe = new BufferedReader(new InputStreamReader(in));
				StringBuffer sb = new StringBuffer("");
				String line = "";
				while ((line = bufferRe.readLine()) != null) {
					sb.append(line);
				}
				in.close();
				String tempStr = sb.toString();
				callback.onSuccess(tempStr);
			} else {
				callback.onError("network error!");
			}

		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			callback.onError("network error!");
			e.printStackTrace();
		} catch (ProtocolException e) {
			// TODO Auto-generated catch block
			callback.onError("network error!");
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			callback.onError("network error!");
			e.printStackTrace();
		}finally {
			if (url_con != null)
				url_con.disconnect();
		}
	}
	public void QueryUid(String puid,String gpid,BindCallBack callback)
	{
		
		LogUtil.LOGE(TAG, "mQueryAddress= :" + mQueryAddress);
		
		if (mQueryAddress.equals("")){
			callback.onError("mQueryAddress is null");
			return ;
		}
		URL url = null;
		HttpURLConnection url_con = null;
		try {
			url  = new URL(mQueryAddress);
			url_con = (HttpURLConnection) url.openConnection();
			url_con.setRequestMethod("POST");
			url_con.setDoOutput(true);  
			url_con.setDoInput(true);
			url_con.setConnectTimeout(3000);
			url_con.setReadTimeout(3000);
			String param = "dvid=" + puid+"&platform=android"+"&pid="+gpid;
			url_con.getOutputStream().write(param.getBytes());
			url_con.getOutputStream().flush();
			url_con.getOutputStream().close();
			LogUtil.LOGE("UidBindMange", "call mQueryAddress= :" + url_con.getURL());
			LogUtil.LOGW("UidBindMange", "QueryUidByFbID param:" + param);
			LogUtil.LOGW("UidBindMange", "QueryUidByFbID status" + url_con.getResponseCode());
			if (url_con.getResponseCode() == 200) {
				InputStream in = url_con.getInputStream();
				BufferedReader bufferRe = new BufferedReader(new InputStreamReader(in));
				StringBuffer sb = new StringBuffer("");
				String line = "";
				while ((line = bufferRe.readLine()) != null) {
					sb.append(line);
				}
				bufferRe.close();
				in.close();
				String tempStr = sb.toString();
				LogUtil.LOGE("UidBindMange", "QueryUidByFbID result = "+tempStr);
				
				
				callback.onSuccess(tempStr);
			} else {
				callback.onError("network error!");
			}

		} catch (MalformedURLException e) {
			// TODO Auto-generated catch block
			callback.onError("network error!");
			e.printStackTrace();
		} catch (ProtocolException e) {
			// TODO Auto-generated catch block
			callback.onError("network error!");
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			callback.onError("network error!");
			e.printStackTrace();
		}finally {
			if (url_con != null)
				url_con.disconnect();
		}
		
		/*
		 * HashMap 遍历
		 */
//		Map map = new HashMap();
//		Iterator iter =map.entrySet().iterator();
//		while(iter.hasNext()){
//			Map.Entry enter = (Map.Entry) iter.next();
//			String Key = (String) enter.getKey();
//			String value = (String) enter.getValue();
//		}
	}
	public void moveAccountEnter(String code,String pwd,String dvid,BindCallBack callback)
	{
		LogUtil.LOGE(TAG, "mDataTransferAddress" + mDataTransferAddress);
		LogUtil.LOGE(TAG, "code" + code);
		LogUtil.LOGE(TAG, "dvid" + pwd);
		if (mDataTransferAddress.equals("")){
			callback.onError("mDataTransferAddress is null");
			return ;
		}
		URL url = null;
		HttpURLConnection url_con = null;
		try {
			url  = new URL(mDataTransferAddress);
			url_con = (HttpURLConnection) url.openConnection();
			url_con.setRequestMethod("POST");
			url_con.setDoOutput(true);  
			url_con.setDoInput(true);
			url_con.setConnectTimeout(3000);
			url_con.setReadTimeout(3000);
			String param = "password=" + pwd + "&accode="+code+"&dvid="+dvid;
			url_con.getOutputStream().write(param.getBytes());
			url_con.getOutputStream().flush();
			url_con.getOutputStream().close();
			if (url_con.getResponseCode() == 200) {
				InputStream in = url_con.getInputStream();
				BufferedReader bufferRe = new BufferedReader(new InputStreamReader(in));
				StringBuffer sb = new StringBuffer("");
				String line = "";
				while ((line = bufferRe.readLine()) != null) {
					sb.append(line);
				}
				bufferRe.close();
				in.close();
				String tempStr = sb.toString();
				

				String result[] = tempStr.split("\\|");
				if(result[0].equals("1")){//移行成功
					LogUtil.LOGE(TAG, "moveAccountEnter - callback strCode = "+code);
					DeviceUtil.SetAccountId(code);
				}
				
				
				LogUtil.LOGE("UidBindMange", "moveAccountEnter result = "+tempStr);
				callback.onSuccess(tempStr);
			} else {
				callback.onError("network error!");
			}
		} catch (MalformedURLException e) {
			callback.onError("network error!");
			e.printStackTrace();
		} catch (ProtocolException e) {
			callback.onError("network error!");
			e.printStackTrace();
		} catch (IOException e) {
			callback.onError("network error!");
			e.printStackTrace();
		}finally {
			if (url_con != null)
				url_con.disconnect();
		}
	}
	public void changePassWord(String code,String pwd,BindCallBack callback)
	{
		LogUtil.LOGE("PlatformSDKActivity", "----mDataTransferChangePwdAddress" + mDataTransferChangePwdAddress);
		if (mDataTransferChangePwdAddress.equals("")){
			callback.onError("mDataTransferChangePwdAddress is null");
			return ;
		}
		URL url = null;
		HttpURLConnection url_con = null;
		try {
			url  = new URL(mDataTransferChangePwdAddress);
			url_con = (HttpURLConnection) url.openConnection();
			url_con.setRequestMethod("POST");
			url_con.setDoOutput(true);  
			url_con.setDoInput(true);
			url_con.setConnectTimeout(3000);
			url_con.setReadTimeout(3000);
			String param = "password=" + pwd + "&accode="+code;
			url_con.getOutputStream().write(param.getBytes());
			url_con.getOutputStream().flush();
			url_con.getOutputStream().close();
			LogUtil.LOGW("UidBindMange", "changePassWord param:" + param);
			LogUtil.LOGW("UidBindMange", "changePassWord status" + url_con.getResponseCode());
			if (url_con.getResponseCode() == 200) {
				InputStream in = url_con.getInputStream();
				BufferedReader bufferRe = new BufferedReader(new InputStreamReader(in));
				StringBuffer sb = new StringBuffer("");
				String line = "";
				while ((line = bufferRe.readLine()) != null) {
					sb.append(line);
				}
				bufferRe.close();
				in.close();
				String tempStr = sb.toString();
				LogUtil.LOGE("UidBindMange", "changePassWord result = "+tempStr);
				callback.onSuccess(tempStr);
			} else {
				callback.onError("network error!");
			}
		} catch (MalformedURLException e) {
			callback.onError("network error!");
			e.printStackTrace();
		} catch (ProtocolException e) {
			callback.onError("network error!");
			e.printStackTrace();
		} catch (IOException e) {
			callback.onError("network error!");
			e.printStackTrace();
		}finally {
			if (url_con != null)
				url_con.disconnect();
		}
	}
}
