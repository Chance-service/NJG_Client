#ifndef  _CORESDK_DEEPLINK_IOS_BRIDGE_H_
#define  _CORESDK_DEEPLINK_IOS_BRIDGE_H_

#include "cocos2d.h"
#include "DeepLink.h"

namespace coresdk {
	class DeepLinkIosBridge
	{
	public:
		static void openURL(std::string url, coresdk::DeepLink::OnDeepLinkCallback callback);

	};
}

#endif // _CORESDK_DEEPLINK_IOS_BRIDGE_H_
