#pragma once


#include "cocos2d.h"
#include "cocos-ext.h"
#include "StateMachine.h"
#include "GamePrecedure.h"
#include "MessageManager.h"
#include "CCBManager.h"
#include "CCBContainer.h"
#include "GamePackets.h"
#include "lib91.h"
#include "libOS.h"
#include "PackageLogic.h"
#include "Concurrency.h"
#include "SeverConsts.h"
#include "ContentBase.h"
#include "CurlDownloadForScript.h"
#include "CurlDownload.h"
#include "UpdateVersion.h"

#define LoadinAniPageTag 15678

using namespace cocos2d;

class ServerListContent
	: public ContentBase
	, public cocos2d::extension::CCReViSvItemNodeFacade
{
public:
	ServerListContent(unsigned int id,CCBContainerListener* listener)
		: ContentBase(id)
		, mListener(listener)
	{};
	virtual ~ServerListContent(){};
	virtual void refreshContent(void){};

	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender, int tag){};

	virtual void rebuildAllItem(void){};
	virtual void clearAllItem(void){};
	virtual void buildItem(){};
	virtual void addItem(ContentBase* item){};
	virtual void refreshAllItem(){};
	virtual void removeItem(ContentBase* item){};

	virtual void initItemView();
	virtual void refreshItemView(cocos2d::extension::CCReViSvItemData* pItem);

protected:
	virtual const std::string& getCcbiFileName(void) const
	{
		static std::string ccbiFileName = "LoadingFrameSeverList.ccbi";
		return ccbiFileName;
	}

	virtual const std::string& getBtnCcbiFileName(void) const
	{
		static std::string ccbiStarFileName = "LoadingFrameSever.ccbi";
		return ccbiStarFileName;
	}

private:
	CCBContainerListener* mListener;
	static std::list<SeverConsts::SEVER_ATTRIBUTE> mOrderlist;
};


class SpineData
{
public:
	std::string spinePath;
	std::string spineName;
	float scaleX;
	float scaleY;
	float offsetX;
	float offsetY;
	std::string actionName;
	bool isLoadSuccess;

public:
	SpineData() :spinePath(std::string(""))
		, spineName(std::string(""))
		, scaleX(1.0f)
		, scaleY(1.0f)
		, offsetX(0.0f)
		, offsetY(0.0f)
		, actionName(std::string(""))
		, isLoadSuccess(false)
	{}
};

extern int g_iSelectedSeverIDCopy;	// 断线重连需要发serverID
class LoadingFrame
	: public BasePage
	, public State<GamePrecedure>
	, public MessageHandler
	, public CCBContainer::CCBContainerListener
	, public PacketHandlerGeneral
    , public platformListener
	, public libOSListener
	, public CurlDownload::DownloadListener
	, public CCTouchDelegate
