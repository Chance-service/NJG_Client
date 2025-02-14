#ifndef  _CORESDK_RESULT_H_
#define  _CORESDK_RESULT_H_

#include "cocos2d.h"

namespace coresdk {
	struct LogoutResult {
		std::string exception;
	};

	struct UserInfo {
        std::string birthday;
        std::string country;
        int free_coins;
        int gender;
        std::string user_id;
        std::string hobbies;
        int coins;
        std::string nickname;
        std::string account_status;
        std::string account;
	};

	struct ProfileData {
		std::string result;
		int64_t server_time;
		UserInfo user_info;
	};

	struct ProfileResult {
		std::string exception;
		ProfileData data;
		bool isSuccess;
	};

	struct AccountBindGameResult {
		std::string result;
		std::string reason;
		bool isSuccess;
	};
};

#endif // _CORESDK_RESULT_H_

