#if (CC_TARGET_PLATFORM != CC_PLATFORM_IOS)
    #include "stdafx.h"
#endif
#include "AppDelegate.h"
#include "GamePrecedure.h"
#include "SimpleAudioEngine.h"
//#include "ThreadSocket.h"
#include "SoundManager.h"
#include "CCBManager.h"
#include "CCBScriptContainer.h"
#include "TimeCalculator.h"
#include <time.h>
#include "ServerDateManager.h"
//#include "comHuTuo.h"
#include "SeverConsts.h"
#include "Lua_EcchiGamerSDKBridge.h"
#include "Lua_HttpsBridge.h"

//// 導入頭文件 CrashReport.h 和 BuglyLuaAgent.h 2020.4.24 lin close
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
//#include "Bugly/CrashReport.h"
//#include "Bugly/lua/BuglyLuaAgent.h"       
//#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
//#include "Bugly/CrashReport.h"
//#include "Bugly/lua/BuglyLuaAgent.h"
//#else
//
//#endif
//#include "TalkingData.h"

//
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include <sys/sysinfo.h>//for sysinfo
#include <jni.h>
#include "..\..\cocos2dx\platform\android\jni\JniHelper.h"
#include "../../cocos2dx/platform/android/jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

//

#define  MAX_TEXTURE_MSIZE (1350*1024*1024)


//asuming game is portrait, and the non-retina pad's height is 1024, retina pad is 2048
#define CC_IS_IPAD_PORTRAIT() (CCDirector::sharedDirector()->getWinSize().height==2048||CCDirector::sharedDirector()->getWinSize().height==1024)

static time_t timestamp = time(0);//see this file

//
USING_NS_CC;

AppDelegate* g_AppDelegate = 0;

static float s_recycle_frequence = 5.f;
#define FREQUENCE_MAX  5.f

// 可選語系設定
std::map<int, bool> canSelectLang = {
	{ kLanguageChinese, true },
	{ kLanguageCH_TW, true },
};

#ifdef WIN32
void accelerometerKeyHook(UINT message, WPARAM wParam, LPARAM lParam)
{	
	if (message == WM_KEYUP)
	{
		//Ctrl Pressed
		if (GetKeyState(VK_CONTROL) < 0)
		{
			//Ctrl + 'T' To Dump TextureCache
			if (wParam == 'T')
				CCTextureCache::sharedTextureCache()->dumpCachedTextureInfo();
			if (wParam == 'Q')
				g_AppDelegate->purgeCachedData();
			if (wParam == 'U')
			{
				ResManager::Get()->checkCCBIResource();

				cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
				if(pEngine)
				{
					pEngine->executeGlobalFunction("checkAllConfigFile");
				}
			}
			if (wParam == 'R')
			{
				cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
				if (pEngine)
				{
					pEngine->executeGlobalFunction("reloadCurPage");
				}
			}
			if (wParam == 'O')
			{
				CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFramesPerFrame();
				CCTextureCache::sharedTextureCache()->removeUnusedTexturesPerFrame();
			}
		}
		if (wParam == VK_ESCAPE)
		{
			GamePrecedure::getInstance()->escapeGame();
		}
	}
}
#endif

AppDelegate::AppDelegate()
:needPurgeCache(false),needRecycleTex(false)
,delayRecycleSeconds(5.f),max_cache_bytes(MAX_TEXTURE_MSIZE)
, m_IsOpenPurgeCacheAndroid(false)
, m_IsOpenPurgeCacheIOS(false)
{
	CCLOG("cocos2d-x app delegate");

	g_AppDelegate = this;
}

AppDelegate::~AppDelegate() 
{
}

void registerRecycleTex(const std::string& texName)
{
	g_AppDelegate->registerRecycleTex(texName);
}

