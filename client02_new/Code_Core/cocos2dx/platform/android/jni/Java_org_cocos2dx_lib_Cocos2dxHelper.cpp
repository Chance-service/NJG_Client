#include <stdlib.h>
#include <jni.h>
#include <android/log.h>
#include <string>
#include "JniHelper.h"
#include "cocoa/CCString.h"
#include "Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "libPlatform.h"
#include "libOS.h"

#define  LOG_TAG    "Java_org_cocos2dx_lib_Cocos2dxHelper.cpp"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

#define  CLASS_NAME "org/cocos2dx/lib/Cocos2dxHelper"

static EditTextCallback s_pfEditTextCallback = NULL;
static EditTextCallbackWithCancelFlag s_pfEditTextCallbackWithCancelFlag = NULL;
static DialogOkCallback s_pfDialogOkCallback = NULL;
static void* s_ctx = NULL;

using namespace cocos2d;
using namespace std;

string g_apkPath;
string g_appExternalStoragePath;//add by xinzheng 2013-05-18

extern "C" {

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetApkPath(JNIEnv*  env, jobject thiz, jstring apkPath, jstring appExternalStoragePath) {
        g_apkPath = JniHelper::jstring2string(apkPath);
		g_appExternalStoragePath = JniHelper::jstring2string(appExternalStoragePath);
    }
	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeOnCloseKeyboard(JNIEnv*  env, jobject thiz) {
		if (s_ctx!=NULL)
		{
			libOS::getInstance()->TheEditTextCloseKeyboardCallback(s_ctx);
		}
		else{
			LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeOnCloseKeyboard s_ctx== null");
		}
		
	}
	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeOnOpenKeyboard(JNIEnv*  env, jobject thiz) {
		if (s_ctx != NULL)
		{
			libOS::getInstance()->TheEditTextOpenKeyboardCallback(s_ctx);
		}
		else{
			LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeOnOpenKeyboard s_ctx== null");
		}
	}
	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeUpdateKeyboardHight(JNIEnv * env, jobject obj, int nHight) {

		libOS::getInstance()->UpdateKeyboardHight(s_ctx, nHight);
		
	}
    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult(JNIEnv * env, jobject obj, jbyteArray text) {
        jsize  size = env->GetArrayLength(text);
        if (size > 0) {
            jbyte * data = (jbyte*)env->GetByteArrayElements(text, 0);
            char* pBuf = (char*)malloc(size+1);
            if (pBuf != NULL) {
                memcpy(pBuf, data, size);
                pBuf[size] = '\0';
				LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult1");
                // pass data to edittext's delegate
				if (s_pfEditTextCallbackWithCancelFlag) {
					s_pfEditTextCallbackWithCancelFlag(pBuf, s_ctx, false);
				}
				LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult2");
                free(pBuf);
            }
            env->ReleaseByteArrayElements(text, data, 0);
        } else {
			LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult3");
            if (s_pfEditTextCallbackWithCancelFlag) s_pfEditTextCallbackWithCancelFlag("", s_ctx, false);
			LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogResult4");
        }
    }

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogCancelResult(JNIEnv * env, jobject obj, jbyteArray text) {
		jsize  size = env->GetArrayLength(text);

		if (size > 0) {
			jbyte * data = (jbyte*)env->GetByteArrayElements(text, 0);
			char* pBuf = (char*)malloc(size+1);
			if (pBuf != NULL) {
				memcpy(pBuf, data, size);
				pBuf[size] = '\0';
				// pass data to edittext's delegate
				LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogCancelResult1");
				if (s_pfEditTextCallbackWithCancelFlag) s_pfEditTextCallbackWithCancelFlag(pBuf, s_ctx, true);
				LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogCancelResult2");
				free(pBuf);
			}
			env->ReleaseByteArrayElements(text, data, 0);
		} else {
			LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogCancelResult3");
			if (s_pfEditTextCallbackWithCancelFlag) s_pfEditTextCallbackWithCancelFlag("", s_ctx, true);
			LOGD("Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSetEditTextDialogCancelResult4");
		}
	}

    JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeDialogOkCallback(JNIEnv * env, jobject obj, jint tag) {

    	if (s_pfDialogOkCallback) {
    		s_pfDialogOkCallback(tag, s_ctx);
    	}

    }

	/*
		xinzheng 2013-06-20
		Ӧ�ó������������¼�⡢�������̣�
		apk��ipa��������൱��һ��loader����Ӧ��loader����Game.so��AppDelegate����������ʱ��׼���ö��ߵ��νӣ�
		����ֻ��State(LoadingFrame)���״̬��Ҫ��loaderͨ�ţ�
		����˳��ִ�У�Ϊ�˼����鷳�������У�
		0��apk��ڣ���ʾ��˾&��Ϸlogo��������������̲��˹�����������硢�洢������
		0a������ƽ̨�İ汾���¼���ʵ�֣���Ϊ��Щƽ̨ǿ���ڳ�ʼ��ʹ����汾���¹��ܣ�
		1����ʼ��ƽ̨SDK����ʾƽ̨logo�����ƽ̨������ʾlogo�������ӳ�0������ʾ���棻���������ƽ̨SDK��ֱ��������2����
		2���汾����⣬a�����а汾����ʵ�֣���Ҫ�����Ƿ�ʹ��ƽ̨�ṩ�ĸ��¼�⣻b������ƽ̨SDK�ṩ�ĸ���ʵ�֣����¼����Ϊ��ѡ����ʱ�������3����
		3����ʼ��OpenGL ES Context����������Ƶ���������ϵͳ��صı��������������̻��������Ҫ��loader�㱣�����ϲ�logo������������logo���������棻
		4����ʼ��Game.so������AppDelegate��ָ�����ɵĵ�¼&֧��ƽ̨��׼������loader���νӣ�����State(LoadingFrame)��֪ͨ���Է����ڸ��¼�⣻�Ƴ�loader�����Ľ��棬������ʼ��ʾGame.so��Ⱦ�Ľ��棻
		5���ڸ��¼�ⷵ��������£��������ƽ̨�˺ŵ�¼�����ߣ��ڸ��½��и��£��ɹ���Ϻ󣬷������ƽ̨�˺ŵ�¼��
		6��ͣ����State(LoadingFrame)��ֱ��ƽ̨�˺ŵ�¼�ɹ�֪ͨGame.so�������loader���νӣ�����������ϷState(MainFrame����
		7��Ŀǰ����State(MainFrame�����������л��˺ŷ���State(LoadingFrame)��ֻ��������
	*/

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeNotifyPlatformInitResult(JNIEnv*  env, jobject thiz, 
		jint result) {

			bool bret = result == 0 ? true : false;
			//
			//LOGD("libPlatformManager::getPlatform()->_boardcastInitDone(true)");
			//libPlatformManager::getPlatform()->_boardcastInitDone(bret, "please upgrade your app");
			//
	}

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeNotifyPlatformGameUpdateResult(JNIEnv*  env, jobject thiz, 
		jint result, jint max_version, jint local_version, jstring down_url) {

			if (result < 2)//2ǿ�Ƹ���1�������0�޸��»����
			{
				LOGD("libPlatformManager::getPlatform()->_boardcastNeedUpdateApp(true)");
				libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true, JniHelper::jstring2string(down_url));
			}


	}
	JNIEXPORT jstring JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeSendMessageP2G(JNIEnv*  env, jobject thiz, 
		jstring tag, jstring msg) {

			LOGD("libPlatformManager::getPlatform()->SendMessageP2G");
			return JniHelper::string2jstring(libPlatformManager::getPlatform()->sendMessageP2G(JniHelper::jstring2string(tag), JniHelper::jstring2string(msg)));
			
	}

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeNotifyPlatformLoginResult(JNIEnv*  env, jobject thiz, 
		jint result, jstring uin, jstring sessionid, jstring nickname) {
		
		if (result == 0)
		{
			LOGD("libPlatformManager::getPlatform()->_boardcastLoginResult(true)");
			libPlatformManager::getPlatform()->_boardcastLoginResult(true, JniHelper::jstring2string(sessionid));
		}
		

	}

	JNIEXPORT void JNICALL Java_org_cocos2dx_lib_Cocos2dxHelper_nativeNotifyPlatformPayResult(JNIEnv*  env, jobject thiz, 
		jint result, jstring serial, jstring productId, jstring productName, 
		jfloat price, jfloat orignalPrice, jint count, jstring description) {

		BUYINFO buyinfo;
		buyinfo.cooOrderSerial = JniHelper::jstring2string(serial);
		buyinfo.productId = JniHelper::jstring2string(productId);
		buyinfo.productName = JniHelper::jstring2string(productName);
		buyinfo.description = JniHelper::jstring2string(description);
		buyinfo.productPrice = price;
		buyinfo.productOrignalPrice = orignalPrice;
		buyinfo.productCount = count;
		//
		if (result == 0)
		{
			LOGD("libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true)");
			libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, buyinfo, "");
		}
		else
		{
			LOGD("libPlatformManager::getPlatform()->_boardcastBuyinfoSent(false,%d)", result);
			libPlatformManager::getPlatform()->_boardcastBuyinfoSent(false, buyinfo, "");
		}
	}

}

