


#include "..\include\lib91.h"
#include <string.h>
#include <time.h>
//
#include <sys/statfs.h>//for statfs
#include <sys/sysinfo.h>//for sysinfo
#include <unistd.h>//for rmdir
//
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "jni.h"
#include <android/log.h>
//
#include "libPlatformHelpJni.h"
//
#define  LOG_TAG    "lib91.cpp"
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

//lib91* lib91::m_sInstance = 0;
bool lib91_mLogined = false;
DWORD lib91_mLoginTime = 0;

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

void lib91::initWithConfigure(const SDK_CONFIG_STU& configure)//init(bool privateLogin/* = false*/)
{
	lib91_mLogined = false;
	//
	//ƽ̨֧�ֵ���Ϸ�汾�����Ѿ���ǰ�����ˣ�����ͬ�������������ٷ����ڸ��¼�⣬���첽
	_boardcastUpdateCheckDone(true,"");
}

void lib91::setupSDK(int platformId)
{

}

void lib91::updateApp(std::string& storeUrl)
{

}

static std::string loginName = "";
static std::string sessionId = "";
static std::string userNickName = "";

void lib91::login()
{
	//
	lib91_mLoginTime = timeGetTime();
	if(loginName == "")
	{
		//

		//
		//_boardcastLoginResult(true,"");
	}
	callPlatformLoginJNI();//call java
	//
}

void lib91::doKUSOLogin(){}

void lib91::logout()
{
	callPlatformLogoutJNI();
}
std::string lib91::sendMessageG2P(const std::string& tag, const std::string& msg)
{
	return callPlatformSendMessageG2PJNI(tag,msg);
}
//void lib91::final()
//{
//
//}

bool lib91::getLogined()
{
	if(lib91_mLoginTime > 0 && (timeGetTime()-lib91_mLoginTime) > 5000)
	{
		//lib91_mLogined = true;
		//
	}
	lib91_mLogined = getPlatformLoginStatusJNI();
	return lib91_mLogined;
}

bool lib91::getIsH365(){}
bool lib91::getIsGuest(){}

const std::string& lib91::loginUin()
{
	loginName = getPlatformLoginUinJNI();
	return loginName;
}

const std::string& lib91::sessionID()
{
	sessionId = getPlatformLoginSessionIdJNI();
	return sessionId;
}

const std::string& lib91::nickName()
{
	userNickName = getPlatformUserNickNameJNI();
	return userNickName;
}

void lib91::switchUsers()
{
	//���ṩ�л�ƽ̨�˺�
	//���ṩӦ����ע��
	//ƽ̨�˺Ź���ҳ���ע����
	//1���û���δЯ�˺Ž�����Ϸ������ע���ط�ƽ̨�˺ŵ�¼����
	//2���û��ѽ�����Ϸ����ʱע��ֱ���˳���Ϸ��Ҫ���û��ֶ�����
	/*loginName="";
	sessionId="";
	userNickName="";
	lib91_mLogined = false;
	*/
	//�ѵ�¼����µ����˺Ź������棬δ��¼����µ�����¼����
	callPlatformAccountManageJNI();
}


void lib91::buyGoods( BUYINFO& info)
{
	//BUYINFO��productCount���ܼۣ�����*����
	//�����ֵ���г���91���һ�������ʯ�ı���1:10
	int iCount = 1;//info.productCount / (int)info.productPrice / 10;
	callPlatformPayRechargeJNI(info.productType, info.name.c_str(),info.cooOrderSerial.c_str(), info.productId.c_str(),
		info.productName.c_str(), info.productPrice, info.productOrignalPrice, 
		iCount, info.description.c_str(),info.serverTime,info.extras.c_str());
	//
	_boardcastBuyinfoSent(true, info, "success");
}

void lib91::openBBS()
{
	callPlatformGameBBSJNI("");
}

void lib91::userFeedBack()
{
	callPlatformFeedbackJNI();
}

void lib91::gamePause()
{

}

//void lib91::_enableLogin()
//{
//
//}

const std::string lib91::getClientChannel()
{
	return getClientChannelJNI();
}

const std::string lib91::getClientCps()
{
	return getClientCpsJNI();
}

std::string lib91::getPlatformMoneyName()
{
	return "";
}

const unsigned int lib91::getPlatformId()
{
	return getPlatformIdJNI();
}

void lib91::setLoginName(const std::string content)
{
}

void lib91::setIsGuest(const int guest)
{
}

void lib91::notifyEnterGame()
{
	notifyEnterGameJNI();
}

void lib91::setToolBarVisible(bool isShow)
{
	callPlatToolsJni(isShow);
}

bool lib91::getIsTryUser()
{
	return isTryUserJni();
}

void lib91::callPlatformBindUser()
{
	callPlatformBindUserJni();
}

void lib91::notifyGameSvrBindTryUserToOkUserResult( int result )
{
	notifyGameSvrBindTryUserToOkUserResultJni(result);
}

/************************************************************/
/*����kakao���ѽӿ�*/

//����������
void lib91::OnKrGetInviteCount()
{
	OnKrGetInviteCountJNI();
}

void lib91::OnKrgetInviteLists()
{
	OnKrgetInviteListsJNI();
}

void lib91::OnKrgetFriendLists()
{
	OnKrgetFriendListsJNI();
}

void lib91::OnKrsendInvite( const std::string& strUserId, const std::string& strServerId )
{
	OnKrsendInviteJNI(strUserId,strServerId);
}

void lib91::OnKrgetGiftLists()
{
	OnKrgetGiftListsJNI();
}

void lib91::OnKrReceiveGift( const std::string& strGiftId, const std::string& strServerId )
{
	OnKrReceiveGiftJNI(strGiftId,strServerId);
}

void lib91::OnKrGetGiftCount()
{
	OnKrGetGiftCountJNI();
}

void lib91::OnKrSendGift( const std::string& strUserName, const std::string& strServerId )
{
	OnKrSendGiftJNI(strUserName,strServerId);
}

void lib91::OnKrGiftBlock( bool bVisible )
{
	OnKrGiftBlockJNI(bVisible);
}
void lib91::OnKrGetKakaoId()
{
	OnKrGetKakaoIdJNI();
}
void lib91::OnKrLoginGames()
{
	OnKrLoginGamesJNI();
}
/***********************************************************/
void lib91::setLanguageName( const std::string& lang )
{
	setLanguageNameJNI(lang);
}
void lib91::OnKrIsShowFucForIOS()
{

}

static int HoneyP = 0;

void  lib91::setHoneyP(int aMoney)
{
	HoneyP = aMoney;
}

int  lib91::getHoneyP()
{
	return HoneyP;
}