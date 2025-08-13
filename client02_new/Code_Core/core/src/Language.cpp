
#include "stdafx.h"

#include "Language.h"
#include "json/json.h"
#include "cocos2d.h"
#include "GamePlatform.h"
#include "TableReader.h"

USING_NS_CC;

void Language::init( const std::string& languagefile )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	TableAutoReader* reader = TableReaderManager::getInstance()->getTableReader("Win32Setting.cfg");
	if (reader) {
		std::string isClose = reader->getDataIndex(0, 1);
		if (isClose.find("1") != std::string::npos) {
			return;
		}
	}
#endif
	addLanguageFile(languagefile);
}

void Language::addLanguageFile( const std::string& languagefile )
{
	int nChapterCount = 0;
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;
	char* pBuffer = (char*)getFileData(
		cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(languagefile.c_str()).c_str(),
		"rt",&filesize);

	if(!pBuffer)
	{
		char msg[256];
		sprintf(msg,"Failed open file: %s !!",languagefile.c_str());
		cocos2d::CCMessageBox(msg,Language::Get()->getString("@ShowMsgBoxTitle").c_str());
	}
	else
	{
		bool ret = false;
		unsigned char* dataPtr = (unsigned char*)pBuffer;
		if (filesize >= 2 && dataPtr[0] == 0xFF && dataPtr[1] == 0xFE)
			ret = jreader.parse(pBuffer + 2, filesize-2, data, false);
		else if (filesize >= 3 && dataPtr[0] == 0xEF && dataPtr[1] == 0xBB && dataPtr[2] == 0xBF)
			ret = jreader.parse(pBuffer + 3, filesize-3, data, false);
		else
			ret = jreader.parse(pBuffer, filesize, data, false);

		CC_SAFE_DELETE_ARRAY(pBuffer);

		if(!ret && false)
		{
			cocos2d::CCMessageBox("language.lang json format analysis Failed!","Language Analysis");
			return;
		}
		Json::Value chapter = data["chapter"];
		if (!chapter.empty() && chapter.isInt())
		{
			nChapterCount = chapter.asInt();
		}
		if(data["version"].asInt()==1)
		{
			Json::Value files = data["strings"];
			if(!files.empty() && files.isArray())
			{
				for(int i = 0;i < files.size();++i)
				{
					Json::Value unit = files[i];
					if(unit["k"].empty()) continue;
					std::string _key = unit["k"].asString();
					std::string _value = unit["v"].asString();
					replaceEnter(_key);
					if(mStrings.find(_key)==mStrings.end())
						mStrings.insert(std::make_pair(_key,_value));
					else
					{
						char msg[256];
						sprintf(msg,"Multiple defines of string: %s !!",_key.c_str());
						cocos2d::CCMessageBox(msg,Language::Get()->getString("@ShowMsgBoxTitle").c_str());
					}
				}
			}

		}
		/*
		addLangChapterFile
		*/
		CCLOG("init Language_chapter count: %d", nChapterCount);
		cocos2d::CCLog("init Language_chapter count: %d", nChapterCount);
		for (int nChapternIndex = 1; nChapternIndex <= nChapterCount; nChapternIndex++)
		{
			char strChapterName[64] = "";
			sprintf(strChapterName, "Lang/Language_chapter_%d.lang", nChapternIndex);
			CCLOG("init Language_chapter: %s", strChapterName);
			addLangChapterFile(strChapterName);

		}
	}
	//GetSystemTime()
	CC_SAFE_DELETE_ARRAY(pBuffer);
}

