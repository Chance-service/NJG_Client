
#include "stdafx.h"

#include "GamePrecedure.h"

#include "StateMachine.h"
#include "UpdateVersion.h"
#include "LoadingFrame.h"
#include "LogoFrame.h"
#include "MainFrame.h"
#include "cocos2d.h"
#include "CCScheduler.h"
#include "Language.h"
#include "CCBManager.h"
#include "CCBScriptContainer.h"
#include "PacketManager.h"
#include "TimeCalculator.h"
#include "SeverConsts.h"
#include "CharacterConsts.h"

#include "DataTableManager.h"
#include "waitingManager.h"
#include "SoundManager.h"
#include "RestrictedWord.h"
//#include "ThreadSocket.h"
#include "inifile.h"
#include "CustomPage.h"
#include "GamePlatform.h"
#include "GamePlatformInfo.h"
#include "LoginPacket.h"

#include "script_support/CCScriptSupport.h"
#include "CCLuaEngine.h"
#include "Gamelua.h"
#include "pb.h"
#include "libOS.h"
#include "GameNotification.h"
#include "lua_cjson.h"
#include "MessageBoxPage.h"
#include "GamePacketManager.h"
#include "ConfirmPage.h"
#include "LogReport.h"

#include "crypto/CCCrypto.h"

#include <iostream>
#include <sstream>
#include <iomanip>
//
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <jni.h>
#include "..\..\cocos2dx\platform\android\jni\JniHelper.h"
#include "../../cocos2dx/platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

//// 导入头文件 CrashReport.h 和 BuglyLuaAgent.h 2020.4.24 lin close
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
//#include "Bugly/CrashReport.h"
//#include "Bugly/lua/BuglyLuaAgent.h"       
//#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//#include "Bugly/CrashReport.h"
//#include "Bugly/lua/BuglyLuaAgent.h"
//#else
//
//#endif

//
#ifdef PROJECT_RYUK_JP
#include "RyukPlatformListener.h"
static RyukPlatformListener* ryukPlatformListener = NULL;
#endif

using namespace cocos2d;
using namespace cocos2d::extension;
using namespace std;

#define PRELOAD(name, count) \
	{static int preloadCount = 0; \
	int preloadMax = count; \
	if(preloadCount<preloadMax){ \
	CCBContainer* ccb = CCBManager::Get()->createAndLoad(name); \
	ccb->retain(); \
	ccblist.push_back(ccb); \
	preloadCount++;}}

//--begin xinzheng 2013-12-12
static ConfigFile* st_pImgsetCfg = NULL;
//--end

static float fLoginJiShiSeconds = 0.f;

static std::list<CCBContainer*> ccblist;
static ResourceConfigItem* win32ResourceCfg = NULL;
void GamePrecedure::init()
{
	if(mInitialized)
        return;

	int currType = getCurrentLanguageType();
	//GamePlatformInfo::getInstance()->registerPlatform();
	PacketManager::Get()->registerPacketHandler(ASSEMBLE_FINISH_S,this);
	TimeCalculator::Get()->init();
	int userType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
	switch (userType) {
	case kLanguageChinese:
		Language::Get()->init("Lang/Language.lang");
		break;
	case kLanguageCH_TW:
		Language::Get()->init("Lang/LanguageTW.lang");
		break;
	default:
		Language::Get()->init("Lang/Language.lang");
		break;
	}
	setUpdateNodeHandle(updateCCBNode);
#ifdef PROJECT_RYUK_JP
    ryukPlatformListener = new RyukPlatformListener();
#endif
    
	m_pScheduler = CCDirector::sharedDirector()->getScheduler();
	m_pScheduler->retain();
	m_pScheduler->scheduleUpdateForTarget(this, 0, false);
    

    mInitialized = true;

	mReadTables = false;


	std::string reportUrl = VaribleManager::Get()->getSetting("DatareportUrl", "", "https://1jdata.tigerto.com");
	CLogReport::Get()->init(reportUrl);

	CCLog("*************GamePrecedure::init finished****************");
}

void GamePrecedure::startupreport()
{
	try
	{
		std::string url = VaribleManager::Get()->getSetting("DatareportUrl", "", "https://1jdata.tigerto.com");
		//操作
		url.append("/init?");
	
		//类型
		std::string devicetype = libOS::getInstance()->getPlatformInfo();
		std::string oldstr = "#";
		std::string newstr = "";
		

		//替换特殊字符串
		while (true)   {
			string::size_type   pos(0);
			if ((pos = devicetype.find(oldstr)) != string::npos)
				devicetype.replace(pos, oldstr.length(), newstr);
			else   
				break;
		}

		//devicetype.replace('#',' ');
		url.append("channel=" + devicetype);
		//设备号
		std::string deviceid = libOS::getInstance()->getDeviceID();
		url.append("&deviceId=" + deviceid);
		//版本

		std::string version = libOS::getInstance()->getGameVersion();
		url.append("&gameVersion=" + version);

   		std::string signStr = devicetype + deviceid + version + "yjReport";

		unsigned char buffer[CCCrypto::MD5_BUFFER_LENGTH];

		CCCrypto::MD5((void*)signStr.c_str(), strlen(signStr.c_str()), buffer);

		std::ostringstream oss;
		oss << std::hex;
		oss << std::setfill('0');
		for (int i = 0; i < CCCrypto::MD5_BUFFER_LENGTH; i++)
		{
			unsigned char c = buffer[i];
			oss << std::setw(2) << (unsigned int)c;
		}

		url.append("&sign=" + oss.str());

		//数据只管发不做返回处理
		auto request = new CCHttpRequest();
		request->setUrl(url.c_str());
 		request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
		CCHttpClient::getInstance()->send(request);

		request->release();
	}
	catch (...)
	{
		CCLog("URL REQUEST IS NOT  REACH");
	}
	

	
}

void GamePrecedure::sendhttpRequest(const std::string aurl)//数据只管发不做返回处理
{
	auto request = new CCHttpRequest();
	request->setUrl(aurl.c_str());
	request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
	CCHttpClient::getInstance()->send(request);

	request->release();
}

void GamePrecedure::enterLogoMovie()
{
	if(!mLogoFrame)
	{
		mLoadFrameCcbiPreLoad = CCBManager::Get()->createAndLoad("LoadingFrame.ccbi");
		mLogoFrame = new LogoFrame;
	}

	if(!m_pStateMachine)
		m_pStateMachine = new StateMachine<GamePrecedure>(this);

	m_pStateMachine->ChangeState(mLogoFrame);
}