bool checkDeviceInIOSPlist(std::string modelName){
	if (CCFileUtils::sharedFileUtils()->isFileExist("shader/ios-devices.plist"))
	{
		std::transform(modelName.begin(),modelName.end(),modelName.begin(),::tolower);
		//
		CCDictionary* iosDic = CCDictionary::createWithContentsOfFileThreadSafe("shader/ios-devices.plist");
		iosDic->autorelease();
		if (iosDic) {
			CCObject* flagObject = iosDic->objectForKey(modelName);
			if (flagObject) {
				CCString* sResFlag = dynamic_cast<CCString*>(flagObject);//check if value of flag is "true"
				if (sResFlag->compare("true")==0) {
					return true;
				}else{
					CCLOG("@checkDeviceInIOSPlist, the flag is not true");
					return false;
				}
			}else{
				return false;
			}

		}else{
			return false;
		}
	}
	return false;
}

bool checkDeviceInAndroidPlist(int resWidth, int resHeight,std::string sManufactory, std::string sModelName){

	if (CCFileUtils::sharedFileUtils()->isFileExist("shader/android-devices.plist"))
	{
		std::transform(sManufactory.begin(),sManufactory.end(),sManufactory.begin(),::tolower);
		std::transform(sModelName.begin(),sModelName.end(),sModelName.begin(),::tolower);
		//
		CCDictionary* androidDic = CCDictionary::createWithContentsOfFileThreadSafe("shader/android-devices.plist");
		androidDic->autorelease();
		if (androidDic) {
			//Big flag no.1: check gpu names. not use currently.
			CCObject* gpusObject = androidDic->objectForKey("gpus");
			if (gpusObject) {
				CCDictionary* gpusDic = dynamic_cast<CCDictionary*>(gpusObject);
			}else{
				CCLOG("@checkDeviceInAndroidPlist, not find gpus in dic");
				return  false;
			}

			bool bInResolutionDic = false;
			//Big flag no.2: check resolutions 
			CCObject* resolutionsObject = androidDic->objectForKey("resolutions");
			if (resolutionsObject) {
				CCDictionary* resolutionsDic = dynamic_cast<CCDictionary*>(resolutionsObject);//get the res dic
				std::string sResWidth = StringConverter::toString(resWidth);
				std::string sResHeight = StringConverter::toString(resHeight);
				std::string sResolution = sResWidth+"*"+sResHeight;
				CCObject* resFlag = resolutionsDic->objectForKey(sResolution);//check if resolution exist.
				if (resFlag) {
					CCString* sResFlag = dynamic_cast<CCString*>(resFlag);//check if value of resolution is "true"
					if (sResFlag->compare("true")==0) {
						bInResolutionDic = true;
					}else{
						CCLOG("@checkDeviceInAndroidPlist, the flag of resolution(%s) is not true",sResolution.c_str());
						//return false;
					}
				}else{
					CCLOG("@checkDeviceInAndroidPlist, the resolution(%s) not found in dic",sResolution.c_str());
					//return false;
				}

			}else{
				CCLOG("@checkDeviceInAndroidPlist, resolution dic not found");
				return  false;
			}

			//if(bInResolutionDic){
				CCObject* devicesObject = androidDic->objectForKey("devices");
				if (devicesObject) {
					CCDictionary* devicesDic = dynamic_cast<CCDictionary*>(devicesObject);//get the devices dic
					{
						CCDictElement* pElement = NULL;
						CCDICT_FOREACH(devicesDic, pElement)
						{
							if (sManufactory.find(pElement->getStrKey()) != std::string::npos)
							{
								CCDictionary* manuDic = dynamic_cast<CCDictionary*>(pElement->getObject());
								CCDictElement* pElement1 = NULL;
								CCDICT_FOREACH(manuDic, pElement1)
								{
									if (sModelName.find(pElement1->getStrKey()) != std::string::npos)
									{
										CCString* sdeviceFlag = dynamic_cast<CCString*>(pElement1->getObject());
										if (sdeviceFlag && sdeviceFlag->compare("true")==0) {
										
											CCLOG("@checkDeviceInAndroidPlist, found model name %s in dic",sModelName.c_str());
											return true;
										}
										else
										{
											CCLOG("@checkDeviceInAndroidPlist, model name %s in dic is not equal to true",sModelName.c_str());
											return false;
										}
									}
								}
							}
						}
					}
				}else{
					return false;
				}
		}else{
			CCLOG("@checkDeviceInAndroidPlist, shader/android-devices.plist load failed");
			return  false;
		}
	}
	return false;
}

