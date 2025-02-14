#ifndef  _CORESDK_DEEPLINK_H_
#define  _CORESDK_DEEPLINK_H_

#include "cocos2d.h"

namespace coresdk {
	namespace DeepLink {
		typedef void(*OnDeepLinkCallback)(std::string);

		void openURL(std::string url, OnDeepLinkCallback callback);
	}
};

#endif // _CORESDK_DEEPLINK_H_