void GamePrecedure::reEnterLoadingForEnterMate()/*韩国-收到SDK反馈后调用此函数*/
{//client->logout->android->sdk->callback->reEnterLoadingForEnterMate
	//CCLog("*********************reEnterLoadingForEnterMate");
	mInLoadingScene = true;
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_EnterMainScene", std::string("false"));
	fLoginJiShiSeconds = 0.f;	
	mLoginPacketsReceivedCount = 0;
	mIsReEnterLoadingFrame = true;


	LoginPacket::Get()->setEnabled(false);
	PacketManager::Get()->disconnect();
	GamePrecedure::Get()->setLoginAssemblyFinished(false);
	/*
	MainFrame* mainFrame = dynamic_cast<MainFrame*>(CCBManager::Get()->getPage("MainFrame"));
	if (mainFrame)
	{
		CCLOG("mainFrame frame mScene retainCount:%d",mainFrame->getRootSceneNode()->retainCount());
		gameSnapshot();
	}
	*/
	//重登陆时，暂时注释掉了清空所有登录信息，后期有可能会加，
	//ServerDateManager::Get()->clearLoginAllHandler();
	g_AppDelegate->purgeCachedData();
	//
	reset();
	enterLoading();
}
//针对韩国处理我们自己游戏的logout,只是回到游戏的登录选服界面，不出现kakao的LoginView
void GamePrecedure::reEnterMateLogout()
{
	std::string strPlatformName = getPlatformName();
	//CCLog("*********************reEnterMateLogout");
	mInLoadingScene = true;
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_EnterMainScene", std::string("false"));
	fLoginJiShiSeconds = 0.f;
	mLoginPacketsReceivedCount = 0;
	mIsReEnterLoadingFrame = true;

	LoginPacket::Get()->setEnabled(false);
	PacketManager::Get()->disconnect();
	GamePrecedure::Get()->setLoginAssemblyFinished(false);
	/*
	MainFrame* mainFrame = dynamic_cast<MainFrame*>(CCBManager::Get()->getPage("MainFrame"));
	if (mainFrame)
	{
	CCLOG("mainFrame frame mScene retainCount:%d",mainFrame->getRootSceneNode()->retainCount());
	gameSnapshot();
	}
	*/
	//ServerDateManager::Get()->clearLoginAllHandler();
	g_AppDelegate->purgeCachedData();
	//
	reset();
	enterLoading();
#ifdef PROJECT_ENTERMATE
    libOS::getInstance()->reEnterGameGetServerlistForKakao();
#endif
}

void GamePrecedure::reEnterLoading()
{
#ifdef PROJECT_ENTERMATE
	//CCLog("*********************reEnterLoading____");
    mInLoadingScene = true;
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_EnterMainScene", std::string("false"));
    fLoginJiShiSeconds = 0.f;
    mLoginPacketsReceivedCount = 0;
    mIsReEnterLoadingFrame = true;
    
    libOS::getInstance()->reEnterLoading();
    LoginPacket::Get()->setEnabled(false);
    PacketManager::Get()->disconnect();
    GamePrecedure::Get()->setLoginAssemblyFinished(false);
    g_AppDelegate->purgeCachedData();
    reset();
    enterLoading();
#else
	std::string strPlatformName = getPlatformName();
	libOS::getInstance()->reEnterLoading();
	if(-1 != strPlatformName.find("entermate"))
	{//韩国的logout，显示登录界面 需收到SDK的反馈消息后 才做显示。
		return ;
	}
	//CCLog("*********************reEnterLoading____");
	mInLoadingScene = true;
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_EnterMainScene", std::string("false"));
	fLoginJiShiSeconds = 0.f;	
	mLoginPacketsReceivedCount = 0;
	mIsReEnterLoadingFrame = true;
	

	LoginPacket::Get()->setEnabled(false);
	PacketManager::Get()->disconnect();
	GamePrecedure::Get()->setLoginAssemblyFinished(false);
	/*
	MainFrame* mainFrame = dynamic_cast<MainFrame*>(CCBManager::Get()->getPage("MainFrame"));
	if (mainFrame)
	{
		CCLOG("mainFrame frame mScene retainCount:%d",mainFrame->getRootSceneNode()->retainCount());
		gameSnapshot();
	}
	*/
	//ServerDateManager::Get()->clearLoginAllHandler();
	g_AppDelegate->purgeCachedData();
	//
	//reset();
	enterLoading();

#endif
}

void GamePrecedure::reEnterGame()
{
	libOS::getInstance()->reEnterLoading();

	mInLoadingScene = true;
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_EnterMainScene", std::string("false"));
	fLoginJiShiSeconds = 0.f;
	mLoginPacketsReceivedCount = 0;
	//mIsReEnterLoadingFrame = true;

	LoginPacket::Get()->setEnabled(false);
	PacketManager::Get()->disconnect();
	GamePrecedure::Get()->setLoginAssemblyFinished(false);
	g_AppDelegate->purgeCachedData();

	enterLoading();
}

void GamePrecedure::enterUpdateVersion()
{
    if (!mUpdateVersion)
    {
        mUpdateVersion = dynamic_cast<UpdateVersion*>(CCBManager::Get()->getPage("UpdateVersion"));
        mUpdateVersion->retain();
    }
    
    if (!m_pStateMachine)
        m_pStateMachine = new StateMachine<GamePrecedure>(this);
    
    m_pStateMachine->ChangeState(mUpdateVersion);
}

void GamePrecedure::enterLoading()
{
	if(!mLoadingFrame)
    {
        //mLoadingFrame =  LoadingFrame::create();
		mLoadingFrame = dynamic_cast<LoadingFrame*>(CCBManager::Get()->getPage("LoadingFrame"));
        mLoadingFrame->retain();
    }
    
	if(!m_pStateMachine)
		m_pStateMachine = new StateMachine<GamePrecedure>(this);
	
    m_pStateMachine->ChangeState(mLoadingFrame);

    
    if(mMainFrame)
	{		
		mMainFrame->release();
		mMainFrame = 0;
	}
}


void GamePrecedure::enterMainMenu()
{
	gotoMainScene = true;
    
}

void GamePrecedure::enterInstruction(int id)
{
}

void GamePrecedure::enterGame()
{
}

void GamePrecedure::exitGame()
{
	if(m_pStateMachine)
	{
		//m_pStateMachine->CurrentState()->Exit(this);
		delete m_pStateMachine;
		m_pStateMachine = 0;
	}
	if (mLoadingFrame)
	{
		mLoadingFrame->release();
		if (mLoadFrameCcbiPreLoad)
		{
			mLoadFrameCcbiPreLoad->release();
			mLoadFrameCcbiPreLoad = NULL;
		}
		mLoadingFrame = NULL;
	}
	if(mMainFrame)
	{
		mMainFrame->release();
		mMainFrame = 0;
	}
	PacketManager::Get()->disconnect();
	if(m_pScheduler)
	{
		m_pScheduler->unscheduleUpdateForTarget(this);
		m_pScheduler->release();
		m_pScheduler = 0;
	}
	if (win32ResourceCfg)
	{
		delete win32ResourceCfg;
	}
}

static bool sbgo = false;


