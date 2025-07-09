#include "stdafx.h"

#include "LoadingFrame.h"
#include "AppDelegate.h"
//#include "GameMessages.h"
#include "Language.h"
#include "SeverConsts.h"
#include "GameMaths.h"
#include "ServerDateManager.h"
#include "SoundManager.h"
#include "cocos-ext.h"
#include "cocos2d.h"
//#include "ActiveCodePage.h"
#include "BlackBoard.h"
#include "TimeCalculator.h"
//#include "DataTableManager.h"
#include <list>
#include <vector>
#include "md5.h"
#include "LoginPacket.h"
#include "waitingManager.h"
#include "LoadingAniPage.h"
#include "GamePlatformInfo.h"
//#include "GamePlatformInfo.h"
#include "SimpleAudioEngine.h"
//#include "ScriptMathToLua.h"
#include "MessageHintPage.h"
#include "network/HttpRequest.h"
#include "SpineContainer.h"
#include "network/HttpClient.h"
#include "AssetsManagerEx.h"
#include "crypto/CCCrypto.h"
#include <iostream>
#include <sstream>
#include <fstream>
#include <iomanip>
#include "LogReport.h"
#include "GamePlatform.h"
#include "LoginUserPage.h"
#include "Lua_EcchiGamerSDKBridge.h"
#include "LoginBCPage.h"
#include "ConfirmPage.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif
USING_NS_CC;
USING_NS_CC_EXT;


#define downLoadSavePath         "hotUpdate"
#define downLoadUpdateDir        "update"
#define versionPath              "version"
#define versionAppManifestName	 "versionApp.manifest"
#define versionManifestName      "version.manifest"
#define versionManifestNameTmp   "versionTmp.manifest"
#define projectManifestName      "project.manifest"
#define projectManifestLocalName "projectLocal.manifest"
#define updateVersionTipsName    "UpdateVersionTips.cfg"


class ReadTablesAtLoadingFrame : public ThreadTask
{
public:
	virtual int run()
	{
		GamePrecedure::Get()->readTables();
		return 0;
	}
};

REGISTER_PAGE("LoadingFrame",LoadingFrame);

#define CONNECT_DIRECT_ENABLE 0
#define CONNECT_DIRECT_ADDRESS "127.0.0.1"
#define CONNECT_DIRECT_PORT 25524
#define MaxResumeTime 50
int g_iSelectedSeverIDCopy;
int needTime = 0;
float downloadSpeed = 0.0f;
float preAlreadyDownloadSize = 0.0f;

LoadingFrame::LoadingFrame(void)
	:mIsFirstLoginNotServerIDInfo(false)
	,mSendLogin(false), mScene(NULL), mSelectedSeverID(0)
	,mIsCanShowDataTransfer(true)
	, localVersionData(NULL)
	, serverVersionData(NULL)
	, mSpineData(NULL)
	, m_updateVersionTips(NULL)
	, downTotalSize(0)
	, currentFileLoadSize(0)
	, currentLoadFile("")
	, versionStat(NONE)
	, versionAppCompareStat(EQUAL)
	, versionResourceStat(EQUAL)
	, connectCount(0)
	, _ProgressTimerNode(NULL)
	, lastPercent(0.0f)
	, downVersionTimes(0)
	, downProjectTimes(0)
	, downServerCfgTimes(0)
	, m_IsCanClickStartGameBtn(true)
	, m_haveLoadAnnounce(false)
	, m_bUpdateServerName(false)
	, txMap(NULL)
	, m_IsCheckLogout(false)
	, ResumeCount(MaxResumeTime)
{}

LoadingFrame::~LoadingFrame(void)
{
	mSendLogin=false;
}

void LoadingFrame::Enter( GamePrecedure* )
{
	downloadSize = 0;
	downloadStartTime = 0;
	donwloadEndTime = 0;
	downloadStopTimer = 0.0f;
	mLogined = false;
    mNetWorkNotWorkMsgShown = false;
	mSelectedSeverID = 0;//初始化
	defultType = ERO_LOGINTYPE::LOGINTYPE_NONE;
	MessageManager::Get()->regisiterMessageHandler(MSG_LOADINGFRAME_ENTERGAME,this);
	libOS::getInstance()->registerListener(this);
	bool isCompress = StringConverter::parseBool(VaribleManager::Get()->getSetting("isPacketCompress", "", "true"),true);
	PacketManager::Get()->setCompress(isCompress);
	libPlatformManager::getPlatform()->registerListener(this);
	
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
	if (SeverConsts::Get()->IsH365()) // H365
	{
		libPlatformManager::getPlatform()->login();
	}
	else if (SeverConsts::Get()->IsOP())
	{
		libPlatformManager::getPlatform()->login();
	}
	else if (SeverConsts::Get()->IsGP())
	{
		libPlatformManager::getPlatform()->login();
	}
	else if(SeverConsts::Get()->IsEroR18()) {
		Lua_EcchiGamerSDKBridge::callinitbyC();
	}
	else if (SeverConsts::Get()->IsErolabs()) {
		Lua_EcchiGamerSDKBridge::callinitbyC();
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if (SeverConsts::Get()->IsKUSO())
    {
        libPlatformManager::getPlatform()->login();
    }
    else if (SeverConsts::Get()->IsErolabs())
    {
        // Erolabs sdk is handled by lua
        Lua_EcchiGamerSDKBridge::callinitbyC();
    }
#endif

	float reqServerTime = StringConverter::parseLong(VaribleManager::Get()->getSetting("ReqServerListOffest", "", "10"), true);
	SeverConsts::Get()->setReqServerListOffestTime(reqServerTime);

	mSpineData = new SpineData();

    CCLog("init severConst...");
    SeverConsts::Get()->init(GamePlatformInfo::getInstance()->getPlatVersionName());
	mScene = CCScene::create();
	mScene->retain();
	mScene->addChild(this);
	
	load();

	setWaitGameNodeVisible(false);
    setLoginGameNodeVisible(false);
	setEnterServerListVisible(false);
    setEnterGameNodeVisible(false);
	setEnterBCNodeVisible(false);
	setLogoutBtnVisible(false);
	setLogoutNodeVisible(false);
	setLogoutCheck(m_IsCheckLogout);
	CCMenu* newsNode = dynamic_cast<CCMenu*>(getVariable("mNewsBtn"));
	newsNode->setVisible(SeverConsts::Get()->IsDebug());

	CCLabelTTF* eb = dynamic_cast<CCLabelTTF*>(getVariable("mSeverName1"));
    if(eb)eb->setString("");
    
	CCB_FUNC(this, "mLoading1", cocos2d::CCLabelBMFont, setString(""));
    CCLog("************start running LoadingFrame scene**************");
	
	CCDirector::sharedDirector()->setDepthTest(true);
	// run
	if(cocos2d::CCDirector::sharedDirector()->getRunningScene())
		cocos2d::CCDirector::sharedDirector()->replaceScene(mScene);
	else
		cocos2d::CCDirector::sharedDirector()->runWithScene(mScene);

	if (GamePrecedure::Get()->isReEnterLoadingFrame())
	{
		//onUpdate(NULL, true, "");//重进这种情况，刷新一下
	}
	else
	{
#ifndef _CLOSE_MUSIC
		SoundManager::Get()->init();
#endif
	}
#ifndef _CLOSE_MUSIC
	CocosDenshion::SimpleAudioEngine::sharedEngine()->stopBackgroundMusic(true);
	SoundManager::Get()->playLoadingMusic();
#endif

	CCMenuItemImage* pMenuFeedBackBtn = dynamic_cast<CCMenuItemImage*>(getVariable("mServiceSupport"));
	if (pMenuFeedBackBtn)
	{
		pMenuFeedBackBtn->setVisible(true);
	}
	CCMenuItemImage* mDataTransferBtn = dynamic_cast<CCMenuItemImage*>(getVariable("mDataTransfer"));
	if (mDataTransferBtn)
	{
		mDataTransferBtn->setVisible(false);
	}
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, 0, true);

	loginReport(REPORT_STEP::REPORT_STEP_ENTER_GAME);
}

void LoadingFrame::Exit( GamePrecedure* )
{	
	libOS::getInstance()->removeListener(this);
    libPlatformManager::getPlatform()->removeListener(this);
	PacketManager::Get()->removePacketHandler(this);
	MessageManager::Get()->removeMessageHandler(this);

	unload();
	mScene->removeAllChildrenWithCleanup(true);
	mScene->release();
	CCLog("loading frame mScene retainCount:%d",mScene->retainCount());
	mScene = NULL;
	mThread.shutdown();
}

void LoadingFrame::Recycle(){}

void LoadingFrame::Execute( GamePrecedure* gp)
{

	if (CurlDownload::Get())
	{
		CurlDownload::Get()->update(0.2);
	}

	loadingAsset(gp->getFrameTime());

	SeverConsts::Get()->update(gp->getFrameTime());

	CCNode* node = dynamic_cast<CCNode*>(getVariable("mNodeFront"));
	if (node)
	{
		LoadingAniPage* page = dynamic_cast<LoadingAniPage*>(node->getChildByTag(LoadinAniPageTag));
		if (page && !page->getIsInWaiting())
		{
			page->runLoadingAni();
		}
	}

	//  
	if (SeverConsts::Get()->mCheckState == SeverConsts::CS_OK && (!m_haveLoadAnnounce))
	{
		m_haveLoadAnnounce = true;
	}

	LoginBCPage *mLoginBCPage = dynamic_cast<LoginBCPage*>(CCBManager::Get()->getPage("LoginBCPage"));

	if (mLoginBCPage)
	{
		mLoginBCPage->Execute(NULL);
	}

	if (TimeCalculator::getInstance()->hasKey("R18checkLogin")){
		if (TimeCalculator::getInstance()->getTimeLeft("R18checkLogin") <= 0)
		{
			TimeCalculator::getInstance()->removeTimeCalcultor("R18checkLogin");
			libPlatformManager::getPlatform()->login();
		}
	}

}

void LoadingFrame::onReceiveMassage( const GameMessage * message )
{
	if(message->getTypeId() == MSG_LOADINGFRAME_ENTERGAME)
	{
		GamePrecedure::Get()->enterMainMenu();
	}
}
bool LoadingFrame::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
	touchBeganPosX = pTouch->getLocation().x;
	touchBeganPoxY = pTouch->getLocation().y;
	isTouchMoved = false;
	if (txMap)
	{
		CCTMXLayer *_pLayer1 = txMap->layerNamed("layer3");
		_pLayer1->setVisible(true);
	}
	return true;
}
void LoadingFrame::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
	if (txMap)
	{
		isTouchMoved = true;
		float x = pTouch->getLocation().x;
		float y = pTouch->getLocation().y;
		txMap->setPositionY(txMap->getPositionY() + y - touchBeganPoxY);
	}
	
}
void LoadingFrame::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{
	if (isTouchMoved && txMap)
	{
		CCTMXLayer *_pLayer1 = txMap->layerNamed("layer3");
		_pLayer1->setVisible(false);
	}
}
void LoadingFrame::ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)
{

}
void LoadingFrame::onLogin(libPlatform* lib, bool success, const std::string& log)
{
	cocos2d::CCLog("LoadingFrame::onLogin");
    if(success)
    {
		std::string uin = "";
		std::string pass = "";
		if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsOP() || SeverConsts::Get()->IsGP() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ()) // H365/JSG/LSJ
		{
			#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
				std::string uinkey = "LastLoginPUID";
				uin = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");

				std::string passkey = "PassKey";
				pass = CCUserDefault::sharedUserDefault()->getStringForKey(passkey.c_str(), "");

				if ((uin != "") && (pass != ""))
				{
					libPlatformManager::getPlatform()->setLoginName(uin);
					GamePrecedure::getInstance()->setDefaultPwd(pass);
				}
			#endif
		}
		else if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs()) //工口 or Erolabs
		{
			glClear(GL_COLOR_BUFFER_BIT);
			Lua_EcchiGamerSDKBridge::callLoginbyC(); // c++ sdk to call java
		}
		else if (SeverConsts::Get()->IsKUSO()) //69
		{
			cocos2d::CCLog("LoadingFrame::onLogin IsKUSO");
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
			callPlatformLoginJNI();
#endif
		}
		else if (SeverConsts::Get()->IsAPLUS()) //aplus
		{
			cocos2d::CCLog("LoadingFrame::onLogin IsAPLUS");
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
			callPlatformLoginJNI();
#endif
		}
		else 
		{
			std::string uinkey = "LastLoginPUID";
			uin = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");

			std::string passkey = "PassKey";
			pass = CCUserDefault::sharedUserDefault()->getStringForKey(passkey.c_str(), "");
			int strLen = uin.length();
			if ((uin != "") && (pass != ""))
			{
				libPlatformManager::getPlatform()->setLoginName(uin);
				GamePrecedure::getInstance()->setDefaultPwd(pass);
			}
		}

		GamePrecedure::Get()->setLoginCode(log);
        mLogined = true;
		CCB_FUNC(this, "mLoading1", cocos2d::CCLabelBMFont, setString(log.c_str()));
		CCLog("onLogin showEnter");
		showEnter();

		int newServerId = getDefaultSeverID();
		
		SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(newServerId);

		if (it == SeverConsts::Get()->getSeverList().end())
			newServerId = SeverConsts::Get()->getSeverDefaultID();
		
		if (newServerId != mSelectedSeverID)
		{
			mSelectedSeverID = newServerId;
			m_bUpdateServerName = true;
		}
		if (getVariable("mSeverNode"))
		{
			CCNode* sever = dynamic_cast<CCNode*>(getVariable("mSeverNode"));
			if (sever &&mIsFirstLoginNotServerIDInfo)
			{
				mIsFirstLoginNotServerIDInfo = false;
			}
		}
    }
}

void LoadingFrame::onPlatformLogout(libPlatform*)
{
	if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs()){
		Lua_EcchiGamerSDKBridge::callLogoutbyC();
	}
};

void LoadingFrame::onUpdate(libPlatform*, bool ok, std::string msg)
{
    if(!ok)
    {
		cocos2d::CCLog("LoadingFrame::onUpdate failed");
        libOS::getInstance()->showMessagebox(msg);
    }
    else
    {
		cocos2d::CCLog("LoadingFrame::onUpdate success");
        SeverConsts::Get()->start();
    }
}