const char * getApkPath() {
    return g_apkPath.c_str();
}

const char * getAppExternalStoragePath() {
	return g_appExternalStoragePath.c_str();
}

void showDialogJNI(const char * pszMsg, const char * pszTitle, DialogOkCallback pDialogCallback, void* ctx, int tag) {
    if (!pszMsg) {
        return;
    }

    s_pfDialogOkCallback = pDialogCallback;
    s_ctx = ctx;

    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showDialog", "(Ljava/lang/String;Ljava/lang/String;ILjava/lang/String;)V")) {
        jstring stringArg1;

        if (!pszTitle) {
            stringArg1 = t.env->NewStringUTF("");
        } else {
            stringArg1 = t.env->NewStringUTF(pszTitle);
        }

        jstring stringArg2 = t.env->NewStringUTF(pszMsg);
        jint msgId = tag;
        jstring strPositiveCallback = t.env->NewStringUTF("");//not use now

        t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1, stringArg2, msgId, strPositiveCallback);

        t.env->DeleteLocalRef(stringArg1);
        t.env->DeleteLocalRef(stringArg2);
        t.env->DeleteLocalRef(t.classID);
    }
}

void showEditTextDialogJNI(const char* pszTitle, const char* pszMessage, int nInputMode, int nInputFlag, int nReturnType, int nMaxLength, EditTextCallbackWithCancelFlag pfEditTextCallback, void* ctx) {
    if (pszMessage == NULL) {
        return;
    }

    s_pfEditTextCallbackWithCancelFlag = pfEditTextCallback;
    s_ctx = ctx;

    JniMethodInfo t;
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showEditTextDialog", "(Ljava/lang/String;Ljava/lang/String;IIII)V")) {
        jstring stringArg1;

        if (!pszTitle) {
            stringArg1 = t.env->NewStringUTF("");
        } else {
            stringArg1 = t.env->NewStringUTF(pszTitle);
        }

        jstring stringArg2 = t.env->NewStringUTF(pszMessage);

        t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1, stringArg2, nInputMode, nInputFlag, nReturnType, nMaxLength);

        t.env->DeleteLocalRef(stringArg1);
        t.env->DeleteLocalRef(stringArg2);
        t.env->DeleteLocalRef(t.classID);
    }
}

