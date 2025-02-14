#pragma once

#include "libPlatform.h"

class libYouaiKY: public libPlatform
{
private:
    BUYINFO mBuyInfo;
public:
	BUYINFO getBuyInfo(){return mBuyInfo;}
	/**
	call this function first of all.
	NOTICE: Platform should call _boardcastInitDone to notify client logic WHEN initialization is done.
	*/
	virtual void initWithConfigure(SDK_CONFIG_STU configure);
    
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

	/** IMPORTANT: get the only ID for game. MUST be unique! */
	virtual const std::string& loginUin();
    
	/** optional: get the session ID.*/
	virtual const std::string& sessionID();
    
	/** optional: get the nick name. which is shown on the loading scene */
	virtual const std::string& nickName();
    
	const std::string getClientChannel();
    
    std::string getPlatformMoneyName();
    
	virtual const unsigned int getPlatformId();
};


