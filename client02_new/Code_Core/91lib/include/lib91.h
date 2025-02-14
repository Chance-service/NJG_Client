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

	/** optional: get the session ID.*/
	virtual const std::string& sessionID();
	/** optional: get the nick name. which is shown on the loading scene */
	virtual const std::string& nickName();

	virtual const std::string getClientChannel();

    virtual std::string getPlatformMoneyName();
    

	virtual void setLoginName(const std::string content);
	virtual void setIsGuest(const int guest);
	virtual void notifyEnterGame();
#if defined(WIN32) || defined(ANDROID)
	
	

	virtual bool getIsTryUser();

	virtual void callPlatformBindUser();

	virtual void notifyGameSvrBindTryUserToOkUserResult(int result);
#endif
	virtual std::string sendMessageG2P(const std::string& tag, const std::string& msg);

	/************************************************************/
	/*韩国kakao好友接口*/

	//获得邀请次数
	virtual void OnKrGetInviteCount();
	//邀请列表
	virtual void OnKrgetInviteLists();
	//好友列表
	virtual void OnKrgetFriendLists();
	//发送邀请信息
	virtual void OnKrsendInvite(const std::string& strUserId, const std::string& strServerId);
	//获取礼物列表
	virtual void OnKrgetGiftLists();
	//接受礼物
	virtual void OnKrReceiveGift(const std::string& strGiftId, const std::string& strServerId);
	//当前所接受礼物的个数
	virtual void OnKrGetGiftCount();
	//赠送礼物
	virtual void OnKrSendGift(const std::string& strUserName, const std::string& strServerId);
	//屏蔽礼物
	virtual void OnKrGiftBlock(bool bVisible);
	virtual void OnKrGetKakaoId();
	virtual void OnKrLoginGames();
	virtual void OnKrIsShowFucForIOS();
	/***********************************************************/
	//R2接口
	virtual void  setLanguageName(const std::string& lang);
	virtual void  setPlatformName(int platform);
	virtual void  setPayH365(const std::string& url){};
	virtual void  setPayR18(int mid, int serverid, const std::string& url){};
	virtual void  setHoneyP(int aMoney);
	virtual int  getHoneyP();

	/***********************************************************/
};


