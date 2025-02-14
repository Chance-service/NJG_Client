package com.nuclear.manager;

import com.nuclear.gjwow.GameActivity;
import com.nuclear.state.BaseState;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;

public class StateManager {
	private static StateManager instance = new StateManager();
	private ViewGroup mContainer;
	private BaseState mNowState;
	private View mView;
	private GameActivity activity;

	private StateManager() {
	}

	public static StateManager getInstance() {
		return instance;
	}

	public void setViewContainer(ViewGroup container) {
		this.mContainer = container;
	}

	public void changeState(Class clazz) {
		try {
			if (mNowState != null) {
				mNowState.destory();
				mNowState = null;
			}
			BaseState nowState = (BaseState) clazz.newInstance();
			nowState.setActivity(activity);
			if (mContainer != null && nowState.needChangeView()) {
				mContainer.removeAllViews();
				mView = nowState.getShowView();
				mContainer.addView(mView);
			}
			nowState.create();

			mNowState = nowState;

		} catch (InstantiationException e) {
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			e.printStackTrace();
		}

	}
	
	public final View getShowView(){
		return mView;
	}

	public void setActivity(GameActivity activity) {
		this.activity = activity;
		
	}

}
