#include "stdafx.h"

#include "SeverConsts.h"
#include "Concurrency.h"
#include "GameMaths.h"
#include "GamePlatform.h"
#include "json/json.h"
#include "cocos2d.h"
#include "GameEncryptKey.h"
#include "Language.h"
#include "libPlatform.h"
#include "StringConverter.h"
#include "inifile.h"
#include "RecourceFilePath.h"
#include "AssetsManagerEx.h"
#include "Check.h"

const std::string TEMP_SEVER_FILE_DOWNLOADED = "_tempSeverConfigFile.cfg";
const std::string TEMP_CONFIG_FILE_BACKUP = "_tempConfigFile.cfg";
const std::string HOT_UPDATE_PATH = "hotUpdate";
#define AUTO_RETRY_TIME 1
#define serverListCfg            "server.cfg"
#define PlatformCheckCfg		 "platform.cfg"
using namespace cocos2d;
void SeverConsts::init( const std::string& configfile, std::string internationalPath )
{
	_waitThreadFileCheck = FCS_NOTSTART;
	mSeverDefaultID = -1;

	//setSearchPath();

	//RecourceFilePathManager::Get()->init("txt/RecourceFilePath.txt");
	libOS::getInstance()->registerListener(this);

	CurlDownload::Get()->addListener(this);
    
	mConfigFile = configfile;
    
	/*std::string versionCfgPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(configfile.c_str());
	mCfgFilePath = versionCfgPath;
	CCLOG("0 parse bundleConfigFile: %s", versionCfgPath.c_str());
    _parseConfigFile(versionCfgPath);*/

	Check::InitCheckVersion();
}

void SeverConsts::start()
{
	std::string desFile(cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath());
	desFile=desFile+"/"+TEMP_SEVER_FILE_DOWNLOADED;
    CurlDownload::Get()->downloadFile(mSeverFile,desFile);
	cocos2d::CCLog("*********DOWNLOAD FILE: %s", mSeverFile.c_str());
}

bool SeverConsts::_parseConfigFile( const std::string& configfile )
{
	Json::Value root;
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;
    
	char* pBuffer = (char*)getFileData(configfile.c_str(),"rt",&filesize,0,false);

	bool openSuccessful = true;
	if(!pBuffer)
	{
		char msg[256];
		sprintf(msg,"Failed open file: %s !!",configfile.c_str());
		cocos2d::CCMessageBox(msg,Language::Get()->getString("@ShowMsgBoxTitle").c_str()); 
		openSuccessful = false;
	}
	else
	{
		openSuccessful = jreader.parse(pBuffer, filesize, data, false);
		if(openSuccessful && !data["sever"].empty())
		{
			std::string channel = "android_NG";
			time_t t;
			time(&t);
			if (SeverConsts::Get()->IsOP()) {
				channel += "_OP";
			}
			CCString* _time = CCString::createWithFormat("%ld", t);
			mSeverFile = data["sever"].asString() + "/" + "Server" + "/" + channel + "/" + serverListCfg;// + "?" + "time=" + _time->m_sString;
			cocos2d::CCLog("*********SERVER FILE: %s", mSeverFile.c_str());
		}
		else
			openSuccessful = false;
		CC_SAFE_DELETE_ARRAY(pBuffer);
    }
	return openSuccessful;
}

bool SeverConsts::_parsePlatformFile(const std::string& platformfile)
{
	Json::Value root;
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;

	char* pBuffer = (char*)getFileData(platformfile.c_str(), "rt", &filesize, 0, false);

	bool openSuccessful = true;
	if (!pBuffer)
	{
		char msg[256];
		sprintf(msg, "Failed open file: %s !!", platformfile.c_str());
		cocos2d::CCMessageBox(msg, Language::Get()->getString("@ShowMsgBoxTitle").c_str());
		openSuccessful = false;
	}
	else
	{
		openSuccessful = jreader.parse(pBuffer, filesize, data, false);
		
		if (openSuccessful && !data["isDebug"].empty())
		{
			_IsDebug = (data["isDebug"].asString() == "true");
		}
		else
			openSuccessful = false;

		CC_SAFE_DELETE_ARRAY(pBuffer);
	}
	return openSuccessful;
}

bool SeverConsts::_parsePlatformId(const unsigned int platformId)
{
	ePlatform = E_PLATFORM(platformId);
	return true;
}

