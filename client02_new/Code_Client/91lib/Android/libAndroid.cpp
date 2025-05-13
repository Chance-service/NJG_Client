#include "..\include\libAndroid.h"
#include <string.h>
#include <time.h>
//
#include <sys/statfs.h>//for statfs
#include <sys/sysinfo.h>//for sysinfo
#include <unistd.h>//for rmdir
//
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "jni.h"
#include "libOS.h"
#include <android/log.h>
//
#include "libPlatformHelpJni.h"
#include "..\..\Game\Classes\H365API.h"
//
#define  LOG_TAG    "libAndroid.cpp"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
//

unsigned int timeGetTime()  
{  
	unsigned int uptime = 0;  
	struct timespec on;  
	if(clock_gettime(CLOCK_MONOTONIC, &on) == 0)  
		uptime = on.tv_sec*1000 + on.tv_nsec/1000000;  
	return uptime;  
}  

typedef unsigned long DWORD;
typedef wchar_t TCHAR;

//libAndroid* libAndroid::m_sInstance = 0;
bool libAndroid_mLogined = false;
DWORD libAndroid_mLoginTime = 0;

int enc_unicode_to_utf8_one(wchar_t unic, std::string& outstr)  
{  

	if ( unic <= 0x0000007F )  
	{  
		// * U-00000000 - U-0000007F:  0xxxxxxx  
		outstr.push_back(unic & 0x7F);  
		return 1;  
	}  
	else if ( unic >= 0x00000080 && unic <= 0x000007FF )  
	{  
		// * U-00000080 - U-000007FF:  110xxxxx 10xxxxxx  
		outstr.push_back(((unic >> 6) & 0x1F) | 0xC0); 
		outstr.push_back((unic & 0x3F) | 0x80);  
		return 2;  
	}  
	else if ( unic >= 0x00000800 && unic <= 0x0000FFFF )  
	{  
		// * U-00000800 - U-0000FFFF:  1110xxxx 10xxxxxx 10xxxxxx  
		outstr.push_back( ((unic >> 12) & 0x0F) | 0xE0);  
		outstr.push_back(((unic >>  6) & 0x3F) | 0x80);  
		outstr.push_back( (unic & 0x3F) | 0x80);  
		return 3;  
	}  
	else if ( unic >= 0x00010000 && unic <= 0x001FFFFF )  
	{  
		// * U-00010000 - U-001FFFFF:  11110xxx 10xxxxxx 10xxxxxx 10xxxxxx  
		outstr.push_back( ((unic >> 18) & 0x07) | 0xF0); 
		outstr.push_back( ((unic >> 12) & 0x3F) | 0x80);
		outstr.push_back( ((unic >>  6) & 0x3F) | 0x80);
		outstr.push_back( (unic & 0x3F) | 0x80);
		return 4;  
	}  
	else if ( unic >= 0x00200000 && unic <= 0x03FFFFFF )  
	{  
		// * U-00200000 - U-03FFFFFF:  111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx  

		outstr.push_back( ((unic >> 24) & 0x03) | 0xF8); 
		outstr.push_back( ((unic >> 18) & 0x3F) | 0x80);
		outstr.push_back( ((unic >> 12) & 0x3F) | 0x80);
		outstr.push_back( ((unic >>  6) & 0x3F) | 0x80);  
		outstr.push_back( (unic & 0x3F) | 0x80);  
		return 5;  
	}  
	else if ( unic >= 0x04000000 && unic <= 0x7FFFFFFF )  
	{  
		// * U-04000000 - U-7FFFFFFF:  1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx  
		outstr.push_back( ((unic >> 30) & 0x01) | 0xFC);
		outstr.push_back( ((unic >> 24) & 0x3F) | 0x80); 
		outstr.push_back( ((unic >> 18) & 0x3F) | 0x80);
		outstr.push_back( ((unic >> 12) & 0x3F) | 0x80);  
		outstr.push_back( ((unic >>  6) & 0x3F) | 0x80);  
		outstr.push_back( (unic & 0x3F) | 0x80); 
		return 6;  
	}  

	return 0;  
}  

void libAndroid::initWithConfigure(const SDK_CONFIG_STU& configure)//init(bool privateLogin/* = false*/)
{
	libAndroid_mLogined = false;
	//
	//平台支持的游戏版本更新已经在前面检查了，可以同步等其结果回来再发起内更新检测，或异步
	_boardcastUpdateCheckDone(true,"");
}

void libAndroid::setupSDK(int platformId)
{
}

static std::string loginName = "";
static std::string sessionId = "";
static std::string userNickName = "";
static std::string token = "";
static bool IsH365 = false;
static bool IsEroR18 = false;
static bool IsJSG = false;
static bool IsLSJ = false;
static bool IsMURA = false;
static bool IsKUSO = false;
static bool IsErolabs = false;
static bool IsAPLUS = false;
static std::string PayUrl = "";
static int HoneyP = 0;
static int isGuest = 0;

