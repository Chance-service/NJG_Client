#pragma once
#include "Singleton.h"

#include "cocos2d.h"
#include "ExtensionMacros.h"
#include "network/HttpRequest.h"
#include "network/HttpClient.h"
#include "network/HttpResponse.h"

#include "UpdateVersion.h"

USING_NS_CC;

/* 下載狀態 */
enum InGameDlAllStateEnum
{
	eAllStateNone = 0,
	eAllStateManifestDling = 1,			// manifest下載中
	eAllStateManifestDlSuccess = 2,		// manifest下載成功
	eAllStateEmpty = 3,					// 不加會跳錯 原因不明
	eAllStateManifestDlFailed = 4,		// manifest下載失敗
	eAllStateManifestCompare = 5,		// manifest比對中
	eAllStateManifestCompareFailed = 6,	// manifest比對失敗
	eAllStateDownloadComplete = 7,		// 更新完成
	eAllStateDownloadNeed = 8,			// 需要更新
	eAllStateDownloading = 9,			// 更新中
	eAllStateDownloadFailed = 10,		// 更新失敗
	/*------------------------------------------------*/
	eOneStateNone = 100,
	eOneStateIng = 101,			// 該檔案下載中
	eOneStateSuccess = 102,		// 該檔案下載成功
	eOnwStateEmpty = 103,		// 不加會跳錯 原因不明
	eOneStateFailed = 104,		// 該檔案下載失敗
};

class InGameDownloaderListener
{
public:
	virtual void onInGameDownloadCompleted(std::string& fileName){};
};
class InGameDownloader : public CCObject, public Singleton<InGameDownloader>, 
						 public CurlDownload::DownloadListener, public libOSListener,
						 public platformListener
{
public:
	InGameDownloader();
	~InGameDownloader();

	static InGameDownloader* getInstance() { return InGameDownloader::Get(); }

	int getDownloadState();
	float getTotalDownloadPercent();
	float getFileDownloadPercent(const std::string fileName);

	void checkManifest(const std::string& url);

	bool checkNeedDownload();
	bool checkNeedDownloadByName(const std::string& fileName);
	int checkDownloadStateByName(const std::string& fileName);
	void downloadAllAsset();
	void downloadAssetByName(const std::string& fileName);

private:
	void downloadAssetByData(assetData* data);
	/* Manifest */
	void getLocalProjectAssets();
	void onHttpRequestCompleted(CCNode *sender, void*data);
	void compareProjectAsset();
	void getProjectAssetData(ProjectAssetData* projectAssetData, unsigned char* content);
	/* 下載機制 */
	void writeProjectManifest();
	void downloaded(const std::string& url, const std::string& filename);
	void downloadFailed(const std::string& url, const std::string& filename, int errorType);
	void onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& filename);
	void redownloadAll();
	virtual void OnDownloadProgress(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, long progress);
	virtual void OnDownloadComplete(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, const std::string& md5Str);
	virtual void OnDownloadFailed(const std::string& urlStr, const std::string& filenameStr, const std::string& basePathStr, int errorCode);

	std::vector<std::string> split(const std::string& str, char delimiter);

	int nowType;
	ProjectAssetData* localProjectAssetData;
	ProjectAssetData* serverProjectAssetData;
	std::vector<assetData*> needUpdateAsset;
	std::vector<assetData*> failedUpdateAsset;
	int downloadFailedTime;
	float totalNeedLoadSize;
	std::map<std::string, float> fileLoadSizeMap;

	std::string tempUrl;
};