void SeverConsts::CheckPlatform()
{
	std::string PlatformCfgPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(PlatformCheckCfg);
	_parsePlatformFile(PlatformCfgPath);
    libPlatform* platform = libPlatformManager::getPlatform();
	_parsePlatformId(platform->getPlatformId());
    platform->setPlatformName(platform->getPlatformId());
	CCLog("------------CheckPlatform : %d--------------", ePlatform);
	CCLog("------------CheckDebug : %s--------------", IsDebug() ? "true" : "false");
    
    platform->setupSDK(ePlatform);
}

void SeverConsts::update( float dt )
{
	_updateReqServerListTime = _updateReqServerListTime + dt;

	if (_updateReqServerListTime >= _updateReqServerListOffestTime)
	{
		_updateReqServerListTime = 0.0f;

		if (_mReDownLoadServerFile)
		{
			start();
		}
	}

	CurlDownload::Get()->update(dt);
}

void SeverConsts::downloaded( const std::string& url,const std::string& filename )
{
	if(url.find(mSeverFile) != url.npos)
	{
		_parseSeverFile(filename);
		if (mCheckState != CS_OK) {
			downloadServerFileTimes++;
			if (downloadServerFileTimes < 10)
			{
				start();
			}
			else {
				libOS::getInstance()->showMessagebox(Language::Get()->getString("@ReceivedTimeout"), -1);
				start();
			}
		}
		else if (!_mReDownLoadServerFile)
		{
			downloadServerFileTimes = 0;
			libPlatformManager::getPlatform()->login();
		    CCLOG("dowinload finish and login");
		}
	}
}

void SeverConsts::downloadFailed(const std::string& url, const std::string& filename, int errorType)
{
	if (url.find(mSeverFile) != url.npos)
	{
		downloadServerFileTimes++;
		if (downloadServerFileTimes < 10)
		{
			start();
		}
		else {
			cocos2d::CCMessageBox(Language::Get()->getString("@ReceivedTimeout").c_str(), Language::Get()->getString("@ShowMsgBoxTitle").c_str());
			start();
		}
	}
}

void SeverConsts::exitServerConst()
{
	CurlDownload::Get()->removeListener(this);
	libOS::getInstance()->removeListener(this);
	libPlatformManager::getInstance()->getPlatform()->removeListener(this);
}