void terminateProcessJNI() {
    JniMethodInfo t;

    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "terminateProcess", "()V")) {
        t.env->CallStaticVoidMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

std::string getPackageNameJNI() {
    JniMethodInfo t;
    std::string ret("");

    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getCocos2dxPackageName", "()Ljava/lang/String;")) {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
    }
    return ret;
}

std::string getFileDirectoryJNI() {//set to CCFileUtilsAndroid::getWritablePath
    JniMethodInfo t;
    std::string ret("");

    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getCocos2dxWritablePath", "()Ljava/lang/String;")) {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
    }
    
    return ret;
}

std::string getCurrentLanguageJNI() {
    JniMethodInfo t;
    std::string ret("");
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getCurrentLanguage", "()Ljava/lang/String;")) {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        ret = JniHelper::jstring2string(str);
        t.env->DeleteLocalRef(str);
    }

    return ret;
}

void enableAccelerometerJNI() {
    JniMethodInfo t;

    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "enableAccelerometer", "()V")) {
        t.env->CallStaticVoidMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

void setAccelerometerIntervalJNI(float interval) {
    JniMethodInfo t;

    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setAccelerometerInterval", "(F)V")) {
        t.env->CallStaticVoidMethod(t.classID, t.methodID, interval);
        t.env->DeleteLocalRef(t.classID);
    }
}

