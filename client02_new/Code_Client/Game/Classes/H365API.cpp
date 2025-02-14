#include "H365API.h"

#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
#include <jni.h>
#include "..\..\cocos2dx\platform\android\jni\JniHelper.h"
#include <android/log.h>
#define H365APIDef "com/chance/allsdk/H365API"
#endif

#define LOG_ALLSDKTAG "allSDK-cocos-bridge"
#define LOGDH365(...) __android_log_print(ANDROID_LOG_DEBUG,LOG_ALLSDKTAG,__VA_ARGS__)

using namespace cocos2d;
/**
void H365API::setH365CheckJNI(bool chk) {
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo t;
	LOGDH365("setH365CheckJNI standby");
	if (JniHelper::getStaticMethodInfo(t, H365APIDef, "setH365APISwitch", "(Z)V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID, chk);
		t.env->DeleteLocalRef(t.classID);
		LOGDH365("setH365CheckJNI sendtojava");
	}
#endif
}


void H365API::setH365PayUrl(const char *aurl){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	JniMethodInfo t;
	LOGDH365("setPayUrl standby");
	if (JniHelper::getStaticMethodInfo(t, H365APIDef, "setH365PayUrl", "(Ljava/lang/String;)V")) {
		jstring jurl = t.env->NewStringUTF(aurl);
		t.env->CallStaticVoidMethod(t.classID, t.methodID, jurl);
		t.env->DeleteLocalRef(t.classID);
		LOGDH365("setPayUrl sendtojava");
	}
#endif
}
*/
void H365API::JNILOG(std::string alog){
#if CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID
	LOGDH365(alog.c_str());
#endif
}
