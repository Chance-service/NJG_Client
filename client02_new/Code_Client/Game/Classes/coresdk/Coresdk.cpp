#include "Coresdk.h"
#include "coresdk/util.h"
#include "coresdk/webapi.h"
#include "coresdk/DeepLink.h"

USING_NS_CC;
namespace coresdk {
	// 初始化靜態變數
	std::string Coresdk::prefKeyToken = "coresdk.token";

	static Coresdk *_sharedInstance = NULL;
	bool isCoresdkInitialized = false;

	Coresdk::OnInitializeCallback onInitializeCallback;
	Coresdk::OnLoginCallback onLoginCallback;
	Coresdk::OnLogoutCallback onLogoutCallback;
	Coresdk::OnBindCallback onBindCallback;

	void onConfigInitializeCallback(bool isSuccess, coresdk::Config config) {
		if (isSuccess) {
			isCoresdkInitialized = true;
			Coresdk::getInstance()->config = config;

			// 輸出組態檔相關資訊
			//CCLog("ApiDomain:%s", config.ApiDomain.c_str());
		}

		if (onInitializeCallback) {
			onInitializeCallback(isSuccess);
		}
	}

	void setToken(std::string value) {
		Coresdk::getInstance()->token = value;
		CCUserDefault::sharedUserDefault()->setStringForKey(coresdk::Coresdk::prefKeyToken.c_str(), value);
	}

	std::string parsePlatformEnum(Platform platform) {
		switch (platform) {
		case Platform::R18:
			return "R18";
		case Platform::R15:
			return "R15";
		}

		return "";
	}

	Coresdk *Coresdk::getInstance() {
		if (! _sharedInstance)
		{
			_sharedInstance = new Coresdk();
			_sharedInstance->loader = new ConfigLoader();
			_sharedInstance->apiUtil = APIUtil::create();

			// 試著取出token
			_sharedInstance->token = CCUserDefault::sharedUserDefault()->getStringForKey(coresdk::Coresdk::prefKeyToken.c_str(), "");
		}

		return _sharedInstance;
	}

	void Coresdk::initialize(std::string gameId, std::string applicationIdentifier, Platform platform, Coresdk::OnInitializeCallback callback) {
		Coresdk::getInstance()->gameId = gameId;
		Coresdk::getInstance()->applicationIdentifier = applicationIdentifier;
		Coresdk::getInstance()->platform = parsePlatformEnum(platform);

		onInitializeCallback = callback;

		// 更新設定檔及確認domain 網址
		Coresdk::getInstance()->loader->initialize(onConfigInitializeCallback);
	}

	std::string Coresdk::getToken() {
		return Coresdk::getInstance()->token;
	}

	std::string Coresdk::getLoginURL() {
		if (!isCoresdkInitialized) {
			CCLog("Please initialize() first.");
			return "";
		}

		return Coresdk::getInstance()->config.Domain + "/login/";
	}

	// 登入啟動deeplink 時的回調函式
	void coresdk_login_invoke_request_profile(coresdk::ProfileResult profileResult) {
		if (onLoginCallback) {
			onLoginCallback(profileResult);
		}
	}

	// 綁定啟動deeplink 時的回調函式
	void coresdk_bind_invoke_request_profile(coresdk::ProfileResult profileResult) {
		if (onBindCallback) {
			onBindCallback(profileResult);
		}
	}

	// 提供C++ DeepLink 收到回調時，調用的函式

	void onDeepLinkLoginCallback(std::string url) {
		// 取得回傳網址中的token
		std::string token = coresdk::util::url_find_key(url, "token");
		setToken(token);

		// 向 web api 要求 profile 資訊
		coresdk::webapi::requestProfile(
			Coresdk::getInstance()->config.ApiDomain,
			token,
			coresdk_login_invoke_request_profile);
	}

	void onDeepLinkLogoutCallback(std::string url) {
		setToken("");
		coresdk::LogoutResult logoutResult = coresdk::LogoutResult();
		if (onLogoutCallback)
			onLogoutCallback(logoutResult);
	}

