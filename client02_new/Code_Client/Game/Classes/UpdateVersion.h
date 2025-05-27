#pragma once


#include "cocos2d.h"
#include "cocos-ext.h"
#include "StateMachine.h"
#include "GamePrecedure.h"
#include "CCBManager.h"
#include "CCBContainer.h"
#include "GamePackets.h"
#include "libOS.h"
#include "Concurrency.h"
#include "SeverConsts.h"
#include "ContentBase.h"
#include "CurlDownloadForScript.h"
#include "CurlDownload.h"

using namespace cocos2d;

class UpdateVersionTips
{
public:
	std::string checkVersionTxT;
	std::string noAssetNeedUpdateTxT;
	std::string newAssetNeedUpdateTxT;
	std::string startUpdateTxT;
	std::string checkFailTxT;
	std::string checkProjectFailTxT;
	std::string notNetworkTxT;
	std::string updateFailTxT;
	std::string uncompressTxT;
	std::string uncompressCompleteTxT;
    std::string appStoreUpdateTxT;
	std::string updateBtnTxT;
	std::string confirmBtnTxT;

	UpdateVersionTips():checkVersionTxT(std::string(""))
		 ,noAssetNeedUpdateTxT(std::string(""))
		 ,newAssetNeedUpdateTxT(std::string(""))
		 ,startUpdateTxT(std::string(""))
		 ,checkFailTxT(std::string(""))
		 ,checkProjectFailTxT(std::string(""))
		 ,notNetworkTxT(std::string(""))
		 ,updateFailTxT(std::string(""))
		 ,uncompressTxT(std::string(""))
         ,appStoreUpdateTxT(std::string(""))
		 ,updateBtnTxT(std::string(""))
		 ,confirmBtnTxT(std::string(""))
	{}
};

class VersionData
{
public:
    std::string packageUrl;
    std::string versionApp;
    std::string remoteVersionUrl;
	std::string IOSAppStoreURL;
	std::string AndroidStoreURL;
	std::string AppUpdateUrlH365;
	std::string AppUpdateUrlR18;
	std::string AppUpdateUrlKUSO;
	std::string AppUpdateUrlEROLABS;
	std::string AppUpdateUrlOP;
	std::string AppUpdateUrlJSG;
	std::string AppUpdateUrlAPLUS_CPS1;
	std::string versionResource;
	int isNeedGoAppStore;
    
	bool isLoadSuccess;
    
public:
     VersionData():packageUrl(std::string(""))
		 ,versionApp(std::string(""))
		 ,remoteVersionUrl(std::string(""))
		 ,IOSAppStoreURL(std::string(""))
		 ,AndroidStoreURL(std::string(""))
		 ,AppUpdateUrlH365(std::string(""))
		 ,AppUpdateUrlR18(std::string(""))
		 ,AppUpdateUrlKUSO(std::string(""))
		 ,AppUpdateUrlEROLABS(std::string(""))
		  ,AppUpdateUrlOP(std::string(""))
		 ,AppUpdateUrlJSG(std::string(""))
		 ,AppUpdateUrlAPLUS_CPS1(std::string(""))
		 ,versionResource(std::string(""))
		 ,isLoadSuccess(false)
		 ,isNeedGoAppStore(0)
	 {}
};

class assetData
{
public:
    std::string url;
    std::string name;
    std::string md5;
    int size;
    std::string savePath;
    std::string stroge;
	std::string crc;
	double time;
};

class ProjectAssetData
{
public:
    ProjectAssetData():isLoadSuccess(false){}

    void addAssetData(assetData *data)
    {
        assetDataMap[data->name] = data;
    }
public:
	bool isLoadSuccess;
	double time;
    std::map<std::string, assetData *> assetDataMap;
};

enum CompareStat
{
	GREATER,
	EQUAL,
	LESS,
	HIGH,
};

class UpdateVersion
	: public BasePage
	, public State<GamePrecedure>
	, public CCBContainer::CCBContainerListener
    , public platformListener
	, public libOSListener
    , public CurlDownload::DownloadListener
{
private:
	cocos2d::CCScene* mScene;
    
    VersionData *localVersionData;
    VersionData *serverVersionData;
    
    ProjectAssetData *localProjectAssetData;
    ProjectAssetData *serverProjectAssetData;

	UpdateVersionTips * m_updateVersionTips;

	std::vector<assetData*> needUpdateAsset;

private:
	CompareStat versionAppCompareStat;
	CompareStat versionResourceStat;
    
public:
    enum VERSIONSTAT
    {
        CHECK_VERSION,
        CHECK_PROJECT_ASSETS,
		CHECK_PROJECT_ASSETS_DONE,
        LOADING_ASSETS,
        UPDATE_DONE,
        UPDATE_FAIL,
		UPDATE_APP_STORE,
        NONE,
    } versionStat;
    
public:
    float downTotalSize;
    float currentFileLoadSize;
    
    std::vector<std::string> alreadyDownloadData;
    std::vector<std::string> loadFailData;

public:
	UpdateVersion(void);
	~UpdateVersion(void);

	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender);
    virtual void onAnimationDone(const std::string& animationName);
    
	CREATE_FUNC(UpdateVersion);
    
    virtual void load(void);

	//
	CCScene* getRootSceneNode();
	void showLogAni();

	//this will execute when the state is entered
	virtual void Enter(GamePrecedure*);

	//this is the states normal update function
	virtual void Execute(GamePrecedure*);

	//this will execute when the state is exited. (My word, isn't
	//life full of surprises... ;o))
	virtual void Exit(GamePrecedure*);

    void downloaded(const std::string& url, const std::string& filename);
    
	void downloadFailed(const std::string& url, const std::string& filename, int errorType);
    
	void onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& filename);
    
private:
    
    std::vector<std::string> mTipVec;
    
    void showPersent( float persentage,std::string sizeTip );
	void checkVersion();
	void getUpdateVersionTips();
    void onHttpRequestCompleted(cocos2d::CCNode *sender, void*data);
    
    unsigned char* readLocal(std::string fileName);
	void onSendMailClick();
    void getLocalVersionCfg();
    void getServerVersionCfg();
    void getVersionData(VersionData* versionData, unsigned char* content);
    void compareVersion();
    CompareStat compareVersion(std::string localVersion, std::string serverVersion);
    std::vector<std::string> splitVersion(std::string content, std::string seperator);
        
    void getLocalProjectAssets();
    void getServerProjectAssets();
	void getProjectAssetData(ProjectAssetData* projectAssetData, unsigned char* content, unsigned char* contentLocal = nullptr);
    
    void compareProjectAsset();
    
	void checkNewAssets();
    void UpdateAssetFromServer();
    
	void setActionBtnTxt(std::string meg);
    void setTips(std::string meg);
	void setVersion(std::string meg);
    
    void resetVersion();
    void loadingAsset();

	void appStoreUpdate();

	void showFailedMessage(std::string meg);
};


