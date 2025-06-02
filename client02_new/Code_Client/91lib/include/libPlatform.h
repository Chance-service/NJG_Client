
#include <set>
#include <string>
#include <map>
#include "json/json.h"

#ifndef __LIBPLATFORM_H__
#define __LIBPLATFORM_H__

#define AUTO_REGISTER_PLATFORM(classtype) \
	bool ret_##classtype = libPlatformManager::getInstance()->registerPlatform(#classtype, new classtype);

class libPlatform;

struct BUYINFO
{
	BUYINFO()
		:productType(1), name(""), cooOrderSerial(""), productId(""), productName("")
		, productPrice(1), productOrignalPrice(1), productCount(1), description(""), serverTime(0), extras(""){}
	unsigned int productType;
	std::string name;
	std::string cooOrderSerial;
	std::string productId;
	std::string productName;//display on dev.91.com
	float productPrice;
	float productOrignalPrice;
	unsigned int productCount;
	std::string description;
	unsigned int serverTime;
	std::string extras;
	void clear()
	{
		productType = 1;
		name = "";
		cooOrderSerial = "";
		productId = "";
		productName = "";
		productPrice = 1; 
		productOrignalPrice = 1;
		productCount = 1; 
		description = "";
		serverTime = 0;
		extras = "";
	}
};

//�ۦ����x�Ѽ�
struct COM4LOVES_CONFIG_STU
{
	COM4LOVES_CONFIG_STU()
		:sdkappid(""), sdkappkey(""), channelid(""), platformid(""), appid(""), appstore_phpIP(""), appstore_phpURL(""){}
	std::string sdkappid;       //���R ��x�έp�Ϊ�appid
	std::string sdkappkey;      //���R ��x�έp�Ϊ�appkey
	std::string channelid;      //�U�Ӥp��D��D��
	std::string platformid;     //��D�W 91�App�Aappstore�Ahutuo����
	std::string appid;          //(�έp�ΡA����@�λݽT�{)
	std::string appstore_phpIP; //AppStore�M�� ��I�a�}IP
	std::string appstore_phpURL;//AppStore�M�� ��I�a�}URL
};

struct PLATFORM_CONFIG_STU
{
	PLATFORM_CONFIG_STU()
		:appkey(""), appid(""), uidPrefix(""), bbsurl(""), clientChannel(""), moneyName(""), merchantId(""), appScheme(""), bRelogin(true){}
	std::string appkey;        //�T��SDKappkey
	std::string appid;         //�T��SDKappid
	std::string uidPrefix;     //uid �e��
	std::string bbsurl;        //�׾¦a�}
	std::string clientChannel; //�U�Ӥp��D�Ϥ�
	std::string moneyName;     //��~����W��
	std::string merchantId;    //���x��D
	std::string appScheme;     //�C���W(KY�B���֥Ψ�)
	bool        bRelogin;      //���P�C���^��n������
};

struct SDK_CONFIG_STU
{
	PLATFORM_CONFIG_STU  platformconfig;  //�T��SDK�һݰѼ�
	COM4LOVES_CONFIG_STU com4lovesconfig; //com4lovesSDK�һݰѼ�
};


class platformListener
{
public:
	virtual void onInit(libPlatform*, bool success, const std::string& log){};
	virtual void onUpdate(libPlatform*, bool ok, std::string msg){};
	virtual void onLogin(libPlatform*, bool success, const std::string& log){};
	virtual void onPlatformLogout(libPlatform*){};
	virtual void onBuyinfoSent(libPlatform*, bool success, const BUYINFO&, const std::string& log){};
	virtual void onRequestBindTryUserToOkUser(const char* tyrUin, const char* okUin){};
	virtual void onTryUserRegistSuccess(){};
	virtual void onShareEngineMessage(bool result){};
	virtual void onPlayMovieEnd(){};
	virtual void onMotionShake(){};
	virtual void onReLogin(){};
	virtual void onFBShareBack(bool success){};
	//return value is a member to a map of key for first and value for second
	virtual std::string onReceiveCommonMessage(const std::string& tag, const std::string& msg){ return ""; };

	//����kakao�n�ͦ^��
	//��o�ܽЦ���
	virtual void onKrGetInviteCount(int nCount){};
	virtual void onKrgetInviteLists(const std::string& strInviteInfo){};
	virtual void onKrgetFriendLists(const std::string& strFriendInfo){};
	virtual void onKrsendInvite(const std::string& result){};
	virtual void onKrgetGiftLists(const std::string& strGiftList){};
	virtual void onKrReceiveGift(bool result){};
	virtual void onKrGetGiftCount(int nCount){};
	virtual void onKrSendGift(const std::string& result){};
	virtual void onKrGiftBlock(const std::string& result){};
	//CDKey�^��
	virtual void onKrCouponsBack(const std::string& resultStr){};
	virtual void OnKrGetKakaoIdBack(const std::string& resultStr){};
	//kakao�B�ziOS�����f�֮ɱ���������ê��\����s
	virtual void OnKrIsShowFucForIOSBack(bool result){};
	virtual void OnDownloadProgress(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, long progress){};
	virtual void OnDownloadComplete(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, const std::string& md5Str){};
	virtual void OnDownloadFailed(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, int errorCode){};
};