void GamePrecedure::update( float dt )
{
	if(m_logoutCallback)
	{
		m_logoutCallback = false;
		GamePrecedure::getInstance()->reEnterLoadingForEnterMate();
	}
    //if ( m_pBulletinMgr )
    //{
    //    m_pBulletinMgr->update(dt);
   // }
    
	mFrameTime = dt;
	mTotalTime += dt;
	static float durationTime=0;
	durationTime+=dt;
	if(durationTime>1.0f)
	{
		durationTime -=1.0f;
		//++mServerTime;
	}
	m_pStateMachine->Update();


	PacketManager::Get()->update(dt);


	MessageManager::Get()->update();
	waitingManager::Get()->update(dt);
	TimeCalculator::Get()->update();
	LoginPacket::Get()->update(dt);	

	//显示服务器名称

	if (mLoadingFrame&&(mLoadingFrame->getUpdateServerState()) && SeverConsts::Get()->checkUpdateInfo() == SeverConsts::CS_OK)
	{
		

		mLoadingFrame->updateSeverName();
		mLoadingFrame->setUpdateServerState(false);
	}

	// 处理logoframe
	if (mLogoFrame)
	{
		if (mLogoFrame->isLogoFinished())
		{
			enterLoading();
			delete(mLogoFrame);
			mLogoFrame = 0;
		}
	}

	if (mInLoadingScene)
	{		
		if (mStartLoginJiShi)
		{
			fLoginJiShiSeconds += dt;
			if (fLoginJiShiSeconds > 15.0f)
			{
				PacketManager::Get()->_boardcastReceiveFailed();
				mStartLoginJiShi = false;
				mLoadingFrame->showEnter();
//				libOS::getInstance()->setWaiting(false);
                mLoadingFrame->hidLoadingAniPage();
				//
				//阻止ontimeout、sendfailed、receivefailed、packeterror等_failedPakcage 发起reconnect
				//超时后有赖玩家手动重新点击进入游戏
				LoginPacket::Get()->setEnabled(false);
				PacketManager::Get()->disconnect();
				//
			}
			else
			{
				int percent = 90 + mLoginPacketsReceivedCount*70 / (mLoginRequestPacketsTotalCount);
				CCLOGERROR("LoginingPackets:%d%%	%f		%d", percent, fLoginJiShiSeconds, mLoginPacketsReceivedCount);
				mLoadingFrame->showLoginingInPercent(percent);
//				libOS::getInstance()->setWaiting(true);
                mLoadingFrame->showLoadingAniPage();
				mLoadingFrame->setPosLoadingAniPage();
			}
		}
		else
		{
			fLoginJiShiSeconds = 0.f;
		}
	}
	
	bool preparePacketDone = false;
	//m_loginPacketAssemblySuccess  代表收到了服务器登录收尾的AssemblyFinish包
	//mHasMainRole 表示新手还没有角色时，如果没有角色，需要进入选角色页面
	preparePacketDone =(m_loginPacketAssemblySuccess | (!mHasMainRole));

	if(gotoMainScene && preparePacketDone && mReadTables && sbgo && mInitLuaDone)
	{
		//
		PacketManager::Get()->removePacketHandler(this);
		LoginPacket::Get()->setEnabled(true);

		while(!ccblist.empty())
		{
			ccblist.front()->release();
			ccblist.pop_front();
		}

		gotoMainScene = false;
		mInLoadingScene = false;
		mStartLoginJiShi = false;
		mGotHeartBeatTime = -10.f;//阻止第一次不应该的生效
        libPlatformManager::getPlatform()->sendMessageG2P("G2P_EnterMainScene", std::string("true"));
        
		SeverConsts::Get()->exitServerConst();

		//打开开始界面耗时
		time_t t = time(0);
		char tmp[64];
		strftime(tmp, sizeof(tmp), "%Y/%m/%d %X", localtime(&t));
		CCLog("m_pStateMachine->ChangeState(mMainFrame) %s  ", tmp);

		/*
		AnnouncementPage.ccbi
		MainScene.ccbi
		OfflineBattleAccountPopUp.ccbi
		MainFrame.ccbi
		ArenaPage.ccbi
		BattlePage.ccbi
		EquipmentPage.ccbi
		EquipmentInfoPopUp.ccbi
		*/

		if(!mMainFrame)
			mMainFrame = dynamic_cast<MainFrame*>(CCBManager::Get()->getPage("MainFrame"));//MainFrame::create();
		if(mMainFrame)mMainFrame->retain();

		if(!m_pStateMachine)
			m_pStateMachine = new StateMachine<GamePrecedure>(this);
		m_pStateMachine->ChangeState(mMainFrame);

		time_t t1 = time(0);
		char tmp1[64];
		strftime(tmp1, sizeof(tmp1), "%Y/%m/%d %X", localtime(&t1));
		CCLog("m_pStateMachine->ChangeState(mMainFrame) end %s  ", tmp1);
		libOS::getInstance()->setWaiting(false);


#ifndef _CLOSE_MUSIC
		//CocosDenshion::SimpleAudioEngine::sharedEngine()->stopBackgroundMusic(true);
		//SoundManager::Get()->playGeneralMusic();
#endif


		if(mLoadingFrame)
		{
			mLoadingFrame->release();
			if (mLoadFrameCcbiPreLoad)
			{
				mLoadFrameCcbiPreLoad->release();
				mLoadFrameCcbiPreLoad = NULL;
			}
			mLoadingFrame = NULL;
		}

		g_AppDelegate->purgeCachedData();
	}
	else if (isInLoadingScene() && sbgo/*SeverConsts::Get()->checkUpdateInfo() == SeverConsts::CS_OK*/)
	{
		//
		//--begin xinzheng 2013-12-12
		/*static CCSpriteFrameCache * frameCache = CCSpriteFrameCache::sharedSpriteFrameCache();
		static ConfigFile cfg;
		if (st_pImgsetCfg == NULL)
		{
			cfg.load("Imageset.txt");
			st_pImgsetCfg = &cfg;
			frameCache->purgeSpriteFramesAndFileNames();
		}
		static ConfigFile::SettingsMapIterator itr = cfg.getSettingsMapIterator();
		if (itr.hasMoreElements())
		{
			std::string filename = itr.getNext();
			static int ic = 0;
			CCLOG("Imageset%d:%s", ++ic, filename.c_str());
			if (!filename.empty())
				frameCache->addSpriteFramesNameWithFile(filename.c_str());
		}
		else
		{
			sbgo = true;


		}*/
		//--end
		static int stCount = 0;
		++stCount;
		long mem = libOS::getInstance()->avalibleMemory();//取不准
		if (mem > 3 && sbgo /*&& mStartLoginJiShi*/)
		{
			if (stCount % 3 == 0)
			{
				/*
				得考虑ccbi加载的texture的大小，首次引用texture触发load，大图耗时
				尽量均匀分布耗时，注意不要某一帧特别耗时
				*/
				PRELOAD("MainFrame.ccbi", 1);
			}
			else if (stCount % 5 == 0)
			{
				PRELOAD("BattlePage.ccbi", 1);//8
			}
			else if (stCount % 7 == 0)
			{
				PRELOAD("MainScene.ccbi", 1);//8
				//PRELOAD("OfflineBattleAccountPopUp.ccbi", 1);
				//PRELOAD("GiftPopUp.ccbi",1);
			}
			else if (stCount % 8 == 0)
			{
				PRELOAD("BattleLead.ccbi", 1);
				PRELOAD("BattleBossEnemy.ccbi", 1);
				//PRELOAD("ArenaPage.ccbi", 1);//8
			}
			else if (stCount % 11 == 0)
			{
				PRELOAD("EquipmentPage_new.ccbi", 1);
				PRELOAD("EquipmentInfoPopUp.ccbi", 1);
			}
			else if (stCount % 13 == 0)
			{
				PRELOAD("BattleCritsNum01.ccbi", 1);
				PRELOAD("BattleCritsNum02.ccbi", 1);
				PRELOAD("BattleNormalNum01.ccbi", 1);
				PRELOAD("BattleNormalNum02.ccbi", 1);
				PRELOAD("BattleNormalNum03.ccbi", 1);
				PRELOAD("BattleDodgeNum.ccbi", 1);
				PRELOAD("BattleHealNum02.ccbi", 1);
				PRELOAD("BattleHealNum.ccbi", 1);
				PRELOAD("BattleHealNum04.ccbi", 1);
			}
		}
	}
	else if(!isInLoadingScene())
	{
		//发送心跳包
		//CCLog("sendhurtmessage");
		cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
		if(pEngine)
		{
			pEngine->executeGlobalFunctionByName("GamePrecedure_update",this,"GamePrecedure");
		}
		
		if (mGotHeartBeatTime > 10.f)
		{
			GamePacketManager::Get()->setNeedReConnect();
			mGotHeartBeatTime = 0;
		}
		
		if(mHeartbeatTime > 10.f)//心跳包
		{
			mHeartbeatTime = 0;
			HPHeartBeat info;
			//info.set_version(1);
			time_t nowstamp = time(0);
			info.set_timestamp(nowstamp);
			PacketManager::Get()->sendPakcet(HEART_BEAT,&info, false);
			mGotHeartBeatTime = 0;
		}
		else
			mHeartbeatTime += dt;
		
		mGotHeartBeatTime += dt;
		
	}
}


