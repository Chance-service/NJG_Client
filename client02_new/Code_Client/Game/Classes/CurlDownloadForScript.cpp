#include "CurlDownloadForScript.h"
#include "CCLuaEngine.h"
USING_NS_CC;

#define RUN_SCRIPT_FUN(funname) \
if (mScriptHandler) \
{ \
	CCLuaEngine::defaultEngine()->executeClassFunc(mScriptHandler, funname, this, "CurlDownloadScriptListener"); \
}

CurlDownloadScriptListener::CurlDownloadScriptListener(int nHandler)
{
	mUrl = "";
	mFileName = "";
	mScriptHandler = nHandler;
	CurlDownload::Get()->addListener(this);
}


CurlDownloadScriptListener::~CurlDownloadScriptListener()
{
	if (mScriptHandler)
	{
		CCLuaEngine::defaultEngine()->removeScriptTableHandler(mScriptHandler);
		mScriptHandler = 0;
	}
	CurlDownload::Get()->removeListener(this);
}

void CurlDownloadScriptListener::downloaded(const std::string& url, const std::string& filename)
{
	mUrl = url;
	mFileName = filename;
	RUN_SCRIPT_FUN("onDownLoaded");
}

void CurlDownloadScriptListener::downloadFailed(const std::string& url, const std::string& filename)
{
	mUrl = url;
	mFileName = filename;
	RUN_SCRIPT_FUN("onDownLoadFailed");
}

void CurlDownloadScriptListener::onAlreadyDownSize(unsigned long size)
{
	mLoadSize = size;
	RUN_SCRIPT_FUN("onAlreadyDownSize");
}