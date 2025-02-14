package com.nuclear.gjwow;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.PrintStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import javax.crypto.Cipher;
import javax.crypto.spec.IvParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import android.content.Context;
import android.os.Environment;
import android.os.SystemClock;
import android.util.Base64;
import android.util.Log;
import com.nuclear.util.DeviceUtil;
import com.nuclear.util.IniFileUtil;
import com.nuclear.util.MD5;
import com.nuclear.util.RSAUtil;

public class TigerToLastLoginHelp {

	public static final String Tag = TigerToLastLoginHelp.class.getSimpleName();
	static ArrayList<TigerToServerInfo> tigetToInfos;
	static GameActivity activityGame;
	static String gameId;
	static String yaUid;
	private static File savePath;
	private static File saveFile;
	static boolean found;
	static String platform_str = "Android";
	static File dynamicFile;
	static boolean switchPushGet = false;
	private static boolean mDesBol = false;

	/** 个信SDK的clientId */
	private static String gexingClientId = "";

	/** 个信SDK的推送Tag字符串 */
	private static String gexingTags = "";

	public static void setTigerToLastLoginHelp(GameActivity pActivity) {
		activityGame = pActivity;
		tigetToInfos = new ArrayList<TigerToServerInfo>();
		savePath = new File(Environment.getExternalStorageDirectory()
				+ File.separator + "tigerto" + File.separator); // 数据库文件目录

		if (!savePath.exists()) { // 判断目录是否存在
			savePath.mkdirs(); // 创建目录
		}

	}

	// 客户端向服务器同步服务器id
	@SuppressWarnings("unchecked")
	public static void updateServerInfo(int serverID,
			TigerToServerInfo pTigerToInfo, boolean pushSvr) {
		Log.w("TigerToLastLoginHelp", "updateServerInfo" + serverID);
		platform_str = pTigerToInfo.getPlatform();

		if (platform_str.equals("Android_HuTuo"))
			mDesBol = true;

		if (gameId == null || gameId.equals("") || yaUid == null
				|| yaUid.equals("")) {
			Log.w("TigerToLastLoginHelp", "gameid or yauid invalid");
			return;
		}
		//
		switchPushGet = pushSvr;
		switchPushGet = true;
		if (dynamicFile.exists() && dynamicFile.isFile()) { // 判断目录是否存在
			String _switch = IniFileUtil.GetPrivateProfileString(
					dynamicFile.getAbsolutePath(), "Push_Get", "Switch", "0");
			Log.w("TigerToLastLoginHelp", "_switch" + _switch);
			if (!_switch.equals("1"))
				switchPushGet = false;
		}
		// 存服务器
		JSONObject message = new JSONObject();
		JSONObject data = new JSONObject();
		try {

			data.put("puid", yaUid);
			data.put("serverId", serverID);
			data.put("playerId", pTigerToInfo.getPlayerId());
			data.put("playerName", pTigerToInfo.getPlayerName());
			data.put("gameCoin1", pTigerToInfo.getGameCoin1());
			data.put("gameCoin2", pTigerToInfo.getGameCoin2());
			data.put("vipLvl", pTigerToInfo.getVipLv1());
			data.put("playerLvl", pTigerToInfo.getPlayerLv1());

			data.put("geXingClientId", gexingClientId);
			data.put("geXingTags", gexingTags);

			message.put("data", data);
			JSONObject header = new JSONObject();
			header.put("gameId", gameId);
			header.put("platform", platform_str);
			header.put("deviceMacId", DeviceUtil.getDeviceUUID(activityGame));
			header.put("timestamp", SystemClock.currentThreadTimeMillis());
			header.put("deviceName",
					DeviceUtil.getDeviceProductName(activityGame));
			message.put("header", header);
		} catch (JSONException e1) {
			e1.printStackTrace();
		}
		String pushMsg = message.toString();
		Log.w("TigerToLastLoginHelp:message.toString", pushMsg);
		if (switchPushGet) {
			pushforclient(pushMsg, new RequestListener() {

				@Override
				public void onComplete(String response) {
					Log.w("TigerToLastLoginHelp", response);
				}

				@Override
				public void onIOException(IOException e) {
					Log.w("TigerToLastLoginHelp", "IOException");
				}

				@Override
				public void onError(Exception e) {
					Log.w("TigerToLastLoginHelp", "Exception");
				}

			});
		}

		String jsonsavestr = readJSONFromSD();
		if (jsonsavestr == null || jsonsavestr.equals("")) {
			/*
			 * 无数据，重新初始空白文件，并写入第一组数据
			 */
			JSONObject tosaveObj = new JSONObject();
			JSONArray tosavearray = new JSONArray();
			JSONObject tosaveitem = new JSONObject();
			try {
				String _yaUid;
				if (mDesBol) {
					_yaUid = DES.encryptDES("tigerto", yaUid);
				} else {
					_yaUid = yaUid;
				}
				tosaveitem.put("puid", _yaUid);
				tosaveitem.put("gameId", gameId);
				tosaveitem.put("playerName", pTigerToInfo.getPlayerName());
				tosaveitem.put("serverId", serverID);
				tosaveitem.put("lastlogintime", System.currentTimeMillis());
				tosavearray.put(tosaveitem);

				tosaveObj.put(_yaUid, tosavearray);

				writeJSONObjectToSdCard(tosaveObj);
			} catch (JSONException e) {
				e.printStackTrace();
			} catch (Exception e) {
				e.printStackTrace();
			}

			return;
		} else {

			JSONObject jsonsave = null;
			JSONArray savejsonUser = null;
			try {
				jsonsave = new JSONObject(jsonsavestr);

				String _yaUid;
				if (mDesBol) {
					_yaUid = DES.encryptDES("tigerto", yaUid);
				} else {
					_yaUid = yaUid;
				}
				savejsonUser = jsonsave.optJSONArray(_yaUid);
			} catch (JSONException e) {
				e.printStackTrace();
				/*
				 * 错误的数据，重新初始空白文件，并写入第一组数据
				 */
				JSONObject tosaveObj = new JSONObject();
				JSONArray tosavearray = new JSONArray();
				JSONObject tosaveitem = new JSONObject();
				try {
					String _yaUid;
					if (mDesBol) {
						_yaUid = DES.encryptDES("tigerto", yaUid);
					} else {
						_yaUid = yaUid;
					}
					tosaveitem.put("puid", _yaUid);
					tosaveitem.put("gameId", gameId);
					tosaveitem.put("playerName", pTigerToInfo.getPlayerName());
					tosaveitem.put("serverId", serverID);
					tosaveitem.put("lastlogintime", System.currentTimeMillis());
					tosavearray.put(tosaveitem);
					tosaveObj.put(_yaUid, tosavearray);
					writeJSONObjectToSdCard(tosaveObj);
				} catch (JSONException e2) {
					e2.printStackTrace();
				} catch (Exception e2) {
					e.printStackTrace();
				}
				return;
			} catch (Exception e) {
				e.printStackTrace();
			}

			if (null == readJSONFromSD()) {
				savejsonUser = null;
			}

			if (savejsonUser == null) {
				JSONArray tosavearray = new JSONArray();
				JSONObject tosaveitem = new JSONObject();

				try {
					String _yaUid;
					if (mDesBol) {
						_yaUid = DES.encryptDES("tigerto", yaUid);
					} else {
						_yaUid = yaUid;
					}

					tosaveitem.put("puid", _yaUid);
					tosaveitem.put("gameId", gameId);
					tosaveitem.put("playerName", pTigerToInfo.getPlayerName());
					tosaveitem.put("serverId", serverID);
					tosaveitem.put("lastlogintime", System.currentTimeMillis());
					tosavearray.put(tosaveitem);
					jsonsave.put(_yaUid, tosavearray);
				} catch (JSONException e) {
					e.printStackTrace();
				} catch (Exception e) {
					e.printStackTrace();
				}
			} else {
				found = false;
				int length = savejsonUser.length();
				for (int i = 0; i < length; i++) {
					JSONObject saveitem = null;
					try {
						saveitem = savejsonUser.getJSONObject(i);
						Log.w("TigerToLastLoginHelp",
								"serverId" + saveitem.getInt("serverId"));
						if (saveitem.getInt("serverId") == serverID) {
							found = true;
							saveitem.put("lastlogintime",
									System.currentTimeMillis());

							String _yaUid;
							if (mDesBol) {
								_yaUid = DES.encryptDES("tigerto", yaUid);
							} else {
								_yaUid = yaUid;
							}
							jsonsave.put(_yaUid, savejsonUser);
							break;
						}
					} catch (JSONException e) {
						e.printStackTrace();
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				//
				if (found == false) {
					JSONObject tosaveitem = new JSONObject();

					try {
						String _yaUid;
						if (mDesBol) {
							_yaUid = DES.encryptDES("tigerto", yaUid);
						} else {
							_yaUid = yaUid;
						}
						tosaveitem.put("puid", _yaUid);
						tosaveitem.put("gameId", gameId);
						tosaveitem
								.put("playerName", pTigerToInfo.getPlayerName());
						tosaveitem.put("serverId", serverID);
						tosaveitem.put("lastlogintime",
								System.currentTimeMillis());
						savejsonUser.put(tosaveitem);
					} catch (JSONException e) {
						e.printStackTrace();
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
				//

			}

			writeJSONObjectToSdCard(jsonsave);

			for (TigerToServerInfo aInfo : tigetToInfos) {
				if (aInfo.getServerId() == serverID) {
					found = true;
					aInfo.setLastLoginTime(System.currentTimeMillis());
					break;
				}
			}
			if (found == false) {
				TigerToServerInfo nowuserServer = new TigerToServerInfo();

				nowuserServer.setPuid(yaUid);
				nowuserServer.setGameCoin1(pTigerToInfo.getGameCoin1());
				nowuserServer.setGameCoin2(pTigerToInfo.getGameCoin2());
				nowuserServer.setPlayerLv1(pTigerToInfo.getPlayerLv1());
				nowuserServer.setServerId(serverID);
				nowuserServer.setVipLv1(pTigerToInfo.getVipLv1());
				nowuserServer.setPlayerName(pTigerToInfo.getPlayerName());
				nowuserServer.setGameId(gameId);
				nowuserServer.setLastLoginTime(System.currentTimeMillis());
				//
				tigetToInfos.add(nowuserServer);
			}
		}

		/*
		 * 按LastLoginTime降序排列
		 */
		if (tigetToInfos.size() > 0) {
			Ordercomparator comp = new Ordercomparator();
			Collections.sort(tigetToInfos, comp);
		}

	}

	// 刷新游戏服务器信息，用于切换用户后重置服务器列表
	@SuppressWarnings("unchecked")
	public static void refreshServerInfo(String gameid, String puid,
			TigerToServerInfo pTigerToServerInfo, boolean getSvr) {
		Log.w("TigerToServerInfo", "refreshServerInfo+gameid" + gameid
				+ "puid" + puid);
		// 检查本地，填充list 没有：自己去拉 填充list;

		if (gameId == gameid && yaUid == puid) {
			return;
		}
		//
		switchPushGet = getSvr;
		switchPushGet = true;
		//
		File rootfiles = new File(activityGame.getAppFilesResourcesPath());
		dynamicFile = new File(rootfiles.getAbsoluteFile() + File.separator
				+ "dynamic.ini");
		if (dynamicFile.exists() && dynamicFile.isFile()) { // 判断目录是否存在
			String _switch = IniFileUtil.GetPrivateProfileString(
					dynamicFile.getAbsolutePath(), "Push_Get", "Switch", "0");
			Log.w("TigerToServerInfo", "_switch" + _switch);
			if (!_switch.equals("1"))
				switchPushGet = false;
		}

		gameId = gameid;
		yaUid = puid;
		tigetToInfos.clear();

		if (pTigerToServerInfo.getPlatform().equals("Android_HuTuo"))
			mDesBol = true;

		saveFile = new File(Environment.getExternalStorageDirectory()
				+ File.separator + "tigerto" + File.separator + gameid
				+ pTigerToServerInfo.getPlatform() + "_user"); // 数据库文件
		if (!saveFile.exists()) { // 判断文件是否存在
			try {
				saveFile.createNewFile(); // 创建文件
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		String jsonsavestr = readJSONFromSD();
		if (jsonsavestr == null || jsonsavestr.equals("")) {
			pTigerToServerInfo.setGameId(gameid);
			pTigerToServerInfo.setPuid(puid);
			// 从服务器拉数据
			JSONObject message = new JSONObject();
			JSONObject data = new JSONObject();
			try {
				data.put("puid", puid);
				message.put("data", data);
				message.put("header", makeHead(activityGame, pTigerToServerInfo));
			} catch (JSONException e1) {
				e1.printStackTrace();
			}

			if (switchPushGet)
				getFromNet(message);

		} else {
			JSONObject jsonsave = null;
			JSONArray savejsonUser = null;
			try {
				jsonsave = new JSONObject(jsonsavestr);

				String _yaUid;
				if (mDesBol) {
					_yaUid = DES.encryptDES("tigerto", yaUid);
				} else {
					_yaUid = yaUid;
				}
				savejsonUser = jsonsave.optJSONArray(_yaUid);
			} catch (JSONException e) {
				e.printStackTrace();
				return;
			} catch (Exception e) {
				e.printStackTrace();
				return;
			}

			int length;
			if (savejsonUser == null) {
				length = 0;
			} else {
				length = savejsonUser.length();
			}

			if (length == 0) {
				TigerToServerInfo pTigerToInfo = new TigerToServerInfo();
				pTigerToInfo.setGameId(gameid);
				pTigerToInfo.setPuid(puid);
				// 从服务器拉数据
				JSONObject message = new JSONObject();
				JSONObject data = new JSONObject();
				try {
					data.put("puid", puid);
					message.put("data", data);
					message.put("header", makeHead(activityGame, pTigerToInfo));
				} catch (JSONException e1) {
					e1.printStackTrace();
					// return;
				}

				if (switchPushGet)
					getFromNet(message);
			} else {
				Log.w("TigerToLastLoginHelp", "length" + length);
				for (int i = 0; i < length; i++) {
					JSONObject saveitem = null;
					try {
						saveitem = savejsonUser.getJSONObject(i);
						TigerToServerInfo _userServer = new TigerToServerInfo();
						if (mDesBol) {
							_userServer.setPuid(DES.decryptDES("tigerto",
									saveitem.getString("puid")));
						} else {
							_userServer.setPuid(saveitem.getString("puid"));
						}
						_userServer.setServerId(saveitem.getInt("serverId"));
						_userServer.setPlayerName(saveitem
								.getString("playerName"));
						_userServer.setLastLoginTime(saveitem
								.optLong("lastlogintime"));
						tigetToInfos.add(_userServer);
					} catch (JSONException e) {
						e.printStackTrace();
						// return;
					} catch (Exception e) {
						e.printStackTrace();
						// return;
					}

				}
			}

		}

		/*
		 * 按LastLoginTime降序排列
		 */
		if (tigetToInfos.size() > 0) {
			Ordercomparator comp = new Ordercomparator();
			Collections.sort(tigetToInfos, comp);
		}
		Log.i("tigetToInfos", "tigetToInfos" + tigetToInfos.size());
	}

	// *存本地
	static void getFromNet(final JSONObject pMessage) {
		getPlayerList(pMessage.toString(), new RequestListener() {
			@Override
			public void onIOException(IOException e) {
				Log.w("onIOException", "onIOException" + e.toString());
			}

			@Override
			public void onError(Exception e) {
				Log.w("onError", "onError" + e.toString());
			}

			@SuppressWarnings("unchecked")
			@Override
			public void onComplete(String response) {
				Log.w("onComplete", "onComplete" + response);
				JSONObject jsonServer;
				try {
					jsonServer = new JSONObject(response);
					String error = jsonServer.getString("error");
					// String errorMsg = jsonServer.getString("errorMessage");
					if (error.equals("200")) {
						JSONArray players = jsonServer.getJSONObject("data")
								.getJSONArray("players");

						int length = players.length();
						for (int i = 0; i < length; i++) {
							TigerToServerInfo serverUser = new TigerToServerInfo();
							String playerName = players.getJSONObject(i)
									.getString("name");
							int serverId = players.getJSONObject(i).getInt(
									"serverId");
							serverUser.setPlayerName(playerName);
							serverUser.setGameId(gameId);
							serverUser.setServerId(serverId);

							boolean bContinue = false;
							for (TigerToServerInfo info : tigetToInfos) {
								if (info.getServerId() == serverId) {
									bContinue = true;
									break;
								}
							}
							if (bContinue) {
								continue;
							}

							tigetToInfos.add(serverUser);

						}

						JSONObject tosaveObj = new JSONObject();
						JSONArray tosavearray = new JSONArray();
						JSONObject tosaveitem;

						long _lastTime = 0l;
						String _yaUid = null;
						try {
							if (mDesBol) {
								_yaUid = DES.encryptDES("tigerto", yaUid);
							} else {
								_yaUid = yaUid;
							}

						} catch (Exception e1) {
							e1.printStackTrace();
							return;
						}
						for (int i = tigetToInfos.size() - 1; i >= 0; i--) {

							tosaveitem = new JSONObject();
							try {
								tosaveitem.put("puid", _yaUid);
								tosaveitem.put("gameId", gameId);
								tosaveitem.put("playerName", tigetToInfos.get(i)
										.getPlayerName());
								tosaveitem.put("serverId", tigetToInfos.get(i)
										.getServerId());
								long time = System.currentTimeMillis();
								tosaveitem.put("lastlogintime", time);
								if (time == _lastTime)
									time++;
								_lastTime = time;
								tigetToInfos.get(i).setLastLoginTime(time);
								tosavearray = tosavearray.put(tosaveitem);
								tosaveObj = tosaveObj.put(_yaUid, tosavearray);
							} catch (JSONException e) {
								e.printStackTrace();
							} catch (Exception e) {
								e.printStackTrace();
							}

						}

						if (players.length() > 0)
							writeJSONObjectToSdCard(tosaveObj);

					}
				} catch (JSONException e) {
					e.printStackTrace();
				}

			}
		});

	}

	public static JSONObject makeHead(Context context,
			TigerToServerInfo pTigerToInfo) {

		JSONObject header = new JSONObject();
		try {
			header.put("gameId", pTigerToInfo.getGameId());
			header.put("platform", pTigerToInfo.getPlatform());
			header.put("deviceMacId", DeviceUtil.getDeviceUUID(context));
			header.put("timestamp", SystemClock.currentThreadTimeMillis());
			header.put("deviceName", DeviceUtil.getDeviceProductName(context));

		} catch (JSONException e1) {
			e1.printStackTrace();
		}

		return header;
	}

	// 获得账号服务器上记录的游戏服务器数量
	public static int getServerInfoCount() {
		Log.w("TigerToLastLoginHelp", "getServerInfoCount" + tigetToInfos.size());
		// 返回list count;
		int size = tigetToInfos.size();
		if (size > 12)
			return 12;
		return size;

	}

	// 根据顺序获得账号服务器上第n个游戏服务器的服务器ID
	public static int getServerUserByIndex(int index) {

		Log.w("TigerToLastLoginHelp", "getServerUserByIndex" + index);
		if (tigetToInfos.size() <= 0)
			return 0;
		Log.w("TigerToLastLoginHelp", "serverId:"
				+ tigetToInfos.get(index).getServerId());
		return tigetToInfos.get(index).getServerId();

	}

	public static String readJSONFromSD() {

		String jsonStr = "";

		if (saveFile.exists()) {

			try {
				FileReader fileRe = new FileReader(saveFile);
				BufferedReader buffRe = new BufferedReader(fileRe);

				String temp;
				while ((temp = buffRe.readLine()) != null) {
					jsonStr = jsonStr + temp;
				}
				buffRe.close();
				fileRe.close();
			} catch (FileNotFoundException e) {
				Log.i("TigerToLastLoginHelp", e.toString());
				return null;
				// e.printStackTrace();
			} catch (IOException e) {
				Log.i("TigerToLastLoginHelp", e.toString());
				return null;
				// e.printStackTrace();
			}

		}

		{/*
		 * 容错，返回正确的JsonObj或者null
		 */

			JSONObject jsonsave = null;
			JSONArray savejsonUser = null;
			try {
				jsonsave = new JSONObject(jsonStr);
			} catch (JSONException e1) {
				return null;
			}

			String _yaUid;
			try {
				if (mDesBol) {
					_yaUid = DES.encryptDES("tigerto", yaUid);
				} else {
					_yaUid = yaUid;
				}
			} catch (Exception e1) {
				e1.printStackTrace();
				return null;
			}
			savejsonUser = jsonsave.optJSONArray(_yaUid);

			if (savejsonUser != null) {
				

				for (int i = 0; i < savejsonUser.length(); i++) {
					try {
						JSONObject testsaveitem = savejsonUser.optJSONObject(i);
						testsaveitem.get("puid");
						testsaveitem.get("gameId");
						testsaveitem.get("playerName");
						testsaveitem.get("serverId");
						testsaveitem.get("lastlogintime");
					} catch (Exception e) {
						return null;
					}
				}

			} else {
				return jsonStr;
			}

		}

		return jsonStr;
	}

	public static void writeJSONObjectToSdCard(JSONObject pServerObj) {

		if (!saveFile.getParentFile().exists()) {
			saveFile.getParentFile().mkdirs();
		}
		if (!saveFile.exists() && !saveFile.isFile()) {
			try {
				saveFile.createNewFile();
			} catch (IOException e) {
				Log.i("TigerToLastLoginHelp", e.toString());
				return;
			}
		}

		PrintStream outputStream = null;
		try {
			outputStream = new PrintStream(new FileOutputStream(saveFile));
			outputStream.print(pServerObj.toString());
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} finally {
			if (outputStream != null) {
				outputStream.close();
			}
		}
	}

	public static String getURL(String name) {
		String url = "";
		File rootfiles = new File(activityGame.getAppFilesResourcesPath());
		dynamicFile = new File(rootfiles.getAbsoluteFile() + File.separator
				+ "dynamic.ini");
		if (dynamicFile.exists() && dynamicFile.isFile()) { // 判断目录是否存在
			url = IniFileUtil.GetPrivateProfileString(
					dynamicFile.getAbsolutePath(), "interface", name, "0");
		}

		return url;
	}

	public static void getPlayerList(final String param,
			final RequestListener listener) {
		String tempStr = null;
		URL url;
		HttpURLConnection url_con = null;
		try {
			final String checksum;
			final String encript;
			encript = RSAUtil.encryptByPubKey(param, RSAUtil.pub_key_hand);
			checksum = MD5.sign(encript, "-tiger");
			url = new URL(getURL("getLastloginServer"));
			url_con = (HttpURLConnection) url.openConnection();
			url_con.setRequestMethod("PUT");
			url_con.addRequestProperty("Game-Checksum", checksum);
			url_con.setDoOutput(true);
			url_con.setConnectTimeout(3000);
			url_con.setReadTimeout(3000);
			url_con.getOutputStream().write(encript.getBytes());
			url_con.getOutputStream().flush();
			url_con.getOutputStream().close();
			Log.w("TigerToLastLoginHelp", "status" + url_con.getResponseCode());
			if (url_con.getResponseCode() == 200) {
				InputStream in = url_con.getInputStream();
				BufferedReader bufferRe = new BufferedReader(
						new InputStreamReader(in));
				StringBuffer sb = new StringBuffer("");
				String line = "";
				while ((line = bufferRe.readLine()) != null) {
					sb.append(line);
				}
				in.close();
				tempStr = sb.toString();
				String response = RSAUtil.decryptByPubKey(tempStr,
						RSAUtil.pub_key_hand);
				listener.onComplete(response);
			} else {
				listener.onError(new Exception("url_con.getResponseCode()"));
			}

		} catch (MalformedURLException e) {
			listener.onError(e);
		} catch (IOException e) {
			listener.onIOException(e);
		} catch (Exception e) {
			Log.w("TigerToLastLoginHelp", "catch Exception :" + e.toString());
			listener.onError(e);
		} finally {
			if (url_con != null)
				url_con.disconnect();
		}
	}

	public static void pushforclient(final String param,
			final RequestListener listener) {
		new Thread() {
			public void run() {
				String tempStr = null;
				URL url;
				HttpURLConnection url_con = null;
				try {
					final String checksum;
					final String encript;
					encript = RSAUtil.encryptByPubKey(param,
							RSAUtil.pub_key_hand);
					checksum = MD5.sign(encript, "-tigerto");
					url = new URL(getURL("pushLastloginServer"));
					url_con = (HttpURLConnection) url.openConnection();
					url_con.setRequestMethod("PUT");
					url_con.addRequestProperty("Game-Checksum", checksum);
					url_con.setDoOutput(true);
					url_con.getOutputStream().write(encript.getBytes());
					url_con.getOutputStream().flush();
					url_con.getOutputStream().close();
					Log.w("TigerToLastLoginHelp",
							"status" + url_con.getResponseCode());
					// if(url_con.getResponseCode()==200){
					InputStream in = url_con.getInputStream();
					BufferedReader bufferRe = new BufferedReader(
							new InputStreamReader(in));
					StringBuffer sb = new StringBuffer("");
					String line = "";
					while ((line = bufferRe.readLine()) != null) {
						sb.append(line);
					}
					in.close();
					tempStr = sb.toString();
					listener.onComplete(RSAUtil.decryptByPubKey(tempStr,
							RSAUtil.pub_key_hand));
				} catch (MalformedURLException e) {
					listener.onError(e);
				} catch (IOException e) {
					listener.onIOException(e);
				} catch (Exception e) {
					e.printStackTrace();
				} finally {
					if (url_con != null)
						url_con.disconnect();
				}
			};
		}.start();
	}

	public static void setGexingClientId(String gexingClientId) {
		TigerToLastLoginHelp.gexingClientId = gexingClientId;
	}

	public static void setGexingTags(String gexingTags) {
		TigerToLastLoginHelp.gexingTags = gexingTags;
	}

	public interface RequestListener {

		public void onComplete(String response);

		public void onIOException(IOException e);

		public void onError(Exception e);

	}

}

@SuppressWarnings("hiding")
class Ordercomparator implements Comparator {

	public int compare(Object o1, Object o2) {
		long time1 = ((TigerToServerInfo) o1).getLastLoginTime();
		long time2 = ((TigerToServerInfo) o2).getLastLoginTime();
		if (time1 > time2) {
			return -1;
		} else if (time1 < time2) {
			return 1;
		} else {
			return 0;
		}
	}
}

@SuppressWarnings("hiding")
class Reversecomparator implements Comparator {

	public int compare(Object o1, Object o2) {

		long time1 = ((TigerToServerInfo) o1).getLastLoginTime();
		long time2 = ((TigerToServerInfo) o2).getLastLoginTime();
		if (time1 > time2) {
			return 1;
		} else if (time1 < time2) {
			return -1;
		} else {
			return 0;
		}
	}

}

class DES {

	private static byte[] iv = { 1, 2, 3, 4, 5, 6, 7, 8 };

	/**
	 * CBC是工作模式 PKCS5Padding是填充模式，还有其它的填充模式
	 */
	private static final String ALGORITHM_DES = "DES/CBC/PKCS5Padding";

	/**
	 * DES算法，加密
	 * 
	 * @param encryptKey
	 *            加密私钥，长度不能够小于8位
	 * @param encryptString
	 *            待加密字符串
	 * @return 加密后的结果一般都会用base64编码进行传输
	 * @throws CryptException
	 *             异常
	 */
	public static String encryptDES(String encryptKey, String encryptString)
			throws Exception {
		IvParameterSpec zeroIv = new IvParameterSpec(iv);
		SecretKeySpec key = new SecretKeySpec(encryptKey.getBytes(), "DES");
		Cipher cipher = Cipher.getInstance(ALGORITHM_DES);
		/**
		 * zeroIv初始化向量，注意：必须设置，否则会调用平台默认的 不通平台不一样
		 */
		cipher.init(Cipher.ENCRYPT_MODE, key, zeroIv);
		byte[] encryptedData = cipher.doFinal(encryptString.getBytes());
		return Base64.encodeToString(encryptedData, 0);
	}

	/**
	 * DES算法，解密
	 * 
	 * @param decryptString
	 *            解密私钥，长度不能够小于8位
	 * @param decryptKey
	 *            待解密字符串
	 * @return 解密后的字符串（明文）
	 * @throws Exception
	 */
	public static String decryptDES(String decryptKey, String decryptString)
			throws Exception {
		byte[] byteMi = Base64.decode(decryptString, 0);
		IvParameterSpec zeroIv = new IvParameterSpec(iv);
		SecretKeySpec key = new SecretKeySpec(decryptKey.getBytes(), "DES");
		Cipher cipher = Cipher.getInstance(ALGORITHM_DES);
		cipher.init(Cipher.DECRYPT_MODE, key, zeroIv);
		byte decryptedData[] = cipher.doFinal(byteMi);
		return new String(decryptedData);
	}
}
