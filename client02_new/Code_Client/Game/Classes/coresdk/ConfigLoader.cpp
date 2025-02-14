#include "ConfigLoader.h"
USING_NS_CC;

#include "../rapidjson/rapidjson.h"
#include "../rapidjson/document.h"

#include "WebRequest.h"

namespace coresdk {
	// 初始化靜態變數
	std::string ConfigLoader::configFilename = "coresdk_domain_v1.txt";

	ConfigLoader::OnInitializeCallback onConfigLoaderInitializeCallback;
	ConfigLoader *configLoader;
	coresdk::Config config;

	struct DomainJson {
		std::vector<std::string> config;
		std::vector<std::string> login;
		std::string payment;
	} domainJson;

	WebRequest *webRequest;

	void ConfigLoader::initialize(ConfigLoader::OnInitializeCallback callback) {
		onConfigLoaderInitializeCallback = callback;

		webRequest = WebRequest::create();

		std::string json = CCUserDefault::sharedUserDefault()->getStringForKey(coresdk::ConfigLoader::configFilename.c_str(), "");
		if (json.empty()) {
			unsigned long pSize = 0;
			unsigned char* data = CCFileUtils::sharedFileUtils()->getFileData(coresdk::ConfigLoader::configFilename.c_str(), "r", &pSize);
			CCString *strdata = CCString::createWithData(data, pSize);
			json = strdata->m_sString;
		}

		parseDomainJson(json);
		updateConfig();
	}

	ConfigLoader::ConfigLoader() {
		configLoader = this;
	}

	void onConfigDownloaded(bool isError, std::string text) {
		if (isError) {
			configLoader->updateConfig();
			return;
		}

		// 下載到新的domain_config，保留起來
		CCUserDefault::sharedUserDefault()->setStringForKey(coresdk::ConfigLoader::configFilename.c_str(), text);
		configLoader->parseDomainJson(text);
		configLoader->findLoginDomain();
	}

	void onLoginDomainResponse(bool isError, std::string text) {
		if (isError) {
			configLoader->findLoginDomain();
			return;
		}

		// 確認login domain 可以正常使用
		if (onConfigLoaderInitializeCallback)
			onConfigLoaderInitializeCallback(true, config);
	}

	void ConfigLoader::updateConfig() {
		if (domainJson.config.empty()) {
			if (onConfigLoaderInitializeCallback)
				onConfigLoaderInitializeCallback(false, coresdk::Config());

			return;
		}

		std::string url = domainJson.config.front();		// 取出第一個元素
		domainJson.config.erase(domainJson.config.begin());	// 刪除第一個元素

		webRequest->get(url, onConfigDownloaded);
	}

	void ConfigLoader::findLoginDomain() {
		if (domainJson.login.empty()) {
			if (onConfigLoaderInitializeCallback)
				onConfigLoaderInitializeCallback(false, coresdk::Config());

			return;
		}

		std::string url = domainJson.login.front();			// 取出第一個元素
		domainJson.login.erase(domainJson.login.begin());	// 刪除第一個元素

		config.Domain = url;
		config.ApiDomain = url + "/api";
		config.PaymentDomain = domainJson.payment;
		webRequest->get(url + "/api/checkLoginUrl", onLoginDomainResponse);
	}

	void ConfigLoader::parseDomainJson(std::string json) {
		// json 解析
		rapidjson::Document d;
		d.Parse<0>(json.c_str());
		/*
		if (d.IsObject() && d.HasMember("result")) { 
			CCLOG("%s\n", d["result"].GetString());
		}
		*/
		domainJson = DomainJson();

		const rapidjson::Value& a1 = d["config"];
		for (rapidjson::SizeType i = 0; i < a1.Size(); i++) {
			domainJson.config.push_back(a1[i].GetString());
		}
    
		const rapidjson::Value& a2 = d["login"];
		for (rapidjson::SizeType i = 0; i < a2.Size(); i++) {
			domainJson.login.push_back(a2[i].GetString());
		}

		domainJson.payment = d["payment"].GetString();
	}
}
