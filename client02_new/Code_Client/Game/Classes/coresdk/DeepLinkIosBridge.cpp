#include "DeepLinkIosBridge.h"
#include "ios/OpenWebViewWrapper.h"

USING_NS_CC;

coresdk::DeepLink::OnDeepLinkCallback coresdk_deeplink_ios_bridge_deeplink_callback;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
extern "C" {
    extern double coresdk_open_url(const char *url, CallbackT callback);
}

void invoke_deeplink_callback(const char *data) {
    std::string deepLinkUrl(data);
    
    if (coresdk_deeplink_ios_bridge_deeplink_callback)
        coresdk_deeplink_ios_bridge_deeplink_callback(deepLinkUrl);
}
#endif

void coresdk::DeepLinkIosBridge::openURL(std::string url, coresdk::DeepLink::OnDeepLinkCallback callback)
{
	coresdk_deeplink_ios_bridge_deeplink_callback = callback;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    coresdk_open_url(url.c_str(), invoke_deeplink_callback);
#endif
}

