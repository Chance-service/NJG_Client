
#include <string.h>
#include <jni.h>
#include "libVoiceChat.h"
#include "jni/JniHelper.h"
#include "cocos2d.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "json/json.h"
using namespace cocos2d;

#define  LOG_TAG    "libVoiceChat.cpp"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

//#define  CLASS_NAME "com/nuclear/gjwow/VoiceChat"


void libVoiceChat::login(char* seq)
{
	if (seq){
		Json::Value date;
		date["seq"] = seq;
		callPlatformSendMessageG2PJNI("login", date);
	}
	else
	{
		callPlatformSendMessageG2PJNI("login", Json::Value(Json::objectValue));
	}
		
}

void libVoiceChat::logout(char* seq)
{
	if (seq){
		Json::Value date;
		date["seq"] = seq;
		callPlatformSendMessageG2PJNI("logout", date);
	}
	else
	{
		callPlatformSendMessageG2PJNI("logout", Json::Value(Json::objectValue));
	}
}

void libVoiceChat::playAudio(char* filePath)
{
	if (filePath){
		Json::Value date;
		date["filePath"] = filePath;
		callPlatformSendMessageG2PJNI("playAudio", date);
	}
	else
	{
		callPlatformSendMessageG2PJNI("playAudio", Json::Value(Json::objectValue));
	}
}

void libVoiceChat::stopAudio()
{
	callPlatformSendMessageG2PJNI("stopAudio",Json::Value(Json::objectValue));

}

bool libVoiceChat::isPlayingAudio()
{
	return callPlatformSendMessageG2PJNI("isPlayingAudio",Json::Value(Json::objectValue)).asBool();
}

void libVoiceChat::setSupportVoiceAndTxt(bool isSupport)
{
	Json::Value date;
	date["isSupport"] = isSupport;
	callPlatformSendMessageG2PJNI("setSupportVoiceAndTxt",date);
}

void libVoiceChat::startVoiceRecognition( char* expand )
{
	if (expand){
		Json::Value date;
		date["expand"] = expand;
		callPlatformSendMessageG2PJNI("startVoiceRecognition", date);
	}
	else
	{
		callPlatformSendMessageG2PJNI("startVoiceRecognition", Json::Value(Json::objectValue));
	}
}

void libVoiceChat::uploadVoiceMessage(char* filePath ,  long voiceDuration , char* expand)
{
	Json::Value msg;
	if (filePath){
		msg["filePath"] = filePath;
	}
	if (expand)
	{
		msg["expand"] = expand;
	}
	msg["voiceDuration"] = (int)voiceDuration;
	
	callPlatformSendMessageG2PJNI("uploadVoiceMessage",msg);

}

void libVoiceChat::speakFinish()
{
	callPlatformSendMessageG2PJNI("speakFinish",Json::Value(Json::objectValue));
}

void libVoiceChat::stopVoiceRecognition()
{
	callPlatformSendMessageG2PJNI("stopVoiceRecognition",Json::Value(Json::objectValue));
}

void libVoiceChat::sendTextMessage( char* text , char* expand )
{
	Json::Value msg;
	if (text)
	{
		msg["text"] = text;
	}
	if (expand)
	{
		msg["expand"] = expand;
	}
	
	if (msg.size() > 0)
	{
		callPlatformSendMessageG2PJNI("sendTextMessage", msg);
	}
	else
	{
		callPlatformSendMessageG2PJNI("sendTextMessage", Json::Value(Json::objectValue));
	}
}

void libVoiceChat::notifyLoginResult(int result,std::string msg ,long yunvaId)
{
	CCLOG("VoiceChatManager-login notifyLoginResult:%s" , msg.c_str());
	voiceChatLoginResultInfo.result = result;
	voiceChatLoginResultInfo.msg = msg;
	voiceChatLoginResultInfo.yunvaId = yunvaId;

	voiceChatLoginResultInfo.isLoginResult = true;


}

void libVoiceChat::notifyLougoutResult(int result, std::string msg)
{
	voiceChatLogoutResultInfo.result = result;
	voiceChatLogoutResultInfo.msg = msg;

	voiceChatLogoutResultInfo.isLogoutResult = true;
	

}

void libVoiceChat::notifyVoiceMessage(std::string troopsId , std::string voicePath, long voiceTime ,std::string text, std::string voiceInfo)
{
	
	voiceChatVoiceMsgInfo.troopsId = troopsId;
	voiceChatVoiceMsgInfo.voicePath = voicePath;
	voiceChatVoiceMsgInfo.voiceTime = voiceTime;
	voiceChatVoiceMsgInfo.text = text;
	voiceChatVoiceMsgInfo.voiceInfo = voiceInfo;

	voiceChatVoiceMsgInfo.isVoiceMsg = true;
	
}

void libVoiceChat::notifyUploadVoiceMessage( int result,std::string voiceUrl, long voiceTime, std::string voiceInfo )
{
	voiceChatUploadVoiceMessage.result = result;
	voiceChatUploadVoiceMessage.voiceUrl = voiceUrl;
	voiceChatUploadVoiceMessage.voiceTime = voiceTime;
	voiceChatUploadVoiceMessage.voiceInfo = voiceInfo;

	voiceChatUploadVoiceMessage.isUploadVoice = true;
}

