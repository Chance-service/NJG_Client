#ifndef _CURLDOWNLOADFORSCRIPT_H_
#define _CURLDOWNLOADFORSCRIPT_H_
#include "cocos2d.h"
#include "CurlDownload.h"
using namespace cocos2d;

class CurlDownloadScriptListener : public CCObject,public CurlDownload::DownloadListener
{
public:
	CurlDownloadScriptListener(int nHandler);
	virtual ~CurlDownloadScriptListener();

	virtual void downloaded(const std::string& url, const std::string& filename);
	virtual void downloadFailed(const std::string& url, const std::string& filename);
	virtual void onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& filename);

	std::string getFileName(){ return mFileName; }
	std::string getUrl(){ return mUrl; }
	unsigned long getLoadSize(){ return mLoadSize; }
private:
	std::string mFileName;
	std::string mUrl;
	int mScriptHandler;
	long mLoadSize;
};

#endif