//    , public BulletinBoardPageListener
{
private:

	enum CHILD_TAG
	{
		TAG_CONTENT,
	};
	enum MsgBoxErrCode
	{
		Err_CheckingFailed=300,
		Err_UpdateFailed,
		Err_ConnectFailed,
		Err_ErrMsgReport,
	};
	enum VERSIONSTAT
	{
		CHECK_SERVER,
		CHECK_VERSION,
		CHECK_PROJECT_ASSETS,
		CHECK_PROJECT_ASSETS_DONE,
		LOADING_ASSETS,
		UPDATE_DONE,
		UPDATE_FAIL,
		UPDATE_APP_STORE,
		NONE,
	} versionStat;

	enum ERO_LOGINTYPE {
		LOGINTYPE_NONE = -1,
		LOGINTYPE_NORMAL_ACCOUNT,
		LOGINTYPE_ERO_GUEST,
		LOGINTYPE_ERO_ACCOUNT,
	} defultType;

	enum REPORT_STEP {
		REPORT_STEP_ENTER_GAME = 1,
		REPORT_STEP_START_DOWNLOAD_APK,
		REPORT_STEP_START_DOWNLOAD_PATCH,
		REPORT_STEP_END_DOWNLOAD_PATCH,
		REPORT_STEP_ENTER_MAIN_GAME,
	};

	cocos2d::CCScene* mScene;
    bool mLogined;
	int mSelectedSeverID;
	void showSevers(bool);
	void showInputUI(bool);
    bool mNetWorkNotWorkMsgShown;
	bool mIsFirstLoginNotServerIDInfo;
	bool mIsServerListBuild;
	bool mSendLogin;
    std::string gPuid;
	int downloadSize;
	int downloadStartTime;
	int donwloadEndTime;
	float downloadStopTimer;
    
	SingleThreadExecuter mThread;




	VersionData *localVersionData;
	VersionData *serverVersionData;
	SpineData * mSpineData;
	ProjectAssetData *localProjectAssetData;
	ProjectAssetData *serverProjectAssetData;

	UpdateVersionTips * m_updateVersionTips;

	std::vector<assetData*> needUpdateAsset;

	CCProgressTimer * _ProgressTimerNode ;
	float downTotalSize;
	float currentFileLoadSize;
	std::string currentLoadFile;
	std::map<std::string, float> fileLoadSizeMap;

	std::vector<std::string> alreadyDownloadData;
	std::set<std::string> loadFailData;
	std::vector<std::string> mTipVec;


	CCTMXTiledMap * txMap;
	float touchBeganPosX;
	float touchBeganPoxY;
	bool  isTouchMoved;
	int ResumeCount;
	
private:
	CompareStat versionAppCompareStat;
	CompareStat versionResourceStat;
	int  connectCount;
	float lastPercent;



	bool m_haveLoadAnnounce;



public:
	LoadingFrame(void);
	~LoadingFrame(void);
	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender);

	CREATE_FUNC(LoadingFrame);

	virtual void load(void);

	CCScene* getRootSceneNode();

	//this will execute when the state is entered
	virtual void Enter(GamePrecedure*);

	//this is the states normal update function
	virtual void Execute(GamePrecedure*);

	//this will execute when the state is exited. (My word, isn't
	//life full of surprises... ;o))
	virtual void Exit(GamePrecedure*);
	virtual void Recycle();
	virtual void onReceiveMassage(const GameMessage * message);
	
	virtual void onReceivePacket(const int opcode, const ::google::protobuf::Message* packet);
	virtual void onConnectFailed(std::string ip, int port);
	virtual void onSendPacketFailed(const int opcode){showEnter();};
	virtual void onReceivePacketFailed(){showEnter();};
	virtual void onTimeout(const int opcode){showEnter();};
	virtual void onPacketError(const int opcode){showEnter();};

	virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
	virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);


private:
	virtual int _getOpcode() {return LOGIN_S;};
