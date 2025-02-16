//#include "../coresdk/webapi.h"
#include "webapi.h"

#include "cocos2d.h"
//#include "../coresdk/APIUtil.h"
#include "APIUtil.h"
//#include "../coresdk/Coresdk.h"
#include "Coresdk.h"


//#include "../rapidjson/rapidjson.h"
#include "rapidjson.h"
#include "document.h"
//#include "../rapidjson/document.h"

USING_NS_CC;

namespace coresdk {
	namespace webapi {
		OnRequestProfileCallback onRequestProfileCallback;

		std::string get_json_string(rapidjson::Value &d, char *key) {
			if (!d.HasMember(key))
				return "";

			return d[key].GetString();
		}

		int64_t get_json_int64(rapidjson::Value &d, char *key) {
			if (!d.HasMember(key))
				return 0;

			return d[key].GetInt64();
		}

		int get_json_int(rapidjson::Value &d, char *key) {
			if (!d.HasMember(key))
				return 0;

			return d[key].GetInt();
		}

		// 將RawResponse 轉成ProfileResult，再調用callback
		ProfileResult parseProfileResult(APIUtil::RawResponse &res) {
			ProfileResult result = ProfileResult();
			result.exception = res.Exception;
			result.isSuccess = res.Exception.empty();

			if (result.isSuccess) {
				// 將回傳json 字串轉成物件
				rapidjson::Document d;
				d.Parse<0>(res.Data.c_str());

				result.data = ProfileData();
				result.data.result = get_json_string(d, "result");
				result.data.server_time = get_json_int64(d, "server_time");

				result.data.user_info = UserInfo();
				if (d.HasMember("user_info")) {
					rapidjson::Value& user_info = d["user_info"];
					result.data.user_info.account = get_json_string(user_info, "account");
					result.data.user_info.account_status = get_json_string(user_info, "account_status");
					result.data.user_info.birthday = get_json_string(user_info, "birthday");
					result.data.user_info.coins = get_json_int(user_info, "coins");
					result.data.user_info.country = get_json_string(user_info, "country");
					result.data.user_info.free_coins = get_json_int(user_info, "free_coins");
					result.data.user_info.gender = get_json_int(user_info, "gender");
					result.data.user_info.hobbies = get_json_string(user_info, "hobbies");
					result.data.user_info.nickname = get_json_string(user_info, "nickname");
					result.data.user_info.user_id = get_json_string(user_info, "user_id");
				}
			}

			return result;
		}

		// 提供 requestProfile 函式調用 requestAPI 後，動作結束時調用
		void webapi_requestprofile_rawresponse(APIUtil::RawResponse res) {
			ProfileResult result = parseProfileResult(res);

			if (onRequestProfileCallback) {
				onRequestProfileCallback(result);
			}
		}

		void requestProfile(std::string domain, std::string token, OnRequestProfileCallback callback) {
			onRequestProfileCallback = callback;

			std::string endpoint = "/getUserInfo";
			std::string url = domain + endpoint;

			std::map<std::string, std::string> query;
			query["merchantId"] = "";
			query["serviceId"] = "";

			Coresdk::getInstance()->apiUtil->requestAPI(url, query, token, "", webapi_requestprofile_rawresponse);
		}

		// --------------------
		OnPostAccountBindGameCallback onPostAccountBindGameCallback;

		void webapi_postaccountbindgame_rawresponse(APIUtil::RawResponse res) {
			// RawResponse to AccountBindGame
			AccountBindGameResult result = AccountBindGameResult();

			if (!res.Exception.empty())
			{
				result.isSuccess = false;
				result.result = "-1";
				result.reason = res.Exception;
			}
			else
			{
				rapidjson::Document d;
				d.Parse<0>(res.Data.c_str());

				result.result = d["result"].GetString();
				result.reason = d["reason"].GetString();
				result.isSuccess = result.result == "0000";
			}

			if (onPostAccountBindGameCallback) {
				onPostAccountBindGameCallback(result);
			}
		}

		void postAccountBindGame(std::string domain, std::string token, std::string game_id, std::string game_account, OnPostAccountBindGameCallback callback) {
			onPostAccountBindGameCallback = callback;

			std::string endpoint = "/accountBindGame";
			std::string url = domain + endpoint;
			std::string platform = Coresdk::getInstance()->platform;

			std::map<std::string, std::string> query;
			std::string body = 
				"game_id=" + game_id +
				"&game_account=" + game_account +
				"&platform=" + platform;

			Coresdk::getInstance()->apiUtil->requestAPI(url, query, token, body, webapi_postaccountbindgame_rawresponse);
		}
	}
}
