#ifndef  _CORESDK_UTIL_H_
#define  _CORESDK_UTIL_H_

#include "cocos2d.h"

namespace coresdk {
	namespace util {
		std::string url_find_key(std::string &url, std::string key);

		std::string get_deeplink_url(std::string packageName, std::string lastPath);

		void open_url(const char* pszUrl);

		std::string get_package_name();
	}
};

#endif // _CORESDK_UTIL_H_