bool AppDelegate::applicationDidFinishLaunching()
{
	//TDCCTalkingDataGA::onStart("23A150610FCF4FC887D4207BD0411CC5", "CHANNEL_ID");

	ccLanguageType currentLanguageType = getCurrentLanguage();
	if (currentLanguageType == kLanguageChinese)
	{
		std::string currentCountry = libOS::getInstance()->getCurrentCountry();
		if (currentCountry == "cn")
		{
			currentLanguageType = kLanguageChinese;
		}
		else if (currentCountry == "tw")
		{
			currentLanguageType = kLanguageCH_TW;
		}
	}

	SeverConsts::Get()->initSearchPath();
	GamePrecedure::Get()->registerPlatform();
	SeverConsts::Get()->CheckPlatform();
	if (SeverConsts::Get()->IsEroR18()) // eror18 is true
	{
		//eroR18
		Lua_EcchiGamerSDKBridge::register_function();
		//Lua_EcchiGamerSDKBridge::callinitbyC();
	}

	Lua_HttpsBridge::register_function();
	int defaultLang = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType", currentLanguageType);
	if (!canSelectLang[defaultLang]) {
		defaultLang = kLanguageChinese;
	}
	cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey("LanguageType", defaultLang);
	CCLog("LanguageType : %d", defaultLang);
	GamePrecedure::Get()->setCurrentLanguageType((ccLanguageType)defaultLang);
#if ((CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) )
#else
	std::string path = GamePrecedure::Get()->getCurrentResourcePath();
	if (!path.empty() && path != "none")
	{
		SeverConsts::Get()->initPlatfomtPath("platforms/" + path);
	}
#endif
	
	SeverConsts::Get()->initLanguagePath("Japanese"/*GamePrecedure::Get()->getI18nSrcPath()*/);
	//SeverConsts::Get()->initIsTextLeft2Right(GamePrecedure::Get()->getI18nTextIsLeft2Right());
	//set_is_text_render_left_2_right(GamePrecedure::Get()->getI18nTextIsLeft2Right());
	//SeverConsts::Get()->setSearchPath();

	bool IsAppStoreChecking = StringConverter::parseBool(VaribleManager::Get()->getSetting("IsAppStoreChecking", "", "false"), false);
	cocos2d::CCLog("IsAppStoreChecking = %s", StringConverter::toString(IsAppStoreChecking).c_str());
	SeverConsts::Get()->setIsAppStoreChecking(IsAppStoreChecking);

	m_IsOpenPurgeCacheAndroid = StringConverter::parseBool(VaribleManager::Get()->getSetting("IsOpenPurgeCacheAndroid", "", "false"), false);
	m_IsOpenPurgeCacheIOS = StringConverter::parseBool(VaribleManager::Get()->getSetting("IsOpenPurgeCacheIOS", "", "false"), false);


	//CCTexture2D::setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA4444);
	// initialize director
	CCDirector *pDirector = CCDirector::sharedDirector();
	pDirector->setOpenGLView(CCEGLView::sharedOpenGLView());
	pDirector->setProjection(kCCDirectorProjection2D);
	CCSize screenSize = CCEGLView::sharedOpenGLView()->getFrameSize();
	cocos2d::CCLog("width---%f", screenSize.width);
	cocos2d::CCLog("height---%f", screenSize.height);
	/*
	480*854		320*569.333
	320*480		320*480
	640*1136	320*568
	768*1024	360*480
	800*1280	320*512
	480*800		320*533.333
	720*1280	320*568.889
	738*1152	320*480
	*/
	//新的螢幕適配，固定寬度，適配高度
	CCSize designSize = CCSizeMake(720, 1280);
	//float asp = screenSize.height/screenSize.width;
	//if (asp > (1280.0 / 720.0)) {
	//	designSize.height = 720 * asp;
	//}

	/*CCSize designSize = CCSizeMake(720, 1280);
	float asp = screenSize.width / screenSize.height;
	designSize.width = 1280 * asp;*/


	if (screenSize.height > 1280)
	{
		//CCFileUtils::sharedFileUtils()->addSearchResolutionsOrder("iphonehd/");
	}
 	else
 	{
 		//CCFileUtils::sharedFileUtils()->addSearchResolutionsOrder("iphone/");
 	}

	if (CCFileUtils::sharedFileUtils()->isFileExist("shader/palette.sha"))
	{
		GLchar * fragSource = (GLchar*) CCString::createWithContentsOfFile(CCFileUtils::sharedFileUtils()->fullPathForFilename("shader/palette.sha").c_str())->getCString();	
		if (strstr(fragSource, "main()"))
		{
			bool bUsePaletteFlag = false;

			if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS){
				std::string platformInfo = libOS::getInstance()->getPlatformInfo();
				int pos = platformInfo.find('_');
				std::string iosDeviceName = platformInfo.substr(0,pos);
				bUsePaletteFlag = checkDeviceInIOSPlist(iosDeviceName);
                bUsePaletteFlag = true;
			}else if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
				//
				unsigned int warning_ram_mb = StringConverter::parseUnsignedInt(VaribleManager::Get()->getSetting("WarningRamMb", "", "768"), 768);//768Mb
				//
				struct sysinfo info = {0};
				unsigned long ram_mb = 2000;
				int err = ::sysinfo(&info);
				//LOGD("avalibleMemory (freeram,totalram,freehigh,totalhigh):(%d,%d,%d,%d)", info.freeram/1048576,info.totalram/1048576,info.freehigh/1048576,info.totalhigh/1048576);
				if (err == 0)
					ram_mb = info.totalram/1048576;
				//
				if (ram_mb <= warning_ram_mb)
					bUsePaletteFlag = true;
				else
				{
					std::string platformInfo = libOS::getInstance()->getPlatformInfo();
					bUsePaletteFlag = checkDeviceInAndroidPlist(screenSize.width,screenSize.height,platformInfo,platformInfo);
				}
#endif
			}
			else if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			{
				bUsePaletteFlag = true;
			}
			//
			if (bUsePaletteFlag)
				CCTextureCache::sharedTextureCache()->initPaletteGLProgram(ccPositionTextureColor_vert, fragSource);
			//
		}
		fragSource = NULL;
	}

	CCSize cSize = CCEGLView::sharedOpenGLView()->getFrameSize();
	float fSize = cSize.width / cSize.height;
	//0.5625
	//if (fSize >= 0.62){
		//設定最大縮放比例
	//	CCEGLView::sharedOpenGLView()->setDesignResolutionSize(720, 1162, kResolutionFixedHeight);
	//}
	/*else if (cSize.width == 2048 && cSize.height == 2732){
		CCEGLView::sharedOpenGLView()->setDesignResolutionSize(720, 1280, kResolutionFixedHeight);
	}
	else if (fSize = 0.625){
		CCEGLView::sharedOpenGLView()->setDesignResolutionSize(720, 1280, kResolutionFixedHeight);
	}*/
	//else
	//{
		//CCEGLView::sharedOpenGLView()->setDesignResolutionSize(720, 1280, kResolutionFixedHeight);
	if (fSize > 720.0 / 1280.0){
		CCEGLView::sharedOpenGLView()->setDesignResolutionSize(designSize.width, designSize.height, ResolutionPolicy::kResolutionFixedHeight);
	}
	else {
		CCEGLView::sharedOpenGLView()->setDesignResolutionSize(designSize.width, designSize.height, ResolutionPolicy::kResolutionFixedWidth);
	}
	//}

