#include "DeepLinkAndroidBridge.h"

USING_NS_CC;

// 與 android 相關的代碼必須包起來，否則在win32 平台建置失敗
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#endif

coresdk::DeepLink::OnDeepLinkCallback coresdk_deeplink_android_bridge_deeplink_callback;

// org.cocos2dx.lib.Cocos2dxActivity
// android.content.Context context = Cocos2dxActivity.getContext();
// android.app.Activity activity = (android.app.Activity)context;
void coresdk::DeepLinkAndroidBridge::openURL(std::string url, coresdk::DeepLink::OnDeepLinkCallback callback)
{
	coresdk_deeplink_android_bridge_deeplink_callback = callback;

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

	// 調用 android native
    if (JniHelper::getStaticMethodInfo(minfo,		// JniMethodInfo 的引用
        "games/coresdk/cocos2dx/DeepLinkBridge",	// 類的路徑
        "openURL",									// 函式名稱
        "(Landroid/content/Context;Ljava/lang/String;)V"))	// 函式類型簡寫
    {
		jstring jsurl = minfo.env->NewStringUTF(url.c_str());

        minfo.env->CallStaticVoidMethod(minfo.classID, minfo.methodID, nativeActivity, jsurl);
		minfo.env->DeleteLocalRef(jsurl);
        minfo.env->DeleteLocalRef(minfo.classID);
    }
#endif
}

// 提供給 java 進行調用的函式
extern "C" 
{
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
    // Java_:是格式，必須加的
	// org_cocos2dx_cpp_AppActivity_NativeFunShowText:是包名+類名+方法名
	// 注意，若包名、類名、方法名中具有"_"，則需後綴"1"
	// runtime 時期，若無法找到對應函式將會閃退
	// 但同時也會印出函式名稱
	JNIEXPORT void JNICALL Java_games_coresdk_cocos2dx_DeepLinkBridge_invokeCpp(JNIEnv* env, jclass method, jstring param)
	{
		const char* data = env->GetStringUTFChars(param, 0);
		//CCLog("DeepLinkCallback:%s", data);
		invoke_deeplink_callback(data);
		//do cocosUI something
		env->ReleaseStringUTFChars(param, data);
	}
#endif
}

// 提供給"C" 調用的函式
void invoke_deeplink_callback(const char *data) {
	std::string deepLinkUrl(data);

	if (coresdk_deeplink_android_bridge_deeplink_callback)
		coresdk_deeplink_android_bridge_deeplink_callback(deepLinkUrl);
}
