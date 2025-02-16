#pragma once

#include "libPlatform.h"

class libEfun : public libPlatform
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
    
	/**
	MUST call this function AFTER updating is done(after call back function).
	NOTICE: Platform should call _boardcastLoginResult to notify client logic WHEN login is done.
	*/
    
	virtual void login();
    
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
    
	/** optional: get the session ID.*/
	virtual const std::string& sessionID();
    
	/** optional: get the nick name. which is shown on the loading scene */
	virtual const std::string& nickName();

	virtual const std::string getClientChannel();

    virtual std::string getPlatformMoneyName();

#ifdef WIN32
	//����win32�µ��ԣ���¼���ϴε�¼�ɹ���puid���´ν���ϷĬ��Ϊ�ϴε�¼��puid, by zhenhui 2014/5/20
	static void libEfun::setLoginName(const std::string content);
#endif
    virtual void notifyEnterGame();
    
    virtual bool getIsTryUser();
    
    virtual void callPlatformBindUser();
    
    virtual void notifyGameSvrBindTryUserToOkUserResult(int result);

};


