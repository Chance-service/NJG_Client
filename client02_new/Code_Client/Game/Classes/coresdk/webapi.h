#ifndef  _CORESDK_WEB_API_H_
#define  _CORESDK_WEB_API_H_

#include "coresdk/Result.h"

namespace coresdk {
	namespace webapi {
		
		// request profile
		typedef void(*OnRequestProfileCallback)(ProfileResult);
		void requestProfile(std::string domain, std::string token, OnRequestProfileCallback callback);

		// post accountbindgame
		typedef void(*OnPostAccountBindGameCallback)(AccountBindGameResult);
		void postAccountBindGame(std::string domain, std::string token, std::string game_id, std::string game_account, OnPostAccountBindGameCallback callback);
	}
}

#endif // _CORESDK_WEB_API_H_

