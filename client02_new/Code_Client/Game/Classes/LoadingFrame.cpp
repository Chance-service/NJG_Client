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
//#include "comHuTuo.h"
//#include "Base64.h"
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
#include "LangSettingPage.h"
#include "ConfirmPage.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif
USING_NS_CC;
USING_NS_CC_EXT;


#define downLoadSavePath         "hotUpdate"
#define downLoadUpdateFileName   "hotUpdate.zip"
#define downLoadUpdateDir        "update"
#define versionPath              "version"
#define versionManifestName      "version.manifest"
#define versionAppManifestName	 "versionApp.manifest"
#define versionManifestNameTmp   "versionTmp.manifest"
#define SPINE_CFG_TXT            "txt/LoadingSpineCfg.txt"
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
#define MaxResumeTime 5
int g_iSelectedSeverIDCopy;

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
	, versionStat(NONE)
	, versionAppCompareStat(EQUAL)
	, versionCodeStat(EQUAL)
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
	if (SeverConsts::Get()->IsH365()/* || SeverConsts::Get()->IsKUSO()*/) // H365
	{
		libPlatformManager::getPlatform()->login();
	}
	else if(SeverConsts::Get()->IsEroR18()) {
		Lua_EcchiGamerSDKBridge::callinitbyC();
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    if (SeverConsts::Get()->IsKUSO())
    {
        libPlatformManager::getPlatform()->login();
    }
#endif

	float reqServerTime = StringConverter::parseLong(VaribleManager::Get()->getSetting("ReqServerListOffest", "", "10"), true);
	SeverConsts::Get()->setReqServerListOffestTime(reqServerTime);

	mSpineData = new SpineData();

	this->getLocalSpineDataCfg();

    CCLOG("init severConst...");
    SeverConsts::Get()->init(GamePlatformInfo::getInstance()->getPlatVersionName());
	mScene = CCScene::create();
	mScene->retain();
	mScene->addChild(this);
	
	load();
    
	//CCTextureCache::sharedTextureCache()->dumpCachedTextureInfo();


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
	//CCLabelTTF* versionLabel = dynamic_cast<CCLabelTTF*>(getVariable("mVer"));//mLoading1
	//if(versionLabel)
	//{
	//	std::string ver = "Ver" + SeverConsts::Get()->getVersion();
	//	versionLabel->setString(ver.c_str());
	//}
    
	CCB_FUNC(this, "mLoading1", cocos2d::CCLabelBMFont, setString(""));
    CCLOG("************start running LoadingFrame scene**************");
	
	CCDirector::sharedDirector()->setDepthTest(true);
	// run
	if(cocos2d::CCDirector::sharedDirector()->getRunningScene())
		cocos2d::CCDirector::sharedDirector()->replaceScene(mScene);
	else
		cocos2d::CCDirector::sharedDirector()->runWithScene(mScene);
    
	/*std::string loadingSceneMsg=Language::Get()->getString("@loading2");
	const PlatformRoleItem* item=PlatformRoleTableManager::Get()->getPlatformRoleByName(libPlatformManager::getPlatform()->getClientChannel());
	if(item)
	{
		loadingSceneMsg=item->loadinScenceMsg;
	}
	CCB_FUNC(this,"mLoadingScenceMsg",CCLabelBMFont,setString(loadingSceneMsg.c_str()));*/
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

	//CCNode* aniNode = dynamic_cast<CCNode*>(getVariable("mLogoAni"));
	//aniNode:removeAllChildrenWithCleanup(true);
    
	unload();
	mScene->removeAllChildrenWithCleanup(true);
	mScene->release();
	CCLOG("loading frame mScene retainCount:%d",mScene->retainCount());
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

	loadingAsset();

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
		//ontestLogin();
		//showAnnounce();
		//updateSeverName();
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
		//bool haveDefaultLoing = false;
		std::string uin = "";
		std::string pass = "";
		if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() /*|| SeverConsts::Get()->IsKUSO()*/) // H365,JSG,LSJ
		{
			#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
				std::string uinkey = "LastLoginPUID";
				uin = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");

				std::string passkey = "PassKey";
				pass = CCUserDefault::sharedUserDefault()->getStringForKey(passkey.c_str(), "");

				if ((uin != "") && (pass != ""))
				{
					libPlatformManager::getPlatform()->setLoginName(uin);
					//libOS::getInstance()->initUserID(uin);
					GamePrecedure::getInstance()->setDefaultPwd(pass);
					//haveDefaultLoing = true;
				}

			#endif
		}
		else if(SeverConsts::Get()->IsEroR18()) //工口
		{
			Lua_EcchiGamerSDKBridge::callLoginbyC(); // c++ sdk to call java
		}
		else if (SeverConsts::Get()->IsKUSO()) //Kuso
		{
			cocos2d::CCLog("LoadingFrame::onLogin IsKUSO");
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
				//libOS::getInstance()->initUserID(uin);
				GamePrecedure::getInstance()->setDefaultPwd(pass);
				//haveDefaultLoing = true;
			}
		}

		//取得登入帳號類型
		//std::string loginType = CCUserDefault::sharedUserDefault()->getStringForKey("EroLoginType", "");
		//if (loginType != "") {	//有紀錄
			//defultType = loginType == "Normal" ? ERO_LOGINTYPE::LOGINTYPE_NORMAL_ACCOUNT : loginType == "EroGuest" ? ERO_LOGINTYPE::LOGINTYPE_ERO_GUEST : ERO_LOGINTYPE::LOGINTYPE_ERO_ACCOUNT;
		//}

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
			//t
			m_bUpdateServerName = true;
			// updateSeverName();
		}
		if (getVariable("mSeverNode"))
		{
			CCNode* sever = dynamic_cast<CCNode*>(getVariable("mSeverNode"));
			if (sever &&mIsFirstLoginNotServerIDInfo)
			{
				mIsFirstLoginNotServerIDInfo = false;
			}
		}
		
		if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() || SeverConsts::Get()->IsKUSO()) // H365,JSG,LSJ
		{
#if(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			showSevers(true);
#endif
		}
		//else if (SeverConsts::Get()->IsEroR18())	//工口
		//{
		//	if (mSelectedSeverID > 0) {	// 有選過server
		//		//std::string token = CCUserDefault::sharedUserDefault()->getStringForKey("ecchigamer.token", "");
		//		//if (uin.length() > 35 && uin.find("-") != uin.npos && token != "") {	//有工口帳號紀錄
		//			setEnterGameNodeVisible(true);
		//		//}
		//		//else {
		//		//	showLoginUser(uin, pass, defultType);
		//		//}
		//	}
		//	else {
		//		showSevers(true);
		//	}
		//
		//}
    }
}

void LoadingFrame::onPlatformLogout(libPlatform*)
{
	if (SeverConsts::Get()->IsEroR18()){
		Lua_EcchiGamerSDKBridge::callLogoutbyC();
	}
  //  if(!libPlatformManager::getPlatform()->getLogined())
  //  {
  //      CCLabelTTF* eb = dynamic_cast<CCLabelTTF*>(getVariable("mLoginName"));
		//if(eb)
		//	eb->setString("Login");
		//else
		//{
		//	CCLabelBMFont* eb2 = dynamic_cast<CCLabelBMFont*>(getVariable("mLoginName"));
		//	if(eb2)eb2->setString("Login");
		//}
  //      CCMessageBox(Language::Get()->getString("@LOADINGFRAME_HAVENOT_LOGIN").c_str(),"");
  //  }
};

void LoadingFrame::onUpdate(libPlatform*,bool ok, std::string msg)
{
    if(!ok)
    {
		CCLOG("LoadingFrame::onUpdate failed");
        libOS::getInstance()->showMessagebox(msg);
    }
    else
    {
		cocos2d::CCLog("LoadingFrame::onUpdate success");
		CCLOG("LoadingFrame::onUpdate success");
        SeverConsts::Get()->start();
		////弹出公告板
		//showAnnounce();
		////加载资源


    }
}

