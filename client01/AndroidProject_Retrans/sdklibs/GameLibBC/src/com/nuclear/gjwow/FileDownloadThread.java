package com.nuclear.gjwow;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.net.URL;
import java.net.URLConnection;

import android.util.Log;


public class FileDownloadThread extends Thread {
	private static final String TAG = "FileDownloadThread";
	private static final int BUFFER_SIZE = 2 * 1024;
	
	
//	private int startPosition;
//	private int endPosition;
//	private int curPosition;
	//用于标识当前线程是否下载完成
	
	private int downloadSize = 0;
	private boolean isFinished = false;
	private boolean isCancel = false;
	
	private String fileId;
	private String fileUrl;
	private String filePath;
//	private FileRes fileRes;
	private OnDownloadListener downloadListener;
	private int callback;
	private boolean isProgressCallback = false;
	
	private URLConnection con = null;
	private BufferedInputStream bis = null;
	private FileOutputStream fos = null;
//	private RandomAccessFile fos = null;   
	
    private int connectCount = 0;
	/**
	 * @param fileId 文件的id(或包名)，用来区分哪个文件
	 * @param fileUrl 文件的下载url
	 * @param filePath 文件的保存路径
	 * @param //DownloadListener 下载过程的回调接口
	 * @param callback 回调参数(可选)，可以是项的索引或根据fileId回调
	 */
	public FileDownloadThread(String fileId, String fileUrl, String filePath, OnDownloadListener listener, int callback){
		Log.d(TAG, "FileDownloadThread fileUrl:" + fileUrl);
		Log.d(TAG, "FileDownloadThread filePath:" + filePath);
		if(filePath!=null && filePath.lastIndexOf("/")!=-1){
			try{
				File file = new File(filePath.substring(0, filePath.lastIndexOf("/")));
				if(!file.exists()){
					boolean bl = file.mkdirs();
					Log.d(TAG, "" + bl);
				}
				this.fileId = fileId;
				this.fileUrl = fileUrl;
				this.filePath = filePath;
				this.downloadListener = listener;
				this.callback = callback;
				if (listener == null) {
					isProgressCallback = false;
				}
			}catch(Exception e){
				if(listener!=null){
					listener.onDownloadFinished(-1, fileId, filePath, callback);
				}
			}
		}else{
			if(listener!=null){
				listener.onDownloadFinished(-1, fileId, filePath, callback);
			}
		}
	}
	
	/**
	 * 当使用wap网络是，设置代理
	 */
//	private Proxy getProxy(){
//		Proxy proxy = new Proxy(java.net.Proxy.Type.HTTP, new InetSocketAddress(AppData.proxyStr, 80));
//		return proxy;
//	}
	
	@Override
	public void run() {
		connectCount++;
                                                    
        byte[] buff = new byte[BUFFER_SIZE];
        
        try {
        	URL url = new URL(fileUrl);
//        	if(AppData.isNeedProxy){
//        		con = url.openConnection(getProxy());//设置代理
//        	}else{
        		con = url.openConnection();
//        	}
            con.setAllowUserInteraction(true);
//            conn.setRequestMethod("GET");
            con.setConnectTimeout(6 * 1000);
            //设置当前线程下载的起点，终点
//            con.setRequestProperty("Range", "bytes=" + startPosition + "-" + endPosition);
            //使用java中的RandomAccessFile 对文件进行随机读写操作
            File file = new File(filePath);
            fos = new FileOutputStream(file);
//            fos = new RandomAccessFile(file, "rw");
            //设置开始写文件的位置
//            fos.seek(startPosition);
            int contentLength = con.getContentLength();
            int baseSize = 20 * 1024;
            int notifySize = baseSize;
        	int newSize = 0;
            if (contentLength > 0) {
            	notifySize = Math.min(contentLength / 20, baseSize);
            }
//            T.debug(TAG, "runContentLength:" + contentLength);
            downloadSize = 0;
            isFinished = false;
            isCancel = false;
            
            bis = new BufferedInputStream(con.getInputStream());  
            int len = -1;
            //开始循环以流的形式读写文件
            while ((len = bis.read(buff)) != -1) { //curPosition < endPosition
            	if (isCancel) {
            		return;
            	}
//                fos.write(buff, 0, len);
                fos.write(buff, 0, len);
                downloadSize += len;
                	
                if (isProgressCallback) {
                	newSize += len;
                	if (newSize > notifySize) {
                		newSize = 0;
                		if(downloadListener!=null){
                			downloadListener.onDownloadProgress(fileId, contentLength, downloadSize, callback);
                		}
                	}
            	}
            }
            //下载完成设为true
            isFinished = true;
            if (downloadListener != null) {
            	downloadListener.onDownloadFinished(1, fileId, filePath, callback);
            }
            Log.d(TAG, "run:downloadSuccess--------:" + downloadSize);
        } catch (Exception e) {
        	closeConnect();
//          	T.debug(TAG, "runExc:" + e.toString());
//        	e.printStackTrace();
        	Log.w(TAG, "error:" + e.getMessage());
          	if (connectCount < 3) {
          		run();
          	} else {
          		if(downloadListener!=null){
          			downloadListener.onDownloadFinished(-1, fileId, filePath, callback);
          		}
          	}
        } finally {
        	closeConnect();
        }
	}
 
	private void closeConnect() {
		try {
			if(fos != null){
				fos.close();
				fos = null;
			}
			if(bis != null){
				bis.close();
				bis = null;
			}
//			if(con != null){
//				con.;
//				baos = null;
//			}
//			if(hc != null){
//				hc.disconnect();
//				hc = null;
//			}				
		} catch(Exception e) {
			Log.d(TAG, "closeConnectExc:" + e.toString());
		}
	}
	
	/**
	 * 设置下载过程中是否需要回调，默认true，会回调
	 * @param isProgressCallback
	 */
	public void setProgressCallback(boolean isProgressCallback) {
		this.isProgressCallback = isProgressCallback;
	}
	
	/**
	 * @return 是否下载完成
	 */
	public boolean isFinished(){
		return isFinished;
	}
 
	/**
	 * @return 已下载字节大小
	 */
	public int getDownloadSize() {
		return downloadSize;
	}

	/**
	 * 取消下载
	 */
	public void cancel() {
		isCancel = true;
	}
	
	public interface OnDownloadListener {
		/**
		 * @param fileId 文件的id(或包名)，用来区分哪个文件
		 * @param totalSize 文件的总大小
		 * @param downloadedSize 已下载的文件大小
		 * @param callback 可以是项的索引
		 */
		public void onDownloadProgress(String fileId, int totalSize, int downloadedSize, int callback);
		/**
		 * @param state -4暂停，-3取消，-2超时，-1失败，1下载成功，2正在下载
		 * @param fileId 文件的id(或包名)，用来区分哪个文件
		 * @param filePath 下载后的文件路径
		 * @param callback 可以是项的索引
		 */
		public void onDownloadFinished(int state, String fileId, String filePath, int callback);
	}
}
