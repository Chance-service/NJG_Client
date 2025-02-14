package com.nuclear.application;

import com.nuclear.util.ContextUtil;

import android.app.Application;
import android.content.Context;

public class GameApplication extends Application {
	@Override
	protected void attachBaseContext(Context base) {
		super.attachBaseContext(base);
		ContextUtil.setContext(base);
		copySO();
	}

	private void copySO() {
		
	}
}