void libAndroid::setLoginName(const std::string content){
	libAndroid_mLoginTime = timeGetTime();
	loginName = content;
}

void libAndroid::setIsGuest(const int guest){
	isGuest = guest;
}

void libAndroid::login()
{
	//libAndroid_mLoginTime = timeGetTime();
	loginName = "";
	if (IsH365 || IsJSG || IsLSJ || IsKUSO || IsAPLUS)
	{
		LOGD("login standby");
		callPlatformLoginJNI();//call java
		LOGD("login finish");
	}
	//go to LoadingFrame::onLogin
	libPlatformManager::getPlatform()->_boardcastLoginResult(true, "");
	
	//callPlatformLoginJNI();//call java
}

void libAndroid::logout()
{
	if (IsH365 || IsJSG || IsLSJ || IsKUSO || IsAPLUS)
	{
		callPlatformLogoutJNI();
	}
	else
	{
		// /go to LoadingFrame::onPlatformLogout
		libPlatformManager::getPlatform()->_boardcastPlatformLogout();
	}
}
std::string libAndroid::sendMessageG2P(const std::string& tag, const std::string& msg)
{
	return callPlatformSendMessageG2PJNI(tag,msg);
}

const Json::Value& libAndroid::sendMessageG2P(const std::string& tag, const Json::Value& msg)
{
// 	static Json::Value data;
// 	data=Json::Value();
// 	Json::FastWriter writer;
// 	std::string returnParam = callPlatformSendMessageG2PJNI(tag,writer.write(msg));
// 	Json::Reader jreader;

//	jreader.parse(returnParam,data,false);
// 	return data;
	return callPlatformSendMessageG2PJNI(tag,msg);
}

bool libAndroid::getLogined()
{
	if(libAndroid_mLoginTime > 0 && (timeGetTime()-libAndroid_mLoginTime) > 5000)
	{
		//libAndroid_mLogined = true;
		//
	}
	libAndroid_mLogined = getPlatformLoginStatusJNI();
	return libAndroid_mLogined;
}

bool libAndroid::getIsH365()
{
	return IsH365;
}

int libAndroid::getIsGuest()
{
	return isGuest;
}

const std::string& libAndroid::loginUin()
{
	if (IsH365 || IsJSG || IsLSJ || IsKUSO || IsAPLUS)
	{
		loginName = getPlatformLoginUinJNI();
	}
	return loginName;
}

const std::string& libAndroid::getToken()
{
	token = getPlatformTokenJNI();
	return token;
}

void libAndroid::showPlatformProfile()
{
	if (IsKUSO || IsAPLUS)
	{
		showPlatformProfileJNI();
	}
}

const std::string& libAndroid::sessionID()
{
	sessionId = getPlatformLoginSessionIdJNI();
	return sessionId;
}

const std::string& libAndroid::nickName()
{
	userNickName = getPlatformUserNickNameJNI();
	return userNickName;
}

void libAndroid::switchUsers()
{
	//不提供切换平台账号
	//不提供应用内注销
	//平台账号管理页面的注销：
	//1、用户还未携账号进入游戏，允许注销重返平台账号登录界面
	//2、用户已进入游戏，此时注销直接退出游戏，要求用户手动重启
	/*loginName="";
	sessionId="";
	userNickName="";
	libAndroid_mLogined = false;
	*/
	//已登录情况下调出账号管理界面，未登录情况下调出登录界面
	callPlatformAccountManageJNI();
}


void libAndroid::buyGoods( BUYINFO& info)
{
	//BUYINFO的productCount是总价：单价*个数
	if (IsH365 || IsKUSO || IsAPLUS)
	{
		int iCount = 1;
		callPlatformPayRechargeJNI(info.productType, info.name.c_str(), info.cooOrderSerial.c_str(), info.productId.c_str(),
			info.productName.c_str(), info.productPrice, info.productOrignalPrice,
			iCount, info.description.c_str(), info.serverTime, info.extras.c_str());

		//_boardcastBuyinfoSent(true, info, "success");
	}
	else
	{	

		//_boardcastBuyinfoSent(true, info, "success");
		//if (PayUrl != "")
		//{
		//	std::string R18toPay = PayUrl + info.productId;
		//	libOS::getInstance()->openURL(R18toPay);
		//	_boardcastBuyinfoSent(true, info, "success");
		//}
	}
}

void libAndroid::openBBS()
{
	callPlatformGameBBSJNI("");
}

void libAndroid::userFeedBack()
{
	callPlatformFeedbackJNI();
}

void libAndroid::gamePause()
{

}

const std::string libAndroid::getClientChannel()
{
	return getClientChannelJNI();
}

const std::string libAndroid::getClientCps()
{
	return getClientCpsJNI();
}

std::string libAndroid::getPlatformMoneyName()
{
	return "";
}

const unsigned int libAndroid::getPlatformId()
{
	return getPlatformIdJNI();
}

void libAndroid::notifyEnterGame()
{
	notifyEnterGameJNI();
}

void libAndroid::setToolBarVisible(bool isShow)
{
// 	Json::Value date;
// 	date["isShow"]=isShow;
// 	callPlatformSendMessageG2PJNI("callToolBar",date);
}

bool libAndroid::getIsTryUser()
{
	return callPlatformSendMessageG2PJNI("isPlatformTryUser",Json::Value(Json::objectValue)).asBool();
}

void libAndroid::callPlatformBindUser()
{
//	callPlatformSendMessageG2PJNI("callPlatformBindUser",Json::Value(Json::objectValue));
}

void libAndroid::notifyGameSvrBindTryUserToOkUserResult( int result )
{
// 	Json::Value date;
// 	date["result"]=result;
// 	callPlatformSendMessageG2PJNI("receiveGameSvrBindTryToOkUserResult",date);
}

/************************************************************/
/*韩国kakao好友接口*/

//获得邀请次数
void libAndroid::OnKrGetInviteCount()
{
	callPlatformSendMessageG2PJNI("OnKrGetInviteCount",Json::Value(Json::objectValue));
}

void libAndroid::OnKrgetInviteLists()
{
	callPlatformSendMessageG2PJNI("OnKrGetInviteLists",Json::Value(Json::objectValue));
}

void libAndroid::OnKrgetFriendLists()
{
	callPlatformSendMessageG2PJNI("OnKrGetFriendLists",Json::Value(Json::objectValue));
}

void libAndroid::OnKrsendInvite( const std::string& strUserId, const std::string& strServerId )
{
	Json::Value date;
	date["UserId"] = strUserId;
	date["ServerId"] = strServerId;
	callPlatformSendMessageG2PJNI("OnKrSendInvite",date);
}

void libAndroid::OnKrgetGiftLists()
{
	callPlatformSendMessageG2PJNI("OnKrGetGiftLists",Json::Value(Json::objectValue));
}

void libAndroid::OnKrReceiveGift( const std::string& strGiftId, const std::string& strServerId )
{
	Json::Value date;
	date["GiftId"] = strGiftId;
	date["ServerId"] = strServerId;
	callPlatformSendMessageG2PJNI("OnKrReceiveGift",date);
}

void libAndroid::OnKrGetGiftCount()
{
	callPlatformSendMessageG2PJNI("OnKrGetGiftCount",Json::Value(Json::objectValue));
}

void libAndroid::OnKrSendGift( const std::string& strUserName, const std::string& strServerId )
{
	Json::Value date;
	date["UserName"] = strUserName;
	date["ServerId"] = strServerId;
	callPlatformSendMessageG2PJNI("OnKrSendGift",date);
}

void libAndroid::OnKrGiftBlock( bool bVisible )
{
	Json::Value date;
	date["bVisible"] = bVisible;
	callPlatformSendMessageG2PJNI("OnKrGiftBlock", date);
}

void libAndroid::OnKrGetKakaoId()
{
	callPlatformSendMessageG2PJNI("OnKrGetKakaoId",Json::Value(Json::objectValue));
}

void libAndroid::OnKrLoginGames()
{
	callPlatformSendMessageG2PJNI("OnKrLoginGames",Json::Value(Json::objectValue));
}
/***********************************************************/
void libAndroid::setLanguageName( const std::string& lang )
{
	Json::Value date;
	date["lang"] = lang;
	callPlatformSendMessageG2PJNI("setLanguageName",date);
}

void libAndroid::setPlatformName(int platform)
{
	IsH365 = (platform == 1);
	IsEroR18 = (platform == 2);
	IsJSG = (platform == 3);
	IsLSJ = (platform == 4);
	IsMURA = (platform == 5);
	IsKUSO = (platform == 6);
	IsErolabs = (platform == 7);
	IsAPLUS = (platform == 9);
//	setPlatformNameJNI(platform);
	//H365API::setH365CheckJNI(IsH365);
}

void libAndroid::setPayR18(int mid, int serverid, const std::string& url)
{
	char cdata[128];
	sprintf(cdata, "/idlestore/jpay?mid=%d&puid=%s&sid=%d&pid=", mid, loginName.c_str(), serverid);
	PayUrl = url + cdata;
}

void  libAndroid::setPayH365(const std::string& url)
{
	if (IsH365 || IsKUSO || IsAPLUS)
	{
		setPayUrlJNI(url.c_str()); // JNI to jave
	}
}

void  libAndroid::setHoneyP(int aMoney)
{
	HoneyP = aMoney;
}

int  libAndroid::getHoneyP()
{
	return HoneyP;
}


void libAndroid::OnKrIsShowFucForIOS()
{

}