#if defined(_DEBUG) || (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	// turn on display FPS
	#ifdef WIN32
		LPWSTR *szArgList;  
		int argCount;  
		bool showFps = false;
		szArgList = CommandLineToArgvW((LPWSTR)GetCommandLine(), &argCount);  
		for(int i = 0; i < argCount; i++)  
		{   
			wchar_t* ext = L"ShowFps";
			if (wcsstr(szArgList[i], ext))
			{
				showFps = true;
				break;
			}
		} 
		LocalFree(szArgList);
		if(showFps)
		{
			pDirector->setDisplayStats(true);
		}
	#endif
#endif
		//pDirector->setDisplayStats(true);
		//pDirector->setAnimationInterval(1.0 / 30);
		//bugly
		//const char* appId = "";
		///CrashReport::initCrashReport("Your AppID", false);
//
//		// set default FPS
//		Director::getInstance()->setAnimationInterval(1.0 / 60.0f);
//		// register lua module
//		auto engine = LuaEngine::getInstance();
//		ScriptEngineManager::getInstance()->setScriptEngine(engine);
//
//		// register lua exception handler
//		BuglyLuaAgent::registerLuaExceptionHandler(engine);
//#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
//		// NOTE:Please don't remove this call if you want to debug with Cocos Code ID
//		E
//			auto runtimeEngine = RuntimeEngine::getInstance();
//		runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
//		runtimeEngine->start();
//#else
//		if (engine->executeScriptFile("src/main.lua"))
//		{
//			return false;
//		}
//#endif
	const char* appId = "4d1db34d06";