class libPlatform
{
	std::set<platformListener*> mListeners;

public:
	/**
	NOTICE: Platform should call _boardcastInitDone to notify client logic WHEN initialization is done.
	*/
	virtual void initWithConfigure(const SDK_CONFIG_STU& configure) = 0;
  virtual void setupSDK(int platformId) = 0;

	/**
	MUST call this function AFTER updating is done(after call back function).
	NOTICE: Platform should call _boardcastLoginResult to notify client logic WHEN login is done.
	*/
	virtual void login() = 0;

	/** check whether is logined */
	virtual bool getLogined() = 0;

	virtual bool getIsH365() = 0;

	virtual int getHoneyP() = 0;
	
	virtual int getIsGuest() = 0;

	/** IMPORTANT: get the only ID for game. MUST be unique! */
	virtual const std::string& loginUin() = 0;

	virtual const std::string& getToken() = 0;

	virtual void showPlatformProfile() = 0;

	virtual const std::string getClientChannel() = 0;

	virtual const std::string getClientCps() = 0;

	virtual const std::string getBuildType() = 0;

	virtual const std::string getChannelID(){ return ""; }

	virtual std::string getPlatformMoneyName() = 0;

	virtual const unsigned int getPlatformId() = 0;

	virtual void updateApp(std::string &storeUrl);

	/** logout platform*/
	virtual void logout();

	/** optional: finalize the platform*/
	virtual void final();

	/** show the platform window to switch users */
	virtual void switchUsers();

	/** buy platform RMB*/
	virtual void buyGoods(BUYINFO&);

	/** call platform open bbs function. if the platform doesn't have this usage, just open an url! */
	virtual void openBBS();

	/** call platform open feedback function. if the platform doesn't have this usage, just open an email link! */
	virtual void userFeedBack();

	/** optional: call platform open game pause function.*/
	virtual void gamePause();

	/*
	if the login uin is try user of this platform
	*/
	virtual bool getIsTryUser();
	/*

	*/
	virtual void callPlatformBindUser();
	/*
	the ok user puid alread has one player in this serverid
	0:failed, pls retry
	1:success, pls change to platform sdk client and server
	*/
	virtual void notifyGameSvrBindTryUserToOkUserResult(int result);

	/** optional: get the session ID.*/
	virtual const std::string& sessionID();
	/** optional: get the nick name. which is shown on the loading scene */
	virtual const std::string& nickName();

	virtual void setLoginName(const std::string content) {};
	virtual std::string getLoginName() { return ""; };
	virtual void setIsGuest(const int guest) {};
	virtual void notifyEnterGame();

	virtual const float getPlatformChangeRate();

	virtual void setToolBarVisible(bool isShow);

	virtual void onShareEngineMessage(bool result);

	virtual void onPlayMovieEnd();

	virtual void onMotionShake();

	virtual void onFBShareBack(bool success);
	/************************************************************/
	/*����kakao�n�ͱ��f*/

	//��o�ܽЦ���
	virtual void OnKrGetInviteCount();
	//�ܽЦC��
	virtual void OnKrgetInviteLists();
	//�n�ͦC��
	virtual void OnKrgetFriendLists();
	//�o�e�ܽаT��
	virtual void OnKrsendInvite(const std::string& strUserId, const std::string& strServerId);
	//���§���C��
	virtual void OnKrgetGiftLists();
	//����§��
	virtual void OnKrReceiveGift(const std::string& strGiftId, const std::string& strServerId);
	//���e�ұ���§�����Ӽ�
	virtual void OnKrGetGiftCount();
	//�ذe§��
	virtual void OnKrSendGift(const std::string& strUserName, const std::string& strServerId);
	//�̽�§��
	virtual void OnKrGiftBlock(bool bVisible);
	//�ШDkakaoId
	virtual void OnKrGetKakaoId();
	//�i�J�C���Ĥ@�ɶ��ե�kakao
	virtual void OnKrLoginGames();
	//kakao�B�ziOS�����f�֮ɱ���������ê��\����s
	virtual void OnKrIsShowFucForIOS();
	enum KrFriendType
	{
		GET_INVITE_COUNT,
		GET_INVITE_LIST,
		GET_FRIEND_LIST,
		SEND_INVITE,
		GET_GIFT_LIST,
		RECEIVE_GIFT,
		GET_GIFT_COUNT,
		SEND_GIFT,
		GIFT_BLOCK,
		CDKEY,
		Get_KakaoId,
		KAKAO_IOS_ISSHOWFUC,
	};
	/***********************************************************/
	//R2���f
	virtual void  setLanguageName(const std::string& lang);

	virtual void  setPlatformName(int platform);
	
	virtual void  setH365Check(const bool swit);

	virtual void  setPayR18(int mid,int serverid, const std::string& url);

	virtual void  setPayH365(const std::string& url){};

	virtual void  setHoneyP(int aMoney){};
	/***********************************************************/
	const std::string getPlatformInfo();