void LoadingFrame::LoginSuccess()
{
	if (GamePrecedure::Get()->isReEnterLoadingFrame())
	{
		libPlatformManager::getPlatform()->logout();
	}
	//不论是被挤出来重新登录 还是第一次登录都走一遍这个流程 
	cocos2d::CCLog("LoadingFrame::LoginSuccess");
	libPlatformManager::getPlatform()->initWithConfigure(GamePlatformInfo::getInstance()->getPlatFromconfig());
	loginReport(REPORT_STEP::REPORT_STEP_END_DOWNLOAD_PATCH);
}
void LoadingFrame::onMessageboxEnter(int tag)
{
    if(tag == 100)
    {
		CCLog("onMessageBoxEnter tag 100  versionStat is %d---", versionStat);
		if (versionStat == UPDATE_APP_STORE)
		{
			appStoreUpdate();
		}
		else if (versionStat == CHECK_PROJECT_ASSETS_DONE)
		{
			setOpcaityLoadingAniPage(0);
			UpdateAssetFromServer();
		}
		else if (versionStat == UPDATE_FAIL)
		{
			ResumeCount = MaxResumeTime;
			//UpdateAssetFromServer();
			ResumeUpdateAsset();
		}
		else if (versionStat == CHECK_VERSION)
		{
			downVersionTimes = 0;
			downServerCfgTimes = 0;
			checkVersion();
		}
		else if (versionStat == CHECK_PROJECT_ASSETS)
		{
			downProjectTimes = 0;
		}
    }
	else if (tag == 110)
	{

	}
	else if(tag==Err_CheckingFailed)
	{
		exit(0);
	}
	else if(tag==Err_UpdateFailed)
	{
		exit(0);
	}
	else if(tag==Err_ConnectFailed)
	{
		//exit(0);
	}
	else if(tag==Err_ErrMsgReport)
	{
		mSendLogin=false;
		if(!waitingManager::Get()->getWaiting())
		{
			CCLog("onMessageboxEnter showEnter");
			showEnter();
		}
	}
	else if(tag == 120)
	{
		mNetWorkNotWorkMsgShown = false;
	}
}

void LoadingFrame::onMenuItemAction( const std::string& itemName ,cocos2d::CCObject* sender)
{
    if(itemName == "onSever")
    {
        showSevers(true);
    }
	else if(itemName == "onStartGame")
	{
		if(!mLogined){
#ifdef WIN32
			std::string puidKey = "LastLoginPUID";
			std::string strPuid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey(puidKey.c_str(), "");	
			//如果xml中没有值，则输入puid，否则，直接直接赋值并发送onlogin消息
			if (strPuid.length()>0)
			{
				libPlatformManager::getPlatform()->setLoginName(strPuid);
				libPlatformManager::getPlatform()->_boardcastLoginResult(true,"");
			}else{
				libPlatformManager::getPlatform()->login();

			}
#else
			libPlatformManager::getPlatform()->login();
#endif
		}
	}
	else if(itemName == "onClose")
	{
		showSevers(false);
	}
    else if (itemName == "onLoginGame")
    {
        libPlatformManager::getPlatform()->login();
    }
	else if(itemName =="onEnter")
	{
		CCLOG("onMenuItemAction: onEnter ");
		onEnterGame();
	}
	else if (itemName == "onConfirmLogout")
	{
		CCLog("onConfirmLogout1");
		if (m_IsCheckLogout)
		{
			CCLog("onConfirmLogout2");
			if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsOP() || SeverConsts::Get()->IsGP() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() || SeverConsts::Get()->IsKUSO() || SeverConsts::Get()->IsAPLUS())
			{
				CCLog("onConfirmLogout3");
				libPlatformManager::getPlatform()->logout();
				setLogoutNodeVisible(false);
			}
			else if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs()) {
				showLogoutConfirm();
			}
			else
			{
				CCLog("onConfirmLogout4");
				libPlatformManager::getPlatform()->logout();
				setLogoutNodeVisible(false);
				setLogoutBtnVisible(false);
				setEnterGameNodeVisible(false);
				CCUserDefault::sharedUserDefault()->setStringForKey("LastLoginPUID", "");
				CCUserDefault::sharedUserDefault()->setStringForKey("PassKey", "");
				CCUserDefault::sharedUserDefault()->setStringForKey("ecchigamer.token", "");
			}
		}

	}
	else if (itemName == "onOpenLogoutNode")
	{
		if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsOP() || SeverConsts::Get()->IsGP() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() || SeverConsts::Get()->IsKUSO() || SeverConsts::Get()->IsAPLUS())
		{
			libPlatformManager::getPlatform()->logout();
		}
		else if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs()) {
			showLogoutConfirm();
		}
		else {
			setLogoutNodeVisible(true);
		}
	}
	else if (itemName == "onCancelLogout")
	{
		setLogoutNodeVisible(false);
	}
	else if (itemName == "onCheckAgree")
	{
		m_IsCheckLogout = !m_IsCheckLogout;
		setLogoutCheck(m_IsCheckLogout);
	}
	else if (itemName == "onBCGuest")
	{
		sendGuestLogin();
	}
	else if (itemName == "onNewsBtn")
	{
		if (SeverConsts::Get()->IsDebug())
		{
			ontestLogin();
		}
	}
}

void LoadingFrame::onAnimationDone(const std::string& animationName){
	if (animationName == "LogoAni")
	{
		showLoadingAniPage();
		setPosLoadingAniPage();
		//checkVersion();
		checkServerState();
	}
}

void LoadingFrame::hotUpdateReport(int time, int size)
{
	if (time <= 0 || size <= 0) {
		return;
	}
	try
	{
		// PlatformSDKActivity.java 接口
		Json::Value data;
		data["funtion"] = "trackEvent";
		data["param"] = "#event_hotupdate_time";

		Json::Value property;
		property["#hotupdate_time"] = time;
		property["#hotupdate_size"] = size;

		data["properties"] = property.toStyledString();

		libPlatformManager::getPlatform()->sendMessageG2P("G2P_TAPDB_HANDLER", data.toStyledString());
	}
	catch (...)
	{
		CCLog("URL REQUEST IS NOT  REACH");
	}

}

void LoadingFrame::downloadReport(std::string url, int reslut, int count)
{
	try
	{
		// PlatformSDKActivity.java 接口
		Json::Value data;
		data["funtion"] = "trackEvent";
		data["param"] = "#event_download_result";

		Json::Value property;
		property["#download_url"] = url;
		property["#download_result"] = reslut;
		property["#download_failed_time"] = count;
		property["#download_ip"] = libPlatformManager::getPlatform()->getDomainIp(url);
		data["properties"] = property.toStyledString();

		libPlatformManager::getPlatform()->sendMessageG2P("G2P_TAPDB_HANDLER", data.toStyledString());
	}
	catch (...)
	{
		CCLog("URL REQUEST IS NOT  REACH");
	}

}

void LoadingFrame::loginReport(int step)
{
	//平台
	std::string platform = libPlatformManager::getPlatform()->getClientChannel();
	//裝置id
	std::string deviceid = libOS::getInstance()->getDeviceID();
	std::string stepKey = "REPORT_STEP_" + deviceid + "_" + platform;
	int localStep = CCUserDefault::sharedUserDefault()->getIntegerForKey(stepKey.c_str(), 0);
	if (localStep >= step) {
		return;	//已記錄後面步驟
	}
	try
	{
		// PlatformSDKActivity.java 接口
		Json::Value data;
		data["funtion"] = "trackEvent";
		data["param"] = "#event_device_step";

		Json::Value property;
		property["#device_step"] = step;

		data["properties"] = property.toStyledString();
		
		libPlatformManager::getPlatform()->sendMessageG2P("G2P_TAPDB_HANDLER", data.toStyledString());
	}
	catch (...)
	{
		CCLog("URL REQUEST IS NOT  REACH");
	}

}
void LoadingFrame::loginGame(std::string& address, int port, bool isRegister)
{
#if CONNECT_DIRECT_ENABLE == 1
	PacketManager::Get()->init(CONNECT_DIRECT_ADDRESS,25524);
#else
	PacketManager::Get()->init(address,port);
    CCLOG("Address:%s, port:%d", address.c_str(), port);
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) && defined(Macro_AndroidTestJiHuoMa)
	PacketManager::Get()->registerPacketHandler(OPCODE_ACTIVE_CODERET_S, this);
#endif
	PacketManager::Get()->registerPacketHandler(LOGIN_S, this);
	PacketManager::Get()->registerPacketHandler(ERROR_CODE, this);

	HPLogin loginPack;
	GamePrecedure::Get()->setServerID(mSelectedSeverID);
	GamePrecedure::Get()->setAlertServerUpdating(false);
	std::string uin = libPlatformManager::getPlatform()->loginUin();

	std::string platformInfo = libPlatformManager::getPlatform()->getPlatformInfo();
	std::string deviceID = libOS::getInstance()->getDeviceID();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	// Samsung i9100's audio driver has a bug , it can not accept too much effects concurrently.
	if(((platformInfo.find("samsung")!=std::string::npos)||(platformInfo.find("SAMSUNG")!=std::string::npos))&&(platformInfo.find("9100")!=std::string::npos))
	{
		BlackBoard::Get()->isSamSungi9100Audio = true;				
	}
#endif
	if (uin.empty()) {
		libOS::getInstance()->showMessagebox(Language::Get()->getString("@LoginIDFail"), Err_ConnectFailed);
		return;
	}
	GamePrecedure::Get()->setUin(uin);
	
	if (deviceID.empty()) 
		deviceID="device id is empty";
	if (!platformInfo.empty())
		loginPack.set_platform(platformInfo);

	loginPack.set_puid(uin);
	loginPack.set_isrelogin(false);
	std::string aPwd = GamePrecedure::getInstance()->getDefaultPwd();
	if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs())
	{
		loginPack.set_passwd(aPwd);
	}
	else
	{
		if (aPwd != "")
			loginPack.set_passwd(aPwd);
	}
	int isGuest = libPlatformManager::getPlatform()->getIsGuest();
	loginPack.set_isguest(isGuest);
	loginPack.set_deviceid(deviceID);
    std::string token = libPlatformManager::getPlatform()->getToken();
    loginPack.set_token(token);
    
	std::string langArea = GamePrecedure::getInstance()->getI18nSrcPath();
	if (langArea == "")
	{
		langArea = "none";
	}
	loginPack.set_langarea(langArea);
    g_iSelectedSeverIDCopy = mSelectedSeverID;
	loginPack.set_serverid(mSelectedSeverID);
	loginPack.set_version(SeverConsts::Get()->getServerVersion());

	mSendLogin=true;
	LoginPacket::Get()->setEnabled(false);
	PacketManager::Get()->sendPakcet(LOGIN_C,&loginPack);
	CCLog("LOGIN_C : uin = %s, platformInfo = %s, password = %s, token = %s, serverId = %d, version = %s", 
		uin.c_str(), platformInfo.c_str(), aPwd.c_str(), token.c_str(), mSelectedSeverID, SeverConsts::Get()->getServerVersion().c_str());
	//caculate the time to kill game when player enter background
	if(VaribleManager::Get()->getSetting("ExitGameTime")!="")
	{
		TimeCalculator::getInstance()->createTimeCalcultor("ExitGameTime",StringConverter::parseInt(VaribleManager::Get()->getSetting("ExitGameTime")));
	}
}
void LoadingFrame::onInputboxEnter(const std::string& content)
{
    gPuid = content;
}

void LoadingFrame::onMenuItemAction( const std::string& itemName, cocos2d::CCObject* sender, int tag )
{
	mSelectedSeverID = tag;
	updateSeverName();
	showSevers(false);
	if (!SeverConsts::Get()->IsEroR18() && !SeverConsts::Get()->IsErolabs()) //H365
	{
		#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			showLoginUser();
		#endif
	}
}

void LoadingFrame::updateLocalSeverId()
{
	std::string uinkey = "DefaultSeverID";// +libPlatformManager::getPlatform()->loginUin();
	cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey(uinkey.c_str(),mSelectedSeverID);
	cocos2d::CCUserDefault::sharedUserDefault()->flush();
}

void LoadingFrame::load( void )
{
	loadCcbiFile("LoadingFramenew_jp.ccbi");
	//只針對高度resize
	CCNode* rootNode = dynamic_cast<CCNode*>(getVariable("mLoadingFrameRoot"));
	rootNode->setContentSize(CCSize(720.0f, rootNode->getContentSize().height));
	//unsigned long filesize;
	//char* pBuffer = (char*)cocos2d::CCFileUtils::sharedFileUtils()->getFileData((std::string("hotUpdate.zip")).c_str(), "rt", &filesize);
	//根據平台切換Logo
	CCSprite* logo = dynamic_cast<CCSprite*>(getVariable("mLoadingFrameBG"));
	int langType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
	if (SeverConsts::Get()->IsEroR18()) {	//工口R18
		logo->setTexture("LoadingUI_JP/loadingUI_logo_EROR18.png");
	}
	else if (SeverConsts::Get()->IsErolabs()) {	//EroLAB
		if (langType == kLanguageCH_TW) {
			logo->setTexture("LoadingUI_JP/loadingUI_logo_EROLABS_TC.png");
		}
		else {
			logo->setTexture("LoadingUI_JP/loadingUI_logo_EROLABS_SC.png");
		}
	}
	else if (SeverConsts::Get()->IsOP()) {	//OP
		if (langType == kLanguageCH_TW) {
			logo->setTexture("LoadingUI_JP/loadingUI_logo_OP_TC.png");
		}
		else {
			logo->setTexture("LoadingUI_JP/loadingUI_logo_OP_SC.png");
		}
	}
	else if (SeverConsts::Get()->IsGP()) {	//GP
		if (langType == kLanguageCH_TW) {
			logo->setTexture("LoadingUI_JP/loadingUI_logo.png");
		}
		else {
			logo->setTexture("LoadingUI_JP/loadingUI_logo.png");
		}
	}
	else {
		logo->setTexture("LoadingUI_JP/loadingUI_logo.png");
	}
	TipsManager::TipsItemListIterator itr = TipsManager::Get()->getTipsIterator();
	while(itr.hasMoreElements())
	{
		std::string tip = itr.getNext()->tip;
		mTipVec.push_back(tip);
	}
	setTips("loading......");
	showSpine();
	this->runAnimation("LogoAni");
}
void LoadingFrame::showSpine()
{
	GamePrecedure::Get()->playMovie("LoadingFrame", "op", 1, 1);
}

void LoadingFrame::showDaterTransFerBtn(bool isVisible)
{
	CCMenuItemImage* mDataTransferBtn = dynamic_cast<CCMenuItemImage*>(getVariable("mDataTransfer"));
	if (mDataTransferBtn)
	{
		mDataTransferBtn->setVisible(isVisible);
	}
}

