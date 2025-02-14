/****************************************************************************
Copyright (c) 2010-2011 cocos2d-x.org

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
import java.io.FileDescriptor;
import java.io.FileInputStream;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.media.MediaPlayer;
import android.media.MediaPlayer.OnCompletionListener;
import android.util.Log;

public class Cocos2dxMusic {
	// ===========================================================
	// Constants
	// ===========================================================

	private static final String TAG = Cocos2dxMusic.class.getSimpleName();

	// ===========================================================
	// Fields
	// ===========================================================

	private final Context mContext;
	private static MediaPlayer mBackgroundMediaPlayer;
	private static MediaPlayer mBackgroundOtherMediaPlayer;//由于soundpool不能播放比较长的音效  用额外MediaPlayer来实现
	private float mLeftVolume;
	private float mRightVolume;
	private boolean mPaused;
	private boolean mOtherPaused;
	private String mCurrentPath;
	private boolean msilent;

	// ===========================================================
	// Constructors
	// ===========================================================

	public Cocos2dxMusic(final Context pContext) {
		this.mContext = pContext;

		this.initData();
	}

	// ===========================================================
	// Getter & Setter
	// ===========================================================

	// ===========================================================
	// Methods for/from SuperClass/Interfaces
	// ===========================================================

	// ===========================================================
	// Methods
	// ===========================================================
	
	public void setsilentMode(boolean swit) {
		msilent = swit;
	}

	public void preloadBackgroundMusic(final String pPath) {
		if ((this.mCurrentPath == null) || (!this.mCurrentPath.equals(pPath))) {
			// preload new background music

			// release old resource and create a new one
			if (mBackgroundMediaPlayer != null) {
				mBackgroundMediaPlayer.release();
				mBackgroundMediaPlayer = null;
				Log.d("cocos2dx-music", "preloadBackgroundMusic---release ");
			}

			mBackgroundMediaPlayer = this.createMediaplayer(pPath);
			//this.mBackgroundMediaPlayer.prepare();
			// record the path
			this.mCurrentPath = pPath;
		}
	}

	public void playBackgroundMusic(final String pPath, final boolean isLoop) {
		Log.d("cocos2dx-music", "BackgroundMusic--- " + pPath + ", isLoop--- " + (isLoop ? 1 : 0));
		Log.e("cocos2dx-music", "getBackgroundVolume---" + this.getBackgroundVolume()); 
		if (this.msilent) {
			return;
		}
		if (mBackgroundMediaPlayer != null) {
			if (mBackgroundMediaPlayer.isPlaying()) {
				mBackgroundMediaPlayer.stop();
			}
			mBackgroundMediaPlayer.setOnPreparedListener(null);
			mBackgroundMediaPlayer.setOnCompletionListener(null);
			mBackgroundMediaPlayer.setOnSeekCompleteListener(null);
			mBackgroundMediaPlayer.release();
			mBackgroundMediaPlayer = null;
		}
		mBackgroundMediaPlayer = this.createMediaplayer(pPath);
		this.mCurrentPath = pPath;

		if (mBackgroundMediaPlayer == null) {
			Log.e(Cocos2dxMusic.TAG, "playBackgroundMusic: background media player is null");
		}
		else {
			try {
				// if the music is playing or paused, stop it
				if (mPaused) {
					mBackgroundMediaPlayer.seekTo(0);
					mBackgroundMediaPlayer.setLooping(isLoop);
					mBackgroundMediaPlayer.start();
				}
				else if (mBackgroundMediaPlayer.isPlaying()) {
					mBackgroundMediaPlayer.seekTo(0);
					mBackgroundMediaPlayer.setLooping(isLoop);
				}
				else {
					mBackgroundMediaPlayer.setLooping(isLoop);
					mBackgroundMediaPlayer.prepareAsync();
					mBackgroundMediaPlayer.setOnPreparedListener(
						new MediaPlayer.OnPreparedListener() {
							@Override
							public void onPrepared(MediaPlayer mp) {
								Log.d("cocos2dx-music", "onPrepared--- ");
								mp.seekTo(0);
								//mp.start();
							}
						}
					);
					mBackgroundMediaPlayer.setOnSeekCompleteListener(
						new MediaPlayer.OnSeekCompleteListener() {
							public void onSeekComplete(MediaPlayer mp) {
								Log.d("cocos2dx-music", "onSeekComplete--- ");
								mp.start();
							}
						}
					);
					mBackgroundMediaPlayer.setOnCompletionListener(
						new OnCompletionListener() {
							public void onCompletion(MediaPlayer mp) {
								mBackgroundMediaPlayer.release();
								mBackgroundMediaPlayer = null;
								Log.d("cocos2dx-music", "onCompletion--- ");
							}
						}
					);
				}
				this.mPaused = false;
			} catch (final Exception e) {
				Log.e(Cocos2dxMusic.TAG, "playBackgroundMusic: error state");
			}

		}
	}
	public void playOtherBackgroundMusic(final String pPath, final boolean isLoop) {
		Log.d("cocos2dx-music", "OtherBackgroundMusic--- " + pPath + ", isLoop--- " + (isLoop ? 1 : 0));
		if (this.msilent) {
			return;
		}
		if (mBackgroundOtherMediaPlayer != null) {
			if (mBackgroundOtherMediaPlayer.isPlaying()) {
				mBackgroundOtherMediaPlayer.stop();
			}
			mBackgroundOtherMediaPlayer.release();
			mBackgroundOtherMediaPlayer = null;
		}
		mBackgroundOtherMediaPlayer = this.createMediaplayer(pPath);

		if (mBackgroundOtherMediaPlayer == null) {
			Log.e(Cocos2dxMusic.TAG, "playBackgroundMusic: background media player is null");
		}
		else {
			try {
		 		mBackgroundOtherMediaPlayer.setVolume(this.mLeftVolume, this.mRightVolume);

				// if the music is playing or paused, stop it
		 		if (mPaused) {
		 			mBackgroundOtherMediaPlayer.seekTo(0);
					mBackgroundOtherMediaPlayer.setLooping(isLoop);
					mBackgroundOtherMediaPlayer.start();
		 		}
		 		else if (mBackgroundOtherMediaPlayer.isPlaying()) {
					mBackgroundOtherMediaPlayer.seekTo(0);
					mBackgroundOtherMediaPlayer.setLooping(isLoop);
				}
		 		else {
					mBackgroundOtherMediaPlayer.setLooping(isLoop);
					mBackgroundOtherMediaPlayer.prepareAsync();
					mBackgroundOtherMediaPlayer.setOnPreparedListener(
							new MediaPlayer.OnPreparedListener() {
								@Override
								public void onPrepared(MediaPlayer mp) {
									mp.seekTo(0);
									mp.start();
								}
							}
					);
					mBackgroundOtherMediaPlayer.setOnCompletionListener(
							new OnCompletionListener() {
								public void onCompletion(MediaPlayer mp) {
									mp.release();
									mBackgroundOtherMediaPlayer = null;
								}
							}
					);
				}
				this.mOtherPaused = false;
			} catch (final Exception e) {
				Log.e(Cocos2dxMusic.TAG, "playOtherBackgroundMusic: error state");
			}
		}

	}
	public void stopBackgroundMusic() {
		if (mBackgroundMediaPlayer != null) {
			if (mBackgroundMediaPlayer.isPlaying()) {
				mBackgroundMediaPlayer.stop();
			}
			mBackgroundMediaPlayer.release();
			mBackgroundMediaPlayer = null;

			// should set the state, if not, the following sequence will be error
			// play -> pause -> stop -> resume
			this.mPaused = false;
		}
	}
	public void stopOtherBackgroundMusic() {
		if (mBackgroundOtherMediaPlayer != null) {
			if (mBackgroundOtherMediaPlayer.isPlaying()) {
				mBackgroundOtherMediaPlayer.stop();
			}
			mBackgroundOtherMediaPlayer.release();
			mBackgroundOtherMediaPlayer = null;

			// should set the state, if not, the following sequence will be error
			// play -> pause -> stop -> resume
			this.mOtherPaused = false;
		}
	}
	public void pauseBackgroundMusic() {
		if (mBackgroundMediaPlayer != null && mBackgroundMediaPlayer.isPlaying()) {
			mBackgroundMediaPlayer.pause();
			this.mPaused = true;
		}
		if (mBackgroundOtherMediaPlayer != null && mBackgroundOtherMediaPlayer.isPlaying()) {
			mBackgroundOtherMediaPlayer.pause();
			this.mOtherPaused = true;
		}
	}

	public void resumeBackgroundMusic() {
		if (mBackgroundMediaPlayer != null && this.mPaused) {
			mBackgroundMediaPlayer.start();
			this.mPaused = false;
		}
		if (mBackgroundOtherMediaPlayer != null && this.mOtherPaused) {
			mBackgroundOtherMediaPlayer.start();
			this.mOtherPaused = false;
		}
	}

	public void rewindBackgroundMusic() {
		if (mBackgroundMediaPlayer != null) {
			mBackgroundMediaPlayer.stop();

			try {
				mBackgroundMediaPlayer.prepare();
				mBackgroundMediaPlayer.seekTo(0);
				mBackgroundMediaPlayer.start();

				this.mPaused = false;
			} catch (final Exception e) {
				Log.e(Cocos2dxMusic.TAG, "rewindBackgroundMusic: error state");
			}
		}
		
	}

	public boolean isBackgroundMusicPlaying() {
		boolean ret = false;

		if (mBackgroundMediaPlayer != null) {
			ret = mBackgroundMediaPlayer.isPlaying();
		}

		return ret;
	}

	public boolean isOtherBackgroundMusicPlaying() {
		boolean ret = false;

		if (mBackgroundOtherMediaPlayer != null) {
			ret = mBackgroundOtherMediaPlayer.isPlaying();
		}

		return ret;
	}

	public void end() {
		if (mBackgroundMediaPlayer != null) {
			mBackgroundMediaPlayer.release();
			mBackgroundMediaPlayer = null;
			Log.d("cocos2dx-music", "end---release ");
		}
		if (mBackgroundOtherMediaPlayer != null) {
			mBackgroundOtherMediaPlayer.release();
			mBackgroundOtherMediaPlayer = null;
		}

		this.initData();
	}

	public float getBackgroundVolume() {
		if (mBackgroundMediaPlayer != null) {
			return (this.mLeftVolume + this.mRightVolume) / 2;
		} else {
			return 0.0f;
		}
	}

	public void setBackgroundVolume(float pVolume) {
		if (pVolume < 0.0f) {
			pVolume = 0.0f;
		}

		if (pVolume > 1.0f) {
			pVolume = 1.0f;
		}
		Log.e("cocos2dxMusic---audio--", pVolume + "");
		this.mLeftVolume = this.mRightVolume = pVolume;
		if (mBackgroundMediaPlayer != null) {
			mBackgroundMediaPlayer.setVolume(this.mLeftVolume, this.mRightVolume);
		}
	}

	private void initData() {
		this.mLeftVolume = 1.0f;
		this.mRightVolume = 1.0f;
		mBackgroundMediaPlayer = null;
		mBackgroundOtherMediaPlayer = null;
		this.mPaused = false;
		this.mOtherPaused = false;
		this.mCurrentPath = null;
		this.msilent = false;
	}

	/**
	 * create mediaplayer for music
	 * 
	 * @param pPath
	 *			the pPath relative to assets
	 * @return mediaPlayer
	 */
	private MediaPlayer createMediaplayer(final String pPath) {
		MediaPlayer mediaPlayer = new MediaPlayer();
		mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
		try {
			if (pPath.startsWith("/")) {
				final FileInputStream fis = new FileInputStream(pPath);
				mediaPlayer.setDataSource(fis.getFD());
				fis.close();
			} else {
				String strExternal = ((Cocos2dxActivity)Cocos2dxActivity.getContext()).mAppDataExternalStorageResourcesFullPath
						+ "/" + pPath;
				File fileTemp = new File(strExternal);
				if (fileTemp.exists()) {
					final FileInputStream fis = new FileInputStream(strExternal);
					FileDescriptor fd = fis.getFD();
					mediaPlayer.setDataSource(fd);
					fis.close();
				}
				else {
				//--end
					final AssetFileDescriptor assetFileDescritor = this.mContext.getAssets().openFd(pPath);
					mediaPlayer.setDataSource(assetFileDescritor.getFileDescriptor(), assetFileDescritor.getStartOffset(), assetFileDescritor.getLength());
				}
				//
				//fileTemp = null;
			}
			//mediaPlayer.prepare();
			//考虑加个try catch抛出IllegalStateException？
			//try{
			//	//是否考虑改为异步加载用prepareAsync
			//	//mediaPlayer.prepare();
			//} catch (IllegalStateException e) {
			//	e.printStackTrace();
			//}
			mediaPlayer.setVolume(this.mLeftVolume, this.mRightVolume);
		} catch (final Exception e) {
			mediaPlayer = null;
			Log.e(Cocos2dxMusic.TAG, "error: " + e.getMessage() + ", " + pPath, e);
		}

		return mediaPlayer;
	}

	// ===========================================================
	// Inner and Anonymous Classes
	// ===========================================================
}