void SeverConsts::_parseSeverFile( const std::string& severfile )
{
	Json::Value root;
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;
	char* pBuffer = (char*)getFileData(
		cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(severfile.c_str()).c_str(),
		"rt",&filesize,0,false);

	if(!pBuffer)
	{
		if (!_mReDownLoadServerFile)
		{
			std::string fullPath = cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(severfile.c_str());
			std::string msg = "Get SeverFile data from file(";
			msg.append(severfile).append(") failed!").append("   filePath:").append(fullPath.c_str());
			cocos2d::CCMessageBox(msg.c_str(), "File Not Found");
		}
	}

	if(!pBuffer)
	{
		{
			CC_SAFE_DELETE_ARRAY(pBuffer);
			if (!_mReDownLoadServerFile)
			{
				mCheckState = CS_SEVERFAILED;
			}
			return;
		}
	}
	
	bool ret = jreader.parse(pBuffer, filesize, data, false);
	if(	
		!ret ||
		data["severs"].empty() ||
		!data["severs"].isArray())
	{
		{
			CC_SAFE_DELETE_ARRAY(pBuffer);
			if (!_mReDownLoadServerFile)
			{
				mCheckState = CS_SEVERFAILED;
			}
			return;
		}
	}

	cleanup();
	
	std::map<int, Json::Value> serverNameMap;
	Json::Value severs = data["severs"];
	for(int i=0;i<severs.size();++i)
	{
		if(	!severs[i]["name"].empty() &&
			!severs[i]["address"].empty() &&
			!severs[i]["port"].empty() &&
			!severs[i]["id"].empty() &&
			!severs[i]["state"].empty() )
		{
			SEVER_ATTRIBUTE* severAtt = new SEVER_ATTRIBUTE;
			severAtt->name = severs[i]["name"].asString();
			severAtt->nameTW = severs[i]["nameTW"].asString();
			severAtt->nameEN = severs[i]["nameEN"].asString();
			severAtt->address = severs[i]["address"].asString();
			severAtt->port = severs[i]["port"].asInt();
			severAtt->id = severs[i]["id"].asInt();

			if(severs[i]["state"].asString() == "general")
				severAtt->state = SS_GENERAL;
			else if(severs[i]["state"].asString() == "new")
				severAtt->state = SS_NEW;
			else if(severs[i]["state"].asString() == "full")
				severAtt->state = SS_FULL;
			else if(severs[i]["state"].asString() == "maintain")
				severAtt->state = SS_MAINTAIN;
				
			if(severs[i]["order"].empty())
			{
				severAtt->order=severAtt->id;
			}
			else
			{
				severAtt->order=severs[i]["order"].asInt();
			}
			if (serverNameMap.find(severAtt->id) != serverNameMap.end())
			{
				Json::Value serverNameItem = serverNameMap[severAtt->id];
				std::string i18nSrc = mLanguagePath;
				if (i18nSrc != "" && !serverNameItem[i18nSrc.c_str()].empty())
				{
					std::string tempServerName = serverNameItem[i18nSrc.c_str()].asString();
					if (tempServerName != "")
					{
						severAtt->name = tempServerName.c_str();
					}
				}
			}
			mSeverList.insert(std::make_pair(severAtt->id,severAtt));
		}
	}

	if (!data["internalAnnouncementFilePath"].empty())
	{
		mInternalAnnouncementFilePath = data["internalAnnouncementFilePath"].asString();

		cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("announcement", mInternalAnnouncementFilePath);
	}
	else
	{
		mInternalAnnouncementFilePath = "";
		cocos2d::CCUserDefault::sharedUserDefault()->setStringForKey("announcement", mInternalAnnouncementFilePath);
	}
	if (!data["internalAnnouncementVersion"].empty())
	{
		mInternalAnnouncementVersion = data["internalAnnouncementVersion"].asUInt();
	}
	else
	{
		mInternalAnnouncementVersion = 0;
	}
	if (!data["serverMaintenanceTip"].empty())
	{
		mMaintenanceTips = data["serverMaintenanceTip"].asString();
	}

	if (!data["R18PayAddress"].empty())
	{
		mR18PayUrl = data["R18PayAddress"].asString();
	}

	SEVERLIST::const_reverse_iterator it = mSeverList.rbegin();
	std::list<SeverConsts::SEVER_ATTRIBUTE> orderlist;

	for (; it != mSeverList.rend(); ++it)
	{
		orderlist.push_back(*it->second);
	}
	//orderlist.sort();
	std::list<SeverConsts::SEVER_ATTRIBUTE>::iterator itOrdered = orderlist.begin();
	mSeverDefaultID = itOrdered->id;
	//mSeverVerson = data["severVerson"].asString();

	//for (SeverConsts::SEVER_ATTRIBUTE itr : orderlist)
	for (std::list<SeverConsts::SEVER_ATTRIBUTE>::iterator it = orderlist.begin(); it != orderlist.end(); it++)
	{
		if (it->id == data["defaultSeverID"].asInt())
		{
			mSeverDefaultID = data["defaultSeverID"].asInt();
			break;
		}
	}

	if (!_mReDownLoadServerFile)
	{
		cocos2d::CCLog("*********CHECK_STATE OK!!!!!");
		mCheckState = CS_OK;
	}

	//CCLog("server ready");
	CC_SAFE_DELETE_ARRAY(pBuffer);
#ifdef WIN32
#else
	remove(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(severfile.c_str()).c_str());
#endif
}

void SeverConsts::cleanup()
{
	for(SEVERLIST::iterator it = mSeverList.begin();it!=mSeverList.end();++it)
		if(it->second)delete it->second;
	mSeverList.clear();
}

void SeverConsts::_notifyFileCheckDone()
{
	AutoRelaseLock _autolock(_waitThreadFileCheckMutex);
	_waitThreadFileCheck = FCS_DONE;
}

void SeverConsts::clearVersion()
{
    std::string tempFile(cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath());
 	tempFile.append("/");
 	tempFile.append(TEMP_CONFIG_FILE_BACKUP);
	remove(tempFile.c_str());
    
	std::string desFile(cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath());
    desFile.append("/");
    desFile.append(mAdditionalSearchPath);
	desFile.append("/");

#if !defined(ANDROID)
	/*
		for android, desfile path is bundle unziped path, we do not remove it
	*/
    game_rmdir(desFile.c_str());
#endif
    CCLOG("clearVersion dir:%s",desFile.c_str());
}