void LoadingFrame::showLoginingInPercent(int pct)
{
	if (getVariable("mUpdateDescription"))
	{
		CCLabelBMFont* sever = dynamic_cast<CCLabelBMFont*>(getVariable("mUpdateDescription"));
		if (sever)
		{
			sever->setVisible(true);
			char sztmp[16] = { 0 };
			sprintf(sztmp, "%d%%", pct);
			std::string strpct = Language::Get()->getString("@UpdateDescriptionupLoginingIn");
			strpct.append(sztmp);
			sever->setString(strpct.c_str(), true);
		}
	}
}
/*
登入介面
*/
void LoadingFrame::showLoginUser(const std::string& UserID, const std::string& aPwd, const ERO_LOGINTYPE loginType)
{
	BasePage* page = CCBManager::Get()->getPage("LoginUserPage");
	if (page && !page->getParent() && (loginType == ERO_LOGINTYPE::LOGINTYPE_NONE || loginType == ERO_LOGINTYPE::LOGINTYPE_NORMAL_ACCOUNT))
	{
		page->load();
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
		if (sta)
		{
			sta->Enter(NULL);
		}
		//屏蔽下层触摸
		cocos2d::CCLayer* layer = CCLayer::create();
		layer->setContentSize(CCDirector::sharedDirector()->getOpenGLView()->getVisibleSize());
		layer->setPosition(0, 0);
		layer->setAnchorPoint(ccp(0, 0));
		layer->setTouchEnabled(true);
		layer->setTouchMode(cocos2d::kCCTouchesOneByOne);
		page->addChild(layer, -1);

		CCNode* uiNode = dynamic_cast<CCNode*>(getVariable("mUINode"));
		uiNode->addChild(page);
		page->setPosition(ccp(0, 0));

		LoginUserPage* mLoginUserPage = dynamic_cast<LoginUserPage*>(CCBManager::Get()->getPage("LoginUserPage"));
		if (mLoginUserPage)
		{
			mLoginUserPage->DefaultLogin(UserID, aPwd);
		}
	}
}


void  LoadingFrame::hideLoginUser()
{
	LoginUserPage* page = dynamic_cast<LoginUserPage*>(CCBManager::Get()->getPage("LoginUserPage"));
	if (!page)
	{
		return;
	}
	page->closePage();
}
void LoadingFrame::showSevers(bool _show)
{
	if(getVariable("mSeverNode"))
	{
		CCNode* sever = dynamic_cast<CCNode*>(getVariable("mSeverNode"));
		if(sever)
		{
			m_IsCanClickStartGameBtn = !_show;

			sever->setVisible(_show);
			if(_show && getVariable("mSeverRecentList"))
			{
				CCScrollView* severlist = dynamic_cast<CCScrollView*>(getVariable("mSeverRecentList"));
				CCNode* attachNode = CCNode::create();
				CCBContainer * node = CCBContainer::create();
				node->loadCcbiFile("LoadingFrameSeverRecentList.ccbi");
				float singleButtonHeight=0;
				int count = 0;
				int noteCount = 0;

				if(node->getVariable("mRecent"))
				{
					int trueCount = count;
                    
                    std::vector<int> *servers = new std::vector<int>();
                    
                    if(count == 0)
                        count = 1;
                    
					std::string uinkey = "DefaultSeverID";
					int defid = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey(uinkey.c_str(),SeverConsts::Get()->getSeverDefaultID());
                    
                    for(int i=0; i<count;++i)
                    {
						if(noteCount>6) break;
                        int serverIDtoforRecent = defid;
                        if(trueCount>0)
						{
							int numToFind = 1;
							std::vector<int>::iterator iter = std::find(servers->begin(),servers->end(),numToFind);
							if (iter==servers->end())
							{
								serverIDtoforRecent=numToFind;
								servers->push_back(numToFind);
							}
							else
							{
								continue;
							}
						}
                        
                        SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(serverIDtoforRecent);
                        if(it==SeverConsts::Get()->getSeverList().end())
                            continue;
                                              
                        CCNode* recentNode = dynamic_cast<CCNode*>(node->getVariable("mRecent"));
                        if(noteCount%2==1)
                           recentNode = dynamic_cast<CCNode*>(node->getVariable("mRecent2"));
                        
                        if(recentNode && it!=SeverConsts::Get()->getSeverList().end())
                        {
                            CCBContainer* button = CCBContainer::create();
                            button->setListener(this,it->second->id);
                            button->loadCcbiFile("LoadingFrameSever.ccbi");
                            if(button->getVariable("mSeverName"))
                            {
                                CCLabelTTF* str = dynamic_cast<CCLabelTTF*>(button->getVariable("mSeverName"));
                                if(str)	str->setString(it->second->name.c_str());
                            }

                            CCNode* fullSever = 0;
                            CCNode* newSever = 0;
							CCNode* maintainSever = 0;
                            if(button->getVariable("mSeverFull"))
                                fullSever = dynamic_cast<CCNode*>(button->getVariable("mSeverFull"));
                            if(button->getVariable("mSeverNew"))
                                newSever = dynamic_cast<CCNode*>(button->getVariable("mSeverNew"));
							if(button->getVariable("mSeverMaintain"))
							    maintainSever = dynamic_cast<CCNode*>(button->getVariable("mSeverMaintain"));

							if(fullSever) fullSever->setVisible(it->second->state == SeverConsts::SS_FULL);
                            if(newSever)  newSever->setVisible(it->second->state == SeverConsts::SS_NEW);
                            if(maintainSever) maintainSever->setVisible(it->second->state == SeverConsts::SS_MAINTAIN);

                            singleButtonHeight = button->getContentSize().height;
							
							button->setPositionY(-(singleButtonHeight)*(noteCount-noteCount%2)*0.5f);//(i-i%2)*0.5f

                            recentNode->addChild(button);
                        }
						noteCount++;
                    }
                    delete servers;
                }
				attachNode->addChild(node);
				
                //count--;
                float offpos1 = singleButtonHeight * ((noteCount + 1)/2 - 1);//count
                if(offpos1<severlist->getContentSize().height - singleButtonHeight)
                    offpos1 = severlist->getContentSize().height - singleButtonHeight;             
				//count++;
				node->setPosition(0,offpos1);

				CCSize size;				
				size.width  = node->getContentSize().width;
                size.height = (noteCount+noteCount%2) * 0.5f * singleButtonHeight;//count
                if(severlist->getContentSize().height>size.height)
                    size.height = severlist->getContentSize().height;
				
				attachNode->setContentSize(size);
				severlist->setContainer(attachNode);
				severlist->setContentSize(size);
				severlist->setContentOffset(ccp(0,severlist->getViewSize().height-size.height));
			}

			if(_show && getVariable("mSeverList"))
			{
				CCScrollView* severlist = dynamic_cast<CCScrollView*>(getVariable("mSeverList"));
				CCTouchHandler* pHandler = CCDirector::sharedDirector()->getTouchDispatcher()->findHandler(severlist);
				if (pHandler)
				{
					CCTargetedTouchHandler* pTh = dynamic_cast<CCTargetedTouchHandler*>(pHandler);
					if (pTh)
					{
						pTh->setSwallowsTouches(true);
					}
				}
				CCNode* attachNode = CCNode::create();

				CCBContainer * node = CCBContainer::create();
				node->loadCcbiFile("LoadingFrameSeverList.ccbi");
				int countID = 0;
				float singleButtonHeight = 0;
				if(node->getVariable("mAll1") && node->getVariable("mAll2"))
				{
					CCNode* allNode1 = dynamic_cast<CCNode*>(node->getVariable("mAll1"));
					CCNode* allNode2 = dynamic_cast<CCNode*>(node->getVariable("mAll2"));
					SeverConsts::SEVERLIST::const_reverse_iterator it = SeverConsts::Get()->getSeverList().rbegin();

					std::list<SeverConsts::SEVER_ATTRIBUTE> orderlist;
					for(;it!=SeverConsts::Get()->getSeverList().rend();++it)
					{
						orderlist.push_back(*it->second);
					}
					//orderlist.sort();
					std::list<SeverConsts::SEVER_ATTRIBUTE>::iterator itOrdered = orderlist.begin();
					for(;itOrdered!=orderlist.end();++itOrdered)
					{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
						// H365, 69, aplus以外平台不顯示測試1-3服
						if (!SeverConsts::Get()->IsH365() && !SeverConsts::Get()->IsKUSO() && !SeverConsts::Get()->IsAPLUS()) {
							if (itOrdered->id <= 3) {
								continue;
							}
						}
#endif
						CCBContainer* button = CCBContainer::create();
						button->setListener(this,itOrdered->id);
						button->loadCcbiFile("LoadingFrameSever.ccbi");
						if(button->getVariable("mSeverName"))
						{
							CCLabelTTF* str = dynamic_cast<CCLabelTTF*>(button->getVariable("mSeverName"));
							int userType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
							switch (userType) {
							case kLanguageChinese:
								if (str)	str->setString(itOrdered->name.c_str());
								break;
							case kLanguageCH_TW:
								if (str)	str->setString(itOrdered->nameTW.c_str());
								break;
							default:
								if (str)	str->setString(itOrdered->name.c_str());
								break;
							}
						}
						CCNode* fullSever = 0;
						CCNode* newSever = 0;
						CCNode* maintainSever = 0;
						if(button->getVariable("mSeverFull"))
							fullSever = dynamic_cast<CCNode*>(button->getVariable("mSeverFull"));
						if(button->getVariable("mSeverNew"))
							newSever = dynamic_cast<CCNode*>(button->getVariable("mSeverNew"));
						if(button->getVariable("mSeverMaintain"))
							maintainSever = dynamic_cast<CCNode*>(button->getVariable("mSeverMaintain"));

						if(fullSever) fullSever->setVisible(itOrdered->state == SeverConsts::SS_FULL);
						if(newSever) newSever->setVisible(itOrdered->state == SeverConsts::SS_NEW);
						if(maintainSever) maintainSever->setVisible(itOrdered->state == SeverConsts::SS_MAINTAIN);

						if(countID %2 ==0)
							allNode1->addChild(button);
						else
							allNode2->addChild(button);
						singleButtonHeight = button->getContentSize().height;

						button->setPosition(ccp(0,-(singleButtonHeight)*(countID-countID%2)*0.5f));
						countID++;
					}
				}
				attachNode->addChild(node);
				
                //countID--;
                float offpos1 = singleButtonHeight * ((countID+1)/2 - 1);
                if(offpos1<severlist->getContentSize().height - singleButtonHeight)
                   offpos1 = severlist->getContentSize().height - singleButtonHeight;
                //countID++;
				node->setPosition(0,offpos1);

				CCSize size;
				size.width = node->getContentSize().width;
				size.height = (countID + countID%2)*0.5f*singleButtonHeight;
                if(severlist->getContentSize().height>size.height)
                    size.height = severlist->getContentSize().height;
				CCLOG("contentheight:%f", severlist->getContentSize().height);
				
				attachNode->setContentSize(size);
				severlist->setContainer(attachNode);
				severlist->setContentSize(size);
				severlist->setContentOffset(ccp(0,severlist->getViewSize().height-size.height));
			}
		}
	}
}

void LoadingFrame::showEnter()
{

	hidLoadingAniPage();
	CCLog("LoadingFrame::showEnter");
	if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs() || SeverConsts::Get()->IsKUSO() || SeverConsts::Get()->IsAPLUS() || SeverConsts::Get()->IsOP() || SeverConsts::Get()->IsGP()) {
		setEnterGameNodeVisible(true);
	}
	else {
		setEnterGameNodeVisible(false);
	}
    
	setEnterServerListVisible(true);
	if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs() || SeverConsts::Get()->IsKUSO() || SeverConsts::Get()->IsAPLUS() || SeverConsts::Get()->IsOP() || SeverConsts::Get()->IsGP())
	{
		setLogoutBtnVisible(true);
	}

	setLogoutNodeVisible(false);
	CCLabelTTF* tipsLabel = dynamic_cast<CCLabelTTF*>(getVariable("mTips"));//mLoading1
	if (tipsLabel)
	{
		tipsLabel->setVisible(false);
	}

    setLoginGameNodeVisible(false);
}

int LoadingFrame::getDefaultSeverID()
{
	std::string uinkey = "DefaultSeverID";// + uin;
	int itmp = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey(uinkey.c_str(), -1);
	if (itmp == -1)
	{
		mIsFirstLoginNotServerIDInfo = true;
		libOS::getInstance()->analyticsLogEvent("getDefaultSeverID-mIsFirstLoginNotServerIDInfo");
		itmp = SeverConsts::Get()->getSeverDefaultID();
		return itmp;
	}
	else
	{
		return itmp;
	}
}

void LoadingFrame::updateSeverName()
{
	if(getVariable("mSeverName1") && mSelectedSeverID != -1)
	{
		CCLabelTTF* eb = dynamic_cast<CCLabelTTF*>(getVariable("mSeverName1"));
		SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(mSelectedSeverID);
		if (eb && it != SeverConsts::Get()->getSeverList().end()) {
			CCLog("servername %s", it->second->name.c_str());
			int userType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
			switch (userType) {
			case kLanguageChinese:
				eb->setString(it->second->name.c_str());
				break;
			case kLanguageCH_TW:
				eb->setString(it->second->nameTW.c_str());
				break;
			default:
				eb->setString(it->second->name.c_str());
				break;
			}
		}
	}
}
void LoadingFrame::onReLogin(){

}

