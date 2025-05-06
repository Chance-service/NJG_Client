package com.nuclear.state;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Properties;
import org.json.JSONException;
import org.json.JSONObject;
import org.json.JSONTokener;

import com.nuclear.gjwow.GameActivity;
import com.nuclear.manager.StateManager;
import com.nuclear.util.ContextUtil;
import com.nuclear.util.LogUtil;
import com.nuclear.util.StorageUtil;
import com.guajibase.gamelib.R;
import android.annotation.SuppressLint;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.content.res.AssetManager;
import android.os.Build;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;
import android.widget.TextView;

/**
 * 
 * @author Administrator
 * 
 */
public class UzipState extends BaseState {

	private static final String TAG = null;
	private Handler handler;
	private String spath;
	private String mAppFilesPath;
	private String mAppDataExternalStorageFullPath;
	private String mAppDataExternalStorageResourcesFullPath;
	private String mAppDataExternalStorageCacheFullPath;
	private String mAppDataExternalStorageHotupdateFullPath;
	private String mAppDataExternalStorageVersionFullPath;
	private TextView mAssetsUnzipTextView;
	private ProgressBar mAssetsUnzipProgressBar;
    public  static boolean allowStorage  = false;
	private ArrayList<String> resFilesPath = new ArrayList<String>();
	private ImageView imageView_logo;
	private static final int HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResProgress = 0;
	private static final int HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResText = 1;
	public static String newPath = "";

	@Override
	public boolean needChangeView() {
		return true;
	}

	private static class ProgressMessage {

		public int progress;
		public String text;

		public ProgressMessage(int progress, String text) {
			this.progress = progress;
			this.text = text;
		}
	}

	@Override
	public View getView() {
		View view = LayoutInflater.from(getActivity()).inflate(
				R.layout.logo_layout, null);
		return view;
	}

	@Override
	public void create() {
		super.create();
		//mAssetsUnzipProgressBar = (ProgressBar) findViewById(R.id.assetsUnzipProgress);
		mAssetsUnzipTextView = (TextView) findViewById(R.id.assets_unzip_textView);
		
		mAssetsUnzipProgressBar = (ProgressBar) findViewById(R.id.assetsUnzipProgress);
		imageView_logo = (ImageView)findViewById(R.id.imageView_logo);
		if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
			imageView_logo.setImageDrawable(getActivity().getLogoDrawable());
	    } else {
	    	imageView_logo.setBackgroundDrawable(getActivity().getLogoDrawable());
	    }
		imageView_logo.setScaleType(ImageView.ScaleType.FIT_CENTER);
		mAssetsUnzipProgressBar.setVisibility(View.INVISIBLE);
		handler = new Handler(getActivity().getMainLooper()) {
			@Override
			public void handleMessage(Message msg) {

				if (msg.what == HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResProgress) {
					ProgressMessage obj = (ProgressMessage) msg.obj;
					if (obj.progress < 100) {
						Log.d(TAG,
								"uncompressing resources to external storage "
										+ obj.text);

						//mAssetsUnzipProgressBar.setVisibility(View.VISIBLE);
						mAssetsUnzipProgressBar.setProgress(obj.progress);
						if (obj.progress < 99) {
							String str = getActivity().getResources()
									.getString(R.string.assets_unzip_msg)
									+ obj.text;
							mAssetsUnzipTextView.setText(str);
						} else {
							mAssetsUnzipTextView.setText(getActivity().getApplicationContext()
									.getResources().getString(
											R.string.starting_game));
						}
					} else {
						//
						((GameActivity) getActivity())
								.setAppPath(mAppDataExternalStorageFullPath);
						StateManager.getInstance().changeState(
								UpdateSOState.class);
					}
				}

				else if (msg.what == HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResText) {
					ProgressMessage obj = (ProgressMessage) msg.obj;
					mAssetsUnzipTextView.setText(obj.text);
				}else if (msg.what == 2) {
					  unZipAssert();
				}

			}
		};
		// 检查网络及存储状态
		if (!checkNetWorkStatus()) {
			// 弹提示框
			String title = getActivity().getResources().getString(
					R.string.app_dlg_title);
			String msg = getActivity().getResources().getString(
					R.string.app_dlg_newwork_notok_msg);
			showDialog(title, msg);
			return;
		}
		if (!checkStorageStatus()) {
			// 弹提示框
			String title = getActivity().getResources().getString(
					R.string.app_dlg_title);
			String msg = getActivity().getResources().getString(
					R.string.app_dlg_externalstorage_nofreespace_msg);
			showDialog(title, msg);
			return;
		}

