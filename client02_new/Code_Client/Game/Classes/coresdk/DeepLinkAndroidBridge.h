#ifndef  _CORESDK_DEEPLINK_ANDROID_BRIDGE_H_
#define  _CORESDK_DEEPLINK_ANDROID_BRIDGE_H_

#include "cocos2d.h"
#include "coresdk/DeepLink.h"


// 此代碼依賴於 coresdk-android-cc2dx-bridge
// coresdk-android-cc2dx-bridge 之目的即為產出 "libCoresdkBridge-release"

// 作為 C++ / Android 之間的溝通橋樑
// 將C++ 調用時的參數進行包裝，調用 games.coresdk.DeepLink.openByUrl(String url)
// 提供 android native 回調函式
namespace coresdk {
	class DeepLinkAndroidBridge
	{
	public:
		static void openURL(std::string url, coresdk::DeepLink::OnDeepLinkCallback callback);

	};
}

extern "C" {
	void invoke_deeplink_callback(const char *data);
}

#endif // _CORESDK_DEEPLINK_ANDROID_BRIDGE_H_