void libVoiceChat::notifySendTextMessage( int result, std::string msg )
{
	voiceChatSendTextMessage.result = result;
	voiceChatSendTextMessage.msg = msg;

	voiceChatSendTextMessage.isSendTextMessage = true;
}

void libVoiceChat::notifyReceiveTextMessage( std::string troopsId,std::string text, std::string expand )
{
	voiceChatReceiveTextMessage.troopsId = troopsId;
	voiceChatReceiveTextMessage.text =text;
	voiceChatReceiveTextMessage.expand = expand;

	voiceChatReceiveTextMessage.isReceive = true;
}

void libVoiceChat::notifyUploadBdVoiceMessage( int result,std::string msg,std::string voiceUrl,int voiceDuration,std::string filePath,std::string expand,std::string text )
{
	voiceChatVoiceAndTextInfo.result = result;
	voiceChatVoiceAndTextInfo.msg = msg;
	voiceChatVoiceAndTextInfo.voiceUrl = voiceUrl;
	voiceChatVoiceAndTextInfo.voiceDuration = voiceDuration;
	voiceChatVoiceAndTextInfo.filePath = filePath;
	voiceChatVoiceAndTextInfo.expand =expand;
	voiceChatVoiceAndTextInfo.text = text;

	voiceChatVoiceAndTextInfo.isNotify = true;
}

void libVoiceChat::notifyBdMineTxtMsg( std::string txtMsg )
{
	voiceChatBdMineTxtMsg.txtMsg = txtMsg;

	voiceChatBdMineTxtMsg.isNotify = true;
}

extern "C" {
	//登陆成功通知接口
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifyLoginResult( JNIEnv*  env, jobject thiz, jint result, jstring msg, jlong yunvaId )
	{
		libVoiceChat::getInstance()->notifyLoginResult(result, JniHelper::jstring2string(msg) ,yunvaId);
		LOGD("VoiceChatManager-login Java_com_nuclear_gjwow_VoiceChat_nativeNotifyLoginResult:" + result);
	}
	//注销成功接口
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifyLogoutResult( JNIEnv*  env, jobject thiz,jint result, jstring msg )
	{
		libVoiceChat::getInstance()->notifyLougoutResult(result, JniHelper::jstring2string(msg));
	}
	
	//语音留言消息通知接口
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifyVoiceMessage( JNIEnv*  env, jobject thiz,jstring troopsId , jstring voiceUrl , jlong voiceTime ,jstring text, jstring voiceInfo)
	{
		LOGD("VoiceChatManager-login Java_com_nuclear_gjwow_VoiceChat_nativeNotifyVoiceMessage:" );
		libVoiceChat::getInstance()->notifyVoiceMessage(JniHelper::jstring2string(troopsId), JniHelper::jstring2string(voiceUrl), voiceTime,JniHelper::jstring2string(text), JniHelper::jstring2string(voiceInfo));
	}

	//上传语音回调接口
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifyUploadVoiceMessage( JNIEnv*  env, jobject thiz,jint result , jstring voiceUrl , jlong voiceTime , jstring voiceInfo)
	{
		libVoiceChat::getInstance()->notifyUploadVoiceMessage(result,JniHelper::jstring2string(voiceUrl) , voiceTime ,JniHelper::jstring2string(voiceInfo));
	}

	//文字聊天消息接口（仅失败调用）
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifySendTextMessage( JNIEnv*  env, jobject thiz,jint result , jstring msg)
	{
		libVoiceChat::getInstance()->notifySendTextMessage(result , JniHelper::jstring2string(msg));
	}

	//接受文字消息接口
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifyReceiveTextMessage( JNIEnv*  env, jobject thiz,jstring troopsId , jstring text, jstring expand)
	{
		libVoiceChat::getInstance()->notifyReceiveTextMessage(JniHelper::jstring2string(troopsId) ,JniHelper::jstring2string(text) ,JniHelper::jstring2string(expand));
	}

	//语音识别同时返回语音与文字接口
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifyUploadBdVoiceMessage( JNIEnv*  env, jobject thiz,jint result, jstring msg, jstring voiceUrl, jint voiceDuration, jstring filePath, jstring expand, jstring text)
	{
		libVoiceChat::getInstance()->notifyUploadBdVoiceMessage( result, JniHelper::jstring2string(msg), JniHelper::jstring2string(voiceUrl), voiceDuration, JniHelper::jstring2string(filePath), JniHelper::jstring2string(expand), JniHelper::jstring2string(text) );
	}

	//语音识别单独返回文字接口
	JNIEXPORT void Java_com_nuclear_gjwow_VoiceChat_nativeNotifyBdMineTxtMsg( JNIEnv*  env, jobject thiz,jstring txtMsg )
	{
		libVoiceChat::getInstance()->notifyBdMineTxtMsg( JniHelper::jstring2string(txtMsg));
	}
}



libVoiceChat* libVoiceChat::mInstance = 0;

libVoiceChat* libVoiceChat::getInstance()
{
	if (!mInstance)
	{
		mInstance = new libVoiceChat();
	}
	return mInstance;
}

