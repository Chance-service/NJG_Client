#include "util.h"

USING_NS_CC;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
extern "C" {
    extern void coresdk_util_openbrowser(const char *url);
    extern const char * coresdk_util_get_bundle_identifier();
}
#endif

namespace coresdk {
	namespace util {
		std::string url_find_key(std::string &url, std::string key) {
			std::string _key = key + "=";
			std::size_t start_pos = url.find(_key);
			std::size_t end_pos = url.find("&", start_pos);

			if (end_pos != url.npos) {
				return url.substr(start_pos + _key.length(), end_pos - start_pos - _key.length());
			}
	
			return url.substr(start_pos + _key.length(), url.length());
		}

		std::string get_deeplink_url(std::string packageName, std::string lastPath) {
			if (lastPath.empty()) {
				return "coresdk://coresdk.games/" + packageName;
			}

			return "coresdk://coresdk.games/" + packageName + "/" + lastPath;
		}

		void open_url(const char* pszUrl) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
			ShellExecuteA(NULL, "open", pszUrl, NULL, NULL, SW_SHOWNORMAL);
#endif
            
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
            coresdk_util_openbrowser(pszUrl);
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			JniMethodInfo minfo;
			jobject nativeActivity;

			// 取得 android.content.Context
			if (JniHelper::getStaticMethodInfo(minfo,		// JniMethodInfo 的引用
				"org/cocos2dx/lib/Cocos2dxActivity",		// 類的路徑
				"getContext",								// 函式名稱
				"()Landroid/content/Context;"))				// 函式類型簡寫
			{
				nativeActivity = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
				minfo.env->DeleteLocalRef(minfo.classID);
			}

			// 調用 android native
			if (JniHelper::getStaticMethodInfo(minfo,		// JniMethodInfo 的引用
				"games/cocos2dx/Util",						// 類的路徑
				"openURL",									// 函式名稱
				"(Landroid/content/Context;Ljava/lang/String;)V"))	// 函式類型簡寫
			{
				jstring jsurl = minfo.env->NewStringUTF(pszUrl);

				minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, nativeActivity, jsurl);
				minfo.env->DeleteLocalRef(jsurl);
				minfo.env->DeleteLocalRef(minfo.classID);
			}
#endif
		}

		std::string get_package_name() {
			std::string package_name = "";
            
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
            package_name = std::string(coresdk_util_get_bundle_identifier());
#endif

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
			JniMethodInfo minfo;
			jobject nativeActivity;

			// 取得 android.content.Context
			if (JniHelper::getStaticMethodInfo(minfo,		// JniMethodInfo 的引用
				"org/cocos2dx/lib/Cocos2dxActivity",		// 類的路徑
				"getContext",								// 函式名稱
				"()Landroid/content/Context;"))			// 函式類型簡寫
			{
				nativeActivity = minfo.env->CallStaticObjectMethod(minfo.classID, minfo.methodID);
				minfo.env->DeleteLocalRef(minfo.classID);
			}

			// 取得 package name
			if (JniHelper::getMethodInfo(minfo, 
				"android/content/Context",
				"getPackageName", 
				"()Ljava/lang/String;"))
			{
				jstring js_packagename = (jstring)(minfo.env->CallObjectMethod(nativeActivity, minfo.methodID));
		
				const char* strReturn = minfo.env->GetStringUTFChars(js_packagename, 0);
				package_name = std::string(strReturn);
				minfo.env->ReleaseStringUTFChars(js_packagename, strReturn);
			}
#endif

			return package_name;
		}
	}
};
