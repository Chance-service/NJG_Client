#include "..\include\lib91.h"
#include <windows.h>
#include "libOS.h"
#include "libPlatform.h"
#include <atlstr.h>

bool lib91_mLogined = false;
DWORD lib91_mLoginTime = 0;



void lib91::initWithConfigure(const SDK_CONFIG_STU& configure)
{
	lib91_mLogined = false;
	_boardcastUpdateCheckDone(true,"");
}

bool lib91::getLogined()
{
	if(lib91_mLoginTime>0 && timeGetTime() - lib91_mLoginTime>500)
	{
		lib91_mLogined = true;
		//_boardcastLoginResult(true,"success");
	}
	return lib91_mLogined;
}

static std::string loginName = "";
static std::string token = "";
static bool IsH365 = false;
static bool IsEroR18 = false;
static bool IsJSG = false;
static bool IsLSJ = false;
static bool IsMURA = false;
static bool IsKUSO = false;
static bool IsErolabs = false;
static bool IsOP = false;
static bool IsGP = false;
static bool IsAPLUS = false;
static std::string PayUrl = "";
static int HoneyP = 0;
static int isGuest = 0;

bool lib91::getIsH365()
{
	return IsH365;
}

int lib91::getIsGuest()
{
	return isGuest;
}

void lib91::setLoginName(const std::string content){
	lib91_mLoginTime = timeGetTime();
	loginName = content;
}

std::string lib91::getLoginName()
{
    return loginName;
}

void lib91::setIsGuest(const int guest){
	isGuest = guest;
}

void lib91::login()
{
	//class myListener: public libOSListener
	//{
	//public:
	//	virtual void onInputboxEnter(const std::string& content)
	//	{
	//		loginName = content;
	//		libPlatformManager::getPlatform()->_boardcastLoginResult(true,"");
	//	}
	//}_listener;
	//lib91_mLoginTime = timeGetTime();
	//if(loginName == "")
	//{
	//	libOS::getInstance()->registerListener(&_listener);
	//	libOS::getInstance()->showInputbox(false);//_InputBox(L"input your uin");
	//	libOS::getInstance()->removeListener(&_listener);
	//}
	//std::string uinkey = "DefaultUin";
	//loginName = cocos2d:CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");
	loginName = "";
	libPlatformManager::getPlatform()->_boardcastLoginResult(true, "");
}

void lib91::doSDKLogin(){}

void lib91::setupSDK(int platformId)
{

}

const std::string& lib91::getToken()
{	
	return token;
}

void lib91::showPlatformProfile()
{
}

const std::string& lib91::loginUin()
{	
	return loginName;
}
const std::string& lib91::sessionID()
{
	static TCHAR chBuf[128];
	DWORD dwRet=128;
	GetComputerName(chBuf,&dwRet);
    static std::string ret;
    ret = (char*)chBuf;
	return ret;
}
const std::string& lib91::nickName()
{
	if (loginName.length()==0)
	{
		static TCHAR chBuf[128];
		DWORD dwRet=128;
		GetComputerName(chBuf,&dwRet);
		static std::string ret;
		ret = (char*)chBuf;
		return ret;
	} 
	else
	{
		return loginName;
	}
	
}
void lib91::switchUsers()
{
	loginName="";
    login();
}

void lib91::updateApp(std::string& storeUrl)
{

}

void lib91::logout()
{
	if (IsH365)
	{
		//callPlatformLogoutJNI();
	}
	else
	{
		libPlatformManager::getPlatform()->_boardcastPlatformLogout();
	}
}

void lib91::buyGoods( BUYINFO& info)
{
	CString boughtStr(L"Bought a item!!");
	CString shopStr(L"shop");

	MessageBox(0, boughtStr, shopStr,MB_OK);
	char ser[128];
	sprintf(ser,"%d",timeGetTime());
	info.cooOrderSerial = ser;
	_boardcastBuyinfoSent(true,info,"success");
}


void lib91::openBBS()
{
	CString openStr(L"open a bbs!!");
	CString urlStr(L"url");
	MessageBox(0, openStr, urlStr,MB_OK);
}

void lib91::userFeedBack()
{

}

void lib91::gamePause()
{

}

const std::string lib91::getClientChannel()
{

return "android_NG";
	//return "win32";
}

const std::string lib91::getClientCps()
{
	return "#0";
}

const std::string lib91::getBuildType()
{
	return "release";
}

std::string lib91::getPlatformMoneyName()
{
	return "91dou";
}

const unsigned int lib91::getPlatformId()
{
	return 0;
}

void lib91::notifyEnterGame()
{
}

void lib91::setToolBarVisible(bool isShow)
{

}

bool lib91::getIsTryUser()
{
	return false;
}

void lib91::callPlatformBindUser()
{
	
}

void lib91::notifyGameSvrBindTryUserToOkUserResult( int result )
{
	
}

std::string lib91::sendMessageG2P(const std::string& tag, const std::string& msg)
{
	return "";
}

/************************************************************/
/*����kakao���ѽӿ�*/

//����������
void lib91::OnKrGetInviteCount()
{

}

void lib91::OnKrgetInviteLists()
{

}

void lib91::OnKrgetFriendLists()
{

}

void lib91::OnKrsendInvite( const std::string& strUserId, const std::string& strServerId )
{

}

void lib91::OnKrgetGiftLists()
{

}

void lib91::OnKrReceiveGift( const std::string& strGiftId, const std::string& strServerId )
{

}

void lib91::OnKrGetGiftCount()
{

}

void lib91::OnKrSendGift( const std::string& strUserName, const std::string& strServerId )
{

}

void lib91::OnKrGiftBlock( bool bVisible )
{

}

void lib91::OnKrGetKakaoId()
{

}

void lib91::OnKrLoginGames()
{

}

/***********************************************************/
void lib91::setLanguageName( const std::string& lang )
{
	
}

void lib91::setPlatformName(int platform)
{
	IsH365 = (platform == 1);
	IsEroR18 = (platform == 2);
	IsJSG = (platform == 3);
	IsLSJ = (platform == 4);
	IsMURA = (platform == 5);
	IsKUSO = (platform == 6);
	IsErolabs = (platform == 7);
	IsOP = (platform == 8);
	IsAPLUS = (platform == 9);
	IsGP = (platform == 10);
}

void  lib91::setHoneyP(int aMoney)
{
	HoneyP = aMoney;
}

int  lib91::getHoneyP()
{
	return HoneyP;
}

void lib91::OnKrIsShowFucForIOS()
{

}