		// 是否需要解压：新安装及覆盖安装需要解压资源。
		if (!needUnZipFile()) {
			// needUnZipFile返回false说明不需要解压,返回true说明要解压。
			((GameActivity) getActivity())
					.setAppPath(mAppDataExternalStorageFullPath);
			StateManager.getInstance().changeState(UpdateSOState.class);
			return;
		}

		// 检查SD卡空间
		if (!storageIsEnough()) {
			// 弹提示框
			String title = getActivity().getResources().getString(
					R.string.app_dlg_title);
			String msg = getActivity().getResources().getString(
					R.string.app_dlg_externalstorage_nofreespace_msg);
			showDialog(title, msg);
			return;
		}
		new Thread(new Runnable()
	      {
	        public void run()
	        {
	          while (!UzipState.allowStorage)
	            try
	            { 
	              Thread.sleep(1000L);
	            }
	            catch (InterruptedException localInterruptedException)
	            {
	              localInterruptedException.printStackTrace();
	            }
	          LogUtil.LOGE("PlatfromSDKActivity","-------step2");
	          Message localMessage = new Message();
	          localMessage.what = 2;
	          UzipState.this.handler.sendMessage(localMessage);
	        }
	      }).start();
	}

	private void unZipAssert() {

		new Thread(new Runnable() {

			@Override
			public void run() {
				// 如果有旧的目录，将其移除。
				File rootfiles = new File(
						mAppDataExternalStorageResourcesFullPath);
				if (rootfiles.exists()) {
					StorageUtil.removeFileDirectory(rootfiles);
				}
				// 万事俱备，只欠解压。
				if (storageCanUzipAllAssert()) {

					// 空间足够，解压所有资源
					unzipAssertFiles();
				} else {
					// 空间不足，解压音乐资源
					unzipMusicSoundFiles();
				}
			}
		}).start();

	}

	private boolean needUnZipFile() {
		mAppFilesPath = ContextUtil.getSPConfig("StorageFullPath", "");
		if ("".equals(mAppFilesPath)) {
			return true;
		} else {
			initAppDataPath(mAppFilesPath);
			return checkExternalStorageResourcesStatus();
		}
	}

	private boolean checkExternalStorageResourcesStatus() {
		File resources = new File(mAppDataExternalStorageResourcesFullPath);
		if (!resources.exists() || !resources.canRead()
				|| !resources.canWrite()) {
			// assert目录有问题。
			// TODO assert目录有问题时需要处理。
		}
		//
		return checkExternalStorageResourcesVersion();

	}

	@SuppressLint("NewApi") private boolean storageCanUzipAllAssert() {
		File dir1 = new File(mAppFilesPath);
		if (dir1.getUsableSpace() < 100 * 1024 * 1024) {
			// SD卡剩余空间不足。将mExternalStorageEnough设为false
			return false;
		}
		return true;
	}

	private int recursionSumAssetsFileNum(String path) {
		int num = 0;
		try {
			AssetManager assetMgr = getActivity().getAssets();
			String[] assets = assetMgr.list(path);
			//
			for (String filepath : assets) {
				if (filepath.isEmpty())
					continue;
				//
				if (!path.isEmpty())
					filepath = path + "/" + filepath;
				//
				int idx = filepath.lastIndexOf('/');
				int idy = filepath.lastIndexOf('.');
				if (idx == -1 && idy == -1) {
					num += recursionSumAssetsFileNum(filepath);
					File temp = new File(
							mAppDataExternalStorageResourcesFullPath + "/"
									+ filepath);
					Log.d(TAG, "recursionSumAssetsFileNum " + mAppDataExternalStorageResourcesFullPath + "/"
							+ filepath);
					if (!temp.exists())
						temp.mkdirs();
					if (!temp.exists())
						Log.d(TAG, "recursionSumAssetsFileNum !temp.exists()");
					// temp = null;
					Message msg = new Message();
					msg.obj = new ProgressMessage(0, getActivity().getString(
							R.string.unpack_the_resources_b));
					msg.what = HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResText;
					handler.sendMessage(msg);
				} else if (idx > 0 && idy > idx) {
					num++;
					resFilesPath.add(filepath);
				} else if (idx == -1 && idy > 0) {
					num++;
					resFilesPath.add(filepath);
				} else if (idx > 0 && idy < idx) {
					num += recursionSumAssetsFileNum(filepath);
					File temp = new File(
							mAppDataExternalStorageResourcesFullPath + "/"
									+ filepath);
					if (!temp.exists())
						temp.mkdirs();
					// temp = null;
					Message msg = new Message();
					msg.obj = new ProgressMessage(0, getActivity().getString(
							R.string.unpack_the_resources_c));
					msg.what = HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResText;
					handler.sendMessage(msg);
				}
			}
			//
		} catch (IOException e) {

		} finally {

		}
		return num;
	}

	private void unzipAssertFiles() {
		//
		long start = System.currentTimeMillis();
		//
		AssetManager assetMgr = getActivity().getAssets();
		int idx = 0;
		BufferedInputStream in = null;
		BufferedOutputStream out = null;
		recursionSumAssetsFileNum("");
		//
		long end1 = System.currentTimeMillis();
		long span1 = end1 - start;
		LogUtil.LOGE(TAG, "recursionSumAssetsFileNum cost time: " + span1 + " millis");
		//
		byte[] buf = null;
		if (resFilesPath.size() > 0)
			buf = new byte[10240];
		//
		for (String filepath : resFilesPath) {
			idx++;
			//
			try {
				in = new BufferedInputStream(assetMgr.open(filepath,
						AssetManager.ACCESS_STREAMING), 40960);
				out = new BufferedOutputStream(new FileOutputStream(
						mAppDataExternalStorageResourcesFullPath + "/"
								+ filepath), 40960);
				//
				int readNum = 0;
				while (true) {

					readNum = in.read(buf, 0, buf.length);
					if (readNum <= 0) {
						break;
					}

					out.write(buf, 0, readNum);

				}
				//
				out.flush();
			} catch (IOException e) {
				File tmp = new File(mAppDataExternalStorageResourcesFullPath
						+ "/" + filepath);
				if (tmp.exists())
					tmp.delete();
				tmp = null;
			} catch (OutOfMemoryError omm) {
				File tmp = new File(mAppDataExternalStorageResourcesFullPath
						+ "/" + filepath);
				if (tmp.exists())
					tmp.delete();
				tmp = null;
			} finally {
				try {
					if (in != null)
						in.close();
					if (out != null)
						out.close();
					//
					// in = null;
					// out = null;
					//
				} catch (IOException e) {

				}
			}
			//
			int itmp = idx % 20;
			if (itmp == 0) {
				int progress = idx * 100 / resFilesPath.size();
				String text = String.valueOf(idx) + "/"
						+ String.valueOf(resFilesPath.size());

				Message msg = new Message();
				msg.obj = new ProgressMessage(progress, text);
				msg.what = HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResProgress;
				handler.sendMessage(msg);
				//
			}
			if (idx >= resFilesPath.size() && itmp > 0) {

				Message msg = new Message();
				msg.obj = new ProgressMessage(100, ", starting game");
				msg.what = HANDLER_MSG_TO_MAINTHREAD_UpdateMoveAssetResProgress;
				handler.sendMessage(msg);
				//
				long end = System.currentTimeMillis();
				long span = end - start;
				LogUtil.LOGE(TAG, "UnzipAssetToExternalStorageResources cost time: "
						+ span + " millis");
			}
			//
		}
		//
		buf = null;
		//
		// } catch (IOException e) {

		// }
		//

	}

	@SuppressLint("NewApi") private boolean storageIsEnough() {

		// SD卡已挂载。
		File externalStorageDir = Environment.getExternalStorageDirectory();
		if (!externalStorageDir.canRead() || !externalStorageDir.canWrite()
				|| externalStorageDir.getUsableSpace() < 200 * 1024 * 1024) {
			Log.d(TAG, "UzipState storageIsEnough1 " + newPath);
			// SD卡不能读且不能写且空间不足。获取第二SD卡路径。
			String secondPath = null;//StorageUtil.getSecondStorageWithFreeSize(200 * 1024 * 1024);
			if (secondPath != null) {
				mAppFilesPath = secondPath;
			} else {
				// 获取不到，减小 限制大小，继续获取
				secondPath = null;//StorageUtil.getSecondStorageWithFreeSize(externalStorageDir.getUsableSpace() * 2);
				if (secondPath != null) {
					mAppFilesPath = secondPath;
				} else {
					// 获取不到，设为默认SD卡路径
					mAppFilesPath = newPath;//externalStorageDir.getAbsolutePath();
				}
				File dir1 = new File(mAppFilesPath);
				if (dir1.getUsableSpace() < 10 * 1024 * 1024) {
					// SD卡剩余空间不足。将mExternalStorageEnough设为false
					return false;
				}
			}
		} else {
			// 获取外部存储路径。
			Log.d(TAG, "UzipState storageIsEnough2");
			mAppFilesPath = newPath;//externalStorageDir.getAbsolutePath();
		}
		setUzipPath();
		return true;
	}

	private void unzipMusicSoundFiles() {
		if (ContextUtil.getSPConfig("unzipMusicSoundFiles", false)) {

			return;
		}

		ContextUtil.setSPConfig("unzipMusicSoundFiles", true);

	}

	public boolean checkNetWorkStatus() {
		return ContextUtil.checkNetworkStatus();
	}

	private boolean checkStorageStatus() {
		// 检查存储状态，mExternalStorageOK，mUnzipedAssets
		String exStorageState = Environment.getExternalStorageState();
		// 检查存储状态。MEDIA_MOUNTED 与 MEDIA_SHARED 都不行时
		return exStorageState.equals(Environment.MEDIA_MOUNTED);

	}

	private void showDialog(String title, String message) {
		AlertDialog dlg = new AlertDialog.Builder(getActivity())
				.setTitle(title)
				.setMessage(message)
				.setPositiveButton(R.string.confirm,
						new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog,
									int which) {

								ContextUtil.requestDestroy();

							}
						})
				.setOnCancelListener(new DialogInterface.OnCancelListener() {

					@Override
					public void onCancel(DialogInterface dialog) {

						ContextUtil.requestDestroy();

					}

				}).create();
		dlg.show();
	}

	private void setUzipPath() {
		File file1 = new File(mAppFilesPath + "/Android/Data");
		File file2 = new File(mAppFilesPath + "/Android/data");
		// 都存在用小写，那个存在用哪个，都不存在用小写。
		if (file1.exists() && file2.exists()) {
			Log.d(TAG, "setUzipPath1");
			spath = mAppFilesPath;/* + "/Android/data/"
					+ getActivity().getPackageName() + "/files";*/
		} else if (file1.exists() && !file2.exists()) {
			Log.d(TAG, "setUzipPath2");
			spath = mAppFilesPath;/* + "/Android/Data/"
					+ getActivity().getPackageName() + "/files";*/
		} else if (!file1.exists() && file2.exists()) {
			Log.d(TAG, "setUzipPath3");
			spath = mAppFilesPath;/* + "/Android/data/"
					+ getActivity().getPackageName() + "/files";*/
		} else {
			Log.d(TAG, "setUzipPath4");
			spath = mAppFilesPath;/* + "/Android/data/"
					+ getActivity().getPackageName() + "/files";*/
		}
		Log.d(TAG, "setUzipPath " + spath);
		ContextUtil.setSPConfig("StorageFullPath", spath);
		initAppDataPath(spath);

	}

	public void initAppDataPath(String fullPath) {
		
		mAppDataExternalStorageFullPath = fullPath;
		mAppDataExternalStorageResourcesFullPath = mAppDataExternalStorageFullPath
				+ "/assets";
		getActivity().setAppFilesResourcesPath(mAppDataExternalStorageResourcesFullPath);
		mAppDataExternalStorageCacheFullPath = mAppDataExternalStorageFullPath
				+ "/Cache";
		mAppDataExternalStorageHotupdateFullPath = mAppDataExternalStorageFullPath
				+ "/hotUpdate";
		mAppDataExternalStorageVersionFullPath = mAppDataExternalStorageFullPath
				+ "/version";
		//

		// xiaomi
		// 2S上getExternalCacheDir指向/storage/sdcard0/Android/data/PackageName/cache
		//
		File tempDir = new File(mAppDataExternalStorageFullPath);
		if (!tempDir.exists())
			tempDir.mkdirs();
		//
		if (!tempDir.exists())
			LogUtil.LOGE(TAG,
					"mAppDataExternalStorageFullPath: "
							+ tempDir.getAbsolutePath() + " is not OK!");
		else
			Log.d(TAG,
					"mAppDataExternalStorageFullPath: "
							+ tempDir.getAbsolutePath());

		//
		tempDir = null;
		//
		tempDir = new File(mAppDataExternalStorageCacheFullPath);
		if (!tempDir.exists())
			tempDir.mkdirs();
		//
		if (!tempDir.exists())
			LogUtil.LOGE(TAG,
					"AppDataExternalStorageCacheFullPath: "
							+ tempDir.getAbsolutePath() + " is not OK!");
		else
			Log.d(TAG,
					"AppDataExternalStorageCacheFullPath: "
							+ tempDir.getAbsolutePath());
		//
		tempDir = null;
		//
		tempDir = new File(mAppDataExternalStorageResourcesFullPath);
		if (!tempDir.exists())
			tempDir.mkdirs();
		//
		if (!tempDir.exists())
			LogUtil.LOGE(TAG,
					"AppDataExternalStorageResourcesFullPath: "
							+ tempDir.getAbsolutePath() + " is not OK!");
		else
			Log.d(TAG,
					"AppDataExternalStorageResourcesFullPath: "
							+ tempDir.getAbsolutePath());
		//
		tempDir = null;
		//
		// 需要時才清除舊熱更資料
		if (checkExternalStorageResourcesVersion()) {
			tempDir = new File(mAppDataExternalStorageHotupdateFullPath);
			StorageUtil.removeFileDirectory(tempDir);
			if (tempDir.exists())
				LogUtil.LOGE(TAG,
						"mAppDataExternalStorageHotupdateFullPath: "
								+ tempDir.getAbsolutePath() + " delete failed!");
			tempDir = new File(mAppDataExternalStorageVersionFullPath);
			StorageUtil.removeFileDirectory(tempDir);
			if (tempDir.exists())
				LogUtil.LOGE(TAG,
						"mAppDataExternalStorageVersionFullPath: "
								+ tempDir.getAbsolutePath() + " delete failed!");
		}
	}

	private boolean checkExternalStorageResourcesVersion() {
		// 找到开关文件。
		File version_cfg = new File(mAppDataExternalStorageResourcesFullPath
				+ "/version_android_local.cfg");
		if (!version_cfg.exists()) {
			version_cfg = null;
			return true;
		}
		File font = new File(mAppDataExternalStorageResourcesFullPath
				+ "/Barlow-SemiBold.ttf");
		Log.d(TAG, "checkExternalStorageResourcesVersion: font path : " + mAppDataExternalStorageResourcesFullPath + "/Barlow-SemiBold.ttf");
		if (!font.exists()) {
			Log.d(TAG, "checkExternalStorageResourcesVersion: !font.exists()");
		}
		else {
			Log.d(TAG, "checkExternalStorageResourcesVersion: font.exists()");
		}
		byte[] buf1 = new byte[4096];// 会自动初始化0
		try {
			FileInputStream inp1 = new FileInputStream(version_cfg);
			inp1.read(buf1);// utf8文本
			inp1.close();
			inp1 = null;
		} catch (Exception e) {
			// e.printStackTrace();
			Log.d(TAG,
					"local unzip storage version_android_local.cfg file not exist!");
			return true;
		}

		String str1 = new String(buf1);
		String local_version = "";

		{
			JSONTokener jsonParser = new JSONTokener(str1);
			try {
				JSONObject version = (JSONObject) jsonParser.nextValue();
				local_version = version.getString("localVerson");
			} catch (JSONException e) {
				// e.printStackTrace();
				Log.d(TAG,
						"local unzip storage version.cfg file json parse failed!");
				return true;
			}
			jsonParser = null;
		}

		str1 = null;
		buf1 = null;

		byte[] buf2 = new byte[4096];
		AssetManager assetMgr = getActivity().getAssets();
		try {
			InputStream inp2 = assetMgr.open("version_android_local.cfg");
			inp2.read(buf2);
			inp2.close();
			inp2 = null;
		} catch (IOException e) {
			// e.printStackTrace();
			Log.d(TAG,
					"apk assets version_android_local_local.cfg file not exist!");
			return false;
		}

		String str2 = new String(buf2);
		String apk_version = "";

		{
			JSONTokener jsonParser = new JSONTokener(str2);
			try {
				JSONObject version = (JSONObject) jsonParser.nextValue();
				apk_version = version.getString("localVerson");
			} catch (JSONException e) {
				// e.printStackTrace();
				Log.d(TAG,
						"apk assets version_android_local.cfg file parse failed!");
				return false;
			}
			jsonParser = null;
		}

		str2 = null;
		buf2 = null;
		String apkVer[] = apk_version.split("\\.");
		LogUtil.LOGE(TAG, apkVer[0] + "." + apkVer[1] + "." + apkVer[2]);
		String localVer[] = local_version.split("\\.");
		LogUtil.LOGE(TAG, localVer[0] + "." + localVer[1] + "." + localVer[2]);
		try {
			if (Integer.valueOf(apkVer[0]) > Integer.valueOf(localVer[0])) {
				return true;
			} else if (Integer.valueOf(apkVer[0]) < Integer
					.valueOf(localVer[0])) {
				return false;
			}
			if (Integer.valueOf(apkVer[1]) > Integer.valueOf(localVer[1])) {
				return true;
			} else if (Integer.valueOf(apkVer[1]) < Integer
					.valueOf(localVer[1])) {
				return false;
			}
			if (Integer.valueOf(apkVer[2]) > Integer.valueOf(localVer[2])) {
				return true;
			} else {

			}
		} catch (Exception e) {
			Log.d(TAG, "compare apkversion and localversion failed");
			return false;
		}
		LogUtil.LOGE(TAG, "apk_version:" + apk_version + ", local_version:"
				+ local_version);
		// if (apk_version.compareTo(local_version) > 0)
		// return true;

		return false;
	}

	interface UzipListener {
		void onUnZipCompeleteListener();

		void onUnZipFailListener();
	};
}