void GamePrecedure::loadCcbi()
{
	//加载CCBI测试
	/*
	AnnouncementPage.ccbi
	MainScene.ccbi
	OfflineBattleAccountPopUp.ccbi
	MainFrame.ccbi
	ArenaPage.ccbi
	BattlePage.ccbi
	EquipmentPage.ccbi
	EquipmentInfoPopUp.ccbi
	*/

	////loadCcbiFile("LoadingFramenew_jp.ccbi");
	//CCBManager::Get()->createAndLoad("AnnouncementPage.ccbi");
	//CCBManager::Get()->createAndLoad("MainScene.ccbi");
	//CCBManager::Get()->createAndLoad("OfflineBattleAccountPopUp.ccbi");
	//CCBManager::Get()->createAndLoad("MainFrame.ccbi");
	//CCBManager::Get()->createAndLoad("ArenaPage.ccbi");
	//CCBManager::Get()->createAndLoad("BattlePage.ccbi");
	//CCBManager::Get()->createAndLoad("EquipmentPage.ccbi");
	//CCBManager::Get()->createAndLoad("EquipmentInfoPopUp.ccbi");

	//CCBScriptContainer *pRet = CCBScriptContainer::create("MailPage");
	//CCBScriptContainer *pRet2 = CCBScriptContainer::create("MailBattlePage");

	//CCBManager::Get()->registerPage("MailPage", pRet);
	//CCBManager::Get()->registerPage("MailBattlePage", pRet2);

	//CCBManager::Get()->createAndLoad("AnnouncementPage.ccbi");

}

void GamePrecedure::loadPlsit()
{
	//读取Imageset  加载plist文件
	static CCSpriteFrameCache * frameCache = CCSpriteFrameCache::sharedSpriteFrameCache();
	static ConfigFile cfg;
	if (st_pImgsetCfg == NULL)
	{
		cfg.load("txt/Imageset.txt");
		st_pImgsetCfg = &cfg;
		frameCache->purgeSpriteFramesAndFileNames();
	}
	static ConfigFile::SettingsMapIterator itr = cfg.getSettingsMapIterator();
	while (itr.hasMoreElements())
	{
		std::string filename = itr.getNext();
		static int ic = 0;
		CCLOG("Imageset%d:%s", ++ic, filename.c_str());
		cocos2d::CCLog("Imageset%d:%s", ic, filename.c_str());
		if (!filename.empty()) {
			if (filename.find("i18n") != std::string::npos){
				int userType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
				int pos = std::string::npos;
				switch (userType) {
				case kLanguageChinese:
					pos = filename.find("i18n_cn");
					if (pos != std::string::npos){
						frameCache->addSpriteFramesNameWithFile(filename.c_str());
					}
					break;
				case kLanguageCH_TW:
					pos = filename.find("i18n_tw");
					if (pos != std::string::npos){
						frameCache->addSpriteFramesNameWithFile(filename.c_str());
					}
					break;
				default:
					pos = filename.find("i18n_cn");
					if (pos != std::string::npos){
						frameCache->addSpriteFramesNameWithFile(filename.c_str());
					}
					break;
				}
			}
			else {
				frameCache->addSpriteFramesNameWithFile(filename.c_str());
			}
		}
	}


	sbgo = true;

	//重新加载一次  本地化文件
	Language::Get()->clear();
	int userType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
	switch (userType) {
	case kLanguageChinese:
		Language::Get()->init("Lang/Language.lang");
		break;
	case kLanguageCH_TW:
		Language::Get()->init("Lang/LanguageTW.lang");
		break;
	default:
		Language::Get()->init("Lang/Language.lang");
		break;
	}
	

	/*if (itr.hasMoreElements())
	{
		std::string filename = itr.getNext();
		static int ic = 0;
		CCLOG("Imageset%d:%s", ++ic, filename.c_str());
		if (!filename.empty())
			frameCache->addSpriteFramesNameWithFile(filename.c_str());
	}*/
}

void GamePrecedure::initLuaEnv(){
	
	/*
			初始化和加载lua环境，这个很耗时！！！
		*/
		CCLOG("initLuas");
		if(!cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine())
		{
			cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
			cocos2d::CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);
			//bugly lua 注册
			//		// register lua exception handler with lua engine
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID ||CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

			//BuglyLuaAgent::registerLuaExceptionHandler(pEngine);

#endif
			pEngine->start();
			tolua_Gamelua_open(pEngine->getLuaStack()->getLuaState());
			luaopen_pb(pEngine->getLuaStack()->getLuaState());
			luaopen_cjson(pEngine->getLuaStack()->getLuaState());
			luaopen_cjson_safe(pEngine->getLuaStack()->getLuaState());

			pEngine->executeString("require \"main\"");

			pEngine->executeGlobalFunctionByName("GamePrecedure_preEnterMainMenu",this,"GamePrecedure");

			//修改lua堆栈大小
			int stack_size = 32;
			while (lua_checkstack(pEngine->getLuaStack()->getLuaState(), stack_size))
				stack_size <<= 1;

			CCLog("lua stack size: %d", stack_size >> 1);
		}

		mInitLuaDone = true;

}

void GamePrecedure::initLuaUpdateVersionEnv()
{
	CCLOG("initLuas");
		if(!cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine())
		{
			cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
			cocos2d::CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);
			pEngine->start();
			tolua_Gamelua_open(pEngine->getLuaStack()->getLuaState());
			luaopen_pb(pEngine->getLuaStack()->getLuaState());
			luaopen_cjson(pEngine->getLuaStack()->getLuaState());
			luaopen_cjson_safe(pEngine->getLuaStack()->getLuaState());

			pEngine->executeString("require \"HotUpdate\"");

			pEngine->executeGlobalFunctionByName("UpdateVersion",this,"GamePrecedure");

			//修改lua堆栈大小
			int stack_size = 32;
			while (lua_checkstack(pEngine->getLuaStack()->getLuaState(), stack_size))
				stack_size <<= 1;

			CCLog("lua stack size: %d", stack_size >> 1);
		}

		mInitLuaDone = true;
		//有可能需要在这里加入初始化lua 结束指令，发给后端，代表前段已经做好了准备工作，再由他们发assembly 消息。
}


float GamePrecedure::getFrameTime()
{
	return mFrameTime;
}

float GamePrecedure::getTotalTime()
{
	return mTotalTime;
}

