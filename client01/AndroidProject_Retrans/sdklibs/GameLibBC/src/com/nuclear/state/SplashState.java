package com.nuclear.state;

import static com.nuclear.gjwow.GameActivity.getPlatformName;

import android.annotation.SuppressLint;
import android.graphics.drawable.Drawable;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.view.animation.*;
import android.view.animation.AlphaAnimation;
import android.view.animation.AccelerateInterpolator;
import com.chance.allsdk.E_PLATFORM;

import com.nuclear.manager.StateManager;
import com.guajibase.gamelib.R;

/**
 * 
 * @author Administrator
 * 
 */
public class SplashState extends BaseState {

	private ImageView imageView_logo;
	private ImageView.ScaleType[] scaleTypes;
	private Drawable[] drawables;
	private int nowDrawable = 0;

	// private int mSplashTime;
	@SuppressLint("NewApi") @Override
	public void create() {
		super.create();
		ProgressBar mAssetsUnzipProgressBar = (ProgressBar) findViewById(R.id.assetsUnzipProgress);
		imageView_logo = (ImageView)findViewById(R.id.imageView_logo);
		nowDrawable = 0;
		//Drawable[] drawables;
		if (getPlatformName() == E_PLATFORM.KUSO || getPlatformName() == E_PLATFORM.APLUS || getPlatformName() == E_PLATFORM.EROLABS){
			scaleTypes = new ImageView.ScaleType[]{ ImageView.ScaleType.FIT_CENTER, ImageView.ScaleType.FIT_CENTER };
			drawables = new Drawable[]{ getActivity().getLogo69Drawable(), getActivity().getLogoDrawable() };
		}
		else {
			scaleTypes = new ImageView.ScaleType[]{ ImageView.ScaleType.FIT_CENTER };
			drawables = new Drawable[]{ getActivity().getLogoDrawable() };
		}

		imageView_logo.setImageDrawable(drawables[nowDrawable]);
		imageView_logo.setScaleType(scaleTypes[nowDrawable]);
		mAssetsUnzipProgressBar.setVisibility(View.INVISIBLE);
		fadeInAndShowImage(imageView_logo);

	}

	@Override
	public boolean needChangeView() {
		return true;
	}

	@SuppressLint("InflateParams")
	@Override
	public View getView() {
		return LayoutInflater.from(getActivity()).inflate(
				R.layout.logo_layout, null);
	}

	private void fadeOutAndHideImage(final ImageView img){
		if (nowDrawable >= drawables.length) {
			StateManager.getInstance().changeState(UzipState.class);
		}
		else {
			Animation fadeOut = new AlphaAnimation(1, 0);
			fadeOut.setInterpolator(new AccelerateInterpolator());
			fadeOut.setDuration(1500);
			fadeOut.setAnimationListener(new Animation.AnimationListener() {
				public void onAnimationEnd(Animation animation) {
					imageView_logo.setImageDrawable(drawables[nowDrawable]);
					imageView_logo.setScaleType(scaleTypes[nowDrawable]);
					fadeInAndShowImage(img);
				}
				public void onAnimationRepeat(Animation animation) { }
				public void onAnimationStart(Animation animation) { }
			});
			img.startAnimation(fadeOut);
		}
	}
	private void fadeInAndShowImage(final ImageView img){
		Animation fadeIn = new AlphaAnimation(0, 1);
		fadeIn.setInterpolator(new DecelerateInterpolator());
		fadeIn.setDuration(1500);
		nowDrawable++;
		fadeIn.setAnimationListener(new Animation.AnimationListener()
		{
			public void onAnimationEnd(Animation animation)
			{
				fadeOutAndHideImage(img);
			}
			public void onAnimationRepeat(Animation animation) { }
			public void onAnimationStart(Animation animation) { }
		});
		img.startAnimation(fadeIn);
	}
}
