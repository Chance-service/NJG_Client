#pragma once

#include "libPlatform.h"

class lib91 : public libPlatform
{
    BUYINFO mBuyInfo;
public:
    BUYINFO getBuyInfo(){return mBuyInfo;}
	/**
	call this function first of all.
	NOTICE: Platform should call _boardcastInitDone to notify client logic WHEN initialization is done.
	*/
	virtual void initWithConfigure(const SDK_CONFIG_STU& configure);
  virtual void setupSDK(int platformId);
    
    /** check whether is logined */
	virtual bool getLogined();

	virtual bool getIsH365();

	virtual int getIsGuest();
    
	/**
	MUST call this function AFTER updating is done(after call back function).
	NOTICE: Platform should call _boardcastLoginResult to notify client logic WHEN login is done.
	*/
    
	virtual void login();
    virtual void doSDKLogin();

	virtual void updateApp(std::string& storeUrl);
    
	/** logout platform*/
	virtual void logout();
    
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

    virtual void setToolBarVisible(bool isShow);

	/** IMPORTANT: get the only ID for game. MUST be unique! */
	virtual const std::string& loginUin();

	virtual const std::string& getToken();

	virtual void showPlatformProfile();

	/** optional: get the session ID.*/
	virtual const std::string& sessionID();
	/** optional: get the nick name. which is shown on the loading scene */
	virtual const std::string& nickName();

	virtual const std::string getClientChannel();
	virtual const std::string getClientCps();
	virtual const std::string getBuildType();

    virtual std::string getPlatformMoneyName();

	virtual const unsigned int getPlatformId();
    

	virtual void setLoginName(const std::string content);
    virtual std::string getLoginName();
	virtual void setIsGuest(const int guest);
	virtual void notifyEnterGame();
#if defined(WIN32) || defined(ANDROID) || defined(CC_TARGET_OS_IPHONE)
	virtual bool getIsTryUser();

	virtual void callPlatformBindUser();

	virtual void notifyGameSvrBindTryUserToOkUserResult(int result);
#endif
	virtual std::string sendMessageG2P(const std::string& tag, const std::string& msg);

	/************************************************************/
	/*����kakao���ѽӿ�*/

	//����������
	virtual void OnKrGetInviteCount();
	//�����б�
	virtual void OnKrgetInviteLists();
	//�����б�
	virtual void OnKrgetFriendLists();
	//����������Ϣ
	virtual void OnKrsendInvite(const std::string& strUserId, const std::string& strServerId);
	//��ȡ�����б�
	virtual void OnKrgetGiftLists();
	//��������
	virtual void OnKrReceiveGift(const std::string& strGiftId, const std::string& strServerId);
	//��ǰ����������ĸ���
	virtual void OnKrGetGiftCount();
	//��������
	virtual void OnKrSendGift(const std::string& strUserName, const std::string& strServerId);
	//��������
	virtual void OnKrGiftBlock(bool bVisible);
	virtual void OnKrGetKakaoId();
	virtual void OnKrLoginGames();
	virtual void OnKrIsShowFucForIOS();
	/***********************************************************/
	//R2�ӿ�
	virtual void  setLanguageName(const std::string& lang);
	virtual void  setPlatformName(int platform);
	virtual void  setPayH365(const std::string& url){};
	virtual std::string getDomainIp(const std::string& url) { return "0.0.0.0"; };
	virtual void  setPayR18(int mid, int serverid, const std::string& url){};
	virtual void  setHoneyP(int aMoney);
	virtual int  getHoneyP();

	/***********************************************************/
};


