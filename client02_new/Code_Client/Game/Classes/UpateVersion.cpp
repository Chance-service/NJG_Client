
#include "stdafx.h"

#include "UpdateVersion.h"
#include "AppDelegate.h"
#include "GameMessages.h"
#include "Language.h"
#include "SeverConsts.h"
#include "GameMaths.h"
#include "ServerDateManager.h"
#include "SoundManager.h"
#include "cocos-ext.h"
#include "cocos2d.h"
#include "ActiveCodePage.h"
#include "BlackBoard.h"
#include "TimeCalculator.h"
#include "DataTableManager.h"
#include <list>
#include <vector>
//#include "comHuTuo.h"
#include "Base64.h"
#include "md5.h"
#include "LoginPacket.h"
#include "waitingManager.h"
#include "LoadingAniPage.h"
#include "GamePlatformInfo.h"
#include "GamePlatformInfo.h"
#include "SimpleAudioEngine.h"
#include "ScriptMathToLua.h"
#include "platform/CCFileUtils.h"
#include "network/HttpClient.h"
#include "network/HttpRequest.h"
#include "AssetsManagerEx.h"


USING_NS_CC;
USING_NS_CC_EXT;

REGISTER_PAGE("UpdateVersion",UpdateVersion);

#define downLoadSavePath         "hotUpdate"
#define versionPath              "version"
#define versionManifestName      "version.manifest"
#define projectManifestName      "project.manifest"
#define projectManifestLocalName "projectLocal.manifest"
#define updateVersionTipsName    "UpdateVersionTips.cfg"

UpdateVersion::UpdateVersion(void) : mScene(NULL)
	,localVersionData(NULL)
    ,serverVersionData(NULL)
	,m_updateVersionTips(NULL)
    ,downTotalSize(0)
    ,currentFileLoadSize(0)
    ,versionStat(NONE)
	,versionAppCompareStat(EQUAL)
	,versionResourceStat(EQUAL)
{}


UpdateVersion::~UpdateVersion(void)
{
	
}

void UpdateVersion::Enter( GamePrecedure* )
{
	CCLOG("enter UpdateVersion frame");
 
	mScene = CCScene::create();
	mScene->retain();

	mScene->addChild(this);
	
	load();
    setTips("");

	CCDirector::sharedDirector()->setDepthTest(true);
	// run
	if(cocos2d::CCDirector::sharedDirector()->getRunningScene())
		cocos2d::CCDirector::sharedDirector()->replaceScene(mScene);
	else
		cocos2d::CCDirector::sharedDirector()->runWithScene(mScene);

	checkVersion();
}

void UpdateVersion::Exit( GamePrecedure* )
{	
	libOS::getInstance()->removeListener(this);
	
	unload();
	mScene->removeAllChildrenWithCleanup(true);
	mScene->release();
	CCLOG("loading frame mScene retainCount:%d",mScene->retainCount());
	mScene = NULL;
    
    CCHttpClient::getInstance()->destroyInstance();
    CurlDownload::Get()->removeListener(this);
}

void UpdateVersion::Execute( GamePrecedure* gp)
{
	if (CurlDownload::Get())
	{
		CurlDownload::Get()->update(0.2);
	}
    
    loadingAsset();
}

void UpdateVersion::onMenuItemAction( const std::string& itemName ,cocos2d::CCObject* sender)
{
	if(itemName == "onUpdate")
	{
        if (versionStat == UPDATE_APP_STORE)
        {
            appStoreUpdate();
        }
        else if (versionStat == CHECK_PROJECT_ASSETS_DONE)
        {
            UpdateAssetFromServer();
        }
		else if (versionStat == UPDATE_FAIL)
		{
			exit(0);
		}
	}
	else if (itemName == "onMail")
	{
		//邮件按钮事件
		this->onSendMailClick();
	}
}

//邮件按钮事件
void UpdateVersion::onSendMailClick()
{
	//TODO  创建发送邮件面板

	CCLOG("邮件邮件1111111111111111");

	
}

void UpdateVersion::onAnimationDone(const std::string& animationName){
	if (animationName == "LogoAni")
	{
		
	}
}

void UpdateVersion::load(void)
{
	loadCcbiFile("UpdateVersion.ccbi");

	TipsManager::TipsItemListIterator itr = TipsManager::Get()->getTipsIterator();
	while(itr.hasMoreElements())
	{
		std::string tip = itr.getNext()->tip;
		mTipVec.push_back(tip);
	}
    
	//this->runAnimation("LogoAni");
}

void UpdateVersion::loadingAsset()
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
		if ( m_updateVersionTips)
		{
			setTips(m_updateVersionTips->uncompressTxT);
		}
        versionStat = UPDATE_DONE;
        
        showPersent( 1,std::string(""));
        
        for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
            bool value = AssetsManagerEx::getInstance()->uncompress((*it)->savePath, (*it)->stroge);
            CCLOG("hotUpdate uncompress: %s", ((*it)->name).c_str());
            
            // delete file
            remove((*it)->savePath.c_str());
        }

		if (m_updateVersionTips)
		{
		    setTips(m_updateVersionTips->uncompressCompleteTxT);
		}
        
        CCLOG("hotUpdate uncompress complete");
        resetVersion();
        GamePrecedure::Get()->enterLoading();
        return;
    }
    
    if (alreadyDownloadData.size() + loadFailData.size() >= needUpdateAsset.size())
    {
        versionStat = UPDATE_FAIL;
		CCB_FUNC(this,"mUpdateBtnNode",cocos2d::CCNode,setVisible(true));
		if (m_updateVersionTips)
		{
			setTips( m_updateVersionTips->updateFailTxT);
			showFailedMessage(m_updateVersionTips->updateFailTxT);
			setActionBtnTxt(m_updateVersionTips->confirmBtnTxT);
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
    showPersent( persentage,std::string(""));
}

void UpdateVersion::showPersent( float persentage,std::string sizeTip )
{
	if(getVariable("mPersentage"))
	{
		CCNode* sever = dynamic_cast<CCNode*>(getVariable("mPersentage"));
		if(persentage>1.0f)
			persentage = 1.0f;
		if(persentage<=0.00f)
			persentage = 0.01f;

		if(sever) 
			sever->setScaleX(persentage);
	}
	if(getVariable("mPersentageTxt"))
	{
		CCLabelBMFont* sever = dynamic_cast<CCLabelBMFont*>(getVariable("mPersentageTxt"));
		char perTxt[64];
		sprintf(perTxt,"%d%%   %s",(int)(persentage*100),sizeTip.c_str());
		if(sever) 
			sever->setString(perTxt);
	}
}

void UpdateVersion::checkVersion()
{
	CCB_FUNC(this,"mUpdateBtnNode",cocos2d::CCNode,setVisible(false));
	setTips(std::string(""));

	getUpdateVersionTips();

    versionStat = CHECK_VERSION;
    
    cocos2d::CCFileUtils::sharedFileUtils()->setPopupNotify(true); // is read file fail show messageBox
	std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
    cocos2d::CCFileUtils::sharedFileUtils()->insertSearchPath(writeRootPath.c_str(), 0);

    cocos2d::CCFileUtils::sharedFileUtils()->insertSearchPath((writeRootPath + downLoadSavePath + "/").c_str(), 0);
    cocos2d::CCFileUtils::sharedFileUtils()->insertSearchPath((writeRootPath + versionPath + "/").c_str(), 0);
    
    CurlDownload::Get()->addListener(this);
    
    localVersionData = new VersionData();
    getLocalVersionCfg();
    
    serverVersionData = new VersionData();
    getServerVersionCfg();
}

void UpdateVersion::getUpdateVersionTips()
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
	if(!pBuffer)
	{
		std::string fullPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename((std::string(fileName)).c_str());
	    std::string msg = "Get updateVersionTios data from file(";
		msg.append(fileName).append(") failed!").append("   filePath:").append(fullPath.c_str());
	    cocos2d::CCMessageBox(msg.c_str(),"File Not Found");
	}

	if(!pBuffer)
	{
		{
			CC_SAFE_DELETE_ARRAY(pBuffer);
			return;
		}
	}
	
	bool ret = jreader.parse(pBuffer, filesize, data, false);
	if(	!ret)
	{
		return;
	}
	
	m_updateVersionTips = new UpdateVersionTips();
	m_updateVersionTips->checkVersionTxT = data["checkVersionTxT"].asString();
	m_updateVersionTips->noAssetNeedUpdateTxT = data["noAssetNeedUpdateTxT"].asString();
	m_updateVersionTips->newAssetNeedUpdateTxT = data["newAssetNeedUpdateTxT"].asString();
	m_updateVersionTips->startUpdateTxT = data["startUpdateTxT"].asString();
	m_updateVersionTips->checkFailTxT = data["checkFailTxT"].asString();
	m_updateVersionTips->notNetworkTxT = data["notNetworkTxT"].asString();
	m_updateVersionTips->updateFailTxT = data["updateFailTxT"].asString();
    m_updateVersionTips->uncompressTxT = data["uncompressTxT"].asString();
	m_updateVersionTips->uncompressCompleteTxT = data["uncompressCompleteTxT"].asString();
    m_updateVersionTips->appStoreUpdateTxT = data["appStoreUpdateTxT"].asString();
	m_updateVersionTips->updateBtnTxT = data["updateBtnTxT"].asString();
	m_updateVersionTips->confirmBtnTxT = data["exitBtnTxT"].asString();
}

void UpdateVersion::checkNewAssets()
{
	versionStat = CHECK_PROJECT_ASSETS;
	localProjectAssetData = new ProjectAssetData();
    getLocalProjectAssets();
    
    serverProjectAssetData = new ProjectAssetData();
    getServerProjectAssets();
}

void UpdateVersion::UpdateAssetFromServer()
{   
    CCLOG("hotUpdate : UpdateAssetFromServer");
    
    CCB_FUNC(this,"mUpdateBtnNode",cocos2d::CCNode,setVisible(false));
    if (m_updateVersionTips)
	{
        setTips(m_updateVersionTips->startUpdateTxT);
	}

	versionStat = LOADING_ASSETS;
    
    downTotalSize = 0;
    currentFileLoadSize = 0;
    alreadyDownloadData.clear();
    
    showPersent(0, std::string(""));
    CCB_FUNC(this,"mPersentageNode",cocos2d::CCNode,setVisible(true));
    
    std::string packageUrl = serverVersionData->packageUrl;
    std::string writeablePath = CCFileUtils::sharedFileUtils()->getWritablePath();
    for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
        std::string assetUrl = packageUrl + "/" + (*it)->name;
        std::string writePath = writeablePath + "/" + downLoadSavePath + "/" + (*it)->name;
        
        (*it)->url = assetUrl;
        (*it)->savePath = writePath;
        (*it)->stroge = writeablePath + downLoadSavePath + "/";
        downTotalSize += (*it)->size;
        CurlDownload::Get()->downloadFile(assetUrl, writePath);
    }
}

unsigned char* UpdateVersion::readLocal(std::string fileName)
{
    unsigned long filesize;
    unsigned char* content = CCFileUtils::sharedFileUtils()->getFileData(fileName.c_str(), "r", &filesize);
    
    CCLOG("hotUpdate : readLocal content:%s", content);
    return content;
}

void UpdateVersion::getLocalVersionCfg()
{   
	unsigned char* content = readLocal(std::string(versionManifestName));

	if (! content)
	{
		std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
		return;
	}
    getVersionData(localVersionData, content);
	if (localVersionData && localVersionData->isLoadSuccess)
	{
		std::string ver = "Ver" + localVersionData->versionApp;
		setVersion(ver);
	}
}

void UpdateVersion::getServerVersionCfg()
{
    std::string url = localVersionData->remoteVersionUrl;
    auto request = new CCHttpRequest();
    request->setUrl(url.c_str());
    request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
    request->setResponseCallback(this,callfuncND_selector(UpdateVersion::onHttpRequestCompleted));
    
    request->setTag("serverVersionCfg");
    
    CCHttpClient::getInstance()->send(request);
    
    CCLOG("hotUpdate : getServerVersionCfg 2");

    request->release();
}

void UpdateVersion::getVersionData(VersionData* versionData, unsigned char* content)
{
	if (! content)
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
	versionData->versionResource = value["versionResource"].asString();
	versionData->isLoadSuccess = true;
}

void UpdateVersion::compareVersion()
{
	cocos2d::CCLog("UpdateVersion compareVersion()");
	if (m_updateVersionTips)
	{
	    setTips(m_updateVersionTips->checkVersionTxT);
	}

	if (!serverVersionData || !serverVersionData->isLoadSuccess)
	{
		showFailedMessage(m_updateVersionTips->checkFailTxT);
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

	     versionApp      versionCode      versionResource      resourceUpdate      AppStore update
           EQUAL            EQUAL              EQUAL                NO                   NO

           EQUAL            EQUAL              LESS                YES                   NO
       
           EQUAL            LESS             not care               NO                  YES

           LESS             EQUAL            not care              YES                   NO

           LESS             LESS             not care               NO                  YES
	*/

	int result = 0; // result = 0  not update, result = 1 resourse update, result = 2 appStore update 
	if (versionAppCompareStat == LESS) {
		result = 2;
	}
	else if (versionAppCompareStat == HIGH) {
		result = 0;
	}
	else {
		result = 1;
	}

    if (result == 0)
    {
        GamePrecedure::Get()->enterLoading();
        return;
    }

	if (result == 1)
	{
		checkNewAssets();
		return;
	}

	if (result == 2)
	{
		versionStat = UPDATE_APP_STORE;
        CCB_FUNC(this,"mUpdateBtnNode",cocos2d::CCNode,setVisible(true));
        if (m_updateVersionTips)
        {
            setTips(m_updateVersionTips->appStoreUpdateTxT);
			setActionBtnTxt(m_updateVersionTips->confirmBtnTxT);
        }

        return;
	}
}

void UpdateVersion::appStoreUpdate()
{   
	if (!serverVersionData || !serverVersionData->isLoadSuccess)
	{
		 return;
	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	if (SeverConsts::Get()->IsH365()) {
		cocos2d::CCLog("UpdateVersion appStoreUpdate H365");
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
	else if (SeverConsts::Get()->IsAPLUS()) {
		std::string cps = libPlatformManager::getPlatform()->getClientCps();
		if (cps == "#1") {
			libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlAPLUS_CPS1);
		}
		else {
			libOS::getInstance()->openURL(serverVersionData->AppUpdateUrlAPLUS_CPS1);
		}
	}
	else {
		cocos2d::CCLog("UpdateVersion appStoreUpdate Default");
		libOS::getInstance()->openURL(serverVersionData->AndroidStoreURL);
	}
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    libPlatformManager::getInstance()->getPlatform()->updateApp(serverVersionData->IOSAppStoreURL);
	
#endif
}

CompareStat UpdateVersion::compareVersion(std::string localVersion, std::string serverVersion)
{
	CompareStat stat = EQUAL;

    std::vector<std::string> localVector = splitVersion(localVersion, ".");
    std::vector<std::string> serverVector = splitVersion(serverVersion, ".");
    
    for (size_t i = 0; i < serverVector.size(); ++i) {
        std::string serverValue = serverVector[i];
        if (i >= localVector.size())
        {
            stat = LESS;
			break;
        }
        
        std::string localValue = localVector[i];
        
        int server = std::atoi(serverValue.c_str());
        int local = std::atoi(localValue.c_str());
        if (server > local)
        {
            stat = LESS;
			break;
        }
    }
    
    return stat;
}

void UpdateVersion::getLocalProjectAssets()
{
    unsigned char* content = readLocal(projectManifestName);
	unsigned char* contentLocal = readLocal(projectManifestLocalName);
	if (! content)
	{
		return;
	}

	if (!content){
		getProjectAssetData(localProjectAssetData, contentLocal);
	}
	else if (!contentLocal){
		getProjectAssetData(localProjectAssetData, content);
	}
	else{
		getProjectAssetData(localProjectAssetData, content, contentLocal);
	}
}

void UpdateVersion::getServerProjectAssets()
{
    if (!localVersionData)
    {
        return;
    }
    
	std::string url = localVersionData->packageUrl;
    
    auto request = new CCHttpRequest();
    request->setUrl(url.c_str());
    request->setRequestType(CCHttpRequest::HttpRequestType::kHttpGet);
    //request->setResponseCallback(this, httpresponse_selector(UpdateVersion::onHttpRequestCompleted));
	request->setResponseCallback(this, callfuncND_selector(UpdateVersion::onHttpRequestCompleted));
	
    request->setTag("serverProjectAsset");
    
    CCHttpClient::getInstance()->send(request);
    
    request->release();
}

void UpdateVersion::getProjectAssetData(ProjectAssetData* projectAssetData, unsigned char* content, unsigned char* contentLocal)
{
    Json::Reader reader;
    Json::Value value;
	Json::Reader readerLocal;
	Json::Value valueLocal;
    
    CCLOG("hotUpdate getVersionData: %s", content);
    
    const char* constContent = (const char*)(char*)content;
    
    bool ret = reader.parse(constContent, value);
    
    if (!ret)
    {
        CCLOG("hotUpdate getVersionData: fail");
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
		}
	}
	else{
		valueTrue = value;
	}

	Json::Value files = valueTrue["assets"];
    if(!files.empty() && files.isArray())
    {
        for(int i = 0;i < files.size();++i)
        {
            Json::Value unit = files[i];
            if(unit["name"].empty())
            {
                continue;
            }
            
            assetData* data = new assetData();
            data->name = unit["name"].asString();
            data->md5 = unit["md5"].asString();
            
            data->size = unit["size"].asInt();
            
            projectAssetData->addAssetData(data);
        }
    }
}

void UpdateVersion::compareProjectAsset()
{
    if (!localProjectAssetData || !localProjectAssetData->isLoadSuccess || !serverProjectAssetData || !serverProjectAssetData->isLoadSuccess)
    {   
		if (m_updateVersionTips)
		{
		    setTips(m_updateVersionTips->noAssetNeedUpdateTxT);
		}
		GamePrecedure::Get()->enterLoading();
        return;
    }
    
    needUpdateAsset.clear();
    
	int downSize = 0;
    for (std::map<std::string, assetData *>::const_iterator it = serverProjectAssetData->assetDataMap.begin(); it != serverProjectAssetData->assetDataMap.end(); ++it) {
        //std::cout << it->first << " => " << it->second << '\n';
        std::string name = it->first;
        assetData* data = it->second;
        
        auto localIt = localProjectAssetData->assetDataMap.find(name);
        if(localIt == localProjectAssetData->assetDataMap.end())
        {
            needUpdateAsset.push_back(data);
			downSize += data->size;
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
        GamePrecedure::Get()->enterLoading();
        return;
    }
    
    CCB_FUNC(this,"mUpdateBtnNode",cocos2d::CCNode,setVisible(true));

	if (m_updateVersionTips)
	{
		setActionBtnTxt(m_updateVersionTips->updateBtnTxT);

	    downSize /= 1024;
	    downSize = (downSize > 1) ? downSize : 1;
		const char* size = CCString::createWithFormat("%d", downSize)->getCString();

	    std::string needUpdateAsset = m_updateVersionTips->newAssetNeedUpdateTxT + std::string(size) + "M";
	    setTips(needUpdateAsset);
	}
}

void UpdateVersion::onHttpRequestCompleted(cocos2d::CCNode *sender, void*data)
{
    CCLOG("hotUpdate : onHttpRequestCompleted");
    
    CCHttpResponse* response = (CCHttpResponse*)data;
    if (!response->isSucceed())
    {
        CCLOG("hotUpdate: onHttpRequestCompleted fail");
        return;
    }

    int codeIndex = response->getResponseCode();
    if (codeIndex < 0)
    {
        CCLOG("hotUpdate : codeIndex: %d", codeIndex);
    }
    const char* tag = response->getHttpRequest()->getTag();

    std::vector<char>* buffer = response->getResponseData();
    std::string temp(buffer->begin(), buffer->end());
    CCString* responseData = CCString::create(temp);
    const char* content = responseData->getCString();
    
    const char* serverVersionTag = "serverVersionCfg";
    const char* serverProjectAssetTag = "serverProjectAsset";
    
    CCLOG("hotUpdate : onHttpRequestCompleted 2");
    unsigned char *unsignedContent= (unsigned  char *)(content);
    if ( strcmp(tag, serverVersionTag) == 0)
    {
        getVersionData(serverVersionData, unsignedContent);
        compareVersion();
    }
    else if (strcmp(tag, serverProjectAssetTag) == 0)
    {
        getProjectAssetData(serverProjectAssetData, unsignedContent);
        compareProjectAsset();
    }
}

void UpdateVersion::setTips(std::string meg)
{
    CCLabelBMFont* tipsLabel = dynamic_cast<CCLabelBMFont*>(getVariable("mTips"));//mLoading1
    if(tipsLabel)
    {
        tipsLabel->setString(meg.c_str());
    }
}

void UpdateVersion::setVersion(std::string meg)
{
	CCLabelBMFont* versionLabel = dynamic_cast<CCLabelBMFont*>(getVariable("mVersion"));//mLoading1
    if(versionLabel)
    {
        versionLabel->setString(meg.c_str());
    }
}

void UpdateVersion::setActionBtnTxt(std::string meg)
{
	CCLabelTTF* mbtnLabel = dynamic_cast<CCLabelTTF*>(getVariable("mbtn"));
	if (mbtnLabel)
	{
		mbtnLabel->setString(meg.c_str());
	}
}

void UpdateVersion::showFailedMessage(std::string meg)
{
	if(libOS::getInstance()->getNetWork()==NotReachable)
	{
		libOS::getInstance()->showMessagebox(m_updateVersionTips->notNetworkTxT);
	}
	else
	{
		libOS::getInstance()->showMessagebox(meg);
	}
}

std::vector<std::string> UpdateVersion::splitVersion(std::string content, std::string seperator)
{
    std::vector<std::string> result;
    
    string::size_type cutAt;
    while( (cutAt = content.find_first_of(seperator)) != content.npos )
    {
        if(cutAt > 0)
        {
            result.push_back(content.substr(0, cutAt));
        }
            
        content = content.substr(cutAt + 1);
    }
    
    if(content.length() > 0)
    {
        result.push_back(content);
    }
    
    return result;
}

void UpdateVersion::resetVersion()
{
    std::string writeRootPath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();

    std::string saveVersionPath = writeRootPath + versionPath + "/" + versionManifestName;
    CurlDownload::Get()->downloadFile(localVersionData->remoteVersionUrl, saveVersionPath);
    
    std::string saveProjectAssetPath = writeRootPath + versionPath + "/" + projectManifestName;
	CurlDownload::Get()->downloadFile(localVersionData->packageUrl, saveProjectAssetPath);
}

void UpdateVersion::downloaded(const std::string &url, const std::string& filename)
{
    CCLOG("hotUpdate download  url: %s    : filename : %s ", url.c_str(), filename.c_str());
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.compare((*it)->url) == 0)
		{
			CCLOG("hotUpdate download  url pushBack to alreadyDownloadData: %s    : filename : %s ", url.c_str(), filename.c_str());
			alreadyDownloadData.push_back(url);
		}
    }
}

void UpdateVersion::downloadFailed(const std::string& url, const std::string &filename)
{
	CCLOG("hotUpdate downloadFailed  url: %s    : filename : %s ", url.c_str(), filename.c_str());
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.compare((*it)->url) == 0)
		{
			CCLOG("hotUpdate downloadFailed  url push_back to loadFailData: %s    : filename : %s ", url.c_str(), filename.c_str());
			loadFailData.push_back(url);
		}
    }
    //CurlDownload::Get()->reInit();
}

void UpdateVersion::onAlreadyDownSize(unsigned long size)
{
	//CCLOG("hotUpdate onAlreadyDownSize  size: %d", (int)size);
    currentFileLoadSize = float(size);
}