void LoadingFrame::LoginSuccess()
{

	//SeverConsts::Get()->mCheckState = SeverConsts::CS_OK;

	if (GamePrecedure::Get()->isReEnterLoadingFrame())
	{
		libPlatformManager::getPlatform()->logout();
	}
	//不论是被挤出来重新登录 还是第一次登录都走一遍这个流程 
	cocos2d::CCLog("LoadingFrame::LoginSuccess");
	libPlatformManager::getPlatform()->initWithConfigure(GamePlatformInfo::getInstance()->getPlatFromconfig());
	loginReport(REPORT_STEP::REPORT_STEP_END_DOWNLOAD_PATCH);
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//	if (!GamePrecedure::Get()->isReEnterLoadingFrame())
//		libPlatformManager::getPlatform()->initWithConfigure(GamePlatformInfo::getInstance()->getPlatFromconfig());
//#else
//	libPlatformManager::getPlatform()->initWithConfigure(GamePlatformInfo::getInstance()->getPlatFromconfig());
//#endif
}
void LoadingFrame::onMessageboxEnter(int tag)
{
    if(tag == 100)
    {
		CCLOG("onMessageBoxEnter tag 100  versionStat is %d---", versionStat);
		if (versionStat == UPDATE_APP_STORE)
		{
			appStoreUpdate();
		}
		else if (versionStat == CHECK_PROJECT_ASSETS_DONE)
		{
		    //hidLoadingAniPage();
			setOpcaityLoadingAniPage(0);
			UpdateAssetFromServer();
		}
		else if (versionStat == UPDATE_FAIL)
		{
			ResumeCount = MaxResumeTime;
			UpdateAssetFromServer();
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
/**
param1 txt_files_path  是一个具体的txt文件 里面存放的是要解析的所有文件的名字  "E:\\txt\\txt\\txt.txt"
param2 src_path  是要解析的文件的文件夹路径    "E:\\Assets\\txt\\"
param  des_path  是要存放的文件夹路径    "E:\\girl\\txt\\"
*/
void LoadingFrame::Encrypt_GirlFile(std::string txt_files_path, std::string src_path, std::string des_path)
{
	//解析资源的时候 要先设置对应的加密密码  GameEncryptKey.h 设置
	//读取txt文件
	ConfigFile cfg;
	ConfigFile* st_pImgsetCfg = NULL;

	if (st_pImgsetCfg == NULL)
	{
		cfg.load(txt_files_path);
		st_pImgsetCfg = &cfg;

	}
	ConfigFile::SettingsMapIterator itr = cfg.getSettingsMapIterator();
	while (itr.hasMoreElements())
	{
		std::string fileTmp = src_path;
		std::string filenameTmp = itr.getNext();
		std::string filename = fileTmp + filenameTmp;

		static int ic = 0;
		CCLOG("Imageset%d:%s", ++ic, filename.c_str());
		if (!filename.empty())
		{
			unsigned long codeBufferSize = 0;
			unsigned char* codeBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(filename.c_str()).c_str(),
				"rb", &codeBufferSize, false);
			if (codeBuffer)
			{
				std::string path = des_path + filenameTmp;
				FILE * out = fopen(path.c_str(), "wb");
				fwrite(codeBuffer, codeBufferSize, 1, out);
				fclose(out);
			}
		}
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
	else if (itemName == "onServiceSupport")
	{
		showFeedBack();
	}
	else if (itemName == "onDataTransfer")
	{
		showChangeUser();
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
			if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() || SeverConsts::Get()->IsKUSO())
			{
				CCLog("onConfirmLogout3");
				libPlatformManager::getPlatform()->logout();
				setLogoutNodeVisible(false);
			}
			else if (SeverConsts::Get()->IsEroR18()) {
				showLogoutConfirm();
			}
			else
			{
				CCLog("onConfirmLogout4");
				//std::string loginType = CCUserDefault::sharedUserDefault()->getStringForKey("EroLoginType", "");
				//if (loginType == "EroGuest" || loginType == "EroAccount") {
				libPlatformManager::getPlatform()->logout();
				//}
				setLogoutNodeVisible(false);
				setLogoutBtnVisible(false);
				setEnterGameNodeVisible(false);
				//defultType = ERO_LOGINTYPE::LOGINTYPE_NONE;
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
				CCUserDefault::sharedUserDefault()->setStringForKey("LastLoginPUID", "");
				CCUserDefault::sharedUserDefault()->setStringForKey("PassKey", "");
				CCUserDefault::sharedUserDefault()->setStringForKey("ecchigamer.token", "");
				//CCUserDefault::sharedUserDefault()->setStringForKey("EroLoginType", "");
				//showLoginUser();
//#endif	
			}
		}

	}
	else if (itemName == "onOpenLogoutNode")
	{
		if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() || SeverConsts::Get()->IsKUSO())
		{
			libPlatformManager::getPlatform()->logout();
		}
		else if (SeverConsts::Get()->IsEroR18()) {
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
	else if (itemName == "onBCLogin")
	{
		showBCLogin();
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
		//showAnnounce();
	}
	else if (itemName == "onLangBtn")
	{
		showLangSetting();
	}
}

void LoadingFrame::onAnimationDone(const std::string& animationName){
	if (animationName == "LogoAni")
	{
		showLoadingAniPage();
		setPosLoadingAniPage();
		checkVersion();
		//SeverConsts::Get()->mCheckState = SeverConsts::CS_OK;
		//showAnnounce();
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

		//std::string url = VaribleManager::Get()->getSetting("DatareportUrl", "", "");
		//if (url == "") {
		//	return;
		//}
		//url.append("/recordStep?");
		////版本
		////url.append("&gameVersion=" + localVersionData->versionResource);
		//
		////数据只管发不做返回处理
		//std::string data = CCString::createWithFormat("device=%s&platform=%s&step=%d", deviceid.c_str(), platform.c_str(), step)->m_sString;
		//auto request = new CCHttpRequest();
		//request->setUrl(url.c_str());
		//request->setRequestType(CCHttpRequest::HttpRequestType::kHttpPost);
		//request->setRequestData(data.c_str(), data.size());
		//CCHttpClient::getInstance()->send(request);

		//CCUserDefault::sharedUserDefault()->setIntegerForKey(stepKey.c_str(), step);

		//request->release();
	}
	catch (...)
	{
		CCLOG("URL REQUEST IS NOT  REACH");
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
	PacketManager::Get()->registerPacketHandler(OPCODE_ACTIVE_CODERET_S,this);
#endif
	//ServerDateManager::Get()->setSeverID(mSelectedSeverID);
	PacketManager::Get()->registerPacketHandler(LOGIN_S,this);
	PacketManager::Get()->registerPacketHandler(ERROR_CODE,this);

	HPLogin loginPack;
	GamePrecedure::Get()->setServerID(mSelectedSeverID);
	GamePrecedure::Get()->setAlertServerUpdating(false);
	std::string uin = libPlatformManager::getPlatform()->loginUin();

#ifdef PROJECT91Quasi
	if(gPuid != "")
	{
		uin = gPuid;
		GamePrecedure::Get()->setLoginUin(uin);
	}
#endif
	std::string platformInfo = libPlatformManager::getPlatform()->getPlatformInfo();
	std::string deviceID = libOS::getInstance()->getDeviceID();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	// Samsung i9100's audio driver has a bug , it can not accept too much effects concurrently.
	if(((platformInfo.find("samsung")!=std::string::npos)||(platformInfo.find("SAMSUNG")!=std::string::npos))&&(platformInfo.find("9100")!=std::string::npos))
	{
		BlackBoard::Get()->isSamSungi9100Audio = true;				
	}
#endif
	GamePrecedure::Get()->setUin(uin);

	if(uin.empty()) 
		uin="none";
	if(deviceID.empty()) 
		deviceID="device id is empty";
	if(!platformInfo.empty())
		loginPack.set_platform(platformInfo);
#ifdef PROJECT91Quasi
	if (uin.empty())
	{
		libOS::getInstance()->showInputbox(true);
	}
	else
	{
#endif
		loginPack.set_puid(uin);
		loginPack.set_isrelogin(false);
		std::string aPwd = GamePrecedure::getInstance()->getDefaultPwd();
		if (SeverConsts::Get()->IsEroR18())
		{
			//loginPack.set_registed(isRegister);
			loginPack.set_passwd(aPwd);
		}
		else
		{
			if (aPwd != "")
				loginPack.set_passwd(aPwd);
		}
		int isGuest = libPlatformManager::getPlatform()->getIsGuest();
		//if (isGuest == 0 && SeverConsts::Get()->IsEroR18()){
		//	std::string loginType = CCUserDefault::sharedUserDefault()->getStringForKey("EroLoginType", "");
		//	isGuest = loginType == "EroGuest" ? ERO_LOGINTYPE::LOGINTYPE_ERO_GUEST : loginType == "EroAccount" ? ERO_LOGINTYPE::LOGINTYPE_ERO_ACCOUNT : ERO_LOGINTYPE::LOGINTYPE_NORMAL_ACCOUNT;
		//}
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
		//caculate the time to kill game when player enter background
		if(VaribleManager::Get()->getSetting("ExitGameTime")!="")
		{
			TimeCalculator::getInstance()->createTimeCalcultor("ExitGameTime",StringConverter::parseInt(VaribleManager::Get()->getSetting("ExitGameTime")));
		}
		//登录信息上报
		//loginReport();
#ifdef PROJECT91Quasi
	}
#endif
}
void LoadingFrame::onInputboxEnter(const std::string& content)
{
    gPuid = content;
#ifdef PROJECT91Quasi
    //add by xinghui
    CCLabelTTF* eb1 = dynamic_cast<CCLabelTTF*>(getVariable("mLoginName"));
    if (eb1) {
        eb1->setString(gPuid.c_str());
    }else
    {
        CCLabelBMFont* eb2 = dynamic_cast<CCLabelBMFont*>(getVariable("mLoginName"));
        if (eb2) {
            eb2->setString(gPuid.c_str());
        }
    }
#endif
}

void LoadingFrame::onMenuItemAction( const std::string& itemName, cocos2d::CCObject* sender, int tag )
{
	mSelectedSeverID = tag;
	//updateLocalSeverId();
	updateSeverName();
	showSevers(false);
	if (!SeverConsts::Get()->IsEroR18()) //H365
	{
		#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			showLoginUser();
		#endif
	}
	else
	{
		//std::string uin = "";
		//std::string pass = "";
		//std::string uinkey = "LastLoginPUID";
		//uin = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");
		//std::string passkey = "PassKey";
		//pass = CCUserDefault::sharedUserDefault()->getStringForKey(passkey.c_str(), "");
		//std::string token = CCUserDefault::sharedUserDefault()->getStringForKey("ecchigamer.token", "");
		//if (uin.length() > 35 && uin.find("-") != uin.npos && token != "") {	//有工口帳號紀錄
		//	setEnterGameNodeVisible(true);
		//}
		//else {
		//	showLoginUser(uin, pass, defultType);
		//}
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
	TipsManager::TipsItemListIterator itr = TipsManager::Get()->getTipsIterator();
	while(itr.hasMoreElements())
	{
		std::string tip = itr.getNext()->tip;
		mTipVec.push_back(tip);
	}
	setTips("loading......");
	bool m_IsShowSpine = StringConverter::parseBool(VaribleManager::Get()->getSetting("IsShowSpineWithLogin"), false);
	if (m_IsShowSpine)
	{
		showSpine();
		//this->runAnimation("Default Timeline");
		this->runAnimation("LogoAni");
	}
	else
	{
		CCSprite *  mSprite = CCSprite::create("LoadingUI_JP/loadingUI_Bg.png");
		CCNode* mSpine = dynamic_cast<CCNode*>(getVariable("mSpine"));
		mSpine->addChild(mSprite);
		showLoadingAniPage();
		setPosLoadingAniPage();
		checkVersion();
	}
}
void LoadingFrame::showSpine()
{
	glClearColor(0, 0, 0, 0);
	GamePrecedure::Get()->playMovie("op", 1, 1);
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
显示公告
*/
void LoadingFrame::showAnnounce()
{
	static bool allShow = StringConverter::parseBool(VaribleManager::Get()->getSetting("ShowAnnounceSmallExit"), true);
	if (!allShow)
	{
		static unsigned int showCount = 0;
		if (showCount > 0)
		{
			CCLOG("dont show announcePage");
			return;
		}
		++showCount;
	}

	BasePage* page = CCBManager::Get()->getPage("AnnouncePage");
	if (page && !page->getParent())
	{
		page->load();
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>* >(page);
		if (sta)
		{
			CCLOG("show announcePage enter");
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
		CCLOG("show announcePage");
		page->setPosition(ccp(0, 0));
	}
}
/*
数据移行
*/
void LoadingFrame::showChangeUser()
{
	BasePage* page = CCBManager::Get()->getPage("ChangeUserPage");
	if (page && !page->getParent())
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


		addChild(page);
		page->setPosition(ccp(0, 0));
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

/*
BC登入介面
*/
void LoadingFrame::showBCLogin()
{
	BasePage* page = CCBManager::Get()->getPage("LoginBCPage");
	if (page && !page->getParent())
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

		LoginBCPage* mLoginBCPage = dynamic_cast<LoginBCPage*>(CCBManager::Get()->getPage("LoginBCPage"));
		if (mLoginBCPage)
		{
			mLoginBCPage->DefaultEmail();
		}
	}
}

/*
語系選擇介面
*/
void LoadingFrame::showLangSetting()
{
	BasePage* page = CCBManager::Get()->getPage("LangSettingPage");
	if (page && !page->getParent())
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
/*
客服反馈
*/
void LoadingFrame::showFeedBack()
{

	CCMenuItemImage* pMenuFeedBackBtn = dynamic_cast<CCMenuItemImage*>(getVariable("mServiceSupport"));
	if (pMenuFeedBackBtn)
	{
		pMenuFeedBackBtn->stopAllActions();
		pMenuFeedBackBtn->setScale(1.0f);
	}

	BasePage* page = CCBManager::Get()->getPage("FeedBackPage");
	if (page && !page->getParent())
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

		//page->addChild(layer);
		addChild(page);
		page->setPosition(ccp(0, 0));
	}

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
					//count = comHuTuo::getServerInfoCount();
					int trueCount = count;
                    
                    std::vector<int> *servers = new std::vector<int>();
                    
                    if(count == 0)
                        count = 1;
                    
					std::string uinkey = "DefaultSeverID";// + libPlatformManager::getPlatform()->loginUin();
					int defid = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey(uinkey.c_str(),SeverConsts::Get()->getSeverDefaultID());
                    
                    for(int i=0; i<count;++i)
                    {
						if(noteCount>6) break;
                        int serverIDtoforRecent = defid;
                        if(trueCount>0)
						{
							int numToFind = 1;// comHuTuo::getServerUserByIndex(i);
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
                size.height = (noteCount+noteCount%2)*0.5f*singleButtonHeight;//count
				//size.height = singleButtonHeight * ((count+1)/2);
				//float offpos = severlist->getContentSize().height-size.height;
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

void LoadingFrame::showLogin()
{
	//	setEnterGameNodeVisible(false);
	//	setEnterServerListVisible(false);
	//  setLoginGameNodeVisible(true);
}

void LoadingFrame::showEnter()
{

	hidLoadingAniPage();
	CCLog("LoadingFrame::showEnter");
	if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsKUSO()) {
		setEnterGameNodeVisible(true);
	}
	else {
		setEnterGameNodeVisible(false);
	}
    
	setEnterServerListVisible(true);
	if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsKUSO())
	{
		setLogoutBtnVisible(true);
	}
	//else if (SeverConsts::Get()->IsEroR18()) //R18
	//{
	//	//std::string loginType = CCUserDefault::sharedUserDefault()->getStringForKey("EroLoginType", "");
	//	std::string uin = "";
	//	std::string uinkey = "LastLoginPUID";
	//	uin = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");
	//	if ((uin != ""))
	//	{
	//		setLogoutBtnVisible(true);
	//	}
	//}
	setLogoutNodeVisible(false);
	CCLabelTTF* tipsLabel = dynamic_cast<CCLabelTTF*>(getVariable("mTips"));//mLoading1
	if (tipsLabel)
	{
		tipsLabel->setVisible(false);
	}

	/*CCMenuItemImage* mDataTransferBtn = dynamic_cast<CCMenuItemImage*>(getVariable("mDataTransfer"));
	if (mDataTransferBtn)
	{
		mDataTransferBtn->setVisible(true);
	}*/
	//showDaterTransFerBtn(mIsCanShowDataTransfer);
    setLoginGameNodeVisible(false);
}

int LoadingFrame::getDefaultSeverID()
{
//	std::string projectNameKey="gjwow";
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
//	projectNameKey="gjwow_android";
//#else
//	projectNameKey="gjwow_ios";
//#endif
//	const std::string projectName=VaribleManager::Get()->getSetting(projectNameKey,"","gjwow");
//    const std::string uin = libPlatformManager::getPlatform()->loginUin();
//	std::map<std::string,std::string> strMap;
//	strMap.insert(std::pair<std::string,std::string>("gameid",projectName.c_str()));
//	strMap.insert(std::pair<std::string,std::string>("puid", uin));
//	libOS::getInstance()->analyticsLogEvent("getDefaultSeverID-refreshServerInfo", strMap ,true);
//    bool getSvr = false;
//	if (!VaribleManager::Get()->getSetting("OpenAnalytics").empty())
//		getSvr = true;
	//comHuTuo::refreshServerInfo(projectName.c_str(),uin, getSvr);
    //libOS::getInstance()->analyticsLogEndTimeEvent("getDefaultSeverID-refreshServerInfo");
	//int id = comHuTuo::getServerInfoCount()>0?comHuTuo::getServerUserByIndex(0):-1;

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
	if(getVariable("mSeverName1") && mSelectedSeverID!=-1)
	{
		CCLabelTTF* eb = dynamic_cast<CCLabelTTF*>(getVariable("mSeverName1"));
		//*CCLabelTTF *label1 = CCLabelTTF::create("alignment left", "A Damn Mess", fontSize, blockSize,
		//	*kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter);
		//*CCLabelTTF *label2 = CCLabelTTF::create("alignment right", "/mnt/sdcard/Scissor Cuts.ttf", fontSize, blockSize,
		//	*kCCTextAlignmentLeft, kCCVerticalTextAlignmentCenter);

		//CCLabelBMFont* eb = dynamic_cast<CCLabelBMFont*>(getVariable("mSeverName1"));
		SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(mSelectedSeverID);
		if (eb && it != SeverConsts::Get()->getSeverList().end()) {
			CCLOG("servername %s", it->second->name.c_str());
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

					if (SeverConsts::Get()->IsEroR18())
					{
						//std::string aUrl = SeverConsts::Get()->getR18PayUrl();
						//libPlatformManager::getPlatform()->setPayR18(logret->playerid(), mSelectedSeverID, aUrl);
						libPlatformManager::getPlatform()->setIsGuest(logret->isguest());
						//成功登入 紀錄帳號類型
						//std::string loginType = logret->isguest() == 0 ? "Normal" : logret->isguest() == 1 ? "EroGuest" : "EroAccount";
						//CCUserDefault::sharedUserDefault()->setStringForKey("EroLoginType", loginType);
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
				//非訪客的工口登入新帳號需呼叫綁定帳號
				if (logret->isguest() == 2) {
					Lua_EcchiGamerSDKBridge::callPostAccountBindbyC(StringConverter::toString(logret->playerid()));
				}
				GamePrecedure::Get()->setHasMainRole(false);
			}

			GamePrecedure::Get()->preEnterMainMenu();
			//updateLocalSeverId();
			MsgLoadingFrameEnterGame enterGameMsg;
			MessageManager::Get()->sendMessage(&enterGameMsg);
			PacketManager::Get()->removePacketHandler(this);
			GamePrecedure::Get()->setAlertServerUpdating(true);
		}
		else
		{
			CCLog("onReceivePacket showEnter");
			showEnter();
		}
	}
	else if(opcode==ERROR_CODE)
	{
		const HPErrorCode * errMsgRet = dynamic_cast<const HPErrorCode*>(packet);
		if(errMsgRet->hpcode()==LOGIN_S&&mSendLogin)
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
		CCLOG("ret->status()%d",ret->status());
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
		//CCLog("*********************setInLoadingScene 1157");
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
	if(tag=="SERVERLIST")
	{
		std::string ret = SeverConsts::Get()->onReceiveCommonMessage(tag,msg);

		int newServerId = getDefaultSeverID();
		{
			SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(newServerId);
			if(it == SeverConsts::Get()->getSeverList().end())
				newServerId = SeverConsts::Get()->getSeverDefaultID();
		}


		if(newServerId!=mSelectedSeverID)
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
	else if (tag=="P2G_KR_CHECKSERVER_BACK")
	{
		Json::Reader jreader;
		Json::Value jvalue;
		jreader.parse(msg,jvalue,false);

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
		if (SeverConsts::Get()->IsKUSO()){
			if (msg == "1")
			{
				libPlatformManager::getPlatform()->login();
			}
			else
			{
			}
		}
	}
	return "";
}

void LoadingFrame::setEnterGameNodeVisible( bool visible )
{
	//if (!libPlatformManager::getPlatform()->getIsH365()) // not H365 is false
	//{
	//	CCB_FUNC(this, "mLoginNode2", CCNode, setVisible(false));
	//	return;
	//}
	CCB_FUNC(this, "mLoginNode2", CCNode, setVisible(visible));
}

void LoadingFrame::setEnterBCNodeVisible(bool visible)
{
	//if (!libPlatformManager::getPlatform()->getIsH365()) // not H365 is false
	//{
	//	CCB_FUNC(this, "mLoginNode2", CCNode, setVisible(false));
	//	return;
	//}
	CCB_FUNC(this, "mBCLoginNode", CCNode, setVisible(visible));
}

void LoadingFrame::setEnterServerListVisible(bool visible)
{
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
	if (SeverConsts::Get()->IsEroR18()) {
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

	if (SeverConsts::Get()->IsH365() || SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsJSG() || SeverConsts::Get()->IsLSJ() || SeverConsts::Get()->IsKUSO()) // H365,JSG,LSJ
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
		//SeverConsts::Get()->start();
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
			std::string downloadVerUrl = localVersionData->remoteVersionUrl + "/" + versionManifestName + "?" + "time=" + _time->m_sString;
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
	//CCLog("*********************setInLoadingScene 394");
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
			/*Json::Value data;
			data["token"] = "";
			#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			{
			data["token"] = "irk89a";
			libPlatformManager::getPlatform()->sendMessageG2P("G2P_RECORDING_ADJUST_EVENT", data.toStyledString());
			}
			#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			{
			data["token"] = "n70ast";
			libPlatformManager::getPlatform()->sendMessageG2P("G2P_RECORDING_ADJUST_EVENT", data.toStyledString());
			}
			#endif
			*/

			loginGame(it->second->address, it->second->port, isRegister);

			setPosLoadingAniPage();
			setOpcaityLoadingAniPage(150);
			//hideLoginUser();
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
	std::string downloadVerUrl = localVersionData->remoteVersionUrl + "/" + versionManifestName + "?" + "time=" + _time->m_sString;
	CurlDownload::Get()->downloadFile(downloadVerUrl, saveVersionPath);


	//getServerVersionCfg();

}

void LoadingFrame::getServerVersionCfg()
{

	std::string _retTimestamp = "";
	time_t t = time(0);
	//_retTimestamp = "?time=" + StringConverter::toString(t);
	//64bit 不识别 
	_retTimestamp = "?time=" + CCString::createWithFormat("%d", t)->m_sString;
	//std::string url = localVersionData->remoteVersionUrl + _retTimestamp;
	std::string url = localVersionData->remoteVersionUrl + "/" + versionManifestName + _retTimestamp;
	//std::string url = "";

	auto request = new CCHttpRequest();
	request->setUrl(url.c_str());
	request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
	request->setResponseCallback(this, callfuncND_selector(LoadingFrame::onHttpRequestCompleted));

	request->setTag("serverVersionCfg");

	CCHttpClient::getInstance()->send(request);

	CCLOG("hotUpdate : url %s", url.c_str());
	CCLOG("hotUpdate : getServerVersionCfg 2");

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
}

void LoadingFrame::setTips(std::string msg)
{
	CCLabelTTF* tipsLabel = dynamic_cast<CCLabelTTF*>(getVariable("mTips"));//mLoading1
	if (tipsLabel)
	{
		tipsLabel->setString(msg.c_str());
		//tipsLabel->setDimensions(CCSize(10, 200));
	}
}
void LoadingFrame::loadingAsset()
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
		//for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		//	bool value = AssetsManagerEx::getInstance()->uncompress((*it)->savePath, (*it)->stroge);
		//	CCLog("hotUpdate uncompress: %s", ((*it)->name).c_str());
		//	// delete file
		//	remove((*it)->savePath.c_str());
		//}

		if (m_updateVersionTips)
		{
			setTips(m_updateVersionTips->uncompressCompleteTxT);
		}

		if (serverVersionData)
		{
			std::string ver = "Ver" + serverVersionData->versionResource;
			setVersion(ver);
		}
		

		CCLog("hotUpdate uncompress complete");
		resetVersion();
		GamePrecedure::Get()->enterLoading();

		//GamePrecedure::getInstance()->loadPlsit();
		//SeverConsts::Get()->start();
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
		
		//showLogin();
		//libPlatformManager::getPlatform()->login();
		//updateSeverName();

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
				CCLOG("hotUpdate : Updatefailed ----step1");
				setTips(m_updateVersionTips->updateFailTxT);
				showFailedMessage(m_updateVersionTips->updateFailTxT, 100);
				//setActionBtnTxt(m_updateVersionTips->confirmBtnTxT);
			}
		}
		return;
	}

	float alreadyLoadSize = (currentFileLoadSize * 1.0f) / 1024;
	for (auto it = alreadyDownloadData.begin(); it != alreadyDownloadData.end(); ++it) {
		for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
			if ((*it) != (*itNeed)->url)
			{
				continue;
			}

			alreadyLoadSize += (*itNeed)->size;
		}
	}
	float persentage = alreadyLoadSize / downTotalSize;
	char perTxt[64];
	sprintf(perTxt, "(%dMB / %dMB)", (int)alreadyLoadSize, (int)downTotalSize);
	//showPersent(persentage, std::string(""));
	showPersent(persentage, perTxt);
}
void LoadingFrame::resetVersion()
{
	std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();

	//下载最新的 peojectManifest 文件
    std::string saveProjrctPath = writeRootPath + versionPath + "/" + projectManifestName;
	std::string downloadProjectUrl = localVersionData->packageUrl + "/"  + projectManifestName + "?version=" + serverVersionData->versionResource;
	CurlDownload::Get()->downloadFile(downloadProjectUrl, saveProjrctPath);

	//更新version文件操作 把之前的下载versionTmp.mainfest文件存到version.manifest文件里面 下次读取使用
	std::string versionPathTmp = writeRootPath + versionPath + "/" + versionManifestNameTmp;
	std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestName;
	unsigned long filesize;
	unsigned	char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(versionManifestNameTmp).c_str(), "rt", &filesize, 0, nullptr);
	saveFileInPath(saveVersionPath, "wb", pBuffer, filesize);

	SeverConsts::Get()->setServerVersion(serverVersionData->versionResource);

	remove(versionPathTmp.c_str());

	//下载最新的 versionMainfest 文件
	/*std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestName;
	std::string downloadVerUrl = localVersionData->remoteVersionUrl + "/" + versionManifestName + "?" + "time=" + _time->m_sString;
	CurlDownload::Get()->downloadFile(downloadVerUrl, saveVersionPath);*/

}
void LoadingFrame::setActionBtnTxt(std::string meg)
{
	CCLabelTTF* mbtnLabel = dynamic_cast<CCLabelTTF*>(getVariable("mbtn"));
	if (mbtnLabel)
	{
		mbtnLabel->setString(meg.c_str());
	}
}

void  LoadingFrame::getLocalSpineDataCfg()
{
	unsigned char* content = readLocal(std::string(SPINE_CFG_TXT));

	if (!content)
	{
		return;
	}

	Json::Reader reader;
	Json::Value value;

	CCLOG("getLocalSpineDataCfg: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (!ret)
	{
		return;
	}

	mSpineData->spinePath = value["spinePath"].asString();
	mSpineData->spineName = value["spineName"].asString();
	mSpineData->scaleX = value["scaleX"].asDouble();
	mSpineData->scaleY = value["scaleY"].asDouble();
	mSpineData->offsetX = value["offsetX"].asDouble();
	mSpineData->offsetY = value["offsetY"].asDouble();
	mSpineData->actionName = value["actionName"].asString();
	mSpineData->isLoadSuccess = true;

	
}
void LoadingFrame::getLocalVersionCfg()
{
	unsigned char* content = readLocal(std::string(versionManifestName));
	unsigned char* contentApp = readLocal(std::string(versionAppManifestName));
	
	if (!content || !contentApp)
	{
		//本地读取出现错误 从UseDefault中取
		localVersionData->packageUrl = CCUserDefault::sharedUserDefault()->getStringForKey("packageUrl");
		localVersionData->remoteProjectManifestUrl = CCUserDefault::sharedUserDefault()->getStringForKey("remoteProjectManifestUrl");
		localVersionData->versionResource = CCUserDefault::sharedUserDefault()->getStringForKey("versionResource");
		localVersionData->remoteVersionUrl = CCUserDefault::sharedUserDefault()->getStringForKey("remoteVersionUrl");
		localVersionData->versionApp = CCUserDefault::sharedUserDefault()->getStringForKey("versionApp");
		localVersionData->isLoadSuccess = true;
		localVersionData->isNeedGoAppStore = CCUserDefault::sharedUserDefault()->getIntegerForKey("isNeedGoAppStore");

		CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION),libOS::getInstance()->getDeviceInfo(), libOS::getInstance()->getDeviceID(), localVersionData->versionResource, "get local version from userdefault");
		return;
	}
	getVersionData(localVersionData, content,true);
	getVersionAppData(localVersionData, contentApp, true);
	if (localVersionData && localVersionData->isLoadSuccess)
	{
		std::string ver = "Ver" + localVersionData->versionResource;
		setVersion(ver);
		SeverConsts::getInstance()->setVersion(localVersionData->versionApp);
		CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION), libOS::getInstance()->getDeviceInfo(), libOS::getInstance()->getDeviceID(), localVersionData->versionResource, "get local version cfg");

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
	//request->setResponseCallback(this, httpresponse_selector(UpdateVersion::onHttpRequestCompleted));
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
				//severAtt->name = tempServerName.c_str();
			}
			//mSeverList.insert(std::make_pair(severAtt->id, severAtt));
		}
	}

	/*SeverConsts::SEVERLIST::const_reverse_iterator it = mSeverList.rbegin();
	std::list<SeverConsts::SEVER_ATTRIBUTE> orderlist;

	for (; it != mSeverList.rend(); ++it)
	{
		orderlist.push_back(*it->second);
	}
	orderlist.sort();
	std::list<SeverConsts::SEVER_ATTRIBUTE>::iterator itOrdered = orderlist.begin();*/

}
void LoadingFrame::getVersionData(VersionData* versionData, unsigned char* content,bool isLocal)
{
	if (!content)
	{
		return;
	}

	Json::Reader reader;
	Json::Value value;

	CCLOG("hotUpdate getVersionData: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (!ret)
	{
		CCLOG("hotUpdate getVersionData: fail");

		if (isLocal)
		{
			//本地读取出现错误 从UseDefault中取
			versionData->packageUrl = CCUserDefault::sharedUserDefault()->getStringForKey("packageUrl");
			versionData->remoteProjectManifestUrl = CCUserDefault::sharedUserDefault()->getStringForKey("remoteProjectManifestUrl");
			versionData->versionResource = CCUserDefault::sharedUserDefault()->getStringForKey("versionResource");
			versionData->remoteVersionUrl = CCUserDefault::sharedUserDefault()->getStringForKey("remoteVersionUrl");
			versionData->versionApp = CCUserDefault::sharedUserDefault()->getStringForKey("versionApp");
			versionData->isNeedGoAppStore = CCUserDefault::sharedUserDefault()->getIntegerForKey("isNeedGoAppStore");
			versionData->isLoadSuccess = true;
		}
		return;
	}

	versionData->packageUrl = value["packageUrl"].asString();
	versionData->versionApp = value["versionApp"].asString();
	versionData->remoteProjectManifestUrl = value["remoteProjectManifestUrl"].asString();
	versionData->remoteVersionUrl = value["remoteVersionUrl"].asString();
	versionData->IOSAppStoreURL = value["IOSAppStoreURL"].asString();
	versionData->AndroidStoreURL = value["AndroidStoreURL"].asString();
	versionData->AppUpdateUrlH365 = value["AppUpdateUrlH365"].asString();
	versionData->AppUpdateUrlR18 = value["AppUpdateUrlR18"].asString();
	versionData->AppUpdateUrlKUSO = value["AppUpdateUrlKUSO"].asString();
	versionData->AppUpdateUrlJSG = value["AppUpdateUrlJSG"].asString();
	versionData->versionResource = value["versionResource"].asString();
	versionData->versionCode = value["versionCode"].asInt();
	versionData->isNeedGoAppStore = value["isNeedGoAppStore"].asInt();
	versionData->isLoadSuccess = true;

	if (isLocal)
	{
		//是读取的本地 存储上一次的version配置文件
		CCUserDefault::sharedUserDefault()->setStringForKey("packageUrl", versionData->packageUrl);
		CCUserDefault::sharedUserDefault()->setStringForKey("remoteProjectManifestUrl", versionData->remoteProjectManifestUrl);
		CCUserDefault::sharedUserDefault()->setStringForKey("versionResource", versionData->versionResource);
		CCUserDefault::sharedUserDefault()->setStringForKey("remoteVersionUrl", versionData->remoteVersionUrl);
		CCUserDefault::sharedUserDefault()->setStringForKey("versionApp", versionData->versionApp);
		CCUserDefault::sharedUserDefault()->setIntegerForKey("isNeedGoAppStore", versionData->isNeedGoAppStore);
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

	CCLOG("hotUpdate getVersionData: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (!ret)
	{
		CCLOG("hotUpdate getVersionData: fail");

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
	CCLOG("hotUpdate : readLocal content:%s , fileName is %s", content, fileName.c_str());
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
		CCLOG("hotUpdate : showFailedMessage ----step1,tag is %d---",tag);
		libOS::getInstance()->showMessagebox(m_updateVersionTips->notNetworkTxT,tag);
	}
	else
	{
		CCLOG("hotUpdate : showFailedMessage ----step2,tag is %d---", tag);
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
CompareStat LoadingFrame::compareVersion(std::string localVersion, std::string serverVersion)
{
	CompareStat stat = EQUAL;

	std::vector<std::string> localVector = splitVersion(localVersion, ".");
	CCLog("localVersion : %s", localVersion.c_str());
	std::vector<std::string> serverVector = splitVersion(serverVersion, ".");
	CCLog("serverVersion : %s", serverVersion.c_str());
	for (size_t i = 0; i < serverVector.size(); ++i) {
		std::string serverValue = serverVector[i];
		CCLog("serverValue%d : %s", i, serverValue.c_str());
		if (i >= localVector.size())
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
	if (serverVersionData && serverVersionData->isLoadSuccess)
	{
		//SeverConsts::Get()->setVersion(serverVersionData->versionApp);
	}

	if (m_updateVersionTips)
	{
		setTips(m_updateVersionTips->checkVersionTxT);
	}

	if (!serverVersionData || !serverVersionData->isLoadSuccess)
	{ 
		hidLoadingAniPage();
		showFailedMessage(m_updateVersionTips->checkFailTxT,100);
		setTips(m_updateVersionTips->checkFailTxT);
		return;
	}

	if (!localVersionData || !localVersionData->isLoadSuccess)
	{
		GamePrecedure::Get()->enterLoading();
		return;
	}

	versionAppCompareStat = compareVersion(localVersionData->versionApp, serverVersionData->versionApp);
	versionResourceStat = LESS;//compareVersion(localVersionData->versionResource, serverVersionData->versionResource); always check Resource
	versionCodeStat = (localVersionData->versionCode < serverVersionData->versionCode) ? LESS : EQUAL;


	CompareStat localAppCompareVerAppStat = compareVersion(localVersionData->versionApp, serverVersionData->versionApp);

	CompareStat userAppCompareVerAppStat = compareVersion(CCUserDefault::sharedUserDefault()->getStringForKey("UserDefaultAppVer", "1.0.0"), serverVersionData->versionApp);
	/*
	local compare server

	versionApp      versionCode      versionResource      resourceUpdate      AppStore update
	EQUAL            EQUAL              EQUAL                NO                   NO

	EQUAL            EQUAL              LESS                YES                   NO

	EQUAL            LESS             not care               NO                  YES

	LESS             EQUAL            not care              YES                   NO

	LESS             LESS             not care               NO                  YES
	*/

	int result = 0; // result = 0  not update, result = 1 resourse update, result = 2 appStore update 
	
	//服务器APP版本低于之前存储的版本,用存储的APP版本号请求Server.cfg
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		//WINDOWS不檢查APP跟資源版本
		versionAppCompareStat = EQUAL;
		versionResourceStat = EQUAL;
		//localAppCompareVerAppStat = EQUAL;
		//std::string configfile = GamePlatformInfo::getInstance()->getPlatVersionName();
		//std::string versionCfgPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(configfile.c_str());
		//SeverConsts::getInstance()->_parseConfigFile(versionCfgPath);
	#endif
	

    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		if (userAppCompareVerAppStat == LESS && CCUserDefault::sharedUserDefault()->getBoolForKey("IsUseUserDefaultAppVer", false))
		{
			CCUserDefault::sharedUserDefault()->setBoolForKey("IsUseUserDefaultAppVer", true);
			SeverConsts::getInstance()->setVersion(CCUserDefault::sharedUserDefault()->getStringForKey("UserDefaultAppVer", "1.0.0"));
			std::string configfile = GamePlatformInfo::getInstance()->getPlatVersionName();
			std::string versionCfgPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(configfile.c_str());
			SeverConsts::getInstance()->_parseConfigFile(versionCfgPath);

		}else
		{
			CCUserDefault::sharedUserDefault()->setBoolForKey("IsUseUserDefaultAppVer", false);
		}
	#endif

	if (localAppCompareVerAppStat == HIGH)//本地App版本号  高于服务器版本号 不更新 只有审核的包才会出现这种情况
	{
		#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		//Android审核服 true走正常的审核逻辑   false下载资源
		//bool mIsNormalLogin = StringConverter::parseBool(VaribleManager::Get()->getSetting("IsNeedDownResForAndroid", "", "false"), true);
		int isCloseUpdate = StringConverter::parseInt(VaribleManager::Get()->getSetting("IsCloseR18"), 0);
		if (isCloseUpdate == 1)
		{
			result = 0;
		}
		else if (versionResourceStat == LESS)
		{
			CCUserDefault::sharedUserDefault()->setStringForKey("UserDefaultAppVer", localVersionData->versionApp);//当前APP版本大于服务器版本号时存储到本地
			CCUserDefault::sharedUserDefault()->setBoolForKey("IsUseUserDefaultAppVer", true);//用本地大版本号请求服务器列表
			SeverConsts::getInstance()->setVersion(localVersionData->versionApp);
			std::string configfile = GamePlatformInfo::getInstance()->getPlatVersionName();
			std::string versionCfgPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(configfile.c_str());
			SeverConsts::getInstance()->_parseConfigFile(versionCfgPath);
			result = 1;
		}
		else if (versionResourceStat == EQUAL)
		{
			result = 0;
		}

		#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		     result = 0;
		#endif
	}
	else if (versionCodeStat == EQUAL && versionAppCompareStat == EQUAL && versionResourceStat == EQUAL)
	{
		result = 0;
	}
	else if (versionCodeStat == EQUAL && versionAppCompareStat == EQUAL && versionResourceStat == LESS)//APP版本一致，资源版本低 更新资源
	{
		result = 1;
	}
	else if (versionCodeStat == EQUAL && versionAppCompareStat == LESS)//APP版本不一致
	{
		result = 2;
	}
	else if (versionCodeStat == LESS && versionAppCompareStat == EQUAL) //versionCode 暂时不用
	{
		result = 0;
	}
	else if (versionCodeStat == LESS && versionAppCompareStat == LESS)
	{
		result = 2;
	}
	//result = 2;
	CCLOG("compareVersion result is %d", result);
	cocos2d::CCLog("compareVersion result is %d", result);
	ostringstream   ostr;
	ostr << "result is : " << result;
	string strLog = ostr.str();

	CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION), libOS::getInstance()->getDeviceInfo(),libOS::getInstance()->getDeviceID(), localVersionData->versionResource, strLog);

	if (result == 0)
	{
		//GamePrecedure::Get()->enterLoading();
		//加载plist
		//GamePrecedure::getInstance()->loadPlsit();
		//SeverConsts::Get()->start();
		//showAnnounce();
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
		
		//showLogin();
		//libPlatformManager::getPlatform()->login();
		//updateSeverName();
		return;
	}

	if (result == 1)
	{
	    checkNewAssets();
		//compareProjectAsset();
		return;
	}
	//本地App版本低
	if (result == 2)//跳转商店开关是开着的 弹提示跳转商店
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
		else//跳转商店开关是关着的
		{
			if (versionResourceStat == LESS)//资源版本不一致 更新资源
			{
				checkNewAssets();
			}
			else  //资源版本一致不更新
			{
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
			}
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
	else if (SeverConsts::Get()->IsKUSO()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlKUSO);
	}
	else if (SeverConsts::Get()->IsJSG()) {
		libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlJSG);
	}
	else {
		libOS::getInstance()->openURL(serverVersionData->AndroidStoreURL);
	}
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	libPlatformManager::getInstance()->getPlatform()->updateApp(serverVersionData->IOSAppStoreURL); 
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
	CCLog("hotUpdate download  url: %s    : filename : %s ", url.c_str(), filename.c_str());
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.compare((*it)->url) == 0)
		{
			CCLog("hotUpdate download  url pushBack to alreadyDownloadData: %s    : filename : %s ", url.c_str(), filename.c_str());
			alreadyDownloadData.push_back(url);
			// TODO 下載完先解壓縮
			bool value = AssetsManagerEx::getInstance()->uncompress((*it)->savePath, (*it)->stroge);
			CCLog("downloaded uncompress: %s", ((*it)->name).c_str());
			// delete file
			remove((*it)->savePath.c_str());
			// TODO 解壓縮後更新projectManifest 避免重新下載
			//assetData* data = new assetData();
			//data->name = (*it)->name;
			//data->md5 = (*it)->md5;
			//data->crc = (*it)->crc.c_str();
			//data->size = (*it)->size;
			//localProjectAssetData->assetDataMap.insert(std::make_pair((*it)->name, data));
			//auto localIt = localProjectAssetData->assetDataMap.find((*it)->name);
			//CCLog("downloaded size1 %d", (*it)->size * 1000);
			//CCLog("downloaded size2 %d", localIt->second->size * 1000);
			//localIt->second->size = (*it)->size;
			//CCLog("downloaded crc1 %s", (*it)->crc.c_str());
			//CCLog("downloaded crc2 %s", localIt->second->crc.c_str());
			//localIt->second->crc = (*it)->crc;
			//CCLog("downloaded md51 %s", (*it)->md5.c_str());
			//CCLog("downloaded md52 %s", localIt->second->md5.c_str());
			//localIt->second->md5 = (*it)->md5;
			//CCLog("downloaded 5");
			//writeProjectManifest();
		}
	}

	if (url.find(versionManifestName) != url.npos)
	{
		downVersionTimes = 0; 
		//读取检测版本 下载下来的 versionTmp.manifest文件  跟本地的 version.mainfest 作比较
		if (versionStat  == CHECK_VERSION)
		{
			unsigned long filesize;
			unsigned	char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(filename.c_str()).c_str(), "rt", &filesize, 0, nullptr);
			getVersionData(serverVersionData, pBuffer);
			cocos2d::CCLog("LoadingFrame::compareVersion");
			compareVersion();
		}
	}
	if (url.find(projectManifestName) != url.npos)
	{
		downProjectTimes = 0;
	}
}
void LoadingFrame::downloadFailed(const std::string& url, const std::string &filename)
{
	CCLOG("hotUpdate downloadFailed  url: %s    : filename : %s ", url.c_str(), filename.c_str());
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.compare((*it)->url) == 0)
		{
			CCLOG("hotUpdate downloadFailed  url push_back to loadFailData: %s    : filename : %s ", url.c_str(), filename.c_str());
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
			std::string downloadVerUrl = localVersionData->remoteVersionUrl + "/" + versionManifestName + "?" + "time=" + _time->m_sString;
			CurlDownload::Get()->downloadFile(downloadVerUrl, saveVersionPath);
		}
		else
		{
			hidLoadingAniPage();
			setTips(m_updateVersionTips->checkFailTxT);
			showFailedMessage(m_updateVersionTips->checkFailTxT,100);

		}
	}
	if (url.find(projectManifestName) != url.npos)
	{
		if (downProjectTimes < 10)//下载失败之后 允许再尝试10次
		{
			downProjectTimes++;

			std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
			//下载最新的 peojectManifest 文件
			std::string saveProjrctPath = writeRootPath + versionPath + "/" + projectManifestName;
			std::string downloadProjectUrl = localVersionData->packageUrl + "/" + localVersionData->versionResource + "/" + projectManifestName + "?version=" + serverVersionData->versionResource;
			CurlDownload::Get()->downloadFile(downloadProjectUrl, saveProjrctPath);
		}
		else
		{
			hidLoadingAniPage();
			setTips(m_updateVersionTips->checkProjectFailTxT);
			showFailedMessage(m_updateVersionTips->checkProjectFailTxT, 100);
		}

	}
}