#if CC_TARGET_PLATFORM == CC_PLATFORM_IOS
	appId = "338a55adbc";
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID ||CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

		// init the bugly sdk
	//CrashReport::initCrashReport(appId, false);

		// set default FPS
		//Director::getInstance()->setAnimationInterval(1.0 / 60.0f);
		// register lua module

//		cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
//		cocos2d::CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);
//		//auto engine = LuaEngine::getInstance();
//		//		ScriptEngineManager::getInstance()->setScriptEngine(engine);
//		// register lua exception handler with lua engine
//		BuglyLuaAgent::registerLuaExceptionHandler(pEngine);
//
//#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
//		// NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
//		CCLog("Debug__________");
//		auto runtimeEngine = RuntimeEngine::getInstance();
//		runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
//		runtimeEngine->start();
//#else
		//if (pEngine->executeScriptFile("src/main.lua"))
		//{
		//	return false;
		//}
//#endif


#endif
//		// init the bugly sdk
//		CrashReport::initCrashReport("Your AppID", false);
//
//		// set default FPS
//		//Director::getInstance()->setAnimationInterval(1.0 / 60.0f);
//		// register lua module
//
//		cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
//		cocos2d::CCScriptEngineManager::sharedManager()->setScriptEngine(pEngine);
//		//auto engine = LuaEngine::getInstance();
//		//		ScriptEngineManager::getInstance()->setScriptEngine(engine);
//		// register lua exception handler with lua engine
//		BuglyLuaAgent::registerLuaExceptionHandler(pEngine);
//
//#if (COCOS2D_DEBUG > 0) && (CC_CODE_IDE_DEBUG_SUPPORT > 0)
//		// NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
//		auto runtimeEngine = RuntimeEngine::getInstance();
//		runtimeEngine->addRuntime(RuntimeLuaImpl::create(), kRuntimeEngineLua);
//		runtimeEngine->start();
//#else
//		if (pEngine->executeScriptFile("src/main.lua"))
//		{
//			return false;
//		}
//#endif



	// set FPS. the default value is 1.0/60 if you don't call this
#if 1
	pDirector->setAnimationInterval(1.0 / 30);
#endif

#if WIN32
	pDirector->setAnimationInterval(1.0 / 60);