static time_t s_gotoBackgroundTime = 0;

void GamePrecedure::enterForeGround()
{
	libOS::getInstance()->clearNotification();
	GameNotification::Get()->addNotification();

    std::string privateLogin = VaribleManager::Get()->getSetting("privatePause","","false");
    if(privateLogin!="true")
        libPlatformManager::getPlatform()->gamePause();
    
    time_t t = time(0);

	if (SeverConsts::Get()->getIsRedownLoadServer())//后台切前台如果服务器列表还是维护状态 执行重新下载服务器列表
	{
		SeverConsts::Get()->start();
	}

	if(!GamePrecedure::Get()->getUserKickedByServer())
	{
		CCLOG("GamePrecedure::enterForeGround->LoginPacket::forceSentPacket");
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		//if (getIsOnTempShortPauseJNI())
		{
			LoginPacket::Get()->setEnabled(true);
			LoginPacket::Get()->forceSentPacket();
		}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		// win32 不需要断线，方便debug
#else
		LoginPacket::Get()->setEnabled(true);
		LoginPacket::Get()->forceSentPacket();
#endif
		

		cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
		if(pEngine)
		{
			pEngine->executeGlobalFunctionByName("GamePrecedure_enterForeground",this,"GamePrecedure");
		}
	}
	else
	{
		MSG_BOX_LAN("@UserKickoutMsg");
	}
}

void GamePrecedure::preEnterMainMenu()
{
	CCLOG("preEnterMainMenu readTables");
	//
	time_t t = time(0);
	char tmp[64];
	strftime(tmp, sizeof(tmp), "%Y/%m/%d %X", localtime(&t));
	CCLog("READ table time %s  ", tmp);
	//fprintf(g_fpLog, "%s\t\t", tmp);
	//fprintf(g_fpLog, "%s\n", log);
	//fflush(g_fpLog);

	//CCLog("readTable startb  %X");
	readTables();
	CCLog("readTable end");




	time_t t1 = time(0);
	char tmp1[64];
	strftime(tmp1, sizeof(tmp1), "%Y/%m/%d %X", localtime(&t1));
	CCLog("READ table time end %s  ", tmp1);
	//
	CCLog("init lua environment");
	CCLog("init lua environment11111111");
	time_t t2 = time(0);
	char tmp2[64];
	strftime(tmp2, sizeof(tmp2), "%Y/%m/%d %X", localtime(&t2));
	CCLog("init lua environment %s  ", tmp2);
	initLuaEnv();


	time_t t3 = time(0);
	char tmp3[64];
	strftime(tmp3, sizeof(tmp3), "%Y/%m/%d %X", localtime(&t3));
	CCLog("init lua environment end %s  ", tmp3);//7s

	CCLog("init lua environment end");
	//ServerDateManager::Get()->clearLoginAllHandler();
	//
	/*std::list<REQUEST_PACKAGE>::iterator it = mRequestPackages.begin();
	for(; it != mRequestPackages.end(); ++it)
	{
		delete (*it).message;
	}
	mRequestPackages.clear();*/
	//
	//requestPackages();
	mStartLoginJiShi = true;
	mCanIntoGame = true;
	mLoginPacketsReceivedCount = 0;
	mLoginRequestPacketsTotalCount = AFTER_LOGIN_PACKET_NUM;
	//
	CCLog("preEnterMainMenu end");
}
std::string GamePrecedure::getServerNameById(int nServerId)
{
	std::string strServerName = "";
	SeverConsts::SEVERLIST::const_iterator it = SeverConsts::Get()->getSeverList().find(nServerId);
	if (it != SeverConsts::Get()->getSeverList().end())
	{
		strServerName = it->second->name;
	}

	return strServerName;
}
void GamePrecedure::readTables()
{
	CCLog("readTables begin");
	if (mReadTables)
		return;

	//time_t t = time(0);
	//char tmp[64];
	//strftime(tmp, sizeof(tmp), "%Y/%m/%d %X", localtime(&t));
	//CCLog("Language begin %s  ", tmp);
	//CCLog("Language begin");
	//Language::Get()->clear();
	//Language::Get()->init("Lang/Language.lang");
	//CCLog("Language endfsfsd");

	//time_t t2 = time(0);
	//char tmp2[64];
	//strftime(tmp2, sizeof(tmp2), "%Y/%m/%d %X", localtime(&t2));
	//CCLog("anguage end %s  ", tmp2);

	//CCLog("Language endfsfsd");
	//cocos2d::FNTConfigRemoveCache();
	//time_t t3 = time(0);
	//char tmp3[64];
	//strftime(tmp3, sizeof(tmp3), "%Y/%m/%d %X", localtime(&t3));
	//CCLog("VaribleManager begin %s  ", tmp3);
	CCLog("VaribleManager begin");
    VaribleManager::Get()->reload();//构造函数load，因为playLoadingMusic先用它了，内更新后这里reload它
	unsigned int max_texture_cache_bytes = StringConverter::parseUnsignedInt(VaribleManager::Get()->getSetting("MaxTexCacheBytes", "", "1415577600"), 1415577600);//550*1024*1024
    CCTextureCache::sharedTextureCache()->setMaxCacheByteSizeLimit(max_texture_cache_bytes);
	g_AppDelegate->setMaxCacheByteSizeLimit(max_texture_cache_bytes);
	CCLog("VaribleManager end");
	//time_t t4 = time(0);
	//char tmp4[64];
	//strftime(tmp4, sizeof(tmp4), "%Y/%m/%d %X", localtime(&t4));
	//CCLog("VaribleManager end %s  ", tmp4);
	//CCLog("ToolTableManager begin");
	//ToolTableManager::Get()->init("Tools.txt");//非构造函数init
	//ToolTableManager::Get()->initIncludeOther();//see ToolTableManager
	//CCLog("ToolTableManager end");

	//CStageConfigManager::Get()->Load("chapters.txt", "stages.txt", "story.txt");
	//CSkillConfigManager::Get()->Load("Skills.txt", "buff.txt");
	//CFavorConfigManager::Get()->Load("disciplefavor.txt", "disciplefavorachiv.txt");
	
	mReadTables = true;//
	CCLog("readTables end");
}
void GamePrecedure::setInLoadingScene()
{
	mInLoadingScene = true;

	//CCLog("********************* setInLoadingScene");
	libPlatformManager::getPlatform()->sendMessageG2P("G2P_EnterMainScene", std::string("false"));
}
const std::string GamePrecedure::gameSnapshot(const int &posX,const int &posY, const int &width,const int &height,bool fullScreen/* = false*/)
{
	CCSize size = CCEGLView::sharedOpenGLView()->getFrameSize();//CCDirector::sharedDirector()->getWinSize();////;//getWinSizeInPixels
	CCRenderTexture* in_texture = CCRenderTexture::create((int)size.width, (int)size.height, kCCTexture2DPixelFormat_RGBA8888,GL_DEPTH24_STENCIL8);

	CCLOG("GamePrecedure::gameSnapshot width,height: %d,%d", (int)size.width, (int)size.height);

	in_texture->keepBegin();
	if (this->mInLoadingScene)
	{
		if (mLoadingFrame && mLoadingFrame->getRootSceneNode())
		{
			mLoadingFrame->getRootSceneNode()->visit();
		}
	}
	else
	{		
		if (mMainFrame && mMainFrame->getRootSceneNode())
		{
			mMainFrame->getRootSceneNode()->visit();
			
		}
	}
	in_texture->keepEnd();
    static int num = 1;
    char file_path[32]; //= "share.png";
    sprintf(file_path,"share_%d.png", num++);
    std::string fileFullPath = CCFileUtils::sharedFileUtils()->getWritablePath() + file_path;
    bool b_result = false;
    if (!fullScreen)
    {
        float widthRate =  1;//size.width / 640;
        float heightRate = 1;//size.height / 960;
        CCRenderTexture* tmpTexture = CCRenderTexture::create((int)(width * widthRate),(int)(height * heightRate));
        CCSprite* tmpSprite = CCSprite::createWithTexture(in_texture->getSprite()->getTexture(),CCRect(posX*widthRate,posY*heightRate,width * widthRate,height * heightRate));
        tmpSprite->setAnchorPoint(ccp(0,0));
        tmpSprite->setPosition(ccp(0,0));
        tmpSprite->setFlipY(true);
        
        tmpTexture->beginWithClear(0,0,0,0);
        tmpSprite->visit();
        tmpTexture->endToLua();
        
        b_result = tmpTexture->saveToFile(file_path, kCCImageFormatPNG);
        
        CC_SAFE_DELETE(tmpSprite);
        CC_SAFE_DELETE(tmpTexture);
    }
    else
    {
        b_result = in_texture->saveToFile(file_path, kCCImageFormatPNG);
    }
    
    if (b_result)
    {
        CCLOG("GamePrecedure::gameSnapshot success to %s", (CCFileUtils::sharedFileUtils()->getWritablePath() + file_path).c_str());
    }
    else
    {
        CCLOG("GamePrecedure::gameSnapshot failed, %s", (CCFileUtils::sharedFileUtils()->getWritablePath() + file_path).c_str());
    }
    
    CC_SAFE_DELETE(in_texture);
    return fileFullPath;
}