void Language::addLangChapterFile(const std::string& languagefile)
{
	Json::Reader jreader;
	Json::Value data;
	unsigned long filesize;
	char* pBuffer = (char*)getFileData(
		cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(languagefile.c_str()).c_str(),
		"rt",&filesize);

	if (!pBuffer)
	{
		char msg[256];
		sprintf(msg, "Failed open file: %s !!", languagefile.c_str());
		cocos2d::CCMessageBox(msg, Language::Get()->getString("@ShowMsgBoxTitle").c_str());
	}
	else
	{
		bool ret = false;
		unsigned char* dataPtr = (unsigned char*)pBuffer;
		if (filesize >= 2 && dataPtr[0] == 0xFF && dataPtr[1] == 0xFE)
			ret = jreader.parse(pBuffer + 2, filesize-2, data, false);
		else if (filesize >=  3 && dataPtr[0] == 0xEF && dataPtr[1] == 0xBB && dataPtr[2] == 0xBF)
			ret = jreader.parse(pBuffer + 3, filesize-3, data, false);
		else
			ret = jreader.parse(pBuffer, filesize,data, false);

		CC_SAFE_DELETE_ARRAY(pBuffer);

		if (!ret && false)
		{
			cocos2d::CCMessageBox("language.lang json format analysis Failed!", "Language Analysis");
			return;
		}
		if (data["version"].asInt() == 1)
		{
			Json::Value files = data["strings"];
			if (!files.empty() && files.isArray())
			{
				for (int i = 0; i < files.size(); ++i)
				{
					Json::Value unit = files[i];
					if (unit["k"].empty()) continue;
					std::string _key = unit["k"].asString();
					std::string _value = unit["v"].asString();
					replaceEnter(_key);
					if (mStrings.find(_key) == mStrings.end())
						mStrings.insert(std::make_pair(_key, _value));
					else
					{
						char msg[256];
						sprintf(msg, "Multiple defines of string: %s !!", _key.c_str());
						cocos2d::CCMessageBox(msg, Language::Get()->getString("@ShowMsgBoxTitle").c_str());
					}
				}
			}

		}
	}
	CC_SAFE_DELETE_ARRAY(pBuffer);
}

const std::string & Language::getString( const std::string& _key )
{
	std::map<std::string,std::string>::const_iterator it = mStrings.find(_key);
	if(it!=mStrings.end())
		return it->second;
	else
		return _key;

}

bool Language::hasString( const std::string& _key )
{
	std::map<std::string,std::string>::iterator it = mStrings.find(_key);
	return (it!=mStrings.end());
}


void Language::updateNode( cocos2d::CCNode* _root )
{
	cocos2d::CCLabelBMFont* bmf = dynamic_cast<cocos2d::CCLabelBMFont* >(_root);
	if(bmf)
	{	
		std::string _key = bmf->getString();
		replaceEnter(_key);
		if(hasString(_key))
		{
			const std::string& str = Language::Get()->getString(_key);
			bmf->setString(str.c_str(),false);
		}
	}
	cocos2d::CCLabelTTF *ttf = dynamic_cast<cocos2d::CCLabelTTF* >(_root);
	if(ttf)
	{	
		std::string _key = ttf->getString();
		if(hasString(_key))
		{
			const std::string& str = Language::Get()->getString(_key);
			ttf->setString(str.c_str());
		}
	}

	cocos2d::CCObject* pObj = NULL;
	CCARRAY_FOREACH(_root->getChildren(), pObj)
	{
		cocos2d::CCNode* subnode = dynamic_cast<cocos2d::CCNode*>(pObj);
		if(subnode)
		{
			updateNode(subnode);
		}
	}
}

void Language::replaceEnter( std::string &_str )
{
	if(_str.find_first_of('\r')==std::string::npos && _str.find_first_of('\n')==std::string::npos)
		return;

	std::string ret;
	for(std::string::size_type i=0;i<_str.size();++i)
	{
		if(_str[i]!='\r'&&_str[i]!='\n')
			ret+=_str[i];
	}
	_str = ret;
}

void Language::clear()
{
	mStrings.clear();
}

Language* Language::getInstance()
{
	return Language::Get();
}

void updateCCBNode( CCNode* node )
{
	Language::getInstance()->updateNode(node);
}