void SeverConsts::initSearchPath()
{
    mAdditionalSearchPath = std::string("hotUpdate");
	
	mLanguageInitPath = "i18nFiles";
	const std::vector<std::string>& paths = cocos2d::CCFileUtils::sharedFileUtils()->getSearchPaths();

	cocos2d::CCFileUtils::sharedFileUtils()->setDecodeBufferFun(getEncodeBuffer);
	mOriSearchPath.assign(paths.begin(),paths.end());

	//std::string _recourceFilePath = paths[0] + "txt";
	//mOriSearchPath.insert(mOriSearchPath.begin(), _recourceFilePath);

	std::string writablePath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
	mOriSearchPath.insert(mOriSearchPath.begin(), writablePath);

	std::string hotPath = writablePath + HOT_UPDATE_PATH;//+ "/" + HOT_UPDATE_PATH;
	mOriSearchPath.insert(mOriSearchPath.begin(), hotPath);

	//std::string RecourceFilePath = writablePath + mAdditionalSearchPath + "/" + "txt";
	//mOriSearchPath.insert(mOriSearchPath.begin(), RecourceFilePath);

	cocos2d::CCFileUtils::sharedFileUtils()->setSearchPaths(mOriSearchPath);
	cocos2d::CCFileUtils::sharedFileUtils()->purgeCachedEntries();

	setSearchPath();
}

void SeverConsts::initPlatfomtPath(std::string platformPath)
{
	mPlatformPath = platformPath;
	CCLOG("SeverConsts::initPlatfomtPath, mPlatformPath == %s", platformPath.c_str());
}

void SeverConsts::initLanguagePath(std::string languagePath)
{
	mLanguagePath = languagePath;

	CCLOG("SeverConsts::initLanguagePath, mLanguagePath == %s", languagePath.c_str());
	//**//根据系统语种和 语种资源来决定 当前语言后 传递给android 
	std::string ret;

	if (0 == strcmp("Chinese", mLanguagePath.c_str()))
    {
		ret = "zh";
    }
	else if (0 == strcmp("English", mLanguagePath.c_str()))
    {
        ret = "en";
    }
	else if (0 == strcmp("French", mLanguagePath.c_str()))
    {
        ret = "fr";
    }
	else if (0 == strcmp("Italian", mLanguagePath.c_str()))
    {
        ret = "it";
    }
	else if (0 == strcmp("German", mLanguagePath.c_str()))
    {
        ret = "de";
    }
	else if (0 == strcmp("Spanish", mLanguagePath.c_str()))
    {
        ret = "es";
    }
	else if (0 == strcmp("Dutch", mLanguagePath.c_str()))
    {
        ret = "nl";
    }
	else if (0 == strcmp("Russian", mLanguagePath.c_str()))
    {
        ret = "ru";
    }
	else if (0 == strcmp("Korean", mLanguagePath.c_str()))
    {
        ret = "ko";
    }
	else if (0 == strcmp("Japanese", mLanguagePath.c_str()))
    {
        ret = "ja";
    }
	else if (0 == strcmp("Hungarian", mLanguagePath.c_str()))
    {
        ret = "hu";
    }
	else if (0 == strcmp("Portuguese", mLanguagePath.c_str()))
    {
        ret = "br";
    }
	else if (0 == strcmp("Arabic", mLanguagePath.c_str()))
    {
        ret = "ar";
    }
	else if (0 == strcmp("Turkish", mLanguagePath.c_str()))
	{
		ret = "tr";
	}
		else if (0 == strcmp("Thai", mLanguagePath.c_str()))
	{
		ret = "th";
	}

	//libPlatformManager::getPlatform()->setLanguageName(ret);
}

void SeverConsts::initIsTextLeft2Right(bool value)
{
	mIsTextLeft2Right = value;
}

