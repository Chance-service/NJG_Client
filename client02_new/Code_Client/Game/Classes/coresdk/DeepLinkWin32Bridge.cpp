#include "DeepLinkWin32Bridge.h"
#include "Coresdk.h"
#include "webapi.h"
#include "util.h"

#include "../rapidjson/rapidjson.h"
#include "../rapidjson/document.h"

USING_NS_CC;
using namespace coresdk::DeepLink;

OnDeepLinkCallback coresdk_deeplink_win32_bridge_ondeeplink_callback;

namespace editor {
	const std::string base64_chars = 
             "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
             "abcdefghijklmnopqrstuvwxyz"
             "0123456789+/";
 
	static inline bool is_base64(unsigned char c) {
		return (isalnum(c) || (c == '+') || (c == '/'));
	}

	// href: https://blog.csdn.net/acs713/article/details/12705363
	std::string base64_encode(std::string s) {
		char const* bytes_to_encode = s.c_str();
		unsigned int in_len = s.length();

		std::string ret;
		int i = 0;
		int j = 0;
		unsigned char char_array_3[3];
		unsigned char char_array_4[4];
 
		while (in_len--) {
			char_array_3[i++] = *(bytes_to_encode++);
			if (i == 3) {
				char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
				char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
				char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
				char_array_4[3] = char_array_3[2] & 0x3f;
 
				for(i = 0; (i <4) ; i++)
				ret += base64_chars[char_array_4[i]];
				i = 0;
			}
		}
 
		if (i) {
			for(j = i; j < 3; j++)
				char_array_3[j] = '\0';
 
			char_array_4[0] = (char_array_3[0] & 0xfc) >> 2;
			char_array_4[1] = ((char_array_3[0] & 0x03) << 4) + ((char_array_3[1] & 0xf0) >> 4);
			char_array_4[2] = ((char_array_3[1] & 0x0f) << 2) + ((char_array_3[2] & 0xc0) >> 6);
			char_array_4[3] = char_array_3[2] & 0x3f;
 
			for (j = 0; (j < i + 1); j++)
				ret += base64_chars[char_array_4[j]];
 
			while((i++ < 3))
				ret += '=';
 
		}
 		return ret;
	}

	void editor_webapi_postlogin_rawresponse(coresdk::APIUtil::RawResponse res) {
		rapidjson::Document d;
		d.Parse<0>(res.Data.c_str());

		std::string login = d["login"].GetString();
		if (login != "Success") {
			std::string reason = d["reason"].GetString();

			//CCLog("post login failed. returncode:%s", reason.c_str());
			if (coresdk_deeplink_win32_bridge_ondeeplink_callback)
				coresdk_deeplink_win32_bridge_ondeeplink_callback("https://aa.bb/?token=&bind=fail");
			return;
		}

		std::string token = d["jwt"].GetString();

		if (coresdk_deeplink_win32_bridge_ondeeplink_callback)
			coresdk_deeplink_win32_bridge_ondeeplink_callback("https://aa.bb/?token=" + token + "&bind=success");
	}

	void editor_webapi_postaccountbindgame_rawresponse(coresdk::APIUtil::RawResponse res) {
		//CCLog("editor_webapi_postaccountbindgame_rawresponse:%s", res.Data.c_str());
		//{"result":"0403","reason":"您輸入的郵件或密碼有誤，請重新輸入。","jwt":""}
		rapidjson::Document d;
		d.Parse<0>(res.Data.c_str());

		std::string result = d["result"].GetString();
		if (result != "0000") {
			std::string reason = d["reason"].GetString();

			CCLog("post AccountBindGame failed. [%s]%s", reason.c_str(), reason.c_str());
			if (coresdk_deeplink_win32_bridge_ondeeplink_callback)
				coresdk_deeplink_win32_bridge_ondeeplink_callback("https://aa.bb/?bind=failed");
			return;
		}

		std::string token = d["jwt"].GetString();

		if (coresdk_deeplink_win32_bridge_ondeeplink_callback)
			coresdk_deeplink_win32_bridge_ondeeplink_callback("https://aa.bb/?bind=success&token=" + token);
	}

	void editor_webapi_postguestlogin_rawresponse(coresdk::APIUtil::RawResponse res) {
		// {"result":"0000","server_time":1607840657349,"user_info":{"birthday":"","country":"TW","free_coins":0,"gender":0,"user_id":"9e519301-f906-405f-9b4d-190fcb82dd67","hobbies":"","coins":0,"nickname":"","account_status":"pending_activation","account":""},"jwt":"eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiOWU1MTkzMDEtZjkwNi00MDVmLTliNGQtMTkwZmNiODJkZDY3IiwidG9rZW5faWQiOiIwZmU5YmM4ZS04M2EyLTQ1YzgtOThiYi1jZGY3YTk5NzhmYzkiLCJpYXQiOjE2MDc4NDA2NTd9.SX_VviG05Qmrx93mxrH_qHFf5NOaEXN-PYWt8l8iTZK-54JDhMNPndcIJ7-rQAEZ6yjeAQB8qluDBvO9-fjpTJrwkSGYSlMaVbyni6g0u17by7zUSXZqOh8kOxirrzChpLw91JQK31ahmnPa4SoiQGVYQjl1H3_lqJ53v6sYY436vIU8LmlKGTvdG-C2ah7Ff3q38my39qPeXXX6FiEcX10SRV5pbTasGxpO1WLBcE8yunsQKpaI6OnMsB0FJPoBr-NpPJMBKl73vmKyNwP0XFmFJUIDe1WwTUPJrgaGxQ2gUin3-o7anz2M-bGTZGTyPTDzNHsFIyoZ5quBmYi1cQ","is_new_user":1}

		rapidjson::Document d;
		d.Parse<0>(res.Data.c_str());

		std::string result = d["result"].GetString();
		if (result != "0000") {
			//CCLog("post guestLogin failed. result:%s", result.c_str());
			if (coresdk_deeplink_win32_bridge_ondeeplink_callback)
				coresdk_deeplink_win32_bridge_ondeeplink_callback("https://aa.bb/?token=");
			return;
		}

		std::string token = d["jwt"].GetString();

		if (coresdk_deeplink_win32_bridge_ondeeplink_callback)
			coresdk_deeplink_win32_bridge_ondeeplink_callback("https://aa.bb/?token=" + token + "&bind=success");
	}
	
