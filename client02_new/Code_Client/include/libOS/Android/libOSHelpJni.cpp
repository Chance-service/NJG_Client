

#include <string>
#include <map>

#include <jni.h>
#include "jni/JniHelper.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "json/json.h"

#include "libOSHelpJni.h"

#define  CLASS_A_NAME "com/nuclear/gjwow/AnalyticsToolHelp"
#define  CLASS_B_NAME "com/nuclear/gjwow/GameActivity"

using namespace cocos2d;

void requestRestartAppJni()
{	callPlatformSendMessageG2PJNI("requestRestart",Json::Value(Json::objectValue));
}

void initAnalyticsJni( const std::string& appid )
{// 	Json::Value date;
// 	date["appid"] = appid;
// 	callPlatformSendMessageG2PJNI("initAnalytics",date);
}

void initAnalyticsUserIDJni( const std::string userid )
{// 	Json::Value date;
// 	date["userid"] = userid;
// 	callPlatformSendMessageG2PJNI("initAnalyticsUserID",date);
}

void analyticsLogEventJni( const std::string& event )
{// 	Json::Value date;
// 	date["event"] = event;
// 	callPlatformSendMessageG2PJNI("analyticsLogEvent",date);
}

void analyticsLogEventJni( const std::string& event, const std::map<std::string, std::string>& dictionary, bool timed )
{
// 	Json::Value msg;
// 	msg["event"] = event;
// 	msg["dictionary"] = Json::Value();
// 	std::map<std::string, std::string>::const_iterator it = dictionary.begin();
// 	for (; it != dictionary.end(); ++it)
// 	{
// 		msg["dictionary"][it->first.c_str()] = it->second.c_str();
// 	}
//	msg["timed"] = timed;
// 	callPlatformSendMessageG2PJNI("analyticsLogMapParamsEvent",msg);
}

void analyticsLogEndTimeEventJni( const std::string& event )
{
// 	Json::Value date;
// 	date["event"] = event;
// 	callPlatformSendMessageG2PJNI("analyticsLogEndTimeEvent",date);
}

void weChatOpenJni()
{
//	callPlatformSendMessageG2PJNI("openWeChat",Json::Value(Json::objectValue));
}
void weChatShareFriendsJni(const std::string& shareContent)
{
// 	Json::Value date;
// 	date["shareContent"] = shareContent;
// 	callPlatformSendMessageG2PJNI("shareStringToFriends",date);
}
void weChatShareFriendsJni(const std::string& shareImgPath,const std::string& shareContent)
{
// 	Json::Value msg;
// 	msg["shareImgPath"] = shareImgPath;
// 	msg["shareContent"] = shareContent;
// 	callPlatformSendMessageG2PJNI("shareImgToFriends",msg);
}

void weChatSharePersonJni(const std::string& shareContent)
{
// 	Json::Value date;
// 	date["shareContent"] = shareContent;
// 	callPlatformSendMessageG2PJNI("shareStringToFriends",date);
}
	
void weChatSharePersonJni(const std::string& shareImgPath,const std::string& shareContent)
{
// 	Json::Value msg;
// 	msg["shareImgPath"] = shareImgPath;
// 	msg["shareContent"] = shareContent;
// 	callPlatformSendMessageG2PJNI("shareImgToPerson",msg);
}

void platformSharePersonJni(const std::string& shareContent, const std::string& shareImgPath, int platFormCfg /*= 0*/)
{
// 	Json::Value msg;
// 	msg["shareContent"] = shareContent;
// 	msg["shareImgPath"] = shareImgPath;
// 	msg["platFormCfg"] = platFormCfg;
// 	callPlatformSendMessageG2PJNI("paltformSharePerson",msg);
}

void playMovieJni(const std::string filename, bool needSkip /*= true*/)
{
//	Json::Value msg;
//	msg["filename"] = filename;
//	msg["needSkip"] = needSkip;
//	callPlatformSendMessageG2PJNI("playMovie",msg);
}

void stopMovieJni()
{
//	callPlatformSendMessageG2PJNI("stopMovie",Json::Value(Json::objectValue));
}
void createRoleJNI(const std::string& serverId)
{
// 	Json::Value date;
// 	date["serverId"] = serverId;
// 	callPlatformSendMessageG2PJNI("stopMovie",date);
}

void sendUserDataJNI(std::string& data)
{
	Json::Value msg;
	msg["data"] = data;
	callPlatformSendMessageG2PJNI("sendUserData",msg);
}

std::string getCurrentCountryJNI() {
	return callPlatformSendMessageG2PJNI("getCurrentCountry",Json::Value(Json::objectValue)).asString();
}

void facebookShareJNI(std::string& link,std::string& picture,std::string& name,std::string& caption,std::string& description)
{
	Json::Value msg;
	msg["link"] = link;
	msg["picture"] = picture;
	msg["name"] = name;
	msg["caption"] = caption;
	msg["description"] = description;
	callPlatformSendMessageG2PJNI("facebookShare",msg);
}

void reEnterLoadingJNI()
{
	callPlatformSendMessageG2PJNI("reEnterLoading",Json::Value(Json::objectValue));
}

extern void OnLuaExitGameJNI()
{
	callPlatformSendMessageG2PJNI("OnLuaExitGame",Json::Value(Json::objectValue));
}
extern void OnEntermateHomepageJNI()
{
	callPlatformSendMessageG2PJNI("OnEntermateHomepage",Json::Value(Json::objectValue));
}
extern void OnEntermateEventJNI()
{
	callPlatformSendMessageG2PJNI("OnEntermateEvent",Json::Value(Json::objectValue));
}
extern void OnUnregisterJNI()
{
	callPlatformSendMessageG2PJNI("OnUnregister",Json::Value(Json::objectValue));
}

void OnUserInfoChangeJNI(std::string& playerid,std::string& name,std::string& serverId,std::string& level,std::string& exp,std::string& vip,std::string& gold)
{
	Json::Value msg;
	msg["playerid"] = playerid;
	msg["name"] = name;
	msg["serverid"] = serverId;
	msg["level"] = level;
	msg["exp"] = exp;
	msg["vip"] = vip;
	msg["gold"] = gold;
	callPlatformSendMessageG2PJNI("OnUserInfoChange",msg);
}
void OnEntermateCouponsJNI(std::string& strCoupons)
{
	Json::Value date;
	date["strCoupons"] = strCoupons;
	callPlatformSendMessageG2PJNI("OnEntermateCoupons",date);
}
std::string getPackageName()
{
	//分平台获取 包名
	JniMethodInfo methodInfo;
	std::string packageName="";
	bool isHave = JniHelper::getStaticMethodInfo(methodInfo, CLASS_B_NAME, "getPackageNameToLua", "()Ljava/lang/String;");
	if(isHave) {
		packageName = JniHelper::jstring2string((jstring)methodInfo.env->CallStaticObjectMethod(methodInfo.classID, methodInfo.methodID));
		methodInfo.env->DeleteLocalRef(methodInfo.classID);
	}
	return packageName;
}
	