void SeverConsts::setSearchPath()
{
	std::vector<std::string> paths;

	for (std::vector<std::string>::iterator it = mOriSearchPath.begin(); it != mOriSearchPath.end(); ++it)
	{
		paths.push_back((*it).c_str());
	}


	const std::vector<std::string>& searchPaths = cocos2d::CCFileUtils::sharedFileUtils()->getSearchPaths();
	std::string writablePath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
	paths.push_back(writablePath);
	RecourceFilePathManager::Get()->init("RecourceFilePath.txt");
	RecourceFilePathManager::RecourcePathListIterator itr = RecourceFilePathManager::Get()->getRecourcePathIterator();
	while (itr.hasMoreElements())
	{
		std::string searchPath = itr.getNext()->path;
		std::string originalPath = searchPath;
		paths.push_back(originalPath);

		// mOriSearchPath
		//std::string originalPath2 = searchPaths[0] + searchPath;
		//paths.push_back(originalPath2);

		//std::string newPath = writablePath + HOT_UPDATE_PATH + "/" + HOT_UPDATE_PATH   + "/"+ searchPath;
		std::string newPath = writablePath + HOT_UPDATE_PATH + "/"+ searchPath;
		paths.insert(paths.begin(), newPath);
	}

	cocos2d::CCFileUtils::sharedFileUtils()->setSearchPaths(paths);
	cocos2d::CCFileUtils::sharedFileUtils()->purgeCachedEntries();

	cocos2d::CCLog("setOriginalSearchPath::print all searchpath begin~&&&&&&&&&&&&&&&&&&&&&&&");
	for (int i = 0; i < cocos2d::CCFileUtils::sharedFileUtils()->getSearchPaths().size(); i++)
	{
        std::string path = cocos2d::CCFileUtils::sharedFileUtils()->getSearchPaths()[i];
        cocos2d::CCLog("path: %s", path.c_str());
	}
	cocos2d::CCLog("setOriginalSearchPath::print all searchpath end~&&&&&&&&&&&&&&&&&&&&");
}

void SeverConsts::onMessageboxEnter(int tag)
{
	if(tag==CODE_NETWORDDISABLED_SERVER||tag==CODE_SEVER_FAILD_A||tag==CODE_SEVER_FAILD_B||tag==CODE_SEVER_FAILD_C)
	{
		start();
	}
	else if(tag==CODE_NETWORDDISABLED_UPDATE||tag==CODE_UPDATE_FAILD_A||tag==CODE_UPDATE_FAILD_B||tag==CODE_SU_DIFF||tag==CODE_UPDATE_FAILD_C)
	{
	}
	else if(tag==CODE_LIST_FILE_FAILED||tag==CODE_LIST_FILE_DOWNLOADED)
	{//list file failed retry download
	}
}

int _parseSingleServer(SeverConsts::SEVERLIST& serverlist,Json::Value jroot)
{
	int ret = -1;
	if(	!jroot["id"].empty() &&
		!jroot["name"].empty() &&
		!jroot["addr"].empty() &&
		!jroot["port"].empty() &&
		!jroot["status"].empty())
	{
		SeverConsts::SEVER_ATTRIBUTE* severAtt = new SeverConsts::SEVER_ATTRIBUTE;
		severAtt->name = jroot["name"].asString();
		severAtt->address = jroot["addr"].asString();
		severAtt->port = jroot["port"].isString()?StringConverter::parseInt(jroot["port"].asString()):jroot["port"].asInt();
		severAtt->id = jroot["id"].isString()?StringConverter::parseInt(jroot["id"].asString()):jroot["id"].asInt();

		if(jroot["order"].empty())
		{
			severAtt->order=severAtt->id;
		}
		else
		{
			severAtt->order=jroot["order"].isString()?StringConverter::parseInt(jroot["order"].asString()):jroot["order"].asInt();
		}
		serverlist.insert(std::make_pair(severAtt->id,severAtt));

	}	
	return ret;
}

std::string SeverConsts::onReceiveCommonMessage( const std::string& tag, const std::string& msg )
{
	CCLOG("RECEIVE SDK MESSAGE!\ntag:%s\nmsg:%s\n",tag.c_str(),msg.c_str());
	if(tag=="SERVERLIST")
	{
		Json::Reader jreader;
		Json::Value jvalue;
		jreader.parse(msg,jvalue,false);

		Json::Value jroot = jvalue;
		if(!jroot.empty() && jroot.isArray())
		{
			for(int i=0;i<jroot.size();++i)
			{
				int defaultid = _parseSingleServer(mSeverList,jroot[i]);
				if(defaultid!=-1) mSeverDefaultID = defaultid;
			}
		}
		else
		{
			int defaultid = _parseSingleServer(mSeverList,jroot);
			if(defaultid!=-1) mSeverDefaultID = defaultid;
		}
	}
	CCLOG("RECEIVE SDK MESSAGE DONE!");
	return "";
}

void SeverConsts::onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& filename)
{
}

bool SeverConsts::_sortFile( FILE_ATTRIBUTE*a,FILE_ATTRIBUTE*b )
{
	return a->index < b->index;
}
