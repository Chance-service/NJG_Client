/****************************************************************************
Copyright (c) 2010-2013 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 ****************************************************************************/
package org.cocos2dx.lib;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import org.cocos2dx.lib.Cocos2dxHelper.Cocos2dxHelperListener;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ApplicationInfo;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.WindowManager;



public abstract class Cocos2dxActivity extends Activity implements
		Cocos2dxHelperListener
{
	
	// ===========================================================
	// Constants
	// ===========================================================
	
	private static final String		TAG											= Cocos2dxActivity.class
																						.getSimpleName();
	//
	
	// ===========================================================
	// Fields
	// ===========================================================
	
	//public Cocos2dxEditBoxDialog  _Cocos2dxEditBoxDialog;
	
	public Cocos2dxGLSurfaceView	mGLSurfaceView;
	private Cocos2dxHandler			mHandler;
	public Handler 				mGameAppStateHandler;
	private static Context			sContext									= null;
	//
	protected boolean				mIsCocos2dxSurfaceViewCreated				= false;
	protected boolean				mIsRenderCocos2dxView						= false;
	//
	public String					mAppDataExternalStorageFullPath				= null;
	public String					mAppDataExternalStorageResourcesFullPath	= null;
	public String					mAppDataExternalStorageCacheFullPath		= null;
	
	//
	protected boolean				mIsOnPause									= false;
	/*
	 * 当短暂打开平台界面、截屏分享，本Activity被系统置后而Pause，渲染和声音可以暂停，但网络不断，免得重连
	 */
	protected boolean				mIsTempShortPause							= false;
	private long 					mLastLowMemoryNanoTime						= System.nanoTime();
	
	//
	public void SetCocos2dxEditDialog(Cocos2dxEditBoxDialog _Cocos2dxEditBoxDialog)
	{
		//this._Cocos2dxEditBoxDialog = _Cocos2dxEditBoxDialog;
	}
	public static Context getContext()
	{
		return sContext;
	}
	
	public View getCocos2dxGLSurfaceView()
	{
		return mGLSurfaceView;
	}
	
	/*
	 * 启动Activity的UI线程为进程的主线程；操作Activity的UI必须通过对其Handler发消息
	 */
	public Handler getMainThreadHandler()
	{
		return mHandler;
	}
	
	// ===========================================================
	// Constructors
	// ===========================================================
	
	@Override
	protected void onCreate(final Bundle savedInstanceState)
	{
		
		Log.d(TAG, "2		call Cocos2dxActivity.onCreate");
		
		super.onCreate(savedInstanceState);
		
		// 保持屏幕长亮
		getWindow().setFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
				WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
		
		sContext = this;
		
		/*
		 * UI线程即主线程
		 * */
		this.mHandler = new Cocos2dxHandler(this);
		
		
	}
	
	@Override
	protected void onDestroy()
	{
		super.onDestroy();
		Log.d(TAG, "call Cocos2dxActivity.onDestroy");
		//
		if (mIsCocos2dxSurfaceViewCreated)
		{
			Cocos2dxHelper.onPause();
			this.mGLSurfaceView.onPause();
			//
			Cocos2dxHelper.nativeGameDestroy();	// 屏蔽for
												// testin，因为退出崩溃会被testin记录影响报告
		}
		//
		mIsCocos2dxSurfaceViewCreated = false;
		// 结束静态引用的生命周期
		Cocos2dxActivity.sContext = null;
		//
		// System.exit(0);//子类重写了onDestroy
	}
	
	// ===========================================================
	// Getter & Setter
	// ===========================================================
	
	// ===========================================================
	// Methods for/from SuperClass/Interfaces
	// ===========================================================
	
	@Override
	protected void onRestart()
	{
		
		Log.d(TAG, "call Cocos2dxActivity.onRestart");
		super.onRestart();
		
	}
	
	@Override
	protected void onResume()
	{
		
		Log.d(TAG, "call Cocos2dxActivity.onResume");
		
		super.onResume();
		//
		if (mIsCocos2dxSurfaceViewCreated && mIsRenderCocos2dxView && mIsOnPause)
		{
			mIsOnPause = false;
			mIsTempShortPause = false;
			//
			Cocos2dxHelper.onResume();
			Cocos2dxHelper.resumeBackgroundMusic();
			Cocos2dxHelper.resumeAllEffects();
//			this.mGLSurfaceView.onResume();
			//
			if (mGameAppStateHandler != null)
			{
				mGameAppStateHandler
					.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnActivityResume);
			}
		}
		mIsRenderCocos2dxView = true;
		//
	}
	
	@Override
	protected void onPause()
	{
		
		Log.d(TAG, "call Cocos2dxActivity.onPause");
		
		super.onPause();
		//
		if (mIsCocos2dxSurfaceViewCreated && mIsRenderCocos2dxView && !mIsOnPause)
		{
			mIsOnPause = true;
			//
			if (mGameAppStateHandler != null)
			{
				mGameAppStateHandler
					.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnActivityPause);
			}
			//
			//this.mGLSurfaceView.onPause();
			Cocos2dxHelper.onPause();
			Cocos2dxHelper.pauseBackgroundMusic();
			Cocos2dxHelper.pauseAllEffects();
		}

		//
		
	}
	
	@Override
	protected void onStart()
	{
		
		Log.d(TAG, "call Cocos2dxActivity.onStart");
		
		super.onStart();
		//
		if (mIsCocos2dxSurfaceViewCreated && mIsRenderCocos2dxView && mIsOnPause)
		{
			mIsOnPause = false;
			mIsTempShortPause = false;
			//
			Cocos2dxHelper.onResume();
			this.mGLSurfaceView.onResume();
			//
			if (mGameAppStateHandler != null)
			{
				mGameAppStateHandler
					.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnActivityResume);
			}
		}
		mIsRenderCocos2dxView = true;
		//
		
	}
	
	@Override
	protected void onStop()
	{
		
		Log.d(TAG, "call Cocos2dxActivity.onStop");
		
		super.onStop();
		//
		if (mIsCocos2dxSurfaceViewCreated && mIsRenderCocos2dxView && !mIsOnPause)
		{
			mIsOnPause = true;
			
			if (mGameAppStateHandler != null)
			{
				mGameAppStateHandler
					.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnActivityPause);
			}
			//
			Cocos2dxHelper.onPause();
			this.mGLSurfaceView.onPause();
		}
		//
		if(mIsOnPause)
		{
			this.mGLSurfaceView.onPause();
		}
		
	}
	
	@Override
	// Cocos2dxGLSurfaceView劫走传到Native先处理onKeyDown并且返回true中断了Event
	public boolean onKeyDown(int keyCode, KeyEvent event)
	{
		
		if (keyCode == KeyEvent.KEYCODE_BACK)
		{
			Log.e("cocos2dxDialog", "---closeKeyboard---KEYCODE_BACK----");
//			if (_Cocos2dxEditBoxDialog != null) {
//				_Cocos2dxEditBoxDialog.closeKeyboard();
//			}
		
			if (Cocos2dxHelper.nativeHasEnterMainFrame())
		      {
		        //Cocos2dxHelper.nativeAskLogoutFromMainFrameToLoadingFrame();
		        return true;
		      }
			return true;
		}
		if (keyCode == KeyEvent.KEYCODE_MENU)
		{
			Log.e("cocos2dxDialog", "---closeKeyboard---KEYCODE_MENU----");
//			if (_Cocos2dxEditBoxDialog != null) {
//				_Cocos2dxEditBoxDialog.closeKeyboard();
//			}
			super.onKeyDown(keyCode, event);
			return true;
		}
		
		return super.onKeyDown(keyCode, event);
	}
	
	@Override
	public void showDialog(final String pTitle, final String pMessage,
			final int msgId, final String positiveCallback)
	{
		String uniqueActionString = "com.hutuo.message.broadcast";
	    Intent intent = new Intent(uniqueActionString);
	    intent.putExtra("pTitle", pTitle);
	    intent.putExtra("pMessage", pMessage);
	    sContext.sendBroadcast(intent);
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_SHOW_DIALOG;
		msg.obj = new Cocos2dxHandler.DialogMessage(pTitle, pMessage, msgId,
				positiveCallback, "");
		//this.mHandler.sendMessage(msg);
		mGameAppStateHandler.sendMessage(msg);
	}
	
	@Override
	public void showQuestionDialog(final String pTitle, final String pMessage,
			final int msgId, final String positiveCallback,
			final String negativeCallback)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_SHOW_QUESTION_DIALOG;
		msg.obj = new Cocos2dxHandler.DialogMessage(pTitle, pMessage, msgId,
				positiveCallback, negativeCallback);
		this.mHandler.sendMessage(msg);
	}
	
	@Override
	public void showEditTextDialog(final String pTitle, final String pContent,
			final int pInputMode, final int pInputFlag, final int pReturnType,
			final int pMaxLength)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_SHOW_EDITBOX_DIALOG;
		msg.obj = new Cocos2dxHandler.EditBoxMessage(pTitle, pContent,
				pInputMode, pInputFlag, pReturnType, pMaxLength);
		this.mHandler.sendMessage(msg);
	}
	public void setEditBoxText(String pText)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.SET_SHOW_EDITBOX_DIALOG_TEXT;
		msg.obj = pText;
		this.mHandler.sendMessage(msg);
	}
	
	@Override
	public void runOnGLThread(final Runnable pRunnable)
	{
		this.mGLSurfaceView.queueEvent(pRunnable);
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
	
	
	@Override
	public void callPlatformLogin()
	{
		//uncompressTTFFile();
		mGameAppStateHandler
				.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformLogin);
	}
	
	@Override
	public void callPlatformToken()
	{
		mGameAppStateHandler
		.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformToken);
	}
	
	@Override
	public void callPlatformPlayMovie(String fileName, int isLoop, int autoScale)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPlayMovie;
		msg.obj = fileName;
		msg.arg1 = isLoop;
		msg.arg2 = autoScale;
		//this.mHandler.sendMessage(msg);
		mGameAppStateHandler.sendMessage(msg);
		//mGameAppStateHandler
		//		.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPlayStoryMovie);
	}
	@Override
	public void callPlatformCloseMovie()
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformCloseMovie;
		mGameAppStateHandler.sendMessage(msg);
	}
	@Override
	public void callPlatformPauseMovie()
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPauseMovie;
		//this.mHandler.sendMessage(msg);
		mGameAppStateHandler.sendMessage(msg);
		//mGameAppStateHandler
		//		.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPlayStoryMovie);
	}
	@Override
	public void callPlatformResumeMovie()
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformResumeMovie;
		mGameAppStateHandler.sendMessage(msg);
	}
	
	@Override
	public void callPlatformLogout()
	{
		mGameAppStateHandler
				.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformLogout);
	}
	
	@Override
	public void callPlatformAccountManage()
	{
		mGameAppStateHandler
				.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformAccountManage);
	}
	
	@Override
	public void callPlatformPayRecharge(int productType, String name, String serial, String productId,
			String productName, float price, float orignalPrice, int count,
			String description,int serverTime,String extras)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformPayRecharge;
		msg.obj = new Cocos2dxHandler.PayRechargeMessage(productType,name ,serial, productId,
				productName, price, orignalPrice, count, description,serverTime,extras);
		mGameAppStateHandler.sendMessage(msg);
	}
	
	@Override
	public boolean getPlatformLoginStatus()
	{
		return true;
	}
	
	@Override
	public String getPlatformLoginUin()
	{
		return "";
	}
	
	@Override
	public String getPlatformToken()
	{
		return "";
	}

	@Override
	public void showPlatformProfile()
	{

	}
	
	@Override
	public String getPlatformLoginSessionId()
	{
		return "";
	}
	
	@Override
	public String getPlatformUserNickName()
	{
		return "";
	}

	public void callPlatformInit()
	{
		/*
		 * xinzheng 2013-06-21 按重构方案，在Android系统，不是Game.so发起这个
		 * */
		//this.mHandler
		//		.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformInit);
	}
	
	//
	@Override
	public String generateNewOrderSerial()
	{
		return null;
	}
	
	@Override
	public void callPlatformFeedback()
	{
		mGameAppStateHandler
				.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformFeedback);
	}
	
	@Override
	public void callPlatformSupportThirdShare(String content, String imgPath)
	{
		Message msg = new Message();
		msg.what = Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformThirdShare;
		msg.obj = new Cocos2dxHandler.ShareMessage(content, imgPath);
		mGameAppStateHandler.sendMessage(msg);
	}
	
	@Override
	public void callPlatformGameBBS(String url)
	{
		mGameAppStateHandler
			.sendEmptyMessage(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_CallPlatformBBS);
	}
	
	public boolean getIsDebug()
	{
		try {
			ApplicationInfo info = sContext.getApplicationInfo();
			return (info.flags & ApplicationInfo.FLAG_DEBUGGABLE) != 0;
		} catch (Exception e) {

		}
		return false;
	}
	
	@SuppressLint("NewApi") public void openUrlOutside(String url)
	{
		if (url.isEmpty())
			return;
		//
		mIsTempShortPause = true;
		//
		Uri uri = Uri.parse(url);
		Intent it = new Intent(Intent.ACTION_VIEW, uri);
		startActivity(it);
	}
	
	public void showWaitingView(boolean show, int progress, String text)
	{
		if (mGameAppStateHandler != null)
		{
			Message msg = new Message();
			msg.what = Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_ShowWaitingView;
			msg.obj = new Cocos2dxHandler.ShowWaitingViewMessage(show, progress,
					text);
			mGameAppStateHandler.sendMessage(msg);
		}
	}
	
	//
	// ===========================================================
	// Methods
	// ===========================================================
	public void initAndroidContext(View glView, View editText)
	{
		
		/*
		 * 注意子类Activity先调用了initAppDataPath
		 * */
		/*
		 * Music/Sound/Accelerometer
		 * */
		Cocos2dxHelper.init(this, this, this.mAppDataExternalStorageFullPath);
		
		/*
		 * GL Context/GL SurfaceView
		 * */
		this.mGLSurfaceView = (Cocos2dxGLSurfaceView)glView;
        /*
         * */
        this.mGLSurfaceView.setCocos2dxEditText((Cocos2dxEditText)editText);
        /*
         * */
        
	}
	
	protected void setOnTempShortPause(boolean pause)
	{
		mIsTempShortPause = pause;
		//mIsRenderCocos2dxView = !pause;
		
		Log.d(TAG, "mIsTempShortPause: " + String.valueOf(pause));
	}
	//handler提前设置 因为用到了 退出游戏任何地方都会用到这个回调
	protected void setGameAppStateHandler(Handler handler)
	{
		mGameAppStateHandler = handler;
	}
	//和mGameAppStateHandler分开赋值，数据初始化完毕后再设置，否则在未初始化的情况下 会导致空指针
	protected void setGameAppState()
	{
		mIsCocos2dxSurfaceViewCreated = true;
		mIsRenderCocos2dxView = true;
	}
	
	public void onTimeToShowCocos2dxContentView()
	{
		// to Override at subclass
	}
	
	protected void destroy() {
		
		if (mGameAppStateHandler != null)
			mGameAppStateHandler.removeMessages(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnActivityPause);
		mGameAppStateHandler = null;
		// to Override at subclass
		//子类集成第三方SDK后，单单finish本Activity并不能发起销毁进程
		//子类finish其他activity
		super.finish();
	}
	
	public void showToastMsgImp(String msg)
	{
		
	}
	
	@Override
	public void onLowMemory()
	{
		if (mIsCocos2dxSurfaceViewCreated)
		{
			final long timestamp = System.nanoTime();
			final long timedelt = 6*60*1000*1000*1000;
			if ((timestamp-this.mLastLowMemoryNanoTime) > timedelt)
			{
				//this.showDialog("提示", "可用内存不足，正在尝试回收，请稍后！", 
				//		Cocos2dxHandler.bsDialogMsgId_Cocos2dxActivity_OnLowMemory, "");
				//Cocos2dxHelper.nativePurgeCachedData();//在显示提示框后开始长时间的这个操作，且应该runOnGLThread
				mHandler.sendEmptyMessageDelayed(Cocos2dxHandler.HANDLER_MSG_TO_MAINTHREAD_OnLowMemory, 1000);
				//
				this.mLastLowMemoryNanoTime = timestamp;
			}
		}
		
		super.onLowMemory();
	}
	
	public void onLowMemoryImp()
	{
		this.runOnGLThread(new Runnable()
		{

			@Override
			public void run() {
				
				Cocos2dxHelper.nativePurgeCachedData();
			}
			
		});
	}
	
	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================
}