void disableAccelerometerJNI() {
    JniMethodInfo t;

    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "disableAccelerometer", "()V")) {
        t.env->CallStaticVoidMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

// functions for CCUserDefault
bool getBoolForKeyJNI(const char* pKey, bool defaultValue)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getBoolForKey", "(Ljava/lang/String;Z)Z")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        jboolean ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID, stringArg, defaultValue);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
        
        return ret;
    }
    
    return defaultValue;
}

int getIntegerForKeyJNI(const char* pKey, int defaultValue)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getIntegerForKey", "(Ljava/lang/String;I)I")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        jint ret = t.env->CallStaticIntMethod(t.classID, t.methodID, stringArg, defaultValue);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
        
        return ret;
    }
    
    return defaultValue;
}

float getFloatForKeyJNI(const char* pKey, float defaultValue)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getFloatForKey", "(Ljava/lang/String;F)F")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        jfloat ret = t.env->CallStaticFloatMethod(t.classID, t.methodID, stringArg, defaultValue);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
        
        return ret;
    }
    
    return defaultValue;
}

double getDoubleForKeyJNI(const char* pKey, double defaultValue)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDoubleForKey", "(Ljava/lang/String;D)D")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        jdouble ret = t.env->CallStaticDoubleMethod(t.classID, t.methodID, stringArg);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
        
        return ret;
    }
    
    return defaultValue;
}

std::string getStringForKeyJNI(const char* pKey, const char* defaultValue)
{
    JniMethodInfo t;
    std::string ret("");

    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getStringForKey", "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")) {
        jstring stringArg1 = t.env->NewStringUTF(pKey);
        jstring stringArg2 = t.env->NewStringUTF(defaultValue);
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg1, stringArg2);
        ret = JniHelper::jstring2string(str);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg1);
        t.env->DeleteLocalRef(stringArg2);
        t.env->DeleteLocalRef(str);
        
        return ret;
    }
    
    return defaultValue;
}

void setBoolForKeyJNI(const char* pKey, bool value)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setBoolForKey", "(Ljava/lang/String;Z)V")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg, value);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
    }
}

void setIntegerForKeyJNI(const char* pKey, int value)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setIntegerForKey", "(Ljava/lang/String;I)V")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg, value);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
    }
}

void setFloatForKeyJNI(const char* pKey, float value)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setFloatForKey", "(Ljava/lang/String;F)V")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg, value);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
    }
}

void setDoubleForKeyJNI(const char* pKey, double value)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setDoubleForKey", "(Ljava/lang/String;D)V")) {
        jstring stringArg = t.env->NewStringUTF(pKey);
        t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg, value);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg);
    }
}

void setStringForKeyJNI(const char* pKey, const char* value)
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setStringForKey", "(Ljava/lang/String;Ljava/lang/String;)V")) {
        jstring stringArg1 = t.env->NewStringUTF(pKey);
        jstring stringArg2 = t.env->NewStringUTF(value);
        t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1, stringArg2);
        
        t.env->DeleteLocalRef(t.classID);
        t.env->DeleteLocalRef(stringArg1);
        t.env->DeleteLocalRef(stringArg2);
    }
}

//
void callPlatformLoginJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformLogin", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformTokenJNI()
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformToken", "()V")) {
        t.env->CallStaticVoidMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
    }
}

std::string callPlatformSendMessageG2PJNI(const std::string& tag, const std::string& msg)
{
	LOGD("PlatformSendMessageG2PJNI, tag=%s, msg=%s",tag.c_str(), msg.c_str());
	JniMethodInfo t;
	std::string ret;
	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformSendMessageG2P", "(Ljava/lang/String;Ljava/lang/String;)Ljava/lang/String;")) {
		jstring stringArg1 = t.env->NewStringUTF(tag.c_str());
		jstring stringArg2 = t.env->NewStringUTF(msg.c_str());

		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID, stringArg1, stringArg2);
		ret = JniHelper::jstring2string(str);
		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(str);
	}
	LOGD("PlatformSendMessageG2PJNI, retString=%s",ret.c_str());
	return ret;
}

const Json::Value& callPlatformSendMessageG2PJNI(const std::string& tag, const Json::Value& msg)
{
	LOGD("PlatformSendMessageG2PJNI");
	static Json::Value data;
	data=Json::Value();
	Json::FastWriter writer;
	std::string returnParam = callPlatformSendMessageG2PJNI(tag,writer.write(msg));
	
	Json::Reader jreader;
	jreader.parse(returnParam,data,false);

	LOGD("PlatformSendMessageG2PJNI, retJson=%s", data.toStyledString().c_str());

	return data;
}

void callPlatformLogoutJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformLogout", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformPlayMovieJNI(const char* fileName, int isLoop, int autoScale)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformPlayMovie", "(Ljava/lang/String;II)V")) {
		jstring strname = t.env->NewStringUTF(fileName);
		t.env->CallStaticVoidMethod(t.classID, t.methodID, strname, isLoop, autoScale);
		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(strname);
	}
}

void callPlatformCloseMovieJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformCloseMovie", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformPauseMovieJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformPauseMovie", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformResumeMovieJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformResumeMovie", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformAccountManageJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformAccountManage", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformPayRechargeJNI(int productType ,const char* name ,const char* serial, const char* productId, const char* productName, float price, 
	float orignalPrice, int count, const char* description,int serverTime,const char* extras)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformPayRecharge", 
		"(ILjava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;FFILjava/lang/String;ILjava/lang/String;)V"))
	{
		
		jstring strname = t.env->NewStringUTF(name);
		jstring strSerial = t.env->NewStringUTF(serial);
		jstring strProductId = t.env->NewStringUTF(productId);
		jstring strProductName = t.env->NewStringUTF(productName);
		jstring strDescription = t.env->NewStringUTF(description);
        jstring strExtras = t.env->NewStringUTF(extras);

		t.env->CallStaticVoidMethod(t.classID, t.methodID, productType, strname, strSerial, strProductId,
			strProductName, price, orignalPrice, count, strDescription,serverTime,strExtras);

		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(strDescription);
		t.env->DeleteLocalRef(strProductName);
		t.env->DeleteLocalRef(strProductId);
		t.env->DeleteLocalRef(strSerial);
		t.env->DeleteLocalRef(strname);
        t.env->DeleteLocalRef(strExtras);
	}
}

bool getPlatformLoginStatusJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getPlatformLoginStatus", "()Z")) {
		jboolean ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
		
		return ret;
	}

	return false;
}

std::string getPlatformLoginUinJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getPlatformLoginUin", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "";
}

std::string getPlatformTokenJNI()
{
    JniMethodInfo t;
    
    if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getPlatformToken", "()Ljava/lang/String;")) {
        jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
        t.env->DeleteLocalRef(t.classID);
        
        return JniHelper::jstring2string(str);
    }
    
    return "";
}

void showPlatformProfileJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showPlatformProfile", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

std::string getPlatformLoginSessionIdJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getPlatformLoginSessionId", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "PLoginSession";
}

std::string getPlatformUserNickNameJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getPlatformUserNickName", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "PUNickName";
}

std::string generateNewOrderSerialJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "generateNewOrderSerial", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "";
}

void callPlatformFeedbackJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformFeedback", "()V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformSupportThirdShareJNI(const char* content, const char* imgPath)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformSupportThirdShare", "(Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(content);
		jstring stringArg2 = t.env->NewStringUTF(imgPath);
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1, stringArg2);
		
		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(stringArg2);
	}
}

bool getIsDebugJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getIsDebug", "()Z")) {
		jboolean ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return ret;
	}

	return false;
}

void openUrlOutsideJNI(std::string url)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "openUrlOutside", "(Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(url.c_str());
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1);

		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(stringArg1);
	}
}


void emailToJNI(std::string emailTo, std::string title, std::string body)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "emailTo", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String)V")) {
		jstring stringArg1 = t.env->NewStringUTF(emailTo.c_str());
		jstring stringArg2 = t.env->NewStringUTF(title.c_str());
		jstring stringArg3 = t.env->NewStringUTF(body.c_str());
		
		
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1, stringArg2, stringArg3);

		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(stringArg2);
		t.env->DeleteLocalRef(stringArg3);
		
	}
	
}

int getNetworkStatusJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getNetworkStatus", "()I")) {
		jint ret = t.env->CallStaticIntMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return ret;
	}

	return NotReachable;
}

void callPlatformGameBBSJNI( const char* url )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callPlatformGameBBS", "(Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(url);
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1);

		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(stringArg1);
	}
}

void showWaitingViewJNI( bool show, int progress, const char* text )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showWaitingView", "(ZILjava/lang/String;)V")) {
		jstring stringArg = t.env->NewStringUTF(text);
		t.env->CallStaticVoidMethod(t.classID, t.methodID, show, progress, stringArg);

		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(stringArg);
	}
}