void LoadingFrame::onAlreadyDownSize(unsigned long size)
{
	//CCLOG("hotUpdate onAlreadyDownSize  size: %d", (int)size);
	currentFileLoadSize = float(size);
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
		//CCNode* sever = dynamic_cast<CCNode*>(getVariable("mPersentage"));
		if (persentage > 1.0f)
			persentage = 1.0f;
		if (persentage <= 0.00f)
			persentage = 0.01f;
		if (persentage > lastPercent)
		{
			_ProgressTimerNode->setPercentage(persentage * 100);
			//_ProgressTimerNode->runAction(CCProgressFromTo::create(0.2f, lastPercent*100, persentage*100));
			CCLabelTTF* sever = dynamic_cast<CCLabelTTF*>(getVariable("mPersentageTxt"));
			char perTxt[64];
			if (persentage >= 1.0f) {
				sprintf(perTxt, "100%   %s", sizeTip.c_str());
				sever->setString(sizeTip.c_str());
			}
			else {
				sprintf(perTxt, "%d%%   %s", (int)(persentage * 100), sizeTip.c_str());
				//CCLog("showPersent : %s", sizeTip.c_str());
				if (sever)
					sever->setString(perTxt);
			}
			

			lastPercent = 0.0f;// persentage;

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
			CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION), libOS::getInstance()->getDeviceInfo(), libOS::getInstance()->getDeviceID(), localVersionData->versionResource, "get ServerVersion fail");
		}
		else if (strcmp(response->getHttpRequest()->getTag(), "serverProjectAsset") == 0 && downVersionTimes < 10)
		{
			getServerProjectAssets();

			CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION), libOS::getInstance()->getDeviceInfo(), libOS::getInstance()->getDeviceID(), localVersionData->versionResource, "get ServerProject fail");
		}
		cocos2d::CCLog("hotUpdate: onHttpRequestCompleted fail : %s", response->getHttpRequest()->getTag());
		return;
	}

	int codeIndex = response->getResponseCode();
	if (codeIndex < 0)
	{
		cocos2d::CCLog("hotUpdate : codeIndex: %d", codeIndex);
		ostringstream   ostr;
		ostr << "hotUpdate : codeIndex: " << codeIndex;
		string strLog = ostr.str();
	
		CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION), libOS::getInstance()->getDeviceInfo(), libOS::getInstance()->getDeviceID(), localVersionData->versionResource, strLog);

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
	}
	else if (strcmp(tag, serverProjectAssetTag) == 0)
	{
		cocos2d::CCLog("hotUpdate : compareProjectAsset");
		getProjectAssetData(serverProjectAssetData, unsignedContent);
		compareProjectAsset();
	}
	/*else if (strcmp(tag, serverCfgTag) == 0)
	{
		getServerCfg(unsignedContent);
		compareProjectAsset();
	}*/

}
void LoadingFrame::getServerProjectAssets()
{
	if (!localVersionData)
	{

		return;
	}

	//std::string url = localVersionData->packageUrl + "/" + localVersionData->versionResource + "/" + projectManifestName + "?" + "version=" + serverVersionData->versionResource;
	std::string url = localVersionData->packageUrl + "/" + projectManifestName + "?" + "version=" + serverVersionData->versionResource;
	auto request = new CCHttpRequest();
	request->setUrl(url.c_str());
	request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
	//request->setResponseCallback(this, httpresponse_selector(UpdateVersion::onHttpRequestCompleted));
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

		if (serverVersionData)
		{
			std::string ver = "Ver" + serverVersionData->versionResource;
			setVersion(ver);
		}

		remove(versionPathTmp.c_str());

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
		//showLogin();
		//libPlatformManager::getPlatform()->login();
		//updateSeverName();

		//GamePrecedure::Get()->enterLoading();
		return;
	}

	//CCB_FUNC(this, "mUpdateBtnNode", cocos2d::CCNode, setVisible(true));
	cocos2d::CCLog("compareProjectAsset 3");
	ostringstream   ostr;
	ostr << "compareProjectAsset need update fileSzie: " << needUpdateAsset.size();
	string strLog = ostr.str();
	CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION), libOS::getInstance()->getDeviceInfo(), libOS::getInstance()->getDeviceID(), localVersionData->versionResource, strLog);

	if (m_updateVersionTips)
	{
		//setActionBtnTxt(m_updateVersionTips->updateBtnTxT);
		cocos2d::CCLog("compareProjectAsset 4");
		downSize /= 1024;
		downSize = (downSize > 1) ? downSize : 1;
		const char* size = CCString::createWithFormat("%d", downSize)->getCString();

		std::string needUpdateAsset = m_updateVersionTips->newAssetNeedUpdateTxT + std::string(size) + "M";
		setTips(needUpdateAsset);
		libOS::getInstance()->showMessagebox(needUpdateAsset, 100);
		loginReport(REPORT_STEP::REPORT_STEP_START_DOWNLOAD_PATCH);
	}
}
void LoadingFrame::getProjectAssetData(ProjectAssetData* projectAssetData, unsigned char* content, bool isLocal, unsigned char* contentLocal)
{
	Json::Reader reader;
	Json::Value value;
	Json::Reader readerLocal;
	Json::Value valueLocal;

	CCLOG("hotUpdate getProjectAssetData: %s", content);

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
		
		}
		CCLOG("hotUpdate getProjectAssetData: fail");
		return;
	}
	if (contentLocal){
		CCLOG("hotUpdate getProjectAssetDataLocal: %s", contentLocal);

		const char* constContentLocal = (const char*)(char*)contentLocal;

		bool retLocal = reader.parse(constContentLocal, valueLocal);

		if (!retLocal)
		{
			CCLOG("hotUpdate getProjectAssetDataLocal: fail");
			return;
		}
	}

	projectAssetData->isLoadSuccess = true;
	Json::Value valueTrue;
	if (contentLocal){
		Json::Value timeJson = value["time"];
		Json::Value timeJsonLocal = valueLocal["time"];
		double time = timeJson.asDouble();
		double timeLocal = timeJsonLocal.asDouble();
		if (time >= timeLocal){
			valueTrue = value;
		}
		else{
			valueTrue = valueLocal;
			std::string hotUpdatePath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath() + downLoadSavePath + "/";
			cocos2d::CCFileUtils::sharedFileUtils()->removeDirectory(hotUpdatePath);
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
			data->size = unit["size"].asInt();
			data->time = valueTrue["time"].asInt();
			//data->size = 40.44;
			projectAssetData->addAssetData(data);
		}
	}
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
	CCLOG("hotUpdate : UpdateAssetFromServer");

	ostringstream   ostr;
	ostr << "UpdateAssetFromServer : " << needUpdateAsset.size();
	string strLog = ostr.str();
	
	CLogReport::Get()->webReportLog(CLogReport::Get()->getReportType(EnumReportType::CHKVERSION), libOS::getInstance()->getDeviceInfo(), libOS::getInstance()->getDeviceID(), localVersionData->versionResource, strLog);


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

	//进度条
	setWaitGameNodeVisible(true);
	setEnterServerListVisible(false);
	setEnterGameNodeVisible(false);
	setEnterBCNodeVisible(false);
	setLogoutBtnVisible(false);
	setLogoutNodeVisible(false);

	showPersent(0, std::string(""));
	CCB_FUNC(this, "mPersentageNode", cocos2d::CCNode, setVisible(true));

	std::string packageUrl = serverVersionData->packageUrl;
	std::string writeablePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		std::string assetUrl = packageUrl + "/" + (*it)->name + "?" + "version=" + serverVersionData->versionResource;
		std::string writePath = writeablePath + "/" + downLoadSavePath + "/" + (*it)->name;

		(*it)->url = assetUrl;
		(*it)->savePath = writePath;
		(*it)->stroge = writeablePath + "/" +  downLoadSavePath + "/";
		downTotalSize += (*it)->size;
		std::string crc = (*it)->crc;
		std::string md5 = (*it)->md5;
		unsigned short crcCmp = atoi((char*)crc.c_str());
		//CurlDownload::Get()->downloadFile(assetUrl, writePath, crcCmp);
		CurlDownload::Get()->downloadFile(assetUrl, writePath, md5);
		//CurlDownload::Get()->downloadFile(assetUrl, writePath);
	}
}

