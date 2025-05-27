#pragma once

/** 

config file example:
----------verson.cfg---------

{  
"version": 1,  
"localVerson" : "1.0.0",
"sever":  "127.0.0.1/verson91/sever.cfg",
"inStoreUpdate": "http://www.baidu.com"
}

sever file example:
----------sever.cfg(http://127.0.0.1/verson91/sever.cfg)----------

{  
"version": 1,
"severVerson":"1.0.1",
"updateAddress":"http://localhost:8080/verson91/update.cfg", 
"rootAddress" : "http://localhost:8080/verson91/", 
"defaultSeverID" : 1,
"severs" :
[
{"id":1, "name":"一帆风顺" , "address":"127.0.0.1", "port":9999, "state":"full"},
{"id":2, "name":"传到桥头" , "address":"127.0.0.1", "port":9998, "state":"general"},
{"id":3, "name":"风调雨顺" , "address":"127.0.0.1", "port":9998, "state":"new"},
]
} 

update file example(c means crc check, f means file, s means size):
----------update.cfg(http://127.0.0.1/verson91/update.cfg)----------
{
	"version" : 1
	"severVerson" : "1.0.1",
	"files" : 
	[
		{"c" : 16067,	"f" : "/battle/s_battle.jpg",	"s":13578},
		{"c" : 44753,	"f" : "/battle/s_battle_frame1.png", "s":54789},
	],
}

*/

#include <string>
#include <map>
#include "Singleton.h"
#include "CurlDownload.h"
#include "Concurrency.h"
#include "libOS.h"
#include "libPlatform.h"
/**

SeverConsts::Get()->init("version.cfg);	//start download version file and parse
SeverConsts::Get()->update(dt);			//call this function every frame to make it working;
SeverConsts::Get()->checkUpdateInfo();	//call this after init, get to know checking state.
SeverConsts::Get()->getSeverList()		//Sever list can be got after checkUpdate return CS_OK.
SeverConsts::Get()->updateResources();	//Should do this after checkUpdate return CS_NEED_UPDATE
SeverConsts::Get()->checkUpdateState();	//get whether update downloaded all files

*/
class SeverConsts 
	: public Singleton<SeverConsts>
	, public CurlDownload::DownloadListener
	, public libOSListener
	, public platformListener
{
public:
	static SeverConsts* getInstance(){return SeverConsts::Get();}
	enum SEVER_STATE
	{
		SS_GENERAL,
		SS_NEW,
		SS_FULL,
		SS_MAINTAIN,
	};

	enum CHECK_STATE
	{
		CS_NOT_STARTED,
		CS_OK,
		CS_CHECKING,
		CS_NEED_UPDATE,
		CS_NEED_STORE_UPDATE,
		CS_FAILED,
		CS_SEVERFAILED,
		//
		//问题，没法放灰度号、内部号进入，暂不实现
		//CS_SERVER_STATE_WAITING,	//xinzheng 2013-07-15 在server的区服配置上 标示该区GameServer的当前状态，1正常，0弹一个msg阻止进入
		//
	};

	enum E_PLATFORM
	{
		EP_NONE,
		EP_H365,
		EP_EROR18,
		EP_JSG,
		EP_LSJ,
		EP_MURA,
		EP_KUSO,
		EP_EROLABS,
		EP_OP,
		EP_TEMP2,
		EP_APLUS,
	};
	
	struct SEVER_ATTRIBUTE
	{
		int id;
		std::string name;
		std::string nameTW;
		std::string address;
		int port;
        SEVER_STATE state;
		int order;
		/*bool operator < (SEVER_ATTRIBUTE b) {
			return order > b.order;
      }*/
	};
	enum ERROR_MESSAGE_DOWNLOAD_CODE
	{
		CODE_NETWORDDISABLED_SERVER=201,
		CODE_SEVER_FAILD_A,
		CODE_SEVER_FAILD_B,
		CODE_SEVER_FAILD_C,
		CODE_NETWORDDISABLED_UPDATE,
		CODE_UPDATE_FAILD_A,
		CODE_UPDATE_FAILD_B,
		CODE_UPDATE_FAILD_C,
		CODE_SU_DIFF,
		CODE_NO_SPACE,
		CODE_LIST_FILE_FAILED,
		CODE_LIST_FILE_DOWNLOADED,
		CODE_OTHER_ERROR,
	};

	enum FileType
	{
		DownSeverFile,
		DownUpdateFile,
		DownOtherFile,
	};
	typedef std::map<int,SEVER_ATTRIBUTE*> SEVERLIST;
	typedef std::list<SEVER_ATTRIBUTE* > SEVERLISTVec;
	virtual void onMessageboxEnter(int tag);
	void init(const std::string& configfile, std::string internationalPath="" );
	void start();
	void update(float dt);
	void cleanup();

	/**Sever list can be got after checkUpdate return CS_OK*/
	const SEVERLIST& getSeverList(){return mSeverList;}
	const SEVERLISTVec& getSeverListVec();
    
	int getSeverDefaultID(){return mSeverDefaultID;}

	void initPlatfomtPath(std::string platformPath);
	void initLanguagePath(std::string languagePath);

	void initSearchPath();
	void setSearchPath();

	//文字渲染顺序，例如阿拉伯从右向左
	void initIsTextLeft2Right(bool value);
	bool getIsTextLeft2Right(){ return mIsTextLeft2Right; }

	//设置是否在审核ios
	void setIsAppStoreChecking(bool value){ mIsAppStoreChecking = value; }
	bool getIsAppStoreChecking(){ return  mIsAppStoreChecking; }
	void setIsOpenDataTransfer(bool value){mIsOpenDataTransfer = value;}
	bool getIsOpenDataTransfer(){return mIsOpenDataTransfer;}
public://not used for client
	CHECK_STATE mCheckState;
	struct FILE_ATTRIBUTE
	{
		std::string realFileName;
		std::string filename;
        std::string checkpath;
		int crc;
		int size;
		int index;
		bool operator < (const FILE_ATTRIBUTE& f)
		{
			return index < f.index;
		}
		bool findIndex(int tempIndex){
			return index == tempIndex;
		}
	};
	typedef std::list<FILE_ATTRIBUTE*> FILELIST;

	SeverConsts(void):
		mCheckState(CS_NOT_STARTED),_waitThreadFileCheck(FCS_NOTSTART),
		mSeverDefaultID(-1), mPlatformPath(""), mLanguagePath(""), mIsTextLeft2Right(true), mIsAppStoreChecking(false),
		mIsFirstUpdate(false), mIsOpenDataTransfer(false), _mReDownLoadServerFile(false), _updateReqServerListTime(0.0f),
		_updateReqServerListOffestTime(10.0f), mMaintenanceTips(""), downloadServerFileTimes(0)
	   {};

	//add by glj 19-3-18
	CHECK_STATE checkUpdateInfo(){ return mCheckState; }


	void downloaded(const std::string& url,const std::string& filename);
	void downloadFailed(const std::string& url, const std::string& filename, int errorType);
	virtual void onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& filename);
	const std::string getFailedName() { return mFailedName;};
	void exitServerConst();

	void _notifyFileCheckDone();
	void setVersion(std::string version){mLocalVerson = version;}
	const std::string& getVersion(){return mLocalVerson;}
	const std::string& getServerVersion(){return mSeverVerson;}
	const void setServerVersion(std::string serverversion){ mSeverVerson = serverversion; }
	void clearVersion();
	const std::string& getBundleVersionPath(){ return mCfgFilePath; }
	const std::string& getSeverFile(){return mSeverFile;}
	virtual std::string onReceiveCommonMessage(const std::string& tag, const std::string& msg);
	static bool _sortFile(FILE_ATTRIBUTE*a, FILE_ATTRIBUTE*b);
	std::string getAdditionalSearchPath(){ return mAdditionalSearchPath; };
	bool _parseConfigFile(const std::string& configfile);
	bool _parsePlatformFile(const std::string& Platformfile);
	bool _parsePlatformId(const unsigned int platformId);
	void CheckPlatform();
	const std::string & getInternalAnnouncementFilePath() const { return mInternalAnnouncementFilePath; }
	const unsigned int getInternalAnnouncementVersion() const { return mInternalAnnouncementVersion; }
	void setIsRedownLoadServer(bool isReDownLoad){ _mReDownLoadServerFile = isReDownLoad; }
	bool getIsRedownLoadServer(){ return _mReDownLoadServerFile; }
	void setReqServerListOffestTime(float _UpdateTotalTime){ _updateReqServerListOffestTime = _UpdateTotalTime; }
	const std::string & getMaintenanceTip() const { return mMaintenanceTips; }
	const std::string & getR18PayUrl() const { return mR18PayUrl; }
	bool IsH365(){ return (ePlatform == SeverConsts::EP_H365); }
	bool IsEroR18(){ return (ePlatform == SeverConsts::EP_EROR18); }
	bool IsJSG(){ return(ePlatform == SeverConsts::EP_JSG); }
	bool IsLSJ(){ return(ePlatform == SeverConsts::EP_LSJ); }
	bool IsMURA(){ return(ePlatform == SeverConsts::EP_MURA); }
	bool IsKUSO(){ return(ePlatform == SeverConsts::EP_KUSO); }
	bool IsErolabs(){ return(ePlatform == SeverConsts::EP_EROLABS); }
	bool IsOP(){ return(ePlatform == SeverConsts::EP_OP); }
	bool IsAPLUS(){ return(ePlatform == SeverConsts::EP_APLUS); }
	bool IsDebug() { return _IsDebug; }
private:

	


	std::vector<std::string> mOriSearchPath;

	std::string mLocalVerson;
	std::string mSeverVerson;
	std::string mSeverFile;
	std::string mConfigFile;
	std::string mFailedName;
	std::string mCfgFilePath;	//bundle的version_xx.cfg文件全路径
	std::string platformName;

	bool _IsDebug;

	int mSeverDefaultID;
	SEVERLIST mSeverList;
	SEVERLISTVec mSeverListVec;

	FILELIST mFileList;
	E_PLATFORM ePlatform;
	enum FILECHECKSTATE
	{
		FCS_NOTSTART,
		FCS_CHECKING,
		FCS_DONE,
	} _waitThreadFileCheck;
	Mutex _waitThreadFileCheckMutex;
	ThreadService mCheckFileThread;
	bool _isPopNotifyWhenFileNotFound;
	std::string mAdditionalSearchPath;
	//其实是platform路径，主要用于win32
	std::string mPlatformPath;
	//语言包初始路径
	std::string mLanguageInitPath;
	//语言包路径，用于多语言同包的情况
	std::string mLanguagePath;
	//文字渲染相关
	bool mIsTextLeft2Right;
	
	bool mIsAppStoreChecking;
	bool mIsFirstUpdate;//是否第一次内更新
	bool mIsOpenDataTransfer;//是否开启移行
	std::vector<std::string> mAlreadyDownZipVec;

	std::string mInternalAnnouncementFilePath;
	std::string mMaintenanceTips;
	std::string mR18PayUrl;
	unsigned int mInternalAnnouncementVersion;
	bool _mReDownLoadServerFile;
	float _updateReqServerListOffestTime;
	float _updateReqServerListTime;
	int downloadServerFileTimes;  //下载服务器列表的次数

private:
	//bool _parseConfigFile(const std::string& configfile);
	void _parseSeverFile(const std::string& severfile);
	
	static bool _sortServerList(SEVER_ATTRIBUTE* a,SEVER_ATTRIBUTE* b);
};

