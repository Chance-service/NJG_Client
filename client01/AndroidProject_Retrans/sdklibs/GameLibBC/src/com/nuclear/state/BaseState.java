package com.nuclear.state;

import com.nuclear.gjwow.GameActivity;
import com.nuclear.manager.StateManager;
import com.nuclear.util.ContextUtil;

import android.app.Activity;
import android.view.View;

public abstract class BaseState {
	private GameActivity activity;
	private View mView;
	public BaseState(){
		
	}
	public void setContentView(){
		
	}
	public void destory() {
		
	}
	public void create() {
		
	}
	public View getView() {
		return null;
	}
	public View getShowView() {
		mView = getView();
		return mView;
	}
	public abstract boolean needChangeView();
	
	public GameActivity getActivity(){
		return activity;
	}
	public void setActivity(GameActivity activity){
		this.activity = activity;
	}
	
	public View findViewById(int id){
		if(mView == null){
			mView = StateManager.getInstance().getShowView();
		}
		return mView.findViewById(id);
	}
	public void runOnUIThread(Runnable runnable){
		this.activity.runOnUiThread(runnable);
	}
	
	public void postDelay(Runnable r ,long delayMillis) {
		ContextUtil.postDelay(r, delayMillis);
	}
}