void LoadingFrame::ResumeUpdateAsset()
{
	CCLOG("hotUpdate : ResumeUpdateAsset");

	versionStat = LOADING_ASSETS;

	std::string packageUrl = serverVersionData->packageUrl;
	std::string writeablePath = CCFileUtils::sharedFileUtils()->getWritablePath();
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		std::string assetUrl = packageUrl + "/" + (*it)->name + "?" + "version=" + serverVersionData->versionResource;
		if (loadFailData.find(assetUrl) != loadFailData.end())
		{
			std::string writePath = writeablePath + "/" + downLoadSavePath + "/" + (*it)->name;

			(*it)->url = assetUrl;
			(*it)->savePath = writePath;
			(*it)->stroge = writeablePath + "/" + downLoadSavePath + "/";
			downTotalSize += (*it)->size;
			std::string crc = (*it)->crc;
			unsigned short crcCmp = atoi((char*)crc.c_str());
			CurlDownload::Get()->downloadFile(assetUrl, writePath, crcCmp);
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

	//if ((uin != "") && (pass != ""))
	//{
		libPlatformManager::getPlatform()->setLoginName(uin);
		GamePrecedure::getInstance()->setDefaultPwd(pass);
		showLoginUser(uin, pass);
	//}
	//else
	//{
	//	showSevers(true);
	//}
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
			//mConfirmPage->refresh();
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
	CCLog("writeProjectManifest");
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
		assets.append(data);
		root["time"] = it->second->time;
	}
	root["assets"] = assets;
	CCLog("writeProjectManifest : %s", root.asString().c_str());
	//
	std::string out = root.toStyledString();
	std::cout << out << std::endl;
	fout << out << std::endl;
}