#endif

	//調度器優先更新
	pDirector->getScheduler()->scheduleUpdateForTarget(this, -1, false);

#ifdef WIN32
	//設定鍵盤事件回調
	CCEGLView::sharedOpenGLView()->setAccelerometerKeyHook(accelerometerKeyHook);
#endif
    
	GamePrecedure::Get()->init();
	//添加啟動後統計訊息
	GamePrecedure::Get()->startupreport();
	//GamePrecedure::Get()->enterMainMenu();
	// 安卓平台的logomovie是在java層實現的，所以直接進入loading狀態
    //GamePrecedure::Get()->enterUpdateVersion();
	GamePrecedure::Get()->enterLoading();


//#else
//	GamePrecedure::Get()->enterLogoMovie();
//#endif
	return true;
}

void AppDelegate::update(float deltaTime)
{
	if (needRecycleTex)
	{
		if (recycleTex.size() > 0)
		{
			s_recycle_frequence -= deltaTime;
				clearRecycleTex();
				if (!needPurgeCache)
				{
					time_t start, end;
					start = clock();
					CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFramesPerFrame();
					CCTextureCache::sharedTextureCache()->removeUnusedTexturesPerFrame();
					end = clock();
					CCLOG("remove textures use time:%d",(int)(end-start));
				}
				CCLOG("AppDelegate Recycle Texture");
				needRecycleTex = false;
				s_recycle_frequence = FREQUENCE_MAX;
				//內存過高檢測
				checkMemoryWarning();
			//}
		}
		else
		{
			needRecycleTex = false;
			//static float stLastCheck = 0.f;
			//內存過高檢測
			checkMemoryWarning();
		}
	}

	if (needPurgeCache)
	{
		delayRecycleSeconds -= deltaTime;
		if (delayRecycleSeconds < 0)
		{
			delayRecycleSeconds = 5.f;
			needPurgeCache = false;
			purgeCachedData();
		}
	}
}

void AppDelegate::notifyPurgeCached()
{
	needPurgeCache = true;
}

void  AppDelegate::notifyRecycleTex()
{
	needRecycleTex = true;
}

void AppDelegate::registerRecycleTex(const std::string& texName)
{
	recycleTex[texName] = texName;
}

void AppDelegate::clearRecycleTex()
{
	recycleTex.clear();
}

void AppDelegate::checkMemoryWarning(bool forceInst)
{
	if(CCTextureCache::sharedTextureCache()->getTextrueTotalBytes() >= max_cache_bytes/*MAX_TEXTURE_MSIZE*/ 
		|| libOS::getInstance()->avalibleMemory() < 30)
	{
		if (forceInst)
		{
			needPurgeCache = false;
			purgeCachedData();
		}
		else
		{
			needPurgeCache = true;
		}
		//
		needRecycleTex = false;

		int leftMemory = libOS::getInstance()->avalibleMemory();

		CCLOG("AppDelegate Purge Cached Data, current left memory is %d",leftMemory);
	}	
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    if(GamePrecedure::Get()->isInLoadingSceneAndNeedExit())
	{
	#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

	#else
        exit(0);
	#endif
	}
    if (libOS::getInstance()->IsInPlayMovie())
    {
        exit(0);
    }
	//
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	//if (getIsOnTempShortPauseJNI() == false)
	{
		PacketManager::Get()->disconnect();
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	// win32 不需要斷線，方便debug
	LPWSTR *szArgList;  
	int argCount;  
	bool disConnect = false;
	szArgList = CommandLineToArgvW((LPWSTR)GetCommandLine(), &argCount);  
	for(int i = 0; i < argCount; i++)
	{   
		wchar_t* ext = L"DisConnect";
		if (wcsstr(szArgList[i], ext))
		{
			disConnect = true;
			break;
		}
	} 
	LocalFree(szArgList);
	if(disConnect)
	{
		PacketManager::Get()->disconnect();
	}
#else
	PacketManager::Get()->disconnect();
#endif
		
	//
	CCDirector::sharedDirector()->stopAnimation();
	
#ifndef _CLOSE_MUSIC
	SoundManager::Get()->appGotoBackground();
#endif

    if(!GamePrecedure::Get()->isInLoadingScene())
	{
        GamePrecedure::Get()->enterBackGround();
    }
	if(TimeCalculator::getInstance()->hasKey("ExitGameTime"))
	{
		if(TimeCalculator::getInstance()->getTimeLeft("ExitGameTime")<=0)
		{
			//exit(0);
		}
	}
	//--begin xinzheng 2013-7-18
	{
		
		time_t nowstamp = time(0);
		struct tm* timetm = localtime(&timestamp);
		struct tm savetm = {0};
		memcpy(&savetm, timetm, sizeof(struct tm));
		/*
			localtime返回同一個struct tm實例的指針
		*/
		struct tm* nowtm = localtime(&nowstamp);
		if (nowtm->tm_yday > savetm.tm_yday)
		{
			//exit(0);
		}
#if _DEBUG
		//test
		if (nowtm->tm_yday == savetm.tm_yday && (nowtm->tm_hour == savetm.tm_hour) && (nowtm->tm_min-savetm.tm_min) > 1)
		{
			//exit(0);
		}
#endif
		//
		timestamp = nowstamp;
	}
	//--end

	purgeCachedData();
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    if(!GamePrecedure::Get()->isInLoadingScene())
        GamePrecedure::Get()->enterForeGround();

	if (GamePrecedure::Get()->isInLoadingScene() && SeverConsts::Get()->getIsRedownLoadServer())
	{
		SeverConsts::Get()->start();
	}
	CCDirector::sharedDirector()->startAnimation();

#ifndef _CLOSE_MUSIC
	SoundManager::Get()->appResumeBackground();
#endif
}

void AppDelegate::purgeCachedData( void )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	if (m_IsOpenPurgeCacheIOS)
	{
		CCBFileNew::purgeCachedData();

		CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFramesPerFrame();

		CCTextureCache::sharedTextureCache()->removeUnusedTexturesPerFrame();
	}
	#elif(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	if (m_IsOpenPurgeCacheAndroid)
		{
			CCBFileNew::purgeCachedData();


			CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFramesPerFrame();

			CCTextureCache::sharedTextureCache()->removeUnusedTexturesPerFrame();
		}
#elif(CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			CCBFileNew::purgeCachedData();

			CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFramesPerFrame();

			CCTextureCache::sharedTextureCache()->removeUnusedTexturesPerFrame();
#endif


//#ifdef _DEBUG
//	CCTextureCache::sharedTextureCache()->dumpCachedTextureInfo();
//#endif
}

void AppDelegate::applicationWillGoToExit()
{
	if (GamePrecedure::Get()->isInLoadingScene())
	{
		GamePrecedure::Get()->exitGame();
	}
	//
	//
	CCBManager::Get()->Free();
	//
	MessageManager::Get()->Free();
	//
	PacketManager::Get()->Free();
	//
#ifndef _CLOSE_MUSIC
	SoundManager::Get()->Free();
#endif

	//
	Language::Get()->Free();
	//
	GamePrecedure::Get()->Free();
	//
	//ThreadSocket::Get()->Free();
	//
	purgeCachedData();
	//
}

void AppDelegate::setMaxCacheByteSizeLimit( unsigned int maxbytes )
{
	max_cache_bytes = maxbytes;
}


#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
extern "C" {

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeGameDestroy(JNIEnv*  env, jobject thiz) {
		CCApplication::sharedApplication()->applicationWillGoToExit();
	}
	/*
		這個Android Cocos2dxActivity onLowMemory 會控制時間間格觸發
	*/
	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativePurgeCachedData(JNIEnv*  env, jobject thiz) {
		
		CCApplication::sharedApplication()->purgeCachedData();
	}
}
#endif