	void onDeepLinkBindCallback(std::string url) {
		std::string token = coresdk::util::url_find_key(url, "token");
		std::string bind = coresdk::util::url_find_key(url, "bind");
		if (bind == "success") {
			setToken(token);

			// 向 web api 要求 profile 資訊
			coresdk::webapi::requestProfile(
				Coresdk::getInstance()->config.ApiDomain,
				token,
				coresdk_bind_invoke_request_profile);
			return;
		}

		ProfileResult profileResult = ProfileResult();
		profileResult.isSuccess = false;
		profileResult.exception = "bind_failed";
		coresdk_bind_invoke_request_profile(profileResult);
	}

	// End of 提供C++ DeepLink 收到回調時，調用的函式

	void Coresdk::openLogin(OnLoginCallback callback) {
		onLoginCallback = callback;

		std::string token = Coresdk::getInstance()->token;
		if (!token.empty()) {
			// 向 web api 要求 profile 資訊
			coresdk::webapi::requestProfile(
				Coresdk::getInstance()->config.ApiDomain,
				token,
				coresdk_login_invoke_request_profile);

			return;
		}

		// 組合成指定網址
		std::string endpoint = "/login/";
		std::string applicationIdentifier = Coresdk::getInstance()->applicationIdentifier;
		std::string callbackUrl = coresdk::util::get_deeplink_url(applicationIdentifier, "");
		std::string game_id = Coresdk::getInstance()->gameId;
		std::string platform = Coresdk::getInstance()->platform;

		std::string url = Coresdk::getInstance()->config.Domain + 
			endpoint + "?" + "login=true" + "&callback=" + callbackUrl + "&game_id=" + game_id + "&platform=" + platform;

		coresdk::DeepLink::openURL(url, onDeepLinkLoginCallback);
	}

	void Coresdk::openLogout(OnLogoutCallback callback) {
		onLogoutCallback = callback;

		// 組合成指定網址
		std::string endpoint = "/login/";
		std::string applicationIdentifier = Coresdk::getInstance()->applicationIdentifier;
		std::string callbackUrl = coresdk::util::get_deeplink_url(applicationIdentifier, "");

		std::string url = Coresdk::getInstance()->config.Domain
			+ endpoint + "?" + "logout=true" + "&callback=" + callbackUrl;

		coresdk::DeepLink::openURL(url, onDeepLinkLogoutCallback);
	}

	void Coresdk::openPayment() {
		// 組合成指定網址
		std::string endpoint = "/payment/";
		std::string token = Coresdk::getInstance()->token;
		std::string domain = Coresdk::getInstance()->config.PaymentDomain;

		std::string url = domain + endpoint + "?jwt=" + token;

		// open with browser
		coresdk::util::open_url(url.c_str());
	}

	void Coresdk::openAccountBindGame(std::string game_account, OnBindCallback callback) {
		onBindCallback = callback;

		// 組合成指定網址
		std::string endpoint = "/bind/";
		std::string applicationIdentifier = Coresdk::getInstance()->applicationIdentifier;
		std::string callbackUrl = coresdk::util::get_deeplink_url(applicationIdentifier, "");
		std::string game_id = Coresdk::getInstance()->gameId;
		std::string platform = Coresdk::getInstance()->platform;

		std::string url = Coresdk::getInstance()->config.Domain
			+ endpoint + "?" + "game_id=" + game_id + "&game_account=" + game_account + "&callback=" + callbackUrl + "&platform=" + platform;;

		coresdk::DeepLink::openURL(url, onDeepLinkBindCallback);
	}

	void coresdk_postbindgame_callback(AccountBindGameResult result) {
		if (result.isSuccess) {
			coresdk::webapi::requestProfile(
				Coresdk::getInstance()->config.ApiDomain,
				Coresdk::getInstance()->getToken(),
				onBindCallback);

			return;
		}

		ProfileResult profileResult = ProfileResult();
		profileResult.isSuccess = false;
		profileResult.exception = result.reason;

		if (onBindCallback)
			onBindCallback(profileResult);
	}

	void Coresdk::postAccountBindGame(std::string game_account, OnBindCallback callback) {
		onBindCallback = callback;

		// 組合成指定網址
		std::string endpoint = "/accountBindGame";
		std::string game_id = Coresdk::getInstance()->gameId;

		coresdk::webapi::postAccountBindGame(
			Coresdk::getInstance()->config.ApiDomain,
			Coresdk::getInstance()->getToken(),
			game_id,
			game_account,
			coresdk_postbindgame_callback);
	}
}
