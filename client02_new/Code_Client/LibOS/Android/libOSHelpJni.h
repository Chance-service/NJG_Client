
#pragma once


/************************************************************************/


/*
	要求自动重新启动客户端App
*/
extern void requestRestartAppJni();


/************************************************************************/

/*
	初始化客户端统计分析工具包
*/
extern void initAnalyticsJni(const std::string& appid);
/*
	客户端统计分析工具包，设定玩家唯一ID，用作数据key
*/
extern void initAnalyticsUserIDJni(const std::string userid);
/*

*/
extern void analyticsLogEventJni(const std::string& event);

extern void analyticsLogEventJni(const std::string& event, const std::map<std::string, std::string>& dictionary, bool timed);

extern void analyticsLogEndTimeEventJni(const std::string& event);

/************************************************************************/


extern void weChatOpenJni();

extern void weChatShareFriendsJni(const std::string& shareContent);
	
extern void weChatShareFriendsJni(const std::string& shareImgPath,const std::string& shareContent);
	
	
extern void weChatSharePersonJni(const std::string& shareContent);
	
extern void weChatSharePersonJni(const std::string& shareImgPath,const std::string& shareContent);
extern void playMovieJni(const std::string filename, bool needSkip /*= true*/);
extern void platformSharePersonJni(const std::string& shareContent, const std::string& shareImgPath, int platFormCfg /*= 0*/);

extern void stopMovieJni();
extern void createRoleJNI(const std::string& serverId);
extern void sendUserDataJNI(std::string& data);
extern std::string getCurrentCountryJNI();
extern void facebookShareJNI(std::string& link,std::string& picture,std::string& name,std::string& caption,std::string& description);
extern void reEnterLoadingJNI();
extern void OnLuaExitGameJNI();
extern void OnEntermateHomepageJNI();
extern void OnEntermateEventJNI();
extern void OnUnregisterJNI();
extern void OnUserInfoChangeJNI(std::string& playerid,std::string& name,std::string& serverId,std::string& level,std::string& exp,std::string& vip,std::string& gold);
extern void OnEntermateCouponsJNI(std::string &strCoupons);
extern std::string getPackageName();