	void registerListener(platformListener* listerner)
	{
		mListeners.insert(listerner);
	}
	//G2P means Game to Platform
	virtual std::string sendMessageG2P(const std::string& tag, const std::string& msg){ return ""; }

	//P2G means Platform to Game
	//set s special tag indicate which listener answer this message
	std::string sendMessageP2G(const std::string& tag, const std::string& msg)
	{
		std::set<platformListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<platformListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			std::string retVal = (*it)->onReceiveCommonMessage(tag, msg);
			if (!retVal.empty())
			{
				return retVal;
			}
		}
		return "";
	}
public:


	void removeListener(platformListener* listener)
	{
		mListeners.erase(listener);
	}
	void _boardcastInitDone(bool success, const std::string& log)
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onInit(this, success, log);
		}
	}
	void _boardcastLoginResult(bool success, const std::string& log)
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onLogin(this, success, log);
		}
	}
	void _boardcastBuyinfoSent(bool success, const BUYINFO& info, const std::string& log)
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onBuyinfoSent(this, success, info, log);
		}
	}

	void _boardcastUpdateCheckDone(bool ok, std::string msg)
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onUpdate(this, ok, msg);
		}
	}
	void _boardcastPlatformLogout()
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onPlatformLogout(this);
		}
	}
	//relogin 
	void _boardcastPlatfromReLogin()
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onReLogin();
		}
	}
	/*
	if the login uin is try user, could ask GameServer to change the try user's player to the ok user in this serverid first
	*/
	void _boardcastRequestBindTryUserToOkUser(const char* tyrUin, const char* okUin)
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onRequestBindTryUserToOkUser(tyrUin, okUin);
		}
	}
	/*

	*/
	void _boardcastOnTryUserRegistSuccess()
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onTryUserRegistSuccess();
		}
	}

	void _boardcastOnShareEngineMessage(bool _result)
	{

		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onShareEngineMessage(_result);
		}

	}

	void _boardcastOnPlayMovieEnd()
	{
		std::set<platformListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<platformListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->onPlayMovieEnd();
		}
		/*
		std::set<platformListener*>::iterator it = mListeners.begin();
		for(;it!=mListeners.end();++it)
		{
		(*it)->onPlayMovieEnd();
		}
		*/
	}

	void _boardcastOnMotionShake()
	{
		std::set<platformListener*>::iterator it = mListeners.begin();
		for (; it != mListeners.end(); ++it)
		{
			(*it)->onMotionShake();
		}

	}
	void _boardcastOnFBShareBackMessage(bool success)
	{
		std::set<platformListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<platformListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->onFBShareBack(success);
		}
	}

	void _boardcastOnKrCallBack(KrFriendType type, int nCount = 0, bool result = false, const std::string& str = "")
	{
		std::set<platformListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<platformListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			switch (type)
			{
			case GET_INVITE_COUNT:
				(*it)->onKrGetInviteCount(nCount);
				break;
			case GET_INVITE_LIST:
				(*it)->onKrgetInviteLists(str);
				break;
			case GET_FRIEND_LIST:
				(*it)->onKrgetFriendLists(str);
				break;
			case SEND_INVITE:
				(*it)->onKrsendInvite(str);
				break;
			case GET_GIFT_LIST:
				(*it)->onKrgetGiftLists(str);
				break;
			case RECEIVE_GIFT:
				(*it)->onKrReceiveGift(result);
				break;
			case GET_GIFT_COUNT:
				(*it)->onKrGetGiftCount(nCount);
				break;
			case SEND_GIFT:
				(*it)->onKrSendGift(str);
				break;
			case GIFT_BLOCK:
				(*it)->onKrGiftBlock(str);
				break;
			case CDKEY:
				(*it)->onKrCouponsBack(str);
				break;
			case Get_KakaoId:
				(*it)->OnKrGetKakaoIdBack(str);
				break;
			case KAKAO_IOS_ISSHOWFUC:
				(*it)->OnKrIsShowFucForIOSBack(result);
			}

		}
	}

	void _boardcastOnDownloadProgress(const std::string& url, const std::string& filename, const std::string& basePath, long progress)
	{
		std::set<platformListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<platformListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->OnDownloadProgress(url, filename, basePath, progress);
		}
	}

	void _boardcastOnDownloadComplete(const std::string& url, const std::string& filename, const std::string& basePath, const std::string& md5)
	{
		std::set<platformListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<platformListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->OnDownloadComplete(url, filename, basePath, md5);
		}
	}

	void _boardcastOnDownloadFailed(const std::string& url, const std::string& filename, const std::string& basePath, int errorCode)
	{
		std::set<platformListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<platformListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->OnDownloadFailed(url, filename, basePath, errorCode);
		}
	}

};


class libPlatformManager
{
	libPlatform *m_sPlatform;
	static libPlatformManager *m_sInstance;
	std::map<std::string, libPlatform *> mPlatforms;
public:
	void setPlatform(std::string name);
	bool registerPlatform(std::string name, libPlatform* platform);
	static libPlatform* getPlatform(){ return getInstance()->m_sPlatform; }
	static libPlatformManager* getInstance();

};

#endif