void GamePrecedure::unInit()
{
	//
	//return;//zhengxin 2013-12-07 readTables 构造函数模式之后
	//
	if (mReadTables)
	{
		DiscipleTableManager::Get()->Free();
		//
		SkillTableManager::Get()->Free();
		//
		EquipTableManager::Get()->Free();
		//
		YuanfenTableManager::Get()->Free();
		//
		UserPropertyTableManager::Get()->Free();
		//
		ToolTableManager::Get()->Free();
		//
		DisciplesLevelParamManager::Get()->Free();
		//
		EquipLevelParamManager::Get()->Free();
		//
		HelpTableManager::Get()->Free();
		//
		VIPPrivilegeTableManager::Get()->Free();
		//
		AboutTableManager::Get()->Free();
		//
		AdventureTableManager::Get()->Free();
		//
		PlayerGradeTableManager::Get()->Free();
		//
		FragmentBookTableManager::Get()->Free();
		//
		AnnouncementTableManager::Get()->Free();
		//
		ToolTableManager::Get()->Free();
		//
		NewActivePromptTableManager::Get()->Free();
		//
		ArenaRewardTableManager::Get()->Free();
		//
		FightEndRewardTableManager::Get()->Free();
		//
		RestrictedWord::Get()->Free();
		
		//
		VipDataTableManager::Get()->Free();
		//
		ActivityPopTableManager::Get()->Free();
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		//PlatformNameManager::Get()->Free();
		//BBSConfigManager::Get()->Free();
//#endif
		//
		//
		TableReaderManager::Get()->Free();
		//
	}
	//
	mReadTables = false;
	//
	TimeCalculator::Get()->Free();
	//
	SeverConsts::Get()->Free();
	//
	waitingManager::Get()->Free();
	//
	LoginPacket::Get()->Free();
	//
}

GamePrecedure::~GamePrecedure()
{
#ifdef PROJECT_RYUK_JP
    delete ryukPlatformListener;
    ryukPlatformListener = NULL;
#endif
	//this->unInit();//zhengxin 2013-12-07 readTables 构造函数模式之后
}

//bool GamePrecedure::_requestPackage( int opcode, int opcoderet, ::google::protobuf::Message* message )
//{
//	REQUEST_PACKAGE pkt;
//	pkt.opcode = opcode;
//	pkt.opcoderet = opcoderet;
//	pkt.message = message;
//	pkt.bfirstsent = false;
//
//	PacketManager::Get()->registerPacketHandler(opcoderet,this);
//
//	//	
//	std::list<REQUEST_PACKAGE>::iterator it = mRequestPackages.begin();
//	std::list<REQUEST_PACKAGE>::iterator end = mRequestPackages.end();
//	for ( ; it != end; ++it)
//	{
//		if ((*it).opcode == opcode)
//		{
//			return false;
//		}
//	}
//	mRequestPackages.push_back(pkt);
//	return true;
//}

void GamePrecedure::_gotPackage( int opcoderet )
{
	//std::list<REQUEST_PACKAGE>::iterator it = mRequestPackages.begin();
	//std::list<REQUEST_PACKAGE>::iterator end = mRequestPackages.end();
	//for ( ; it != end; ++it)
	//{
	//	if ((*it).opcoderet == opcoderet)
	//	{
	//		delete (*it).message;
	//		mRequestPackages.erase(it);
	//		++mLoginPacketsReceivedCount;
	//		break;;
	//	}
	//}


	//收包做一个计数，用来计算登录百分比
	++mLoginPacketsReceivedCount;
	CCLog("recive package %d",opcoderet);
	//if (opcoderet == ASSEMBLE_FINISH_S)
	//{
	//	m_loginPacketAssemblySuccess = true;
	//	mLoginPacketsReceivedCount =0;
	//	waitingManager::Get()->registerErrReportHandler();
	//	LoginPacket::Get()->setEnabled(true);
	//}
}

void GamePrecedure::_failedPakcage( int opcode, bool isSendFaild )
{

	//if(!isSendFaild)//opcode is opcode ret
	//{		
	//	std::list<REQUEST_PACKAGE>::iterator it = mRequestPackages.begin();
	//	std::list<REQUEST_PACKAGE>::iterator end = mRequestPackages.end();
	//	for ( ; it != end; ++it)
	//	{
	//		if ((*it).opcode == opcode)
	//		{
	//			PacketManager::Get()->sendPakcet((*it).opcode, (*it).message);
	//			CCLOGERROR("LoginingPackets failed receive and resend one packet,opcode:%d",opcode);
	//			break;
	//		}
	//	}
	//}
	//else
	//{
	//	LoginPacket::Get()->setEnabled(true);

	//	std::list<REQUEST_PACKAGE>::iterator it = mRequestPackages.begin();
	//	std::list<REQUEST_PACKAGE>::iterator end = mRequestPackages.end();
	//	for ( ; it != end; ++it)
	//	{
	//		if ((*it).opcode == opcode)
	//		{
	//			PacketManager::Get()->sendPakcet((*it).opcode, (*it).message);
	//			CCLOGERROR("LoginingPackets failed send and resend one packet,opcode:%d",opcode);
	//		}
	//	}
	//}
}

void GamePrecedure::enterBackGround()
{
	CCLOG("GamePrecedure::enterBackGround, enter the back ground");
	//如果登录数据包没有收到完成包，退出
	//if(m_loginPacketAssemblySuccess == false)
	//	exit(0);

	//添加离线24小时候的推送
	libOS::getInstance()->clearNotification();
	GameNotification::Get()->addNotification();
    
    s_gotoBackgroundTime = time(0);

	cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
	if(pEngine)
	{
		pEngine->executeGlobalFunctionByName("GamePrecedure_enterBackGround",this,"GamePrecedure");
	}
    
}

bool GamePrecedure::isInLoadingSceneAndNeedExit()
{
	/*if (mLoadingFrame)
	{
		return !mLoadingFrame->isUpdateDown();
	}*/
    return false;
}

void GamePrecedure::onConnectFailed( std::string ip, int port )
{
	mStartLoginJiShi = false;
	if (mLoadingFrame)
	{
		mLoadingFrame->showEnter();
	}
}

void GamePrecedure::showLoadingEnter(){
	mStartLoginJiShi = false;
	if (mLoadingFrame)
	{
		mLoadingFrame->showEnter();
	}

}

LoadingFrame* GamePrecedure::getLoadingFrame()
{
	if (mLoadingFrame)
	{
		return mLoadingFrame;
	}

	return NULL;
}

void GamePrecedure::reset()
{
	mServerID = -1;
	mUin = mPlayerUin = "";
    libPlatformManager::getPlatform()->switchUsers();
}

void GamePrecedure::showBulletin()
{
/*    if ( !m_pBulletinMgr )
    {
        m_pBulletinMgr = new BulletinManager();
    }
    m_pBulletinMgr->showBulletin();*/
}

void GamePrecedure::closeBulletin()
{
    /*if ( m_pBulletinMgr )
    {
        m_pBulletinMgr->closeBulletin();
        delete m_pBulletinMgr;
        m_pBulletinMgr = NULL;
    }*/
}
void GamePrecedure::setCurrentLanguageType(cocos2d::LanguageType type)
{
	mCurrentLanguageType = type;
	CCLOG("GamePrecedure::setCurrentLanguageType, type == %d", type);
}

cocos2d::LanguageType GamePrecedure::getCurrentLanguageType()
{
	return mCurrentLanguageType;
}

std::string GamePrecedure::getI18nSrcPath()
{
	//先判断是否玩家已经有了默认选择
	std::string uinkey = "UserDefaultI18nLanguageType";
	int userType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey(uinkey.c_str(), -1);

	if (userType >= 0)
	{
		std::string platformId = libPlatformManager::getPlatform()->getClientChannel();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		platformId = "win32";
#endif
		//取本平台对应的语言配置
		I18nPlatformCfgItem* i18nPlatformItem = I18nPlatformCfgManager::Get()->getI18nPlatformItem(platformId);
		if (i18nPlatformItem != NULL)
		{
			std::vector<unsigned int>::iterator it = i18nPlatformItem->languageTypeList.begin();
			for (; it != i18nPlatformItem->languageTypeList.end(); it++)
			{
				unsigned int type = *it;

				if (type == userType)
				{
					I18nLanguageCfgItem* item = I18nLanguageCfgManager::Get()->getI18nItem(cocos2d::LanguageType(userType));
					if (item)
					{
						return item->srcPath.c_str();
					}
					break;
				}
			}
		}
	}
	

	I18nLanguageCfgItem* item = getCurrentLanguageCfgItem();
	if (item)
	{
		return item->srcPath.c_str();
	}
	return "";
}

void GamePrecedure::setUserDefaultI18nSrcPath(int languageType)
{
	std::string uinkey = "UserDefaultI18nLanguageType";
	cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey(uinkey.c_str(), languageType);
	cocos2d::CCUserDefault::sharedUserDefault()->flush();
}


//增加判断，需要从右向左渲染的条件是：
//1、当前语种需要从右向左渲染
//2、当前平台包支持条件1中的语种，即有对应的语言包
bool GamePrecedure::getI18nTextIsLeft2Right()
{
	bool result = true;
	std::string platformId = libPlatformManager::getPlatform()->getClientChannel();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	platformId = "win32";
#endif
	bool isPlatformHasLang = false;
	int defaultLang = -1;
	I18nPlatformCfgItem* i18nPlatformItem = I18nPlatformCfgManager::Get()->getI18nPlatformItem(platformId);
	if (i18nPlatformItem != NULL)
	{
		std::vector<unsigned int>::iterator it = i18nPlatformItem->languageTypeList.begin();
		for (; it != i18nPlatformItem->languageTypeList.end(); it++)
		{
			unsigned int type = *it;

			if (defaultLang == -1)
			{
				defaultLang = type;
			}

			if (type == getCurrentLanguageType())
			{
				isPlatformHasLang = true;
				break;
			}
		}
	}
	I18nLanguageCfgItem* i18nLangItem = this->getCurrentLanguageCfgItem();
	if (i18nLangItem != NULL)
	{
		if (i18nLangItem->isForce)
		{
			if (i18nLangItem->isTextLeft2Right == 0)
			{
				result = false;
			}
		}
		else
		{
			if (isPlatformHasLang && i18nLangItem->isTextLeft2Right == 0)
			{
				result = false;
			}
		}
	}
	return result;
}

I18nLanguageCfgItem* GamePrecedure::getCurrentLanguageCfgItem()
{
	std::string platformId = libPlatformManager::getPlatform()->getClientChannel();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	platformId = "win32";
#endif
	//取本平台对应的语言配置
	bool isPlatformHasLang = false;
	int defaultLang = -1; 
	I18nPlatformCfgItem* i18nPlatformItem = I18nPlatformCfgManager::Get()->getI18nPlatformItem(platformId);
	if (i18nPlatformItem != NULL)
	{
		std::vector<unsigned int>::iterator it = i18nPlatformItem->languageTypeList.begin();
		for (; it != i18nPlatformItem->languageTypeList.end(); it++)
		{			
			unsigned int type = *it;

			if (defaultLang == -1)
			{
				defaultLang = type;
			}

			if (type == getCurrentLanguageType())
			{
				isPlatformHasLang = true;
				break;
			}
		}
	}
	//win32直接读取ResourceConfig.ini配置中 “选择语种” 对应的语言类型，来选取语言包
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	ResourceConfigItem* resourceConfig = getResourceConfigItem();
	if (resourceConfig)
	{
		int langType = resourceConfig->languageType;
		if (langType >= 0)
		{
			return I18nLanguageCfgManager::Get()->getI18nItem(cocos2d::LanguageType(langType));
		}
	}
#endif

	if (isPlatformHasLang)
	{
		return I18nLanguageCfgManager::Get()->getI18nItem(mCurrentLanguageType);
	}
	else
	{
		return I18nLanguageCfgManager::Get()->getI18nItem(cocos2d::LanguageType(defaultLang));
	}
	return NULL;
}


