package com.nuclear.gjwow;

import android.app.Activity;
import android.content.Context;
import com.nuclear.manager.MessageManager;
import com.nuclear.manager.MessageManager.MessageListener;
import com.guajibase.gamelib.R;
import android.widget.Toast;
public class VoiceChat  extends Activity{

	private static Context mContext;
	private static VoiceChat mInstance = null;

	private MessageListener listener = new MessageListener() {
		@Override
		public void registerMsg(){
			MessageManager.getInstance().setMsgHandler("playAudio",this);
			MessageManager.getInstance().setMsgHandler("startVoiceRecognition",this);

		}
		
		@Override
		public void unregisterMsg(){
			MessageManager.getInstance().removeMsgHandler("playAudio");
			MessageManager.getInstance().removeMsgHandler("startVoiceRecognition");

		}
		/**
		 * 语音识别
		 */
		public String startVoiceRecognition(String msg){
			ToastTipsInfo();
			return null;
		};
		public String playAudio(String msg){
			ToastTipsInfo();
			return null;
		};
	};
	
	private VoiceChat() {

	}

	public static VoiceChat getInstance() {
		if (mInstance == null) {
			mInstance = new VoiceChat();
		}
		return mInstance;

	}

	/**
	 * 初始化语音
	 * 
	 * @param context
	 */
	public void init(Context context) {
		mContext = context;
		listener.registerMsg();
	}
	/*
	 * 提示错误信息
	 */
	public	void ToastTipsInfo() {
		runOnUiThread(new Runnable() {
			@Override
			public void run() {
				try {
					//Toast.makeText(mContext,R.string.no_voice_tips, Toast.LENGTH_LONG).show();
				} catch (Exception e) {
				}
			}
			});
		
		
	}
}