void LoadingFrame::onReceivePacket( const int opcode, const ::google::protobuf::Message* packet )
{
	static int siNowSvrID = 0;
	
	if(opcode==LOGIN_S)
	{
		if (siNowSvrID == 0)
		{
			siNowSvrID = mSelectedSeverID;
		}
		const HPLoginRet * logret = dynamic_cast<const HPLoginRet*>(packet);
		//CCLOG("**************User LoginPacket Received *************************");

		//status =0 means log in success 
		if(logret )
		{
			if (logret->has_playerid())
			{
				if (logret->playerid()>0)
				{
					if (siNowSvrID != mSelectedSeverID || 
						(ServerDateManager::Get()->mLoginInfo.m_iPlayerID > 0 && 
							ServerDateManager::Get()->mLoginInfo.m_iPlayerID != logret->playerid()))
					{
						siNowSvrID = mSelectedSeverID;
						//发生了换角色或者换区重新登录
						ServerDateManager::Get()->reset(true);
					}
					//
					if (ServerDateManager::Get()->mLoginInfo.m_iPlayerID > 0)
					{
						//大于0说明不是大退新登，是重新登，重新登就reset
						ServerDateManager::Get()->reset(false);
					}
					ServerDateManager::Get()->mLoginInfo.m_iPlayerID = logret->playerid();

					if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs())
					{
						libPlatformManager::getPlatform()->setIsGuest(logret->isguest());
					}
				}
				else
				{
					CCAssert(false, "logret->playerid()>0");
					return;
				}
			}
			if (logret->has_roleitemid())
			{
				ServerDateManager::Get()->mLoginInfo.m_iRoleItemID= logret->roleitemid();
			}
			else
			{
				ServerDateManager::Get()->mLoginInfo.m_iRoleItemID= 0;//允许从MainFrame退回LoadingFrame就需要这样
			}
			if (logret->has_timestamp())
			{
				if (logret->timestamp()>0)
				{
					ServerDateManager::Get()->mLoginInfo.m_iTimeStamp= logret->timestamp();
					GamePrecedure::Get()->setServerTime(logret->timestamp());
				}
			}
			SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(mSelectedSeverID);
			if (ServerDateManager::Get()->mLoginInfo.m_iRoleItemID == 0)
			{
				//非訪客的工口/Erolabs登入新帳號需呼叫綁定帳號
				if (logret->isguest() == 0) {
					if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs()) {
						Lua_EcchiGamerSDKBridge::callPostAccountBindbyC(StringConverter::toString(logret->playerid()));
					}
				}
				GamePrecedure::Get()->setHasMainRole(false);
			}

			GamePrecedure::Get()->preEnterMainMenu();
			MsgLoadingFrameEnterGame enterGameMsg;
			MessageManager::Get()->sendMessage(&enterGameMsg);
			PacketManager::Get()->removePacketHandler(this);
			GamePrecedure::Get()->setAlertServerUpdating(true);
			CurlDownload::Get()->removeListener(this);
		}
		else
		{
			CCLog("onReceivePacket showEnter");
			showEnter();
		}
	}
	else if(opcode == ERROR_CODE)
	{
		const HPErrorCode * errMsgRet = dynamic_cast<const HPErrorCode*>(packet);
		if(errMsgRet->hpcode() == LOGIN_S&&mSendLogin)
		{
			PacketManager::Get()->removePacketHandler(this);
			std::string _errMsgLang="";
			if(!errMsgRet->has_errmsg())
			{
				char msg[256];
				sprintf(msg, "@ErrorReport_%d", errMsgRet->errcode());
				_errMsgLang=Language::Get()->getString(msg)+"["+StringConverter::toString(errMsgRet->hpcode())+"|"+StringConverter::toString(errMsgRet->errcode())+"]";
			}
			else
			{
				_errMsgLang=errMsgRet->errmsg();
			}
			libOS::getInstance()->showMessagebox(_errMsgLang,Err_ErrMsgReport);
		}
	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) && defined(Macro_AndroidTestJiHuoMa)
	else if(opcode == OPCODE_ACTIVE_CODERET_S)
	{
		const OPActiveCodeRet * ret = dynamic_cast<const OPActiveCodeRet*>(packet);
		CCLog("ret->status()%d", ret->status());
		if(ret->status()==1)
		{
			mScene->removeChildByTag(999,true);
			std::string out = Language::Get()->getString("@ActiveCodeSuccess");
			CCMessageBox(out.c_str(),Language::Get()->getString("@LoadingFrameLogretStatsTitle").c_str());
		}
		else if(ret->status()==2)
		{
			std::string out = Language::Get()->getString("@ActiveCodeBeenUsed");
			CCMessageBox(out.c_str(),Language::Get()->getString("@LoadingFrameLogretStatsTitle").c_str());
		}
		else
		{
			std::string out = Language::Get()->getString("@WrongActiveCode");
			CCMessageBox(out.c_str(),Language::Get()->getString("@LoadingFrameLogretStatsTitle").c_str());
		}
	}
#endif
}

void LoadingFrame::onConnectFailed( std::string ip, int port )
{
	connectCount = connectCount + 1;
	if (connectCount >= 5)
	{
		waitingManager::Get()->endWaiting();
		waitingManager::Get()->clearReasones();//手动触发超时，结束菊花
		CCLog("onConnectFailed showEnter");
		showEnter();
		std::string out = Language::Get()->getString("@LoadingFrameSeversConnectionFailed");
		if (libOS::getInstance()->getNetWork() == NotReachable)
		{
			libOS::getInstance()->showMessagebox(Language::Get()->getString("@NoNetWork"), Err_ConnectFailed);
		}
		else
		{
			{
				libOS::getInstance()->showMessagebox(out, Err_ConnectFailed);
			}
		}
		PacketManager::Get()->removePacketHandler(this); 
	}
	else
	{
		SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(mSelectedSeverID);
		if (it == SeverConsts::Get()->getSeverList().end())
		{
			return;
		}

		if (it->second->state == SeverConsts::SS_MAINTAIN)
		{
			libOS::getInstance()->showMessagebox(Language::Get()->getString("@ServerMaintain"), 0);
			return;
		}

		if (mSelectedSeverID <= 0)
		{
			showSevers(true);
			return;
		}
		GamePrecedure::Get()->setInLoadingScene();
		if (it != SeverConsts::Get()->getSeverList().end())
		{
			int order = it->second->order;

			std::string strPlatformName = GamePrecedure::getInstance()->getPlatformName();
			if (-1 != strPlatformName.find("entermate"))
			{
				Json::Value data;
				data["serverId"] = order;
				libPlatformManager::getPlatform()->sendMessageG2P("OnKrCheckServer", data.toStyledString());
			}
			else
			{
				loginGame(it->second->address, it->second->port);
			}
		}
	}
}

CCScene* LoadingFrame::getRootSceneNode()
{
	return mScene;
}

void LoadingFrame::showLoadingAniPage()
{
	LoadingAniPage* page = dynamic_cast<LoadingAniPage*>(CCBManager::Get()->getPage("LoadingAniPage"));
	if (!page)
	{
		return;
	}
	CCNode* child = this->getChildByTag(LoadinAniPageTag);
	if (child)
	{
		return;
	}
	page->load();
	page->removeFromParent();
	cocos2d::CCLayer* layer = CCLayer::create();
	layer->setContentSize(CCDirector::sharedDirector()->getOpenGLView()->getVisibleSize());
	layer->setPosition(0,0);
	layer->setAnchorPoint(ccp(0,0));
	layer->setTouchEnabled(true);
	layer->setTouchMode(cocos2d::kCCTouchesOneByOne);
	layer->setTag(LoadinAniPageTag + 1);
	page->addChild(layer, -1);



	page->setTag(LoadinAniPageTag);
	CCNode* node = dynamic_cast<CCNode*>(getVariable("mNodeFront"));
	if (node)
	{
		node->addChild(page);
	}
}

void LoadingFrame::hidLoadingAniPage()
{
	LoadingAniPage* page = dynamic_cast<LoadingAniPage*>(CCBManager::Get()->getPage("LoadingAniPage"));
	if (!page)
	{
		return;
	}

	page->stopLoadingAni();
	page->unload();
	page->removeFromParentAndCleanup(true);
}
void LoadingFrame::setOpcaityLoadingAniPage(int value )
{
	LoadingAniPage* page = dynamic_cast<LoadingAniPage*>(CCBManager::Get()->getPage("LoadingAniPage"));
	if (!page)
	{
		return;
	}
	if (page->getChildByTag(LoadinAniPageTag + 1))
	{
		if (value == 0)
		{
			CCLayer *layer = dynamic_cast<CCLayer*>(page->getChildByTag(LoadinAniPageTag + 1));
			layer->setTouchEnabled(false);
		}
		else
		{
			CCLayer *layer = dynamic_cast<CCLayer*>(page->getChildByTag(LoadinAniPageTag + 1));
			layer->setTouchEnabled(true);
		}
		
	}
	CCLayerColor *_mLayerColor = dynamic_cast<CCLayerColor*>(page->getVariable("mLayerColor"));

	if (_mLayerColor)
	{
		_mLayerColor->setOpacity(value);
	}
}
void LoadingFrame::setPosLoadingAniPage()
{
	LoadingAniPage* page = dynamic_cast<LoadingAniPage*>(CCBManager::Get()->getPage("LoadingAniPage"));
	if (!page)
	{
		return;
	}

	CCNode *_clarmNode = dynamic_cast<CCNode*>(page->getVariable("mClarmNode"));
	CCNode * mLoading = dynamic_cast<CCNode*>(getVariable("mWaitingNode"));
	if (_clarmNode && mLoading)
	{
		//_clarmNode->setPositionY(mLoading->getPositionY());

	}
}

std::string LoadingFrame::onReceiveCommonMessage( const std::string& tag, const std::string& msg )
{
	if(tag == "SERVERLIST")
	{
		std::string ret = SeverConsts::Get()->onReceiveCommonMessage(tag,msg);

		int newServerId = getDefaultSeverID();
		{
			SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(newServerId);
			if(it == SeverConsts::Get()->getSeverList().end())
				newServerId = SeverConsts::Get()->getSeverDefaultID();
		}


		if(newServerId != mSelectedSeverID)
		{
			mSelectedSeverID = newServerId;
		}
		updateSeverName();
		if(getVariable("mSeverNode"))
		{
			CCNode* sever = dynamic_cast<CCNode*>(getVariable("mSeverNode"));
			if(sever &&mIsFirstLoginNotServerIDInfo)
			{
				mIsFirstLoginNotServerIDInfo = false;
			}
		}
		return ret;
	}
	else if (tag == "P2G_KR_CHECKSERVER_BACK")
	{
		Json::Reader jreader;
		Json::Value jvalue;
		jreader.parse(msg, jvalue, false);

		Json::Value jroot = jvalue;
		if (!jroot.empty() && !jroot["State"].empty())
		{
			std::string state = jroot["State"].asString();
			if (state == "ok")
			{
				SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(mSelectedSeverID);
				if(it!=SeverConsts::Get()->getSeverList().end())
				{
					CCLog("P2G_KR_CHECKSERVER_BACK");
				}
			}
			else
			{
				CCLog("P2G_KR_CHECKSERVER_BACK false");
				libOS::getInstance()->showMessagebox(state);
			}
		}
	}
	else if (tag=="P2G_DATATRANSFER_SHOW")
	{
		if (msg == "1")
		{
			mIsCanShowDataTransfer = false;
		}
		else
		{
			mIsCanShowDataTransfer = true;
		}
	}
	else if (tag == "P2G_PLATFORM_LOGOUT")
	{
        if (SeverConsts::Get()->IsKUSO() || SeverConsts::Get()->IsAPLUS() || SeverConsts::Get()->IsErolabs()){
			if (msg == "1")
			{
				libPlatformManager::getPlatform()->login();
			}
		}
	}
	return "";
}

void LoadingFrame::setEnterGameNodeVisible( bool visible )
{
	if (visible == true) {
		CCNode* mLoading = dynamic_cast<CCNode*>(getVariable("mWaitingNode"));
		if (mLoading && mLoading->isVisible()){
			CCB_FUNC(this, "mLoginNode2", CCNode, setVisible(false));
			return;
		}
	}
	CCB_FUNC(this, "mLoginNode2", CCNode, setVisible(visible));
}

void LoadingFrame::setEnterBCNodeVisible(bool visible)
{
	CCB_FUNC(this, "mBCLoginNode", CCNode, setVisible(visible));
}

void LoadingFrame::setEnterServerListVisible(bool visible)
{
	if (visible == true) {
		CCNode* mLoading = dynamic_cast<CCNode*>(getVariable("mWaitingNode"));
		if (mLoading && mLoading->isVisible()){
			CCB_FUNC(this, "mLoginNode1", CCNode, setVisible(false));
			return;
		}
	}
	CCB_FUNC(this, "mLoginNode1", CCNode, setVisible(visible));
}

void LoadingFrame::setLoginGameNodeVisible(bool visible)
{
    CCB_FUNC(this, "mPostLoginNode", CCNode, setVisible(visible))
}

void LoadingFrame::setWaitGameNodeVisible( bool visible )
{
	CCB_FUNC(this, "mWaitingNode", CCNode, setVisible(visible));
}

void LoadingFrame::setLogoutNodeVisible(bool visible)
{
	//工口平台訊息換成@SDK8字串
	if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs()) {
		CCLabelTTF* warnTxt = dynamic_cast<CCLabelTTF*>(getVariable("mLogoutWarnTxt"));
		if (warnTxt)
		{
			std::string warnStr = Language::Get()->getString("@SDK8");
			warnTxt->setString(warnStr.c_str());
		}
	}
	CCB_FUNC(this, "mLogoutNode", CCNode, setVisible(visible));
}

void LoadingFrame::setLogoutBtnVisible(bool visible)
{
	CCB_FUNC(this, "mLogoutBtn", CCNode, setVisible(visible));
}

void LoadingFrame::setLogoutCheck(bool visible)
{
	CCB_FUNC(this, "mIsCheck", CCNode, setVisible(visible));
}

void LoadingFrame::onShowMessageBox( const std::string& msgString, int tag )
{
	MessageHintPage::Msg_Hint(msgString,tag);
}

void LoadingFrame::onEnterGame(bool isRegister)
{
	if (!m_IsCanClickStartGameBtn)
		return;

	if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() || SeverConsts::Get()->IsKUSO() || SeverConsts::Get()->IsOP() || SeverConsts::Get()->IsGP()) // H365,JSG,LSJ
	{
		std::string uuid = libPlatformManager::getPlatform()->loginUin();
		if (uuid == "")
		{
			libPlatformManager::getPlatform()->login();
			return;
		}
	}

	SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(mSelectedSeverID);
	if (it == SeverConsts::Get()->getSeverList().end())
	{
		return;
	}

	if (it->second->state == SeverConsts::SS_MAINTAIN)
	{
		SeverConsts::Get()->setIsRedownLoadServer(true);//第一次点击的时候是维护状态
		if (SeverConsts::Get()->getMaintenanceTip() == "")
		{
			libOS::getInstance()->showMessagebox(Language::Get()->getString("@ServerMaintain"), 0);
		}
		else
		{
			libOS::getInstance()->showMessagebox(SeverConsts::Get()->getMaintenanceTip(), 0);
		}
		return;
	}
	else
	{
		if (SeverConsts::Get()->getIsRedownLoadServer())
		{
			time_t t;
			time(&t);
			CCString* _time = CCString::createWithFormat("%d", t);
			std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
			std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestNameTmp;
			std::string downloadVerUrl = localVersionData->remoteVersionUrl + "/" + versionManifestName;// +"?" + "time=" + _time->m_sString;
			versionStat = CHECK_VERSION;
			getLocalVersionCfg();
			CurlDownload::Get()->downloadFile(downloadVerUrl, saveVersionPath);
			return;
		}
		SeverConsts::Get()->setIsRedownLoadServer(false);
	}


	if (mSelectedSeverID <= 0)
	{
		showSevers(true);
		return;
	}
	GamePrecedure::Get()->setInLoadingScene();

	if (it != SeverConsts::Get()->getSeverList().end())
	{
		int order = it->second->order;

		std::string strPlatformName = GamePrecedure::getInstance()->getPlatformName();
		if (-1 != strPlatformName.find("entermate"))
		{
			Json::Value data;
			data["serverId"] = order;
			libPlatformManager::getPlatform()->sendMessageG2P("OnKrCheckServer", data.toStyledString());
		}
		else
		{
			loginGame(it->second->address, it->second->port, isRegister);

			setPosLoadingAniPage();
			setOpcaityLoadingAniPage(150);
			loginReport(REPORT_STEP::REPORT_STEP_ENTER_MAIN_GAME);
		}
	}
	else
	{
		mSelectedSeverID = -1;
		showSevers(true);
		return;
	}
}