std::string GamePrecedure::getCurrentResourcePath()
{
	std::string reourcePath = "";
	ResourceConfigItem* resourceConfig = getResourceConfigItem();
	if (resourceConfig)
	{
		reourcePath = resourceConfig->reourcePath;
	}	
	return reourcePath;
}
// std::string GamePrecedure::getPlatformPath()
// {
// 	std::string platformName = libPlatformManager::getPlatform()->getClientChannel();
// 	if(!platformName.empty())
// 	{
// 		std::transform(platformName.begin(),platformName.end(),platformName.begin(),tolower);
// 		if (platformName.find_first_of("_") != std::string::npos)
// 		{
// 			std::string::size_type length = platformName.length();
// 			platformName = platformName.substr(platformName.find_first_of("_") + 1,length);
// 		}
// 		if (platformName.find_first_of("_") != std::string::npos)
// 		{
// 			std::string::size_type length = platformName.length();
// 			platformName = platformName.substr(0,platformName.find_first_of("_"));
// 		}
// 		
// 	}
// 	
// 	return platformName;
// }
std::string GamePrecedure::getWin32ResourcePath()
{
	if (win32ResourceCfg)
	{
		return win32ResourceCfg->reourcePath;
	}
	return "";
}
void GamePrecedure::setWin32ResourceConfigItem(ResourceConfigItem* item)
{
	if (item)
	{
		win32ResourceCfg = item;
	}
	
}
ResourceConfigItem* GamePrecedure::getResourceConfigItem()
{
	std::string platformName = libPlatformManager::getPlatform()->getClientChannel();
	ResourceConfigItem* itemconfig = ResourceConfigManager::Get()->getResourceItem(platformName);
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	if (win32ResourceCfg)
	{
		return win32ResourceCfg;
	}
	else
	{
		win32ResourceCfg = itemconfig;
	}
#endif
	
	return itemconfig;
}
std::string  GamePrecedure::getLocalVersionToLua()
{
    std::string platVersionName = GamePlatformInfo::getInstance()->getPlatVersionName();

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	platVersionName = "version_android_local.cfg";
#endif
    std::string filePath = libOS::getInstance()->getPathFormBundle(platVersionName);
    std::string mLocalVerson ="";
    Json::Value root;
    Json::Reader jreader;
    Json::Value data;
    unsigned long filesize;
    
    char* pBuffer = (char*)getFileData(filePath.c_str(),"rt",&filesize,0,false);
    
    bool openSuccessful = true;
    if(!pBuffer)
    {
        char msg[256];
        sprintf(msg,"Failed open file: %s !!",filePath.c_str());
        openSuccessful = false;
    }
    else
    {
		openSuccessful = jreader.parse(pBuffer, filesize, data, false);
        if(openSuccessful && data["version"].asInt()==1 && !data["localVerson"].empty())
        {
            mLocalVerson = data["localVerson"].asString();
        }
    }
    CC_SAFE_DELETE_ARRAY(pBuffer);
    return mLocalVerson;

}
std::string GamePrecedure::getPlatformName()
{
	return libPlatformManager::getPlatform()->getClientChannel();
}
void GamePrecedure::registerPlatform()
{
	GamePlatformInfo::getInstance()->registerPlatform();
}

bool GamePrecedure::CheckMailRule(const std::string&aStr)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)

	std::regex emailRule("([0-9A-Za-z\\-_\\.]+)@([0-9a-z\-]+\\.[a-z]{2,3}(\\.[a-z]{2})?)");
	return (std::regex_match(aStr, emailRule));

#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID||CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	char ss[100] = {};
	sprintf(ss, "%s", aStr.c_str());
	regmatch_t pmatch[4];
	regex_t match_regex;

	regcomp(&match_regex,
		"([0-9A-Za-z\\-_\\.]+)@([0-9a-z\-]+\\.[a-z]{2,3}(\\.[a-z]{2})?)",
		REG_EXTENDED);
	if (regexec(&match_regex, ss, 4, pmatch, 0) != 0)
	{
		regfree(&match_regex);
		return false;
	}
	regfree(&match_regex);
	return true;
#endif

}

void ReEnterLoading( bool boo )
{
	if (boo)
	{
		GamePrecedure::Get()->reEnterLoading();
	}
}

void ReEnterGame(bool boo)
{
	if (boo)
	{
		GamePrecedure::Get()->reEnterGame();
	}
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C"
{
	JNIEXPORT jstring JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeGameSnapshot() {
		JNIEnv * env = 0;

		//if (JniHelper::getJavaVM()->GetEnv((void**)&env, JNI_VERSION_1_6) != JNI_OK || ! env) {
		//	return 0;
		//}
		//std::string file_path = GamePrecedure::Get()->gameSnapshot();
		return env->NewStringUTF("");
	}

	JNIEXPORT jboolean JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeHasEnterMainFrame(JNIEnv * env, jobject obj) {

		return (!GamePrecedure::Get()->isInLoadingScene());

	}

	JNIEXPORT jint JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeGetServerId(JNIEnv * env, jobject obj) {

		return GamePrecedure::Get()->getServerID();

	}

	JNIEXPORT jint JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeGetHasMainRole(JNIEnv * env, jobject obj) {

		return GamePrecedure::Get()->getHasMainRole();

	}

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeReEnterLoadingFrame(JNIEnv * env, jobject obj) {

		GamePrecedure::Get()->reEnterLoading();

	}

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeAskLogoutFromMainFrameToLoadingFrame(JNIEnv * env, jobject obj) {

		//cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
		//	->executeGlobalFunctionByName("askLogoutFromMainFrameToLoadingFrame", NULL, "askLogoutFromMainFrameToLoadingFrame()");
		std::string title = Language::Get()->getString("@LogOffTitle");
		std::string message = Language::Get()->getString("@LogOffMSG");

		ShowConfirmPage( message , title ,ReEnterLoading );
	}

	JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnBack(JNIEnv * env, jobject obj) {
		MainFrame* mMainFrame = dynamic_cast<MainFrame*>(CCBManager::Get()->getPage("MainFrame"));
		if (mMainFrame)
		{
			if(!mMainFrame->popCurrentPage())
			{
				libOS::getInstance()->OnLuaExitGame();
			}
		}
		else
		{
			libOS::getInstance()->OnLuaExitGame();
		}
	}
	JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnEnterMateShowLoginPage(JNIEnv * env, jobject obj) {
		GamePrecedure::getInstance()->m_logoutCallback = true;
	}
}



#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	void GamePrecedure::escapeGame()
	{
		MainFrame* mMainFrame = dynamic_cast<MainFrame*>(CCBManager::Get()->getPage("MainFrame"));
		if (mMainFrame)
		{
			CCLOG("nativeOnBack pop page begin===========");
			if(!mMainFrame->popCurrentPage())
			{
				int result = MessageBox( NULL , TEXT("爱玩不玩") , TEXT("走你") , MB_YESNO);
				switch(result)
				{
				case IDYES:exit(0);break;
				case IDNO:break;
				}
			}
			CCLOG("nativeOnBack pop page end===========");
		}
		else
		{
			int result = MessageBox( NULL , TEXT("爱玩不玩") , TEXT("走你") , MB_YESNO);
			switch(result)
			{
			case IDYES:exit(0);break;
			case IDNO:break;
			}
		}
		CCLOG("nativeOnBack end===========");
	}
#endif

void GamePrecedure::playMovie(std::string fileName, int isLoop, int autoScale)
{
    // FixMe: For testing purpose, use an existing movie file 
    fileName = "Video/AVG_V_C00101";
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	callPlatformPlayMovieJNI(fileName.c_str(), isLoop, autoScale);
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	libOS::getInstance()->playMovie(fileName.c_str(), isLoop);
#endif
}

void GamePrecedure::closeMovie()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	callPlatformCloseMovieJNI();
#endif
}

void GamePrecedure::pauseMovie()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	callPlatformPauseMovieJNI();
#endif
}

void GamePrecedure::resumeMovie()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	callPlatformResumeMovieJNI();
#endif
}
