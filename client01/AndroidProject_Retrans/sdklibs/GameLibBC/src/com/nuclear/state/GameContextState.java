package com.nuclear.state;

import org.cocos2dx.lib.Cocos2dxEditText;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;

import com.nuclear.gjwow.GameActivity;
import com.nuclear.util.ContextUtil;
import com.guajibase.gamelib.R;

import android.annotation.SuppressLint;
import android.os.Build;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

public class GameContextState extends BaseState {

	@Override
	public boolean needChangeView() {
		return true;
	}
	
	@SuppressLint("NewApi") @Override
	public void create() {
		ImageView imageView_logo = (ImageView) getActivity()
				.findViewById(R.id.game_activity_logo);
		
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
			imageView_logo.setImageDrawable(getActivity().getLogoDrawable());
	    } else {
	    	imageView_logo.setBackgroundDrawable(getActivity().getLogoDrawable());
	    }
		imageView_logo.setScaleType(ImageView.ScaleType.FIT_CENTER);
		Cocos2dxGLSurfaceView glView = (Cocos2dxGLSurfaceView)findViewById(R.id.GameApp_Cocos2dxGLSurfaceView);
		glView.setZOrderMediaOverlay(true);
		Cocos2dxEditText editText = (Cocos2dxEditText)findViewById(R.id.GameApp_Cocos2dxEditText);
		((GameActivity)getActivity()).initAndroidContext(glView, editText);

		TextView loading_game_textView = (TextView) findViewById(R.id.loading_game_textView);
		loading_game_textView.setText(getActivity().getApplicationContext()
				.getResources().getString(
						R.string.starting_game));
	}

	@Override
	public View getView() {
		View view = LayoutInflater.from(getActivity()).inflate(R.layout.activity_game, null);
		return view;
	}


}