public:
    virtual void onLogin(libPlatform*, bool success, const std::string& log);
    virtual void onReLogin();
    virtual void onPlatformLogout(libPlatform*);
    virtual void onUpdate(libPlatform*,bool ok, std::string msg);
	virtual void onMessageboxEnter(int tag);
    virtual void onBuyinfoSent(libPlatform*, bool success, const BUYINFO&, const std::string& log){};
	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender, int tag);
    virtual void onAnimationDone(const std::string& animationName);

    virtual void onInputboxEnter(const std::string& content);
    virtual void onShowMessageBox(const std::string& msgString, int tag);
	virtual void OnKrIsShowFucForIOSBack(bool result){};
	virtual void OnDownloadProgress(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, long progress);
	virtual void OnDownloadComplete(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, const std::string& md5Str);
	virtual void OnDownloadFailed(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, int errorCode);
	void showLoginUser(const std::string& UserID = "", const std::string& aPwd = "", const ERO_LOGINTYPE = ERO_LOGINTYPE::LOGINTYPE_NONE);
	void showEnter();
	void hideLoginingInPercent();

	void showLoadingAniPage();
	void hidLoadingAniPage();
	void hideLoginUser();
	void setPosLoadingAniPage();
	void setOpcaityLoadingAniPage(int value);

	virtual std::string onReceiveCommonMessage(const std::string& tag, const std::string& msg);
	void showOthersNode();
	void onEnterGame(bool isRegister = false);


	void checkVersion();
	void checkServerState();
	void setTips(std::string meg);
	void setVersion(std::string meg);

	void getUpdateVersionTips();
	void getLocalVersionCfg();
	void getServerVersionCfg();
	void onHttpRequestCompleted(cocos2d::CCNode *sender, void*data);
	void onServerStateRequestCompleted(cocos2d::CCNode *sender, void*data);
	void showPersent(float persentage, std::string sizeTip);

	void sendGetServerCfg();
	void getServerCfg(unsigned char* content, bool isLocal);
	int getSelectedSeverID(){ return mSelectedSeverID; }

	void getVersionData(VersionData* versionData, unsigned char* content, bool isLocal = false);
	void getVersionAppData(VersionData* versionData, unsigned char* content, bool isLocal = false);	//新增獨立判斷APP版本
	unsigned char* readLocal(std::string fileName);
	void showFailedMessage(std::string msg , int tag  = 0);


	void compareVersion();
	void transform();
	CompareStat compareVersion(std::string localVersion, std::string serverVersion);
	std::vector<std::string> splitVersion(std::string content, std::string seperator);


	void getLocalProjectAssets();
	void getServerProjectAssets();
	//第三个参数是否是读的本地的配置
	void getProjectAssetData(ProjectAssetData* projectAssetData, unsigned char* content, bool isLocal = false, unsigned char* contentLocal = nullptr);

	void compareProjectAsset();
	void checkNewAssets();
	void UpdateAssetFromServer();
	void ResumeUpdateAsset();

	void resetVersion();
	void loadingAsset(float dt);
	void appStoreUpdate();


	void downloaded(const std::string& url, const std::string& filename);

	void downloadFailed(const std::string& url, const std::string& filename, int errorType);

	void onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& filename);

	void showLoginingInPercent(int pct);

	void showDaterTransFerBtn(bool isVisible);
	bool getUpdateServerState(){ return m_bUpdateServerName; }
	void updateSeverName();
	void setUpdateServerState(bool state){ m_bUpdateServerName = state; }
	void updateLocalSeverId();
	void ontestLogin();
	void sendGuestLogin();

	void enterBackGround();
	void enterForeGround();
	void reportDownloadEvent(std::string eventName, std::string eventInfo);
private:
	void setEnterGameNodeVisible(bool isVisible);
	void setEnterBCNodeVisible(bool isVisible);
	void setEnterServerListVisible(bool isVisble);
    void setLoginGameNodeVisible(bool isVisible);
	void setWaitGameNodeVisible(bool isVisible);
	void setLogoutNodeVisible(bool isVisible);
	void setLogoutBtnVisible(bool isVisible);
	void setLogoutCheck(bool visible);
	void showLogoutConfirm();

	void LoginSuccess();

	int getDefaultSeverID();
	void showSpine();
	void hotUpdateReport(int time, int size);
	void downloadReport(std::string url, int reslut, int count);
	void loginReport(int step);
	void loginGame(std::string& address, int port, bool isRegister = false);
	void writeProjectManifest();
	std::string split(const std::string& str, char delimiter);

	bool mIsCanShowDataTransfer;
	int  downVersionTimes; //下载Version文件 失败的次数
	int  downProjectTimes; //下载project文件 失败的次数
	int  downServerCfgTimes; //下载server文件 失败的次数
	bool m_IsCanClickStartGameBtn;//控制显示服务器列表的时候不让点击开始按钮
	bool m_IsCheckLogout;

	bool m_bUpdateServerName;
};

void logoutAccount(bool boo);