	void postLogin(std::string account, std::string password) {
		std::string domain = coresdk::Coresdk::getInstance()->config.ApiDomain;
		std::string token = coresdk::Coresdk::getInstance()->getToken();
		std::string game_id = coresdk::Coresdk::getInstance()->gameId;

		std::string endpoint = "/accountLogin";
		std::string url = domain + endpoint;

		std::map<std::string, std::string> query;
		std::string body = 
			"game_id=" + game_id +
			"&password=" + editor::base64_encode(password) + 
			"&account=" + account;

		coresdk::Coresdk::getInstance()->apiUtil->requestAPI(url, query, token, body, editor_webapi_postlogin_rawresponse);
	}

	void postAccountBindGame(std::string account, std::string password, std::string game_account) {
		std::string domain = coresdk::Coresdk::getInstance()->config.ApiDomain;
		std::string token = coresdk::Coresdk::getInstance()->getToken();
		std::string game_id = coresdk::Coresdk::getInstance()->gameId;
		std::string platform = coresdk::Coresdk::getInstance()->platform;

		std::string endpoint = "/accountLoginBindGame";
		std::string url = domain + endpoint;

		std::map<std::string, std::string> query;
		std::string body = 
			"game_id=" + game_id +
			"&password=" + editor::base64_encode(password) + 
			"&account=" + account + 
			"&game_account=" + game_account + 
			"&platform=" + platform;

		coresdk::Coresdk::getInstance()->apiUtil->requestAPI(url, query, token, body, editor_webapi_postaccountbindgame_rawresponse);
	}

	void postGuestLogin() {
		std::string domain = coresdk::Coresdk::getInstance()->config.ApiDomain;
		std::string token = coresdk::Coresdk::getInstance()->getToken();
		std::string game_id = coresdk::Coresdk::getInstance()->gameId;
		std::string platform = coresdk::Coresdk::getInstance()->platform;

		std::string endpoint = "/guestLogin";
		std::string url = domain + endpoint;

		std::map<std::string, std::string> query;
		std::string body = 
			"game_id=" + game_id +
			"&platform=" + platform;

		coresdk::Coresdk::getInstance()->apiUtil->requestAPI(url, query, token, body, editor_webapi_postguestlogin_rawresponse);
	}
};

void coresdk::DeepLinkWin32Bridge::openURL(std::string url, OnDeepLinkCallback callback) {
	coresdk_deeplink_win32_bridge_ondeeplink_callback = callback;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	CCLog("Coresdk::DeepLinkWin32Bridge::openByUrl(%s)", url.c_str());

	// 讀取測試組態檔(Resources/editor/test.json)
	unsigned long pSize = 0;
	unsigned char* data = CCFileUtils::sharedFileUtils()->getFileData("editor/test.json", "r", &pSize);
	CCString *strdata = CCString::createWithData(data, pSize);
	std::string json = strdata->m_sString;

	rapidjson::Document d;
	d.Parse<0>(json.c_str());

	if (d.HasParseError()) {
		CCLog("editor/test.json parse error(offset %u):%s", 
			(unsigned)d.GetErrorOffset(),
			d.GetParseError());
		return;
	}

	if (url.find("/login") != url.npos && url.find("login=true") != url.npos) {
		if (!d.HasMember("login")) {
			CCLog("editor/test.json does not include 'login'");
			return;
		}

		bool isGuest = d["login"]["isGuest"].GetBool();
		if (isGuest) {
			editor::postGuestLogin();
			return;
		}

		std::string account = d["login"]["account"].GetString();
		std::string password = d["login"]["password"].GetString();

		editor::postLogin(account, password);
	}
	else if (url.find("/bind") != url.npos) {
		if (!d.HasMember("bind")) {
			CCLog("editor/test.json does not include 'bind'");
			return;
		}

		std::string account = d["bind"]["account"].GetString();
		std::string password = d["bind"]["password"].GetString();
		std::string game_account = coresdk::util::url_find_key(url, "game_account");

		editor::postAccountBindGame(account, password, game_account);
	}
	else if (url.find("/login") != url.npos && url.find("logout=true") != url.npos) {
		if (coresdk_deeplink_win32_bridge_ondeeplink_callback)
			coresdk_deeplink_win32_bridge_ondeeplink_callback("https://aa.bb/");
	}
#endif
}
