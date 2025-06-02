

#include <string>
#include <map>

#include <jni.h>
#include "jni/JniHelper.h"
#include "libPlatform.h"
#include "platform/CCCommon.h"

#include "libPlatformHelpJni.h"

#define  CLASS_B_NAME "com/nuclear/gjwow/GameActivity"

using namespace cocos2d;

extern "C" {

	JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeRequestGameSvrBindTryToOkUser(JNIEnv* env, jobject thiz, jstring tryUin, jstring okUin) {
		
		std::string tryUser = JniHelper::jstring2string(tryUin);
		std::string okUser = JniHelper::jstring2string(okUin);
		
		libPlatformManager::getPlatform()->_boardcastRequestBindTryUserToOkUser(tryUser.c_str(), okUser.c_str());

	}


  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeNotifyTryUserRegistSuccess() {
    
    libPlatformManager::getPlatform()->_boardcastOnTryUserRegistSuccess();
    
  }

  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnPlayMovieEnd() {

	  libPlatformManager::getPlatform()->_boardcastOnPlayMovieEnd();

  }
  
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeFBShareBack(JNIEnv* env,jobject thiz ,bool _result) {

	  //libPlatformManager::getPlatform()->_boardcastOnFBShareBackMessage(_result);
	  libPlatformManager::getPlatform()->onFBShareBack(_result);
  }
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnShareEngineMessage(JNIEnv* env,jobject thiz ,bool _result,jstring _resultStr) {
	//int length = env->GetStringLength(_resultStr);
    std::string resultStr = JniHelper::jstring2string(_resultStr);
	CCLog("GameActivity_nativeOnShareEngineMessage=====��%d======��%s======",int(_result),resultStr.c_str());
    libPlatformManager::getPlatform()->_boardcastOnShareEngineMessage(_result/*,resultStr.c_str()*/);
    
  }
  
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnMotionShake() {
    
    libPlatformManager::getPlatform()->_boardcastOnMotionShake();
    
  }
  //����kakao���ѻص�
  //����������
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrGetInviteCount(JNIEnv * env, jobject obj,int nCount) {
	libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_INVITE_COUNT,nCount);
  }
  //�����б�
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrGetInviteLists(JNIEnv * env, jobject obj,jstring strInviteInfo) {
	   std::string inviteInfo = JniHelper::jstring2string(strInviteInfo);
	   libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_INVITE_LIST,0,false,inviteInfo);
  }
  //�����б�
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrGetFriendLists(JNIEnv * env, jobject obj,jstring strFriendInfo) {
	  std::string friendInfo = JniHelper::jstring2string(strFriendInfo);
	  libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_FRIEND_LIST,0,false,friendInfo);
  }
  //����������Ϣ
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrSendInvite(JNIEnv * env, jobject obj,jstring resultStr) {
	  std::string result = JniHelper::jstring2string(resultStr);
	  libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::SEND_INVITE,0,false,result);
  }
  //��ȡ�����б�
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrGetGiftLists(JNIEnv * env, jobject obj,jstring strGiftList) {
	  std::string giftList = JniHelper::jstring2string(strGiftList);
	  libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_GIFT_LIST,0,false,giftList);
  }
  //��������
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrReceiveGift(JNIEnv * env, jobject obj,bool result) {
	   libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::RECEIVE_GIFT,0,result);
  }
  //��ǰ����������ĸ���
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrGetGiftCount(JNIEnv * env, jobject obj,int nCount) {
	  libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_GIFT_COUNT,nCount);
  }
  //��������
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrSendGift(JNIEnv * env, jobject obj,jstring resultStr) {
	  std::string result = JniHelper::jstring2string(resultStr);
	  libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::SEND_GIFT,0,false,result);
  }
  //��������
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrGiftBlock(JNIEnv * env, jobject obj,jstring resultStr) {
	   std::string result = JniHelper::jstring2string(resultStr);
	   libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GIFT_BLOCK,0,false,result);
  }
  //CDKey�ص�
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrCouponsBack(JNIEnv * env, jobject obj,jstring resultStr) {
	  CCLog("Java_com_nuclear_gjwow_GameActivity_nativeOnKrCouponsBack == begin");
	  std::string result = JniHelper::jstring2string(resultStr);
	  libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::CDKEY,0,false,result);
	  CCLog("Java_com_nuclear_gjwow_GameActivity_nativeOnKrCouponsBack == end %s",result.c_str());
  }
  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnKrGetKakaoIdBack(JNIEnv * env, jobject obj,jstring resultStr) {
	  std::string result = JniHelper::jstring2string(resultStr);
	  libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::Get_KakaoId,0,false,result);
  }

  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnDownloadProgress(JNIEnv * env, jobject obj, jstring urlStr, jstring filenameStr, jstring basePathStr, long percent) {
	  std::string url = JniHelper::jstring2string(urlStr);
	  std::string filename = JniHelper::jstring2string(filenameStr);
	  std::string basePath = JniHelper::jstring2string(basePathStr);
	  CCLog("--->1Java_com_nuclear_gjwow_GameActivity_nativeOnDownloadProgress == %s %s %s %d", url.c_str(), filename.c_str(), basePath.c_str(), percent);
	  libPlatformManager::getPlatform()->_boardcastOnDownloadProgress(url, filename, basePath, percent);
  }

  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnDownloadComplete(JNIEnv *env, jobject obj, jstring urlStr, jstring filenameStr, jstring basePathStr, jstring md5Str) {
	  std::string url = JniHelper::jstring2string(urlStr);
	  std::string filename = JniHelper::jstring2string(filenameStr);
	  std::string basePath = JniHelper::jstring2string(basePathStr);
	  std::string md5 = JniHelper::jstring2string(md5Str);
	  CCLog("--->1Java_com_nuclear_gjwow_GameActivity_nativeOnDownloadComplete == %s %s %s %s", url.c_str(), filename.c_str(), basePath.c_str(), md5.c_str());
	  libPlatformManager::getPlatform()->_boardcastOnDownloadComplete(url, filename, basePath, md5);
  }

  JNIEXPORT void JNICALL Java_com_nuclear_gjwow_GameActivity_nativeOnDownloadFailed(JNIEnv *env, jobject obj, jstring urlStr, jstring filenameStr, jstring basePathStr, int errorCode) {
	  std::string url = JniHelper::jstring2string(urlStr);
	  std::string filename = JniHelper::jstring2string(filenameStr);
	  std::string basePath = JniHelper::jstring2string(basePathStr);
	  CCLog("--->1Java_com_nuclear_gjwow_GameActivity_nativeOnDownloadFailed == %s %s %s %d", url.c_str(), filename.c_str(), basePath.c_str(), errorCode);
	  libPlatformManager::getPlatform()->_boardcastOnDownloadFailed(url, filename, basePath, errorCode);
  }

  	
  
}

bool isTryUserJni()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "isPlatformTryUser",  "()Z")) {

		jboolean ret = t.env->CallStaticBooleanMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);

		return ret;
	}

	return false;
}

void notifyGameSvrBindTryUserToOkUserResultJni( int result )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "receiveGameSvrBindTryToOkUserResult","(I)V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID, result);

		t.env->DeleteLocalRef(t.classID);
	}
}

void callPlatformBindUserJni()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "callPlatformBindUser",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void callPlatToolsJni( bool visible )
{
	JniMethodInfo t;
	if(JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "callToolBar",  "(Z)V")){
		t.env->CallStaticVoidMethod(t.classID, t.methodID, visible);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void OnKrGetInviteCountJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrGetInviteCount",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void OnKrgetInviteListsJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrGetInviteLists",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void OnKrgetFriendListsJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrGetFriendLists",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void OnKrsendInviteJNI( const std::string& strUserId, const std::string& strServerId )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrSendInvite",  "(Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(strUserId.c_str());
		jstring stringArg2 = t.env->NewStringUTF(strServerId.c_str());
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1,stringArg2);
		t.env->DeleteLocalRef(t.classID);

	}
}

extern void OnKrgetGiftListsJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrGetGiftLists",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void OnKrReceiveGiftJNI( const std::string& strGiftId, const std::string& strServerId )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrReceiveGift",  "(Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(strGiftId.c_str());
		jstring stringArg2 = t.env->NewStringUTF(strServerId.c_str());
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1,stringArg2);
		t.env->DeleteLocalRef(t.classID);

	}
}

extern void OnKrGetGiftCountJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrGetGiftCount",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void OnKrSendGiftJNI( const std::string& strUserName, const std::string& strServerId )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrSendGift",  "(Ljava/lang/String;Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(strUserName.c_str());
		jstring stringArg2 = t.env->NewStringUTF(strServerId.c_str());
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1,stringArg2);
		t.env->DeleteLocalRef(t.classID);

	}
}

extern void OnKrGiftBlockJNI( bool bVisible )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrGiftBlock","(Z)V")) 
	{
		t.env->CallStaticVoidMethod(t.classID, t.methodID, bVisible);
		t.env->DeleteLocalRef(t.classID);

	}
}

extern void OnKrGetKakaoIdJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrGetKakaoId",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void OnKrLoginGamesJNI()
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "OnKrLoginGames",  "()V")) {

		t.env->CallStaticVoidMethod(t.classID, t.methodID);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void setLanguageNameJNI( const std::string& lang )
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "setLanguageName",  "(Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(lang.c_str());
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1);
		t.env->DeleteLocalRef(t.classID);

	}
}

extern void setPlatformNameJNI(int platform)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "setPlatformName", "(I)V")) {
		t.env->CallStaticVoidMethod(t.classID, t.methodID, platform);
		t.env->DeleteLocalRef(t.classID);
	}
}

extern void setPayUrlJNI(const std::string& url)
{
	JniMethodInfo t;

	if (JniHelper::getStaticMethodInfo(t, CLASS_B_NAME, "setPayUrl", "(Ljava/lang/String;)V")) {
		jstring stringArg1 = t.env->NewStringUTF(url.c_str());
		t.env->CallStaticVoidMethod(t.classID, t.methodID, stringArg1);
		t.env->DeleteLocalRef(t.classID);
	}
}