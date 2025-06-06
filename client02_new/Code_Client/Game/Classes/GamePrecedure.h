﻿#pragma once

#include "Singleton.h"
#include "StateMachine.h"
#include "CCScheduler.h"
#include "cocos2d.h"
#include <map>
#include <google/protobuf/message.h>
#include "PacketManager.h"
//#include "BulletinManager.h"
#include "CCCommon.h"
#include "DataTableManager.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <regex>
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID||CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <regex.h>
#endif

class CCBContainer;
class LogoFrame;
class UpdateVersion;
class LoadingFrame;
class MainFrame;

#define AFTER_LOGIN_PACKET_NUM 10

class GamePrecedure : 
	public cocos2d::CCObject,
	public PacketHandler,
	public Singleton<GamePrecedure>
{
protected:
	cocos2d::LanguageType mCurrentLanguageType;
	LogoFrame *mLogoFrame;
    UpdateVersion *mUpdateVersion;
	LoadingFrame *mLoadingFrame;
	MainFrame *mMainFrame;

	CCBContainer *mLoadFrameCcbiPreLoad;

	StateMachine<GamePrecedure> *m_pStateMachine;
	//RythemTouchState * m_pTouchState;

	cocos2d::CCScheduler* m_pScheduler;
	float mFrameTime;
	float mTotalTime;
    bool mInLoadingScene;
	bool gotoMainScene;
	bool mIsReEnterLoadingFrame;	//zhengxin 2014-08-10是否是从MainFrame退回到LoadingFrame的
	float mGotHeartBeatTime;		//zhengxin 2014-08-2310秒钟未收到心跳回报的情况下，重置一次强制needreconnect


	int mServerID;
	std::string mUin;

	float mHeartbeatTime;
    bool mInitialized;
	int mServerTime;
	std::string mServerData;

	bool mCanIntoGame;


	bool mReadTables;
	bool mInitLuaDone;

	bool mHasAlertServerUpdating;

	std::string mPlayerUin;
	std::string mLoginCode;
	bool mStartLoginJiShi;	//处于登录收包计时，20秒菊花，超时玩家可重新点击进入游戏（disconnect、connect）
	int mLoginPacketsReceivedCount;
	int mLoginRequestPacketsTotalCount;
	//--end

	bool m_loginPacketAssemblySuccess;


	//判断是否roleId为0，来表示该玩家是否进入选角色页面
	bool mHasMainRole;

	bool mUserKickStatus;
	int mServerOpenDay;
	std::string DefaultPwd;
	std::string Wallet;
	struct REQUEST_PACKAGE
	{
		int opcode;
		int opcoderet;
		::google::protobuf::Message* message;
		bool bfirstsent;
	};
	//std::list<REQUEST_PACKAGE> mRequestPackages;
    //BulletinManager* m_pBulletinMgr;

	bool _requestPackage(int opcode, int opcoderet, ::google::protobuf::Message* message);
	void _gotPackage(int opcoderet);
	void _failedPakcage(int opcode, bool isSendFaild);
public:
	bool m_logoutCallback;//韩国logout，SDK有消息反馈后此变量为ture
	GamePrecedure()
		:mLoadingFrame(0)
		,mUpdateVersion(0)
		,mLogoFrame(0)
		,mMainFrame(0)
		,mFrameTime(0)
		,mLoadFrameCcbiPreLoad(0)
		,mTotalTime(0),mGotHeartBeatTime(0.f)
		,m_pScheduler(0)
		,m_pStateMachine(0)
        ,mInLoadingScene(true),mIsReEnterLoadingFrame(false)
		,mHasMainRole(true)
		,gotoMainScene(false)
		,mHeartbeatTime(0)
        ,mInitialized(false)
		,mServerTime(0)
		,mServerData("")
		,mHasAlertServerUpdating(false),mLoginRequestPacketsTotalCount(0)
		,mServerOpenDay(0),mStartLoginJiShi(false),mLoginPacketsReceivedCount(0)
		,mUserKickStatus(false)
		,mPlayerUin("")
		,mLoginCode("")
		,mInitLuaDone(false)
		,m_loginPacketAssemblySuccess(false)
        //,m_pBulletinMgr(NULL)
		, mCurrentLanguageType(cocos2d::kLanguageChinese)
		,m_logoutCallback(false)
		, mCanIntoGame(false)
		, DefaultPwd("")
		//,m_pTouchState(0)
	{
		
	}

	~GamePrecedure();

	static GamePrecedure* getInstance(){return GamePrecedure::Get();}

	void init();
	void startupreport();
	void loadPlsit();
	void unInit();//clear memory
	//--end
	//glj 19-3-13
	void loadCcbi();


	void reset();

	LoadingFrame* getLoadingFrame();

	void enterLogoMovie();
	void enterLoading();
	void reEnterLoading();
	void reEnterGame();
	void reEnterLoadingForEnterMate();/*韩国-收到SDK反馈后调用此函数*/
	void reEnterMateLogout();//韩国logout退出到选择服务器界面
	void preEnterMainMenu();
	void readTables();
	//void requestPackages();
	//void reRequestPackages();
	/*
	*/
	std::string getServerNameById(int nServerId);
	void showLoadingEnter();

	void enterMainMenu();
	void enterGame();
	void enterInstruction(int id = -1);//-1 means start from the first
	void exitGame();
	void update(float dt);

    bool isInLoadingSceneAndNeedExit();
    bool isInLoadingScene(){return mInLoadingScene;}
	bool isReEnterLoadingFrame(){return mIsReEnterLoadingFrame;}
    void setInLoadingScene();//{mInLoadingScene = true;}
	float getFrameTime();
	float getTotalTime();
	void setGotHeartBeatTime(){mGotHeartBeatTime = 0.f;}
    
	void enterBackGround();
	void enterLoadingBackGround();
    void enterForeGround();
	void enterLoadingForeGround();

	void initLuaEnv();

	bool getLoginAssemblyFinished(){return m_loginPacketAssemblySuccess;};
	void setLoginAssemblyFinished(bool flag){m_loginPacketAssemblySuccess = flag;};
	void setHasMainRole(bool has){mHasMainRole = has;};
	int getHasMainRole(){ return (mHasMainRole == true) ? 1 : 0;};

	void setServerID(int serverID){mServerID = serverID;}
	int getServerID(){return mServerID;}
	void setLoginUin(std::string uid) { mPlayerUin=uid;}
	std::string getLoginUin() { return mPlayerUin;}
	void setLoginCode(std::string code) { mLoginCode = code; }
	std::string getLoginCode() { return mLoginCode; }

	int getServerTime(){ return mServerTime;};
	std::string getServerData(){return mServerData;}
	void setServerTime(int serverTime){ mServerTime=serverTime;};
	void setServerData(const std::string& data){mServerData = data;}
	void setUin(const std::string& uin){mUin = uin;}
	const std::string& getUin(){return mUin;}
	void setServerOpenTime(int _openDay){ mServerOpenDay=_openDay;};
	int getServerOpenTime(){ return mServerOpenDay;};
	void setDefaultPwd(std::string apass){ DefaultPwd = apass; }
	std::string getDefaultPwd(){ return DefaultPwd; }
	void setWallet(std::string wallet){ Wallet = wallet; }
	std::string getWallet(){ return Wallet; }
	bool hasAlertServerUpdating(){return mHasAlertServerUpdating;}
	void setAlertServerUpdating(bool hasAlert){mHasAlertServerUpdating = hasAlert;}
	//引擎层给游戏截图，返回png文件存储绝对路径
	const std::string gameSnapshot(const int &posX,const int &posY, const int &width,const int &height,bool fullScreen = false);

	void setUserKickedByServer(){ mUserKickStatus=true;};

	bool getUserKickedByServer(){return mUserKickStatus;};
	//监听所有超时重连发送的包接收情况,若全部接收完成后,判定为重连成功,
	virtual void onReceivePacket(const int opcode, const ::google::protobuf::Message* packet){_gotPackage(opcode);}
	//重连后，包若发送失败继续发送
	virtual void onSendPacketFailed(const int opcode){_failedPakcage(opcode,true);}
	virtual void onReceivePacketFailed() { _failedPakcage(0, false); } ;
	virtual void onConnectFailed(std::string ip, int port);
	virtual void onTimeout(const int opcode){_failedPakcage(opcode,true);}
	virtual void onPacketError(const int opcode){_failedPakcage(opcode,true);_failedPakcage(opcode,false);}
    
    void showBulletin();
    void closeBulletin();
	void setCurrentLanguageType(cocos2d::LanguageType type);
	cocos2d::LanguageType getCurrentLanguageType();
	std::string getCurrentResourcePath();

	I18nLanguageCfgItem* getCurrentLanguageCfgItem();
	std::string getI18nSrcPath();
	bool getI18nTextIsLeft2Right();

	//用于玩家手动选择游戏语言
	void setUserDefaultI18nSrcPath(int languageType);

	//std::string getPlatformPath();
	ResourceConfigItem* getResourceConfigItem();
	/*方便测试 增加menu来选择语言*/
	std::string getWin32ResourcePath();
	void setWin32ResourceConfigItem(ResourceConfigItem* item);
	std::string getPlatformName();
	void registerPlatform();
    //获取版本号
    std::string getLocalVersionToLua();

	void playMovie(std::string pageName, std::string fileName, int isLoop, int autoScale);
	void closeMovie(std::string pageName);
	void pauseMovie(std::string pageName);
	void resumeMovie(std::string pageName);

	void sendhttpRequest(const std::string aurl);//数据只管发不做返回处理

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
    void escapeGame();
#endif
	bool CheckMailRule(const std::string&aStr);
};

   void ReEnterLoading(bool boo);

   void ReEnterGame(bool boo);