std::string getPlatformInfoJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getPlatformInfo", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "AndroidPlatformInfo";
}

int getPlatformIdJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getPlatformId", "()I")) {
		jint ret = t.env->CallStaticIntMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return ret;
	}

	return -1;
}

std::string getDeviceInfoJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDeviceInfo", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "AndroidDeviceInfo";
}

std::string getDeviceIDJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getDeviceID", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "AndroidDeviceID";
}

std::string getClientChannelJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getClientChannel", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "Android";
}

std::string getClientCpsJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getClientCps", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "#0";
}

std::string getBuildTypeJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getBuildType", "()Ljava/lang/String;")) {
		jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return JniHelper::jstring2string(str);
	}

	return "release";
}

 void showAnnouncement(const char* pAnnounceUrl)
 {
	 JniMethodInfo t;

	 if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showGameAnnounce", "(Ljava/lang/String;)V")) {
		 jstring stringArg1 = t.env->NewStringUTF(pAnnounceUrl);
		
		 t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1);

		 t.env->DeleteLocalRef(t.classID);
		 t.env->DeleteLocalRef(stringArg1);
	 }

 }

 void pushSysNotification(const char* pTitle,const char* pMessage ,int pInstantMinite )
 {
 
	 JniMethodInfo t;

	 if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "showNotification", "(Ljava/lang/String;Ljava/lang/String;I)V")) {
		 
		 jstring stringArg1 = t.env->NewStringUTF(pTitle);
		 jstring stringArg2 = t.env->NewStringUTF(pMessage);
		 		 
		 t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1,stringArg2,pInstantMinite);

		 t.env->DeleteLocalRef(t.classID);
		 t.env->DeleteLocalRef(stringArg1);
		 t.env->DeleteLocalRef(stringArg2);
	 }


 }

 void clearSysNotification()
 {
	 JniMethodInfo t;

	 if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "clearNotification", "()V")) {
		 
		 t.env->CallStaticVoidMethod(t.classID, t.methodID);
		 
		 t.env->DeleteLocalRef(t.classID);
	 }
 }

 void notifyEnterGameJNI()
 {
	 JniMethodInfo t;

	 if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "notifyEnterGame", "()V")) {
		 
		 t.env->CallStaticVoidMethod(t.classID, t.methodID);

		 t.env->DeleteLocalRef(t.classID);
	 }

 }
 std::string getClipboardTextJNI()
 {
	 JniMethodInfo t;

	 if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "getClipboardText", "()Ljava/lang/String;")) {
		 jstring str = (jstring)t.env->CallStaticObjectMethod(t.classID, t.methodID);
		 t.env->DeleteLocalRef(t.classID);

		 return JniHelper::jstring2string(str);
	 }

	 return "";
 }
 void setClipboardTextJNI(const char* text)
 {
	 JniMethodInfo t;

	 if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setClipboardText", "(Ljava/lang/String;)V")) {
		 jstring stringArg1 = t.env->NewStringUTF(text);

		 t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1);

		 t.env->DeleteLocalRef(t.classID);
		 t.env->DeleteLocalRef(stringArg1);
	 }
 }
 void setEditBoxTextJNI(const char* text)
 {
	 JniMethodInfo t;

	 if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "setEditBoxText", "(Ljava/lang/String;)V")) {
		 jstring stringArg1 = t.env->NewStringUTF(text);

		 t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1);

		 t.env->DeleteLocalRef(t.classID);
		 t.env->DeleteLocalRef(stringArg1);
	 }
 }


void callDownloadJNI(std::string assetUrl, std::string filename, std::string writePath, std::string md5)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_NAME, "callDownload", "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(assetUrl.c_str());
		jstring stringArg2 = t.env->NewStringUTF(filename.c_str());
		jstring stringArg3 = t.env->NewStringUTF(writePath.c_str());
		jstring stringArg4 = t.env->NewStringUTF(md5.c_str());
		
		
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1, stringArg2, stringArg3, stringArg4);

		t.env->DeleteLocalRef(t.classID);
		t.env->DeleteLocalRef(stringArg1);
		t.env->DeleteLocalRef(stringArg2);
		t.env->DeleteLocalRef(stringArg3);
		t.env->DeleteLocalRef(stringArg4);
		
	}
	
}

 
//
