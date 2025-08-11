#include "InGameDownloader.h"
#include "GamePlatform.h"
#include "CCLuaEngine.h"
#include "AssetsManagerEx.h"
#include "SeverConsts.h"
#include <fstream>
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#endif

USING_NS_CC;
USING_NS_CC_EXT;

#define versionPath "version"
#define downLoadSavePath "hotUpdate"
#define projectManifestName "projectInGame.manifest"

/* 建構式 */
InGameDownloader::InGameDownloader()
	:downloadFailedTime(0)
	,totalNeedLoadSize(0)
	,nowType(eAllStateNone)
	,tempUrl("")
{
	CurlDownload::Get()->addListener(this);
	libOS::getInstance()->registerListener(this);
	libPlatformManager::getPlatform()->registerListener(this);
	fileLoadSizeMap.clear();
}
/* 解構式 */
InGameDownloader::~InGameDownloader()
{
	libOS::getInstance()->removeListener(this);
	libPlatformManager::getPlatform()->removeListener(this);
}
/* 取得下載狀態 */
int InGameDownloader::getDownloadState() 
{
	return nowType;
}
/* 檢查全部檔案下載進度 */
float InGameDownloader::getTotalDownloadPercent()
{
	if (totalNeedLoadSize <= 0.0f) {
		return 100.0f;
	}
	float loadedSize = 0.0f;
	for (auto it = fileLoadSizeMap.begin(); it != fileLoadSizeMap.end(); ++it) {
		loadedSize += it->second;	// KB
	}
	if (loadedSize >= (totalNeedLoadSize)) {
		return 100.0f;
	}
	return loadedSize / totalNeedLoadSize * 100.0f;
}
/* 檢查指定檔案下載進度 */
float InGameDownloader::getFileDownloadPercent(const std::string fileName)
{
	std::string trueName = fileName;
	if (trueName.find(".zip") == std::string::npos) {
		trueName = trueName + ".zip";
	}
	// 先檢查對應檔名檔案
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if ((*it)->name == trueName) {
			if ((*it)->state == eOneStateSuccess) {
				// 下載完成
				return 100.0f;
			}
			else if (fileLoadSizeMap[trueName]) { // 正在下載
				return fileLoadSizeMap[trueName] / (*it)->size * 100.0f;
			}
			else {	// 可以下載
				return 0.0f;
			}
		}
	}
	// 後檢查+i18n前綴檔案
	if (trueName.find("i18n") == std::string::npos) {
		int langType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
		if (langType == kLanguageCH_TW) {	// 繁中
			trueName = "i18n_tw_" + trueName;
		}
		else {
			trueName = "i18n_cn_" + trueName;
		}
		for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
			if ((*it)->name == trueName) {
				if ((*it)->state == eOneStateSuccess) {
					// 下載完成
					return 100.0f;
				}
				else if (fileLoadSizeMap[trueName]) { // 正在下載
					return fileLoadSizeMap[trueName] / (*it)->size * 100.0f;
				}
				else {	// 可以下載
					return 0.0f;
				}
			}
		}
	}
	// 下載完成
	return 100.0f;
}
/* 檢查是否需要更新 */
bool InGameDownloader::checkNeedDownload()
{
	bool allComplete = true;
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if ((*it)->state != eOneStateSuccess) {
			allComplete = false;
		}
	}
	return !allComplete;
}
/* 檢查指定檔案是否需要更新 */
bool InGameDownloader::checkNeedDownloadByName(const std::string& fileName)
{
	// 先檢查對應檔名檔案
	for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
		if ((*itNeed)->name == fileName || (*itNeed)->name == (fileName + ".zip")) {
			if ((*itNeed)->state != eOneStateSuccess) {
				return true;
			}
		}
	}
	// 後檢查+i18n前綴檔案
	if (fileName.find("i18n") == std::string::npos) {
		std::string preName = "";
		int langType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
		if (langType == kLanguageCH_TW) {	// 繁中
			preName = "i18n_tw_";
		}
		else {
			preName = "i18n_cn_";
		}
		for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
			if ((*itNeed)->name == (preName + fileName) || (*itNeed)->name == (preName + fileName + ".zip")) {
				if ((*itNeed)->state != eOneStateSuccess) {
					return true;
				}
			}
		}
	}
	return false;
}
/* 檢查指定檔案更新狀態 */
int InGameDownloader::checkDownloadStateByName(const std::string& fileName)
{
	// 先檢查對應檔名檔案
	for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
		if ((*itNeed)->name == fileName || (*itNeed)->name == (fileName + ".zip")) {
			return (*itNeed)->state;
		}
	}
	// 後檢查+i18n前綴檔案
	if (fileName.find("i18n") == std::string::npos) {
		std::string preName = "";
		int langType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
		if (langType == kLanguageCH_TW) {	// 繁中
			preName = "i18n_tw_";
		}
		else {
			preName = "i18n_cn_";
		}
		for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
			if ((*itNeed)->name == (preName + fileName) || (*itNeed)->name == (preName + fileName + ".zip")) {
				return (*itNeed)->state;
			}
		}
	}
	return eOneStateNone;
}
/* 下載needUpdateAsset內全部檔案 */
void InGameDownloader::downloadAllAsset()
{
	for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
		if ((*itNeed)->state != eOneStateSuccess && (*itNeed)->state != eOneStateIng) {
			downloadAssetByData(*itNeed);
		}
	}
}
/* 下載指定名稱檔案 */
void InGameDownloader::downloadAssetByName(const std::string& fileName)
{
	// 先檢查對應檔名檔案
	for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
		if ((*itNeed)->name == fileName || (*itNeed)->name == (fileName + ".zip")) {
			if ((*itNeed)->state != eOneStateSuccess && (*itNeed)->state != eOneStateIng) {
				downloadAssetByData(*itNeed);
			}
		}
	}
	// 後檢查+i18n前綴檔案
	if (fileName.find("i18n") == std::string::npos) {
		std::string preName = "";
		int langType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");
		if (langType == kLanguageCH_TW) {	// 繁中
			preName = "i18n_tw_";
		}
		else {
			preName = "i18n_cn_";
		}
		for (auto itNeed = needUpdateAsset.begin(); itNeed != needUpdateAsset.end(); ++itNeed) {
			if ((*itNeed)->name == (preName + fileName) || (*itNeed)->name == (preName + fileName + ".zip")) {
				if ((*itNeed)->state != eOneStateSuccess && (*itNeed)->state != eOneStateIng) {
					downloadAssetByData(*itNeed);
				}
			}
		}
	}
}
/* 下載指定assetData檔案 */
void InGameDownloader::downloadAssetByData(assetData* data)
{
	std::string writePath = CCFileUtils::sharedFileUtils()->getWritablePath() + downLoadSavePath + "/" + data->name;
	std::string assetUrl = "";
	if (libOS::getInstance()->getIsDebug()) {
		assetUrl = "https://d1qh9gzgwld337.cloudfront.net/InGame/" + data->name;
		data->url = assetUrl;
		CCLog("downloadAssetByData IsDebug : %s", assetUrl.c_str());
	}
	else {
		assetUrl = CCUserDefault::sharedUserDefault()->getStringForKey("packageUrl") + "/InGame/" + data->name;
		data->url = assetUrl;
		CCLog("downloadAssetByData Is not Debug : %s", assetUrl.c_str());
	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) 
	callDownloadJNI(assetUrl, data->name, downLoadSavePath, data->md5);
#else 
	CurlDownload::Get()->downloadFile(assetUrl, writePath, data->md5);
#endif
	data->state = eOneStateIng;
	nowType = eAllStateDownloading;
}
/* 檢查遊戲內下載的manifest檔案 */
void InGameDownloader::checkManifest(const std::string& url)
{
	if (nowType != eAllStateManifestDling) {
		nowType = eAllStateManifestDling;
		tempUrl = url;

		localProjectAssetData = new ProjectAssetData();
		getLocalProjectAssets();

		serverProjectAssetData = new ProjectAssetData();
		CCLog("InGameDownloader get manifest file url : %s", url.c_str());
		CCHttpRequest* request = new CCHttpRequest();
		request->setUrl(url.c_str());
		request->setRequestType(CCHttpRequest::kHttpGet);
		request->setResponseCallback(this, callfuncND_selector(InGameDownloader::onHttpRequestCompleted));
		request->setTag(url.c_str());
		CCHttpClient::getInstance()->send(request);
		
		request->release();
	}
}
/* 取得本地manifest資料 */
void InGameDownloader::getLocalProjectAssets()
{
	unsigned long filesize;
	std::string fileName = projectManifestName;
	unsigned char* content = CCFileUtils::sharedFileUtils()->getFileData(fileName.c_str(), "r", &filesize);
	if (!content) {
		localProjectAssetData->isLoadSuccess = true;
		localProjectAssetData->time = 0.0f;
		return;
	}
	getProjectAssetData(localProjectAssetData, content);
}
/* http回應 -> 成功後接compareProjectAsset */
void InGameDownloader::onHttpRequestCompleted(CCNode *sender, void *data)
{
	CCLog("InGameDownloader : onHttpRequestCompleted");

	CCHttpResponse* response = (CCHttpResponse*)data;
	if (!response->isSucceed()) {
		if (downloadFailedTime < 10) {
			checkManifest(response->getHttpRequest()->getTag());
			downloadFailedTime += 1;
		}
		else {
			nowType = eAllStateManifestDlFailed;
		}
		CCLog("InGameDownloader: onHttpRequestCompleted fail : %s", response->getHttpRequest()->getTag());
		return;
	}
	nowType = eAllStateManifestDlSuccess;
	downloadFailedTime = 0;
	const char* tag = response->getHttpRequest()->getTag();

	std::vector<char>* buffer = response->getResponseData();
	std::string temp(buffer->begin(), buffer->end());
	CCString* responseData = CCString::create(temp);
	const char* content = responseData->getCString();

	unsigned char* unsignedContent = (unsigned char*)(content);

	CCLog("InGameDownloader : compareProjectAsset");
	getProjectAssetData(serverProjectAssetData, unsignedContent);
	compareProjectAsset();
}
/* 比對本地/Server的manifest 建立needUpdateAsset資料 */
void InGameDownloader::compareProjectAsset()
{
	if (!localProjectAssetData || !localProjectAssetData->isLoadSuccess || !serverProjectAssetData || !serverProjectAssetData->isLoadSuccess) {
		nowType = eAllStateManifestCompareFailed;
		return;
	}
	nowType = eAllStateManifestCompare;
	totalNeedLoadSize = 0.0f;
	downloadFailedTime = 0;
	needUpdateAsset.clear();
	failedUpdateAsset.clear();
	fileLoadSizeMap.clear();

	int langType = cocos2d::CCUserDefault::sharedUserDefault()->getIntegerForKey("LanguageType");

	for (std::map<std::string, assetData *>::const_iterator it = serverProjectAssetData->assetDataMap.begin(); it != serverProjectAssetData->assetDataMap.end(); ++it) {
		std::string name = it->first;
		assetData* data = it->second;
		it->second->savePath = CCFileUtils::sharedFileUtils()->getWritablePath() + downLoadSavePath + "/" + it->second->name;
		it->second->stroge = CCFileUtils::sharedFileUtils()->getWritablePath() + downLoadSavePath + "/";

		auto localIt = localProjectAssetData->assetDataMap.find(name);

		// 語系判斷
		if (name.find("i18n_") != std::string::npos) {
			if (langType == kLanguageCH_TW) {	// 繁中
				if (name.find("i18n_tw") == std::string::npos) {	// 跳過非i18n_tw檔案
					continue;
				}
			}
			else {
				if (name.find("i18n_cn") == std::string::npos) {	// 跳過非i18n_cn檔案
					continue;
				}
			}
		}

		if (localIt == localProjectAssetData->assetDataMap.end()) {	// 還沒下載過
			data->state = eOneStateNone;
			needUpdateAsset.push_back(data);
			totalNeedLoadSize += data->size;	// KB
			continue;
		}

		if (localIt->second->md5 != it->second->md5) {	// md5不相同 > 需要更新
			data->state = eOneStateNone;
			needUpdateAsset.push_back(data);
			totalNeedLoadSize += data->size;	// KB
			continue;
		}
	}

	if (needUpdateAsset.size() <= 0) {
		nowType = eAllStateDownloadComplete;
		return;
	}
	nowType = eAllStateDownloadNeed;
}
/* 解析manifest檔案資料 */
void InGameDownloader::getProjectAssetData(ProjectAssetData* projectAssetData, unsigned char* content)
{
	Json::Reader reader;
	Json::Value value;

	CCLog("InGameDownloader getProjectAssetData: %s", content);

	const char* constContent = (const char*)(char*)content;

	bool ret = reader.parse(constContent, value);

	if (!ret) {
		CCLog("InGameDownloader getProjectAssetData: fail");
		return;
	}

	projectAssetData->isLoadSuccess = true;

	Json::Value files = value["assets"];
	if (!files.empty() && files.isArray()) {
		for (int i = 0; i < files.size(); ++i) {
			Json::Value unit = files[i];
			if (unit["name"].empty()) {
				continue;
			}

			assetData* data = new assetData();
			data->name = unit["name"].asString();
			data->md5 = unit["md5"].asString();
			data->crc = unit["crc"].asString();
			data->size = unit["size"].asDouble();
			data->time = unit["time"].asDouble();
			projectAssetData->addAssetData(data);
		}
	}
	projectAssetData->time = value["time"].asDouble();
}
/* 寫入本地manifest資料 */
void InGameDownloader::writeProjectManifest()
{
	std::string writeRootPath = CCFileUtils::sharedFileUtils()->getWritablePath();
	std::string path = writeRootPath + versionPath + "/" + projectManifestName;
	std::ofstream fout;
	fout.open(path.c_str());
	assert(fout.is_open());
	//
	Json::Value root;
	Json::Value assets;
	for (auto it = localProjectAssetData->assetDataMap.begin(); it != localProjectAssetData->assetDataMap.end(); ++it) {
		Json::Value data;
		data["crc"] = it->second->crc;
		data["md5"] = it->second->md5;
		data["name"] = it->second->name;
		data["size"] = it->second->size;
		data["time"] = it->second->time;
		assets.append(data);
	}
	root["assets"] = assets;
	root["time"] = serverProjectAssetData->time;
	//
	std::string out = root.toStyledString();
	std::cout << out << std::endl;
	fout << out << std::endl;
	fout.close();
}
/* 下載callback */
void InGameDownloader::downloaded(const std::string& url, const std::string& filename)
{
	if (url.find("server") != url.npos) {
		return;
	}
	if (url.find("project") != url.npos) {
		return;
	}
	if (url.find("version") != url.npos) {
		return;
	}
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.find((*it)->name) != std::string::npos) {
			fileLoadSizeMap[(*it)->name] = (*it)->size;	// KB
			// 下載完先解壓縮
			CCLog("--->InGameDownload downloaded save path: %s storage: %s ext path %s", (*it)->savePath.c_str(), (*it)->stroge.c_str(), filename.c_str());
			bool value = AssetsManagerEx::getInstance()->uncompress((*it)->savePath.c_str(), (*it)->stroge);
			// delete file
			remove((*it)->savePath.c_str());
			// 解壓縮後更新projectManifest 避免重新下載
			assetData* data = new assetData();
			data->name = (*it)->name;
			data->md5 = (*it)->md5;
			data->crc = (*it)->crc.c_str();
			data->size = (*it)->size;
			data->time = (*it)->time;
			localProjectAssetData->assetDataMap.insert(std::make_pair((*it)->name, data));
			auto localIt = localProjectAssetData->assetDataMap.find((*it)->name);
			localIt->second->size = (*it)->size;
			localIt->second->crc = (*it)->crc;
			localIt->second->md5 = (*it)->md5;
			localIt->second->time = (*it)->time;
			writeProjectManifest();

			(*it)->state = eOneStateSuccess;
		}
	}
	bool allComplete = true;
	bool downloading = false;
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if ((*it)->state != eOneStateSuccess) {
			allComplete = false;
		}
		if ((*it)->state == eOneStateIng) {
			downloading = true;
		}
	}
	if (allComplete) {	// 全部下載完成
		nowType = eAllStateDownloadComplete;
	}
	else if (downloading) {	// 還有檔案下載中
		nowType = eAllStateDownloading;
	}
	else {	// 沒有全部下載完&沒有下載中
		if (failedUpdateAsset.size() > 0) {	// 有下載失敗的檔案 > 重新下載
			redownloadAll();
		}
		else {	// 沒有下載失敗的檔案 > 等待玩家下載
			nowType = eAllStateDownloadNeed;
		}
	}
}
void InGameDownloader::downloadFailed(const std::string& url, const std::string& filename, int errorType)
{
	if (url.find("server") != url.npos) {
		return;
	}
	if (url.find("project") != url.npos) {
		return;
	}
	if (url.find("version") != url.npos) {
		return;
	}
	CCLog("--->InGameDownloader downloadFailed  url: %s : filename : %s error: %d", url.c_str(), filename.c_str(), errorType);
	bool downloading = false;
	for (auto it = needUpdateAsset.begin(); it != needUpdateAsset.end(); ++it) {
		if (url.compare((*it)->url) == 0) {
			(*it)->state = eOneStateFailed;
			failedUpdateAsset.push_back(*it);
		}
		if ((*it)->state == eOneStateIng) {
			downloading = true;
		}
	}
	if (!downloading && failedUpdateAsset.size() > 0) {
		redownloadAll();
	}
}
void InGameDownloader::onAlreadyDownSize(unsigned long size, const std::string& url, const std::string& savePath)
{
	if (url.find("server") != url.npos) {
		return;
	}
	if (url.find("project") != url.npos) {
		return;
	}
	if (url.find("version") != url.npos) {
		return;
	}
	std::string delimiter = "/";
	std::vector<std::string> result = split(url, *delimiter.c_str());
	std::string fileName = result.back();
	if (fileLoadSizeMap[fileName]) {
		if (fileLoadSizeMap[fileName] < float(size) / 1024) {
			fileLoadSizeMap[fileName] = float(size) / 1024;
		}
	}
	else {
		fileLoadSizeMap[fileName] = float(size) / 1024;	//KB
	}
}
void InGameDownloader::redownloadAll()
{
	if (downloadFailedTime < 3) {	// 失敗次數<3 重新下載
		for (auto it = failedUpdateAsset.begin(); it != failedUpdateAsset.end(); ++it) {
			(*it)->state = eOneStateNone;
			downloadAssetByData(*it);
		}
		downloadFailedTime += 1;
		failedUpdateAsset.clear();
	}
	else {
		nowType = eAllStateDownloadFailed;
		checkManifest(tempUrl);	// 重新檢查manifest
	}
}
/* Java下載callback */
void InGameDownloader::OnDownloadProgress(const std::string& url, const std::string& filename, const std::string& basePath, long progress)
{
	onAlreadyDownSize(progress, url, filename);
}
void InGameDownloader::OnDownloadComplete(const std::string& url, const std::string& filename, const std::string& filenameWithPath, const std::string& md5Str)
{
	downloaded(url, filenameWithPath);
}
void InGameDownloader::OnDownloadFailed(const std::string& url, const std::string& filename, const std::string& basePath, int errorCode)
{
	downloadFailed(url, filename, errorCode);
}
/* 字串分割工具 */
std::vector<std::string> InGameDownloader::split(const std::string& str, char delimiter) {
	std::vector<std::string> result;
	std::stringstream ss(str);
	std::string item;

	while (std::getline(ss, item, delimiter)) {
		result.push_back(item);
	}

	return result;
}