void LoadingFrame::checkServerState()
{
	setTips("loading......");

	getUpdateVersionTips();

	versionStat = CHECK_SERVER;

	cocos2d::CCFileUtils::sharedFileUtils()->setPopupNotify(true); // is read file fail show messageBox

	try
	{
		std::string url = VaribleManager::Get()->getSetting("MaintainURL", "", "http://backend.quantagalaxies.com:34567/maintaincheck");

		//数据只管发不做返回处理
		auto request = new CCHttpRequest();
		request->setUrl(url.c_str());
		request->setRequestType(CCHttpRequest::HttpRequestType::kHttpPost);
		const char* postData = "maintaincheck";
		request->setRequestData(postData, strlen(postData));
		request->setResponseCallback(this, callfuncND_selector(LoadingFrame::onServerStateRequestCompleted));
		CCHttpClient::getInstance()->send(request);
		CCHttpClient::getInstance()->setTimeoutForRead(10);

		request->release();
	}
	catch (...)
	{
		checkVersion();
		CCLog("URL REQUEST IS NOT  REACH");
	}
}

void LoadingFrame::checkVersion()
{
	setTips("loading......");

	getUpdateVersionTips();

	versionStat = CHECK_VERSION;

	cocos2d::CCFileUtils::sharedFileUtils()->setPopupNotify(true); // is read file fail show messageBox
	std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
	cocos2d::CCFileUtils::sharedFileUtils()->insertSearchPath(writeRootPath.c_str(), 0);

	cocos2d::CCFileUtils::sharedFileUtils()->insertSearchPath((writeRootPath + versionPath + "/").c_str(), 0);

	CurlDownload::Get()->addListener(this);

	//获取本地version.Manifest
	localVersionData = new VersionData();
	getLocalVersionCfg();
	//赋初始值
	SeverConsts::Get()->setServerVersion(localVersionData->versionResource);

	std::string configfile = GamePlatformInfo::getInstance()->getPlatVersionName();
	std::string versionCfgPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(configfile.c_str());

	SeverConsts::getInstance()->_parseConfigFile(versionCfgPath);
	serverVersionData = new VersionData();


	//检测版本号从CDN 下载一个临时version文件 versionTmp.manifest

	//先删除tmp文件
	std::string versionTmpPath = writeRootPath + versionPath + "/" + versionManifestNameTmp;
	if (CCFileUtils::sharedFileUtils()->isFileExist(versionTmpPath))
	{
		remove(versionTmpPath.c_str());
	}

	time_t t;
	time(&t);

	CCString* _time = CCString::createWithFormat("%d", t);
	std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestNameTmp;
	std::string downloadVerUrl = localVersionData->remoteVersionUrl + "/" + versionManifestName;// + "?" + "time=" + _time->m_sString;
	CurlDownload::Get()->downloadFile(downloadVerUrl, saveVersionPath);
}

void LoadingFrame::getServerVersionCfg()
{

	std::string _retTimestamp = "";
	time_t t = time(0);
	//64bit 不识别 
	_retTimestamp = "?time=" + CCString::createWithFormat("%d", t)->m_sString;
	std::string url = localVersionData->remoteVersionUrl + "/" + versionManifestName;// + _retTimestamp;

	auto request = new CCHttpRequest();
	request->setUrl(url.c_str());
	request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
	request->setResponseCallback(this, callfuncND_selector(LoadingFrame::onHttpRequestCompleted));

	request->setTag("serverVersionCfg");

	CCHttpClient::getInstance()->send(request);

	CCLog("hotUpdate : url %s", url.c_str());
	CCLog("hotUpdate : getServerVersionCfg 2");

	request->release();
}
void LoadingFrame::getUpdateVersionTips()
{
	Json::Value root;
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;

	int userType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
	std::string fileName = "";
	switch (userType) {
	case kLanguageChinese:
		fileName = "UpdateVersionTips.cfg";
		break;
	case kLanguageCH_TW:
		fileName = "UpdateVersionTipsTW.cfg";
		break;
	default:
		fileName = "UpdateVersionTips.cfg";
		break;
	}
	char* pBuffer = (char*)cocos2d::CCFileUtils::sharedFileUtils()->getFileData((std::string(fileName)).c_str(), "rt", &filesize);
	if (!pBuffer)
	{
		std::string fullPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename((std::string(fileName)).c_str());
		std::string msg = "Get updateVersionTios data from file(";
		msg.append(fileName).append(") failed!").append("   filePath:").append(fullPath.c_str());
		cocos2d::CCMessageBox(msg.c_str(), "File Not Found");
	}

	if (!pBuffer)
	{
		{
			CC_SAFE_DELETE_ARRAY(pBuffer);
			return;
		}
	}

	bool ret = jreader.parse(pBuffer, filesize, data, false);
	if (!ret)
	{
		return;
	}

	m_updateVersionTips = new UpdateVersionTips();
	m_updateVersionTips->checkVersionTxT = data["checkVersionTxT"].asString();
	m_updateVersionTips->noAssetNeedUpdateTxT = data["noAssetNeedUpdateTxT"].asString();
	m_updateVersionTips->newAssetNeedUpdateTxT = data["newAssetNeedUpdateTxT"].asString();
	m_updateVersionTips->startUpdateTxT = data["startUpdateTxT"].asString();
	m_updateVersionTips->checkFailTxT = data["checkFailTxT"].asString();
	m_updateVersionTips->checkProjectFailTxT = data["checkProjectFailTxT"].asString();
	m_updateVersionTips->notNetworkTxT = data["notNetworkTxT"].asString();
	m_updateVersionTips->updateFailTxT = data["updateFailTxT"].asString();
	m_updateVersionTips->uncompressTxT = data["uncompressTxT"].asString();
	m_updateVersionTips->uncompressCompleteTxT = data["uncompressCompleteTxT"].asString();
	m_updateVersionTips->appStoreUpdateTxT = data["appStoreUpdateTxT"].asString();
	m_updateVersionTips->updateBtnTxT = data["updateBtnTxT"].asString();
	m_updateVersionTips->confirmBtnTxT = data["exitBtnTxT"].asString();
	m_updateVersionTips->bgDownloadTip = data["bgDownloadTip"].asString();
}

void LoadingFrame::setTips(std::string msg)
{
	CCLabelTTF* tipsLabel = dynamic_cast<CCLabelTTF*>(getVariable("mTips"));//mLoading1
	if (tipsLabel)
	{
		tipsLabel->setVisible(true);
		tipsLabel->setString(msg.c_str());
		std::string buildType = libPlatformManager::getPlatform()->getBuildType();
		if (buildType == "qa") {
			tipsLabel->setAnchorPoint(ccp(0.5f, 0.0f));
		}
	}
}
void LoadingFrame::loadingAsset(float dt)
{
	if (versionStat != LOADING_ASSETS)
	{
		return;
	}

	if (versionStat == UPDATE_DONE)
	{
		return;
	}

	if (versionStat == UPDATE_FAIL)
	{
		return;
	}

	if (alreadyDownloadData.size() >= needUpdateAsset.size())
	{
		if (m_updateVersionTips)
		{
			setTips(m_updateVersionTips->uncompressTxT);
		}
		versionStat = UPDATE_DONE;
		CCLog("hotUpdate uncompressTxT : %s", m_updateVersionTips->uncompressTxT.c_str());
		showPersent(1, m_updateVersionTips->uncompressTxT/*std::string("")*/);
		//进度条
		setWaitGameNodeVisible(false);

		if (m_updateVersionTips)
		{
			setTips(m_updateVersionTips->uncompressCompleteTxT);
		}

		if (localVersionData)
		{
			std::string ver = "Ver" + localVersionData->versionApp;
			setVersion(ver);
		}
		
		CCLog("hotUpdate uncompress complete");
		resetVersion();
		GamePrecedure::Get()->enterLoading();

		if (SeverConsts::Get()->getIsRedownLoadServer())
		{
			SeverConsts::Get()->setIsRedownLoadServer(false);
			setEnterServerListVisible(true);
		}
		else
		{
			//此方法必须放在 更新完成之后进行操作 保证本次热更的最新资源
			GamePrecedure::Get()->loadPlsit();
			LoginSuccess();
		}

		time_t t;
		time(&t);
		donwloadEndTime = t;

		hotUpdateReport(donwloadEndTime - downloadStartTime, downloadSize);
		
		return;
	}

	if (alreadyDownloadData.size() + loadFailData.size() >= needUpdateAsset.size())
	{
		if (ResumeCount > 0)
		{
			ResumeUpdateAsset();
		}
		else
		{
			versionStat = UPDATE_FAIL;
			CCB_FUNC(this, "mUpdateBtnNode", cocos2d::CCNode, setVisible(true));
			if (m_updateVersionTips)
			{
				CCLog("hotUpdate : Updatefailed ----step1");
				setTips(m_updateVersionTips->updateFailTxT);
				showFailedMessage(m_updateVersionTips->updateFailTxT, 100);
			}
		}
		return;
	}

	float alreadyLoadSize = 0.0f;//(currentFileLoadSize * 1.0f) / 1024;
	for (auto it = alreadyDownloadData.begin(); it != alreadyDownloadData.end(); ++it) {
		for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
			if ((*it) != (*itNeed)->url)
			{
				continue;
			}
	
			alreadyLoadSize += (*itNeed)->size;
		}
	}
	for (auto it = fileLoadSizeMap.begin(); it != fileLoadSizeMap.end(); ++it) {
		alreadyLoadSize += (it->second / 1024);
		if (it->second > 0) {
			CCLog("Download size : %s : %f", it->first.c_str(), (it->second / 1024));
		}
	}

	float persentage = alreadyLoadSize / downTotalSize;
	char perTxt[64];

	sprintf(perTxt, "(%dKB / %dKB)", (int)alreadyLoadSize, (int)downTotalSize);
	showPersent(persentage, perTxt);
	// 計算下載速度
	downloadSpeed = (alreadyLoadSize - preAlreadyDownloadSize) / dt;
	preAlreadyDownloadSize = alreadyLoadSize;
	if (downloadSpeed < 0.1f) {
		downloadStopTimer += dt;
		if (downloadStopTimer >= 30.0f) {
			std::ostringstream oss;
			oss << std::fixed << std::setprecision(2) << currentFileLoadSize;
			std::string size = oss.str();
			std::string eventInfo = "downloading file : " + currentLoadFile + ", downloaded size : " + size;
			if (loadFailData.size() > 0) {
				eventInfo = eventInfo + ", fail file : ";
				for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
					std::string assetUrl = serverVersionData->packageUrl + "/" + (*it)->name;
					if (loadFailData.find(assetUrl) != loadFailData.end()) {
						eventInfo = eventInfo + (*it)->name + ", ";
					}
				}
			}
			reportDownloadEvent("DownloadStop", eventInfo);
			downloadStopTimer = 0.0f;
		}
	}
	else {
		downloadStopTimer = 0.0f;
	}
}
void LoadingFrame::resetVersion()
{
	time_t t;
	time(&t);

	CCString* _time = CCString::createWithFormat("%d", t);
	std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();

	//下载最新的 peojectManifest 文件
    std::string saveProjrctPath = writeRootPath + versionPath + "/" + projectManifestName;
	std::string downloadProjectUrl = serverVersionData->packageUrl + "/" + projectManifestName;// + "?" + "time=" + _time->m_sString;
	CurlDownload::Get()->downloadFile(downloadProjectUrl, saveProjrctPath);

	//更新version文件操作 把之前的下载versionTmp.mainfest文件存到version.manifest文件里面 下次读取使用
	std::string versionPathTmp = writeRootPath + versionPath + "/" + versionManifestNameTmp;
	std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestName;
	unsigned long filesize;
	unsigned	char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(versionManifestNameTmp).c_str(), "rt", &filesize, 0, nullptr);
	saveFileInPath(saveVersionPath, "wb", pBuffer, filesize);

	SeverConsts::Get()->setServerVersion(serverVersionData->versionResource);

	remove(versionPathTmp.c_str());

}

void LoadingFrame::getLocalVersionCfg()
{
	unsigned char* content = readLocal(std::string(versionManifestName));
	unsigned char* contentApp = readLocal(std::string(versionAppManifestName));
	
	if (!content)
	{
		//本地读取出现错误 从UseDefault中取
		localVersionData->packageUrl = CCUserDefault::sharedUserDefault()->getStringForKey("packageUrl");
		localVersionData->remoteVersionUrl = CCUserDefault::sharedUserDefault()->getStringForKey("remoteVersionUrl");
		localVersionData->versionApp = CCUserDefault::sharedUserDefault()->getStringForKey("versionApp");
		localVersionData->AndroidStoreURL = CCUserDefault::sharedUserDefault()->getStringForKey("AndroidStoreURL");
		localVersionData->AppUpdateUrlH365 = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlH365");
		localVersionData->AppUpdateUrlR18 = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlR18");
		localVersionData->AppUpdateUrlKUSO = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlKUSO");
		localVersionData->AppUpdateUrlAPLUS_CPS1 = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlAPLUS_CPS1");
		localVersionData->AppUpdateUrlEROLABS = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlEROLABS");
		localVersionData->AppUpdateUrlOP = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlOP");
		localVersionData->AppUpdateUrlGP = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlGP");
		localVersionData->isLoadSuccess = true;

		//return;
	}
	getVersionData(localVersionData, content, true);
	getVersionAppData(localVersionData, contentApp, true);
	if (localVersionData && localVersionData->isLoadSuccess)
	{
		std::string ver = "Ver" + localVersionData->versionApp;
		setVersion(ver);
		SeverConsts::getInstance()->setVersion(localVersionData->versionApp);
		
	}
}

void LoadingFrame::sendGetServerCfg()
{
	if (!localVersionData)
	{
		return;
	}
	std::string serverFilr = SeverConsts::Get()->getSeverFile();
	std::string url = serverFilr;
	auto request = new CCHttpRequest();
	request->setUrl(url.c_str());
	request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
	request->setResponseCallback(this, callfuncND_selector(LoadingFrame::onHttpRequestCompleted));

	request->setTag("sendGetServerCfg");

	CCHttpClient::getInstance()->send(request);

	request->release();
}
void LoadingFrame::getServerCfg(unsigned char* content, bool isLocal)
{
	Json::Reader reader;
	Json::Value value;

	CCLOG("hotUpdate getVersionData: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (
		!ret ||
		value["severs"].empty() ||
		!value["severs"].isArray())
	{
		{
			return;
		}
	}

	std::map<int, Json::Value> serverNameMap;
	Json::Value severs = value["severs"];
	for (int i = 0; i<severs.size(); ++i)
	{
		if (!severs[i]["name"].empty() &&
			!severs[i]["nameTW"].empty() &&
			!severs[i]["address"].empty() &&
			!severs[i]["port"].empty() &&
			!severs[i]["id"].empty() &&
			!severs[i]["state"].empty())
		{
			SeverConsts::SEVER_ATTRIBUTE* severAtt = new SeverConsts::SEVER_ATTRIBUTE;
			severAtt->name = severs[i]["name"].asString();
			severAtt->nameTW = severs[i]["nameTW"].asString();
			severAtt->address = severs[i]["address"].asString();
			severAtt->port = severs[i]["port"].asInt();
			severAtt->id = severs[i]["id"].asInt();

			if (severs[i]["state"].asString() == "general")
				severAtt->state = SeverConsts::SS_GENERAL;
			else if (severs[i]["state"].asString() == "new")
				severAtt->state = SeverConsts::SS_NEW;
			else if (severs[i]["state"].asString() == "full")
				severAtt->state = SeverConsts::SS_FULL;
			else if (severs[i]["state"].asString() == "maintain")
				severAtt->state = SeverConsts::SS_MAINTAIN;

			if (severs[i]["order"].empty())
			{
				severAtt->order = severAtt->id;
			}
			else
			{
				severAtt->order = severs[i]["order"].asInt();
			}
			if (serverNameMap.find(severAtt->id) != serverNameMap.end())
			{
				Json::Value serverNameItem = serverNameMap[severAtt->id];
			}
		}
	}
}
void LoadingFrame::getVersionData(VersionData* versionData, unsigned char* content, bool isLocal)
{
	if (!content)
	{
		return;
	}

	Json::Reader reader;
	Json::Value value;

	CCLog("getVersionData: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (!ret)
	{
		CCLog("getVersionData: fail");

		if (isLocal)
		{
			//本地读取出现错误 从UseDefault中取
			versionData->packageUrl = CCUserDefault::sharedUserDefault()->getStringForKey("packageUrl");
			versionData->remoteVersionUrl = CCUserDefault::sharedUserDefault()->getStringForKey("remoteVersionUrl");
			versionData->versionApp = CCUserDefault::sharedUserDefault()->getStringForKey("versionApp");
			versionData->AndroidStoreURL = CCUserDefault::sharedUserDefault()->getStringForKey("AndroidStoreURL");
			versionData->AppUpdateUrlH365 = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlH365");
			versionData->AppUpdateUrlR18 = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlR18");
			versionData->AppUpdateUrlKUSO = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlKUSO");
			versionData->AppUpdateUrlAPLUS_CPS1 = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlAPLUS_CPS1");
			versionData->AppUpdateUrlEROLABS = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlEROLABS");
			versionData->AppUpdateUrlOP = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlOP");
			versionData->AppUpdateUrlGP = CCUserDefault::sharedUserDefault()->getStringForKey("AppUpdateUrlGP");
			versionData->isLoadSuccess = true;
		}
		return;
	}

	versionData->packageUrl = value["packageUrl"].asString();
	versionData->versionApp = value["versionApp"].asString();
	versionData->remoteVersionUrl = value["remoteVersionUrl"].asString();
	versionData->IOSAppStoreURL = value["IOSAppStoreURL"].asString();
	versionData->AndroidStoreURL = value["AndroidStoreURL"].asString();
	versionData->AppUpdateUrlH365 = value["AppUpdateUrlH365"].asString();
	versionData->AppUpdateUrlR18 = value["AppUpdateUrlR18"].asString();
	versionData->AppUpdateUrlKUSO = value["AppUpdateUrlKUSO"].asString();
	versionData->AppUpdateUrlJSG = value["AppUpdateUrlJSG"].asString();
	versionData->AppUpdateUrlAPLUS_CPS1 = value["AppUpdateUrlAPLUS_CPS1"].asString();
	versionData->AppUpdateUrlEROLABS = value["AppUpdateUrlEROLABS"].asString();
	versionData->AppUpdateUrlOP = value["AppUpdateUrlOP"].asString();
	versionData->AppUpdateUrlGP = value["AppUpdateUrlGP"].asString();
	versionData->versionResource = value["versionResource"].asString();
	versionData->isNeedGoAppStore = value["isNeedGoAppStore"].asInt();
	versionData->isLoadSuccess = true;

	if (isLocal)
	{
		//是读取的本地 存储上一次的version配置文件
		CCUserDefault::sharedUserDefault()->setStringForKey("packageUrl", versionData->packageUrl);
		CCUserDefault::sharedUserDefault()->setStringForKey("remoteVersionUrl", versionData->remoteVersionUrl);
		CCUserDefault::sharedUserDefault()->setStringForKey("versionApp", versionData->versionApp);
		CCUserDefault::sharedUserDefault()->setStringForKey("AndroidStoreURL", versionData->AndroidStoreURL);
		CCUserDefault::sharedUserDefault()->setStringForKey("AppUpdateUrlH365", versionData->AppUpdateUrlH365);
		CCUserDefault::sharedUserDefault()->setStringForKey("AppUpdateUrlR18", versionData->AppUpdateUrlR18);
		CCUserDefault::sharedUserDefault()->setStringForKey("AppUpdateUrlKUSO", versionData->AppUpdateUrlKUSO);
		CCUserDefault::sharedUserDefault()->setStringForKey("AppUpdateUrlAPLUS_CPS1", versionData->AppUpdateUrlAPLUS_CPS1);
		CCUserDefault::sharedUserDefault()->setStringForKey("AppUpdateUrlEROLABS", versionData->AppUpdateUrlEROLABS);
		CCUserDefault::sharedUserDefault()->setStringForKey("AppUpdateUrlOP", versionData->AppUpdateUrlOP);
		CCUserDefault::sharedUserDefault()->setStringForKey("AppUpdateUrlGP", versionData->AppUpdateUrlGP);
	}
}

void LoadingFrame::getVersionAppData(VersionData* versionData, unsigned char* content, bool isLocal)
{
	if (!content)
	{
		return;
	}

	Json::Reader reader;
	Json::Value value;

	CCLog("hotUpdate getVersionData: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (!ret)
	{
		CCLog("hotUpdate getVersionData: fail");

		if (isLocal)
		{
			//本地读取出现错误 从UseDefault中取
			versionData->versionApp = CCUserDefault::sharedUserDefault()->getStringForKey("versionApp");
			versionData->isLoadSuccess = true;
		}
		return;
	}

	versionData->versionApp = value["versionApp"].asString();
	versionData->isLoadSuccess = true;

	if (isLocal)
	{
		//是读取的本地 存储上一次的version配置文件
		CCUserDefault::sharedUserDefault()->setStringForKey("versionApp", versionData->versionApp);
	}
}

unsigned char* LoadingFrame::readLocal(std::string fileName)
{
	unsigned long filesize;
	unsigned char* content = CCFileUtils::sharedFileUtils()->getFileData(fileName.c_str(), "r", &filesize);
	CCLog("hotUpdate : readLocal content:%s , fileName is %s", content, fileName.c_str());
	return content;
}
void LoadingFrame::setVersion(std::string meg)
{
	CCLabelTTF* versionLabel = dynamic_cast<CCLabelTTF*>(getVariable("mVer"));//mLoading1
	if (versionLabel)
	{
		versionLabel->setString(meg.c_str());
	}
}

void LoadingFrame::showFailedMessage(std::string msg , int tag )
{
	if (libOS::getInstance()->getNetWork() == NotReachable)
	{
		CCLog("hotUpdate : showFailedMessage ----step1,tag is %d---",tag);
		libOS::getInstance()->showMessagebox(m_updateVersionTips->notNetworkTxT,tag);
	}
	else
	{
		CCLog("hotUpdate : showFailedMessage ----step2,tag is %d---", tag);
		libOS::getInstance()->showMessagebox(msg,tag);
	}
}

std::vector<std::string> LoadingFrame::splitVersion(std::string content, std::string seperator)
{
	std::vector<std::string> result;

	string::size_type cutAt;
	while ((cutAt = content.find_first_of(seperator)) != content.npos)
	{
		if (cutAt > 0)
		{
			result.push_back(content.substr(0, cutAt));
		}

		content = content.substr(cutAt + 1);
	}

	if (content.length() > 0)
	{
		result.push_back(content);
	}

	return result;
}

void LoadingFrame::transform()
{
	// tapdb 
	Json::Value data;
	data["funtion"] = "setUser";
	data["param"] = "abcdefghijklnmopqrstuvwxyz123456789";
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_TAPDB_HANDLER", data.toStyledString());

	// h365 login , hyena login
	Json::Value data2;
	data2["eventId"] = 2;
	data2["userId"] = "abcdefghijklnmopqrstuvwxyz123456789";
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_REPORT_HANDLER", data2.toStyledString());
}

CompareStat LoadingFrame::compareVersion(std::string localVersion, std::string serverVersion)
{
	CompareStat stat = EQUAL;

	std::vector<std::string> localVector = splitVersion(localVersion, ".");
	CCLog("localVersion : %s", localVersion.c_str());
	std::vector<std::string> serverVector = splitVersion(serverVersion, ".");
	CCLog("serverVersion : %s", serverVersion.c_str());
	for (size_t i = 0; i < 3; ++i) {	// 只檢查前3碼
		std::string serverValue = serverVector[i];
		CCLog("serverValue%d : %s", i, serverValue.c_str());
		if (i >= localVector.size())	// 本地版本號不到3碼
		{
			stat = LESS;
			break;
		}

		std::string localValue = localVector[i];
		CCLog("localValue%d : %s", i, localValue.c_str());
		int server = std::atoi(serverValue.c_str());
		int local = std::atoi(localValue.c_str());
		if (server > local)
		{
			stat = LESS;
			break;
		}
		if (local > server)
		{
			stat = HIGH;
			break;
		}
	}

	return stat;
}
void LoadingFrame::compareVersion()
{
	cocos2d::CCLog("compareVersion()");
	if (m_updateVersionTips)
	{
		setTips(m_updateVersionTips->checkVersionTxT);
	}

	if (!serverVersionData || !serverVersionData->isLoadSuccess)
	{ 
		hidLoadingAniPage();
		showFailedMessage(m_updateVersionTips->checkFailTxT, 100);
		setTips(m_updateVersionTips->checkFailTxT);
		return;
	}

	if (!localVersionData || !localVersionData->isLoadSuccess)
	{
		GamePrecedure::Get()->enterLoading();
		return;
	}

	versionAppCompareStat = compareVersion(localVersionData->versionApp, serverVersionData->versionApp);

	/*
	local compare server

	versionApp  |    resourceUpdate      AppStore update
	HIGH        |       NO                   NO
	            |
	EQUAL       |      YES                   NO
	            |
	LESS        |       NO                  YES
	*/

	int result = 0; // result = 0  not update, result = 1 resourse update, result = 2 appStore update 

	if (versionAppCompareStat == LESS) {
		result = 2;
	}
	else if (versionAppCompareStat == HIGH) {
		//result = 0;
		result = 1;
	}
	else {
		result = 1;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	//WINDOWS不檢查APP版本
	versionAppCompareStat = HIGH;
	result = 0;
#endif
	//result = 1;
	cocos2d::CCLog("compareVersion result is %d", result);
	ostringstream   ostr;
	ostr << "result is : " << result;
	string strLog = ostr.str();

	if (result == 0)
	{
		resetVersion();
		if (SeverConsts::Get()->getIsRedownLoadServer())
		{
			SeverConsts::Get()->setIsRedownLoadServer(false);
			onMenuItemAction("onEnter", NULL);
		}
		else
		{
			GamePrecedure::Get()->loadPlsit();
			LoginSuccess();
		}
		
		return;
	}

	if (result == 1)
	{
	    checkNewAssets();
		return;
	}
	//本地App版本低
	if (result == 2) //跳转商店开关是开着的 弹提示跳转商店
	{
		if (serverVersionData->isNeedGoAppStore == 1)
		{
			versionStat = UPDATE_APP_STORE;
			if (m_updateVersionTips)
			{
				setTips(m_updateVersionTips->appStoreUpdateTxT);
			}
			libOS::getInstance()->showMessagebox(m_updateVersionTips->appStoreUpdateTxT, 100);
			loginReport(REPORT_STEP::REPORT_STEP_START_DOWNLOAD_APK);
		}
		else //跳转商店开关是关着的
		{
			checkNewAssets();
		}
	}
}

void LoadingFrame::appStoreUpdate()
{
	if (!serverVersionData || !serverVersionData->isLoadSuccess)
	{
		return;
	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	if (SeverConsts::Get()->IsH365()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlH365);
	}
	else if (SeverConsts::Get()->IsEroR18()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlR18);
	}
	else if (SeverConsts::Get()->IsErolabs()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlEROLABS);
	}
	else if (SeverConsts::Get()->IsKUSO()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlKUSO);
	}
	else if (SeverConsts::Get()->IsJSG()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlJSG);
	}
	else if (SeverConsts::Get()->IsAPLUS()) {
		std::string cps = libPlatformManager::getPlatform()->getClientCps();
		if (cps == "#1") {
			libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlAPLUS_CPS1);
		}
		else {
			libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlAPLUS_CPS1);
		}
	}
	else if (SeverConsts::Get()->IsOP()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlOP);
	}
	else if (SeverConsts::Get()->IsGP()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlGP);
	}
	else {
		libOS::getInstance()->openURL(serverVersionData->AndroidStoreURL);
	}
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	if (SeverConsts::Get()->IsErolabs()) {	// 跟android用同一個連結
		libPlatformManager::getInstance()->getPlatform()->updateApp(serverVersionData->AppUpdateUrlEROLABS);
	}
	else {
		libPlatformManager::getInstance()->getPlatform()->updateApp(serverVersionData->IOSAppStoreURL); 
	}
	//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id1276526048?mt=8
#endif
}

void LoadingFrame::getLocalProjectAssets()
{
	unsigned char* content = readLocal(projectManifestName);
	unsigned char* contentLocal = readLocal(projectManifestLocalName);
	if (!content && !contentLocal)
	{
		assetData* data = new assetData();
		data->name = "hotUpdate.zip";
		data->md5 = "123456789";
		data->crc = "123456789";
		data->size = 38348;
		data->time = 0.0f;
		localProjectAssetData->isLoadSuccess = true;
		localProjectAssetData->time = 0.0f;
		localProjectAssetData->addAssetData(data);
		return;
	}
	if (!content){
		getProjectAssetData(localProjectAssetData, contentLocal, true);
	}
	else if (!contentLocal){
		getProjectAssetData(localProjectAssetData, content, true);
	}
	else{
		getProjectAssetData(localProjectAssetData, content, true, contentLocal);
	}
}

void LoadingFrame::downloaded(const std::string &url, const std::string& filename)
{
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.compare((*it)->url) == 0)
		{
			currentFileLoadSize = 0.0f;
			fileLoadSizeMap[url] = 0.0f;
			alreadyDownloadData.push_back(url);
			// 下載完先解壓縮
			CCLog("--->hotUpdate downloaded save path: %s storage: %s ext path %s", (*it)->savePath.c_str(), (*it)->stroge.c_str(), filename.c_str());
			bool value = AssetsManagerEx::getInstance()->uncompress( (*it)->savePath.c_str(), (*it)->stroge);
			//CCLog("downloaded uncompress: %s", ((*it)->name).c_str());
			// delete file
			remove((*it)->savePath.c_str());
			// 解壓縮後更新projectManifest 避免重新下載
			assetData* data = new assetData();
			data->name = (*it)->name;
			data->md5 = (*it)->md5;
			data->crc = (*it)->crc.c_str();
			data->size = (*it)->size;
			data->time = (*it)->time;
			localProjectAssetData->assetDataMap.insert(std::make_pair((*it)->name, data));
			auto localIt = localProjectAssetData->assetDataMap.find((*it)->name);
			localIt->second->size = (*it)->size;
			localIt->second->crc = (*it)->crc;
			localIt->second->md5 = (*it)->md5;
			localIt->second->time = (*it)->time;
			writeProjectManifest();
		}
	}

	if (url.find(versionManifestName) != url.npos)
	{
		downVersionTimes = 0; 
		//读取检测版本 下载下来的 versionTmp.manifest文件  跟本地的 version.mainfest 作比较
		if (versionStat  == CHECK_VERSION)
		{
			unsigned long filesize;
			unsigned	char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(filename.c_str()).c_str(), "rt", &filesize, false, 0);
			getVersionData(serverVersionData, pBuffer);
			cocos2d::CCLog("LoadingFrame::compareVersion");
			compareVersion();
			transform();
		}
	}
	if (url.find(projectManifestName) != url.npos)
	{
		downProjectTimes = 0;
	}
	// 下載檔案訊息上報
	downloadReport(url, -1, 0);
}
void LoadingFrame::downloadFailed(const std::string& url, const std::string &filename, int errorType)
{
	int failedTime = (MaxResumeTime - ResumeCount) + 1;
	CCLog("--->hotUpdate downloadFailed  url: %s    : filename : %s error: %d", url.c_str(), filename.c_str(), errorType);
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.compare((*it)->url) == 0)
		{
			CCLog("hotUpdate downloadFailed  url push_back to loadFailData: %s    : filename : %s ", url.c_str(), filename.c_str());
			loadFailData.insert(url);
		}
	}

	if (url.find(versionManifestName) != url.npos)
	{
		if (downVersionTimes < 10)//下载失败接着下载10次
		{
			downVersionTimes++;

			time_t t;
			time(&t);

			CCString* _time = CCString::createWithFormat("%d", t);
			std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
			std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestNameTmp;
			std::string downloadVerUrl = localVersionData->remoteVersionUrl + "/" + versionManifestName;// + "?" + "time=" + _time->m_sString;
			CurlDownload::Get()->downloadFile(downloadVerUrl, saveVersionPath);
		}
		else
		{
			hidLoadingAniPage();
			setTips(m_updateVersionTips->checkFailTxT);
			showFailedMessage(m_updateVersionTips->checkFailTxT,100);

		}
		failedTime = downVersionTimes;
	}
	if (url.find(projectManifestName) != url.npos)
	{
		if (downProjectTimes < 10)//下载失败之后 允许再尝试10次
		{
			time_t t;
			time(&t);
			CCString* _time = CCString::createWithFormat("%d", t);

			downProjectTimes++;

			std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
			//下载最新的 peojectManifest 文件
			std::string saveProjrctPath = writeRootPath + versionPath + "/" + projectManifestName;
			std::string downloadProjectUrl = serverVersionData->packageUrl + "/" + projectManifestName;// + "?" + "time=" + _time->m_sString;
			CurlDownload::Get()->downloadFile(downloadProjectUrl, saveProjrctPath);
		}
		else
		{
			hidLoadingAniPage();
			setTips(m_updateVersionTips->checkProjectFailTxT);
			showFailedMessage(m_updateVersionTips->checkProjectFailTxT, 100);
		}
		failedTime = downProjectTimes;
	}
	// 下載檔案訊息上報
	downloadReport(url, errorType, failedTime);
}

void LoadingFrame::onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& filename)
{
	
	currentFileLoadSize = float(size);
	fileLoadSizeMap[url] = float(size);
	cocos2d::CCLog("--->hotUpdate : onAlreadyDownSize downloading : %f url: %s", currentFileLoadSize / 1024, url.c_str());
	std::string buildType = libPlatformManager::getPlatform()->getBuildType();
	if (buildType == "qa") {
		if (url.find(projectManifestName) == url.npos && url.find(versionManifestName) == url.npos) {
			char tipTxt[500];
			std::string result = split(filename, '/');
			sprintf(tipTxt, "downloading : %s (%.2f MB/s)",
				result.c_str(), (downloadSpeed * 1.0f) / (1024));
			setTips(tipTxt);
		}
	}
}
void LoadingFrame::showPersent(float persentage, std::string sizeTip)
{
	
	CCSprite * _spriteBg = getCCSpriteFromCCB("mBarBg");
	if (!_spriteBg->getChildByTag(1001))
	{
		CCSprite * _sprite = CCSprite::create("LoadingUI_JP/loadingUI_Bar.png");
		_ProgressTimerNode = CCProgressTimer::create(_sprite);
		_ProgressTimerNode->setType(kCCProgressTimerTypeBar);
		_ProgressTimerNode->setMidpoint(CCPointMake(0, 0));
		_ProgressTimerNode->setBarChangeRate(CCPointMake(1, 0));
		_ProgressTimerNode->setAnchorPoint(ccp(0, 0));
		_ProgressTimerNode->setTag(1001);
		_spriteBg->addChild(_ProgressTimerNode);
	}
	if (_spriteBg->getChildByTag(1001) && getVariable("mPersentageTxt"))
	{
		if (persentage > 1.0f)
			persentage = 1.0f;
		if (persentage <= 0.00f)
			persentage = 0.00f;
		if (persentage - lastPercent >= 0.02) {
			//return;
		}
		if (persentage >= lastPercent)
		{
			_ProgressTimerNode->setPercentage(persentage * 100);
			CCLabelTTF* sever = dynamic_cast<CCLabelTTF*>(getVariable("mPersentageTxt"));
			char perTxt[64];
			if (persentage >= 1.0f) {
				sprintf(perTxt, "100%   %s", sizeTip.c_str());
				sever->setString(sizeTip.c_str());
			}
			else {
				sprintf(perTxt, "%d%%   %s", (int)(persentage * 100), sizeTip.c_str());
				if (sever)
					sever->setString(perTxt);
			}
			

			lastPercent = persentage;

			CCNode * light = dynamic_cast<CCNode*>(getVariable("mNowPercent"));
			CCSize szie = _spriteBg->getContentSize();
			light->setPositionX(-254 + szie.width * persentage);
		}
	}
	
}
void LoadingFrame::onHttpRequestCompleted(cocos2d::CCNode *sender, void*data)
{
	cocos2d::CCLog("hotUpdate : onHttpRequestCompleted");

	CCHttpResponse* response = (CCHttpResponse*)data;
	if (!response->isSucceed())
	{
		downVersionTimes++;
		if (strcmp(response->getHttpRequest()->getTag(),"serverVersionCfg") == 0 && downVersionTimes < 10)
		{
			getServerVersionCfg();
		}
		else if (strcmp(response->getHttpRequest()->getTag(), "serverProjectAsset") == 0 && downVersionTimes < 10)
		{
			getServerProjectAssets();
		}
		cocos2d::CCLog("hotUpdate: onHttpRequestCompleted fail : %s", response->getHttpRequest()->getTag());
		const char* serverVersionTag = "serverVersionCfg";
		const char* serverProjectAssetTag = "serverProjectAsset";
		if (strcmp(response->getHttpRequest()->getTag(), serverVersionTag) == 0)
		{
			// 下載檔案訊息上報
			downloadReport(localVersionData->remoteVersionUrl + "/" + versionManifestName, 2, 0);
		}
		else if (strcmp(response->getHttpRequest()->getTag(), serverProjectAssetTag) == 0)
		{
			// 下載檔案訊息上報
			downloadReport(serverVersionData->packageUrl + "/" + projectManifestName, 2, 0);
		}
		return;
	}

	int codeIndex = response->getResponseCode();
	if (codeIndex < 0)
	{
		cocos2d::CCLog("hotUpdate : codeIndex: %d", codeIndex);
		ostringstream   ostr;
		ostr << "hotUpdate : codeIndex: " << codeIndex;
		string strLog = ostr.str();
	
		
	}
	downVersionTimes = 0;
	downProjectTimes = 0;
	downServerCfgTimes = 0;
	const char* tag = response->getHttpRequest()->getTag();

	std::vector<char>* buffer = response->getResponseData();
	std::string temp(buffer->begin(), buffer->end());
	CCString* responseData = CCString::create(temp);
	const char* content = responseData->getCString();

	const char* serverVersionTag = "serverVersionCfg";
	const char* serverProjectAssetTag = "serverProjectAsset";
	const char* serverCfgTag = "sendGetServerCfg";
	unsigned char *unsignedContent = (unsigned  char *)(content);
	if (strcmp(tag, serverVersionTag) == 0)
	{
		cocos2d::CCLog("hotUpdate : compareVersion");
		getVersionData(serverVersionData, unsignedContent);
		compareVersion();
		// 下載檔案訊息上報
		downloadReport(localVersionData->remoteVersionUrl + "/" + versionManifestName, -1, 0);
	}
	else if (strcmp(tag, serverProjectAssetTag) == 0)
	{
		cocos2d::CCLog("hotUpdate : compareProjectAsset");
		getProjectAssetData(serverProjectAssetData, unsignedContent);
		compareProjectAsset();
		// 下載檔案訊息上報
		downloadReport(serverVersionData->packageUrl + "/" + projectManifestName, -1, 0);
	}
}
void LoadingFrame::onServerStateRequestCompleted(cocos2d::CCNode *sender, void *data)
{
	cocos2d::CCLog("LoadingFrame : onServerStateRequestCompleted");

	CCHttpResponse *response = (CCHttpResponse*)data;
	if (!response->isSucceed()) {
		// 檢查失敗就放玩家過去
		checkVersion();
		return;
	}

	std::vector<char>* buffer = response->getResponseData();
	std::string temp(buffer->begin(), buffer->end());
	CCString* responseData = CCString::create(temp);
	const char* content = responseData->getCString();

	Json::Reader reader;
	Json::Value value;

	bool ret = reader.parse(content, value);
	if (ret) {
		Json::Value state = value["maintain"];
		std::string maintainState = state.asString();
		if (maintainState == "2") {	// 維護中
			libOS::getInstance()->showMessagebox(Language::Get()->getString("@ERRORCODE_9"), 999);
		}
		else {
			checkVersion();
		}
	}
	else {
		checkVersion();
	}
}
void LoadingFrame::getServerProjectAssets()
{
	if (!serverVersionData)
	{
		return;
	}
	time_t t;
	time(&t);

	CCString* _time = CCString::createWithFormat("%d", t);
	std::string url = serverVersionData->packageUrl + "/" + projectManifestName;// + "?" + "time=" + _time->m_sString;
	auto request = new CCHttpRequest();
	request->setUrl(url.c_str());
	request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
	request->setResponseCallback(this, callfuncND_selector(LoadingFrame::onHttpRequestCompleted));

	request->setTag("serverProjectAsset");

	CCHttpClient::getInstance()->send(request);

	request->release();
}
void LoadingFrame::compareProjectAsset()
{
	cocos2d::CCLog("compareProjectAsset 1");
	if (!localProjectAssetData || !localProjectAssetData->isLoadSuccess || !serverProjectAssetData || !serverProjectAssetData->isLoadSuccess)
	{
		if (m_updateVersionTips)
		{
			setTips(m_updateVersionTips->noAssetNeedUpdateTxT);
		}
		GamePrecedure::Get()->enterLoading();
		return;
	}
	cocos2d::CCLog("compareProjectAsset 2");
	needUpdateAsset.clear();
	int downSize = 0;
	for (std::map<std::string, assetData *>::const_iterator it = serverProjectAssetData->assetDataMap.begin(); it != serverProjectAssetData->assetDataMap.end(); ++it) {
		std::string name = it->first;
		assetData* data = it->second;

		auto localIt = localProjectAssetData->assetDataMap.find(name);

		if (localIt == localProjectAssetData->assetDataMap.end())
		{
			needUpdateAsset.push_back(data);
			downSize += data->size;
			continue;
		}

		if (localIt->second->time > it->second->time) {
			continue;
		}

		if (localIt->second->md5 != it->second->md5)
		{
			needUpdateAsset.push_back(data);
			downSize += data->size;
			continue;
		}
	}
	versionStat = CHECK_PROJECT_ASSETS_DONE;

	if (needUpdateAsset.size() <= 0)
	{
		if (m_updateVersionTips)
		{
			setTips(m_updateVersionTips->noAssetNeedUpdateTxT);
		}
		//MD5值一样 把新的版本号存下来 不更新资源
		std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
		std::string versionPathTmp = writeRootPath + versionPath + "/" + versionManifestNameTmp;
		std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestName;
		unsigned long filesize;
		unsigned	char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(versionManifestNameTmp).c_str(), "rt", &filesize, 0, nullptr);

		saveFileInPath(saveVersionPath, "wb", pBuffer, filesize);

		if (localVersionData)
		{
			std::string ver = "Ver" + localVersionData->versionApp;
			setVersion(ver);
		}
		resetVersion();
		//remove(versionPathTmp.c_str());

		if (SeverConsts::Get()->getIsRedownLoadServer())
		{
			SeverConsts::Get()->setIsRedownLoadServer(false);
			onMenuItemAction("onEnter", NULL);
		}
		else
		{
			GamePrecedure::Get()->loadPlsit();
			CCLog("compareProjectAsset LoginSuccess");
			LoginSuccess();
		}
		return;
	}

	cocos2d::CCLog("compareProjectAsset 3");
	ostringstream   ostr;
	ostr << "compareProjectAsset need update fileSzie: " << needUpdateAsset.size();
	string strLog = ostr.str();
	
	if (m_updateVersionTips)
	{
		cocos2d::CCLog("compareProjectAsset 4");
		downSize /= 1024;
		downSize = (downSize > 1) ? downSize : 1;
		const char* size = CCString::createWithFormat("%d", downSize)->getCString();

		std::string needUpdateAsset = m_updateVersionTips->newAssetNeedUpdateTxT + std::string(size) + "M";
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
		needUpdateAsset = needUpdateAsset + "\n" + m_updateVersionTips->bgDownloadTip;
#endif
		//setTips(needUpdateAsset);
		libOS::getInstance()->showMessagebox(needUpdateAsset, 100);
		loginReport(REPORT_STEP::REPORT_STEP_START_DOWNLOAD_PATCH);

		downloadSize = downSize;
	}
}
void LoadingFrame::getProjectAssetData(ProjectAssetData* projectAssetData, unsigned char* content, bool isLocal, unsigned char* contentLocal)
{
	Json::Reader reader;
	Json::Value value;
	Json::Reader readerLocal;
	Json::Value valueLocal;

	CCLog("hotUpdate getProjectAssetData: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (!ret)
	{
		if (isLocal)
		{
			assetData* data = new assetData();
			data->name = "hotUpdate.zip";
			data->md5 = "123456789";
			data->crc = "45866";
			data->size = 38348;
			projectAssetData->isLoadSuccess = true;
			projectAssetData->addAssetData(data);
			projectAssetData->time = 0.0f;
		
		}
		CCLog("hotUpdate getProjectAssetData: fail");
		return;
	}
	if (contentLocal){
		CCLog("hotUpdate getProjectAssetDataLocal: %s", contentLocal);

		const char* constContentLocal = (const char*)(char*)contentLocal;

		bool retLocal = reader.parse(constContentLocal, valueLocal);

		if (!retLocal)
		{
			CCLog("hotUpdate getProjectAssetDataLocal: fail");
			return;
		}
	}

	projectAssetData->isLoadSuccess = true;
	Json::Value valueTrue;
	if (contentLocal){
		Json::Value timeJson = value["time"];
		Json::Value timeJsonLocal = valueLocal["time"];
		int time = (int)timeJson.asDouble();
		int timeLocal = (int)timeJsonLocal.asDouble();
		// 只比到整數避免誤差
		if (time >= timeLocal){
			valueTrue = value;
		}
		else{
			valueTrue = valueLocal;
			//std::string hotUpdatePath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath() + downLoadSavePath + "/";
			//cocos2d::CCFileUtils::sharedFileUtils()->removeDirectory(hotUpdatePath);
		}
	}
	else{
		valueTrue = value;
	}
	
	Json::Value files = valueTrue["assets"];
	if (!files.empty() && files.isArray())
	{
		for (int i = 0; i < files.size(); ++i)
		{
			Json::Value unit = files[i];
			if (unit["name"].empty())
			{
				continue;
			}

			assetData* data = new assetData();
			data->name = unit["name"].asString();
			data->md5 = unit["md5"].asString();
			data->crc = unit["crc"].asString();
			data->size = unit["size"].asDouble();
			data->time = unit["time"].asDouble();
			projectAssetData->addAssetData(data);
		}
	}
	projectAssetData->time = valueTrue["time"].asDouble();
}
void LoadingFrame::checkNewAssets()
{
	versionStat = CHECK_PROJECT_ASSETS;
	localProjectAssetData = new ProjectAssetData();
	getLocalProjectAssets();

	serverProjectAssetData = new ProjectAssetData();
	getServerProjectAssets();
}
void LoadingFrame::UpdateAssetFromServer()
{
	CCLog("hotUpdate : UpdateAssetFromServer");

	ostringstream   ostr;
	ostr << "UpdateAssetFromServer : " << needUpdateAsset.size();
	string strLog = ostr.str();

	CCB_FUNC(this, "mUpdateBtnNode", cocos2d::CCNode, setVisible(false));

	if (m_updateVersionTips)
	{
		setTips(m_updateVersionTips->startUpdateTxT);
	}

	versionStat = LOADING_ASSETS;

	downTotalSize = 0;
	currentFileLoadSize = 0;
	alreadyDownloadData.clear();
	loadFailData.clear();
	lastPercent = 0.0f;
	fileLoadSizeMap.clear();

	//进度条
	setWaitGameNodeVisible(true);
	setEnterServerListVisible(false);
	setEnterGameNodeVisible(false);
	setEnterBCNodeVisible(false);
	setLogoutBtnVisible(false);
	setLogoutNodeVisible(false);

	showPersent(0, std::string(""));
	CCB_FUNC(this, "mPersentageNode", cocos2d::CCNode, setVisible(true));

	time_t t;
	time(&t);
	CCString* _time = CCString::createWithFormat("%d", t);
	downloadStartTime = t;

	std::string packageUrl = serverVersionData->packageUrl;
	std::string writeablePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		std::string assetUrl = packageUrl + "/" + (*it)->name;// + "?" + "time=" + _time->m_sString;
		CCLog("UpdateAssetFromServer url : %s", assetUrl.c_str());
		std::string writePath = writeablePath + downLoadSavePath + "/" + (*it)->name;

		(*it)->url = assetUrl;
		(*it)->savePath = writePath;
		(*it)->stroge = writeablePath + downLoadSavePath + "/";
		downTotalSize += (*it)->size;
		std::string crc = (*it)->crc;
		std::string md5 = (*it)->md5;
		std::string filename = (*it)->name;
		std::string path = downLoadSavePath;
		unsigned short crcCmp = atoi((char*)crc.c_str());
		
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
		// Call java to download file so it can run while app is paused
		callDownloadJNI(assetUrl, filename, path, md5);
		//CurlDownload::Get()->downloadFile(assetUrl, writePath, md5);
#else 
		CurlDownload::Get()->downloadFile(assetUrl, writePath, md5);
#endif
	}
}

void LoadingFrame::ResumeUpdateAsset()
{
	CCLog("hotUpdate : ResumeUpdateAsset");

	versionStat = LOADING_ASSETS;

	std::string packageUrl = serverVersionData->packageUrl;
	std::string writeablePath = CCFileUtils::sharedFileUtils()->getWritablePath();

	time_t t;
	time(&t);
	CCString* _time = CCString::createWithFormat("%d", t);
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		std::string timeStr = "?time=" + _time->m_sString;
		std::string assetUrl = packageUrl + "/" + (*it)->name;
		if (loadFailData.find(assetUrl) != loadFailData.end())
		{
			std::string writePath = writeablePath + downLoadSavePath + "/" + (*it)->name;

			(*it)->url = assetUrl + timeStr;
			(*it)->savePath = writePath;
			(*it)->stroge = writeablePath + downLoadSavePath + "/";
			CCLog("ResumeUpdateAsset loadFailData : %s", (*it)->url.c_str());
			//downTotalSize += (*it)->size;
			std::string md5 = (*it)->md5;
			std::string filename = (*it)->name;
			std::string path = downLoadSavePath;
			//unsigned short md5Cmp = atoi((char*)md5.c_str());
			
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
			// Call java to download file so it can run while app is paused
			callDownloadJNI((*it)->url, filename, path, md5);
			//CurlDownload::Get()->downloadFile((*it)->url, writePath, md5);
#else 
			CurlDownload::Get()->downloadFile((*it)->url, writePath, md5);
#endif
		}
	}

	loadFailData.clear();
	ResumeCount--;
}

void LoadingFrame::ontestLogin()
{
	setEnterServerListVisible(true); // display ServerName
	std::string uin = "";
	std::string pass = "";

	std::string uinkey = "LastLoginPUID";
	uin = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");

	std::string passkey = "PassKey";
	pass = CCUserDefault::sharedUserDefault()->getStringForKey(passkey.c_str(), "");

	libPlatformManager::getPlatform()->setLoginName(uin);
	GamePrecedure::getInstance()->setDefaultPwd(pass);
	showLoginUser(uin, pass);
}

void LoadingFrame::sendGuestLogin()
{
	std::string uin = "";
	std::string pass = "";
	bool isRegisted = false;

	std::string uinkey = "LoginGuestID";
	uin = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");
	
	if (uin.find("guest_") == std::string::npos) //not find
	{
		isRegisted = true;
		time_t t = time(0);
		uin = CCString::createWithFormat("guest_%d",t)->m_sString;
	}

	std::string passkey = "PassKey";
	pass = CCUserDefault::sharedUserDefault()->getStringForKey(passkey.c_str(), "888888");

	libPlatformManager::getPlatform()->setLoginName(uin);
	GamePrecedure::getInstance()->setDefaultPwd(pass);
	GamePrecedure::getInstance()->setWallet("");
	libPlatformManager::getPlatform()->setIsGuest(1);

	onEnterGame(isRegisted);

}
/*
工口登出確認介面
*/
void LoadingFrame::showLogoutConfirm() {
	BasePage* page = CCBManager::Get()->getPage("ConfirmPage");
	if (page)
	{
		if (page->getParent())
			page->setParent(nullptr);
		page->load();
		
		//屏蔽下层触摸
		cocos2d::CCLayer* layer = CCLayer::create();
		layer->setContentSize(CCDirector::sharedDirector()->getOpenGLView()->getVisibleSize());
		layer->setPosition(0, 0);
		layer->setAnchorPoint(ccp(0, 0));
		layer->setTouchEnabled(true);
		layer->setTouchMode(cocos2d::kCCTouchesOneByOne);
		page->addChild(layer, -1);


		CCNode* uiNode = dynamic_cast<CCNode*>(getVariable("mUINode"));
		uiNode->addChild(page);
		page->setPosition(ccp(0, 0));

		ConfirmPage* mConfirmPage = dynamic_cast<ConfirmPage*>(page);
		if (mConfirmPage)
		{
			std::string title = Language::Get()->getString("@SDK7");
			std::string message = Language::Get()->getString("@SDK8");
			mConfirmPage->showPage(message, title, logoutAccount);
		}
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
		if (sta)
		{
			sta->Enter(NULL);
		}
	}
}

void logoutAccount(bool boo)
{
	if (boo) {
		libPlatformManager::getPlatform()->logout();
	}
}

void LoadingFrame::writeProjectManifest()
{
	std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
	std::string path = writeRootPath + versionPath + "/" + projectManifestName;
	std::ofstream fout;
	fout.open(path.c_str());
	assert(fout.is_open());
	//
	Json::Value root;
	Json::Value assets;
	for (auto it = localProjectAssetData->assetDataMap.begin(); it != localProjectAssetData->assetDataMap.end(); ++it) {
		Json::Value data;
		data["crc"] = it->second->crc;
		data["md5"] = it->second->md5;
		data["name"] = it->second->name;
		data["size"] = it->second->size;
		data["time"] = it->second->time;
		assets.append(data);
	}
	root["assets"] = assets;
	root["time"] = serverProjectAssetData->time;
	//
	std::string out = root.toStyledString();
	std::cout << out << std::endl;
	fout << out << std::endl;
	fout.close();
}

std::string LoadingFrame::split(const std::string& str, char delimiter) {
	std::vector<std::string> tokens;
	std::stringstream ss(str);
	std::string item;
	std::string fileName = "";

	while (std::getline(ss, item, delimiter)) {
		fileName = item;
	}
	return fileName;
}

// PlatformListener callbacks implementation 
// Called by java DownloadManager
void LoadingFrame::OnDownloadProgress(const std::string& url, const std::string& filename, const std::string& basePath, long progress)
{
	//CCLog("--->OnDownloadProgress");
	onAlreadyDownSize(progress, url, filename);
};

void LoadingFrame::OnDownloadComplete(const std::string& url, const std::string& filename, const std::string& filenameWithPath, const std::string& md5Str)
{
	//CCLog("--->OnDownloadComplete: %s", filenameWithPath.c_str());
	downloaded(url, filenameWithPath); 
	//moveDownloaded(url, filenameWithPath);
};
void LoadingFrame::OnDownloadFailed(const std::string& url, const std::string& filename, const std::string& basePath, int errorCode)
{
	//CCLog("--->OnDownloadFailed");
	downloadFailed(url, filename, errorCode);
};
void LoadingFrame::enterBackGround() {
	if (versionStat != LOADING_ASSETS) {
		CCLog("LoadingFrame::enterBackGround()");
		return;
	}
	std::ostringstream oss;
	oss << std::fixed << std::setprecision(2) << currentFileLoadSize;
	std::string size = oss.str();
	std::string eventInfo = "downloading file : " + currentLoadFile + ", downloaded size : " + size;
	if (loadFailData.size() > 0) {
		eventInfo = eventInfo + ", fail file : ";
		for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
			std::string assetUrl = serverVersionData->packageUrl + "/" + (*it)->name;
			if (loadFailData.find(assetUrl) != loadFailData.end()) {
				eventInfo = eventInfo + (*it)->name + ", ";
			}
		}
	}
	reportDownloadEvent("enterBackGround", eventInfo);
}

void LoadingFrame::enterForeGround() {
	if (versionStat != LOADING_ASSETS) {
		CCLog("LoadingFrame::enterForeGround()");
		return;
	}
	reportDownloadEvent("enterForeGround", "");
}
void LoadingFrame::reportDownloadEvent(std::string eventName, std::string eventInfo) {
	try
	{
		// PlatformSDKActivity.java 接口
		Json::Value data;
		data["funtion"] = "trackEvent";
		data["param"] = "#event_download_event";

		time_t now = time(nullptr);
		std::string timeStr = std::ctime(&now);
		Json::Value property;
		property["#download_event"] = eventName;
		property["#download_event_time"] = timeStr;
		property["#download_event_info"] = eventInfo;
		data["properties"] = property.toStyledString();

		libPlatformManager::getPlatform()->sendMessageG2P("G2P_TAPDB_HANDLER", data.toStyledString());
	}
	catch (...)
	{
		CCLog("URL REQUEST IS NOT  REACH");
	}
}