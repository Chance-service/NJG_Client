package com.nuclear.state;

import org.cocos2dx.lib.Cocos2dxHelper;

import android.os.Handler;
import android.view.View;
import android.widget.ProgressBar;
import android.widget.TextView;

import com.nuclear.gjwow.GameActivity;
import com.guajibase.gamelib.R;

public class GameAppState extends BaseState {

	private View mWaitingView;
	private ProgressBar mProgress;
	private TextView mWaitingText;

	@Override
	public boolean needChangeView() {
		return false;
	}

	@Override
	public void create() {
		mWaitingView = findViewById(R.id.GameApp_WaitingFrameLayout);
		mWaitingView.setBackgroundColor(0x400f0f0f);

		mProgress = (ProgressBar) findViewById(R.id.waiting_progressBar);
		mWaitingText = (TextView) findViewById(R.id.waiting_text);
		mWaitingText.setTextColor(0xfffdfdfd);

		View logoImg = findViewById(R.id.GameApp_LogoRelativeLayout);
		logoImg.setVisibility(View.INVISIBLE);
		logoImg = null;
		notifyEnterGameAppState();
		//Cocos2dxHelper.nativeNotifyPlatformGameUpdateResult(0, 0, 0, "");

	}
	
	private void notifyEnterGameAppState() {
		((GameActivity)getActivity()).setGameAppStateHandler();
	}

}
