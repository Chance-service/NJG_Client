#include "DeepLink.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "coresdk/DeepLinkAndroidBridge.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include "coresdk/DeepLinkWin32Bridge.h"
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "DeepLinkIosBridge.h"
#endif

void coresdk::DeepLink::openURL(std::string url, coresdk::DeepLink::OnDeepLinkCallback callback) {

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		coresdk::DeepLinkAndroidBridge::openURL(url, callback);
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
		coresdk::DeepLinkWin32Bridge::openURL(url, callback);
#endif
    
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        coresdk::DeepLinkIosBridge::openURL(url, callback);
#endif

}
