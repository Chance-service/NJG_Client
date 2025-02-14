package com.nuclear.gjwow;

import org.json.JSONException;
import org.json.JSONObject;

import com.chance.allsdk.SDKFactory;
import com.nuclear.manager.MessageManager;
import com.nuclear.manager.MessageManager.MessageListener;

import android.util.Log;

import ConstValue.PlatformConst;


public class LastLoginHelp {

	static GameActivity mGameActivity;
	public static String mGameid;
	public static String mPuid;
	public static int mServerID;

	public static int mPlayerId;
	public static String mPlayerName;
	public static int mVipLvl;
	public static int mlv;
	public static String mPlatform;
	public static int mPlayervl;
	public static int coin2;

	public static void setActivity(GameActivity pGameActivity) {

		mGameActivity = pGameActivity;
		TigerToLastLoginHelp.setTigerToLastLoginHelp(mGameActivity);
		MessageListener listener = new MessageListener() {
			@Override
			public void registerMsg(){
				MessageManager.getInstance().setMsgHandler("updateServerInfo",this);
				MessageManager.getInstance().setMsgHandler("refreshServerInfo",this);
				MessageManager.getInstance().setMsgHandler("getServerInfoCount",this);
				MessageManager.getInstance().setMsgHandler("getServerUserByIndex",this);
			}
			
			@Override
			public void unregisterMsg(){
				MessageManager.getInstance().removeMsgHandler("updateServerInfo");
				MessageManager.getInstance().removeMsgHandler("refreshServerInfo");
				MessageManager.getInstance().removeMsgHandler("getServerInfoCount");
				MessageManager.getInstance().removeMsgHandler("getServerUserByIndex");
			}
			
			public String updateServerInfo(String msg){
				JSONObject obj;
				try {
					obj = new JSONObject(msg);
					int serverID = obj.getInt("serverID");
					String playerName = obj.getString("playerName");
					int playerID= obj.getInt("playerID");
					int lvl= obj.getInt("lvl");
					int vipLvl= obj.getInt("vipLvl");
					int coin1= obj.getInt("coin1");
					int coin2= obj.getInt("coin2");
					boolean pushSvr= obj.getBoolean("pushSvr");
					LastLoginHelp.updateServerInfo(serverID, playerName, playerID, lvl, vipLvl, coin1, coin2, pushSvr);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				return null;
			};
			
			public String refreshServerInfo(String msg){
				JSONObject obj;
				try {
					obj = new JSONObject(msg);
					String gameid = obj.getString("gameid");
					String puid = obj.getString("puid");
					boolean getSvr = obj.getBoolean("getSvr");
					LastLoginHelp.refreshServerInfo(gameid, puid, getSvr);
				} catch (JSONException e) {
					e.printStackTrace();
				}
				return null;
			};
			
			public String getServerInfoCount(String msg){
				return String.valueOf(LastLoginHelp.getServerInfoCount());
			};
			
			public String getServerUserByIndex(String msg){
				int index;
				JSONObject obj;
				try {
					obj = new JSONObject(msg);
					index = Integer.valueOf(obj.getString("index"));
					return String.valueOf(LastLoginHelp.getServerUserByIndex(index));
				} catch (Exception e) {
					e.printStackTrace();
				}
				return null;
			};

		};
		
		listener.registerMsg();
	}

	public static void updateServerInfo(int serverID, String playerName,
			int playerID, int lvl, int vipLvl, int coin1, int coin2,
			boolean pushSvr) {
		mServerID = serverID;
		mPlayerId = playerID;
		mPlayerName = playerName;
		mVipLvl = vipLvl;
		mPlayervl = vipLvl;
		mlv = lvl;
		TigerToServerInfo _tigerToServerInfo = new TigerToServerInfo();
		if (mPlatform == null)
			mPlatform = mGameActivity.getClientChannel();
		_tigerToServerInfo.setPlatform(mPlatform);
		_tigerToServerInfo.setPlayerName(playerName);
		_tigerToServerInfo.setPlayerId(playerID);
		_tigerToServerInfo.setVipLv1(vipLvl);
		_tigerToServerInfo.setPlayerLv1(lvl);
		_tigerToServerInfo.setGameCoin1(coin1);
		_tigerToServerInfo.setGameCoin2(coin2);
		_tigerToServerInfo.setServerId(serverID);
		//
		// gexinclientid string
		// gexintags string, "tag1 tag2 tag3"
		//
		Log.i("======================", "name:" + playerName + "playid"
				+ playerID + "lvl:" + lvl);
		//
		Log.e("logingame", "updateServerInfo");
		mGameActivity.getMainThreadHandler().postDelayed(new Runnable() {
			@Override
			public void run() {
				mGameActivity.onLoginGame();
			}
		},8000);

		TigerToLastLoginHelp
				.updateServerInfo(serverID, _tigerToServerInfo, pushSvr);

		SDKFactory.getInstance().getSDKHandler().setServerId(serverID);
	}

	public static void refreshServerInfo(String gameid, String puid,
			boolean getSvr) {
		mGameid = gameid;
		mPuid = puid;
		TigerToServerInfo _tigerToServerInfo = new TigerToServerInfo();
		_tigerToServerInfo.setPlatform(mGameActivity.getClientChannel());
		TigerToLastLoginHelp.refreshServerInfo(gameid, puid, _tigerToServerInfo,
				getSvr);
	}

	public static int getServerInfoCount() {
		return TigerToLastLoginHelp.getServerInfoCount();
	}

	public static int getServerUserByIndex(int index) {
		return TigerToLastLoginHelp.getServerUserByIndex(index);

	}

}
