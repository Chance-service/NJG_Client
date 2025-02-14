
#include <string.h>
#include "libVoiceChat.h"
//#import "libVoiceChatObj.h"
//#import "YVToCom4lovesVoiceSDK.h"

//libVoiceChatObj *s_libVoiceChatObj;
void libVoiceChat::login(char* seq)
{
//    if(s_libVoiceChatObj == nil)
//    {
//        s_libVoiceChatObj = [[libVoiceChatObj alloc]init];
//    }
//    [YVToCom4lovesVoiceSDK getInstance].delegate = s_libVoiceChatObj;
//    [[YVToCom4lovesVoiceSDK getInstance] Login:[NSString stringWithUTF8String:seq]];
}

void libVoiceChat::logout(char* seq)
{
    //[[YVToCom4lovesVoiceSDK getInstance] Logout];
}

void libVoiceChat::playAudio(char* filePath)
{
    //    NSLog(@"%@",filePath);
    //播放录音
   // [[YVToCom4lovesVoiceSDK getInstance] startOnlinePlayAudio:[NSString stringWithUTF8String:filePath]];
}

void libVoiceChat::stopAudio()
{
    //[[YVToCom4lovesVoiceSDK getInstance] stopPlayAudio];
}

bool libVoiceChat::isPlayingAudio()
{
    return false;//[[YVToCom4lovesVoiceSDK getInstance] isPlaying];
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

void libVoiceChat::startVoiceRecognition( char* expand )
{
    // [yvaudiotools startRecord];
//    NSLog(@"startRecord");
//    [[YVToCom4lovesVoiceSDK getInstance] startRecord:[NSString stringWithUTF8String:expand]];
}

void libVoiceChat::notifyLoginResult(int result,std::string msg ,long yunvaId)
{
//    NSLog("VoiceChatManager-login notifyLoginResult:%s", msg.c_str());
//    voiceChatLoginResultInfo.result = result;
//    voiceChatLoginResultInfo.msg = msg;
//    voiceChatLoginResultInfo.yunvaId = yunvaId;
//    
//    voiceChatLoginResultInfo.isLoginResult = true;
}

void libVoiceChat::notifyLougoutResult(int result, std::string msg)
{
//    voiceChatLogoutResultInfo.result = result;
//    voiceChatLogoutResultInfo.msg = msg;
//    
//    voiceChatLogoutResultInfo.isLogoutResult = true;
}

void libVoiceChat::notifyVoiceMessage(std::string troopsId , std::string voicePath, long voiceTime ,std::string text, std::string voiceInfo)
{
//    voiceChatVoiceMsgInfo.troopsId = troopsId;
//    voiceChatVoiceMsgInfo.voicePath = voicePath;
//    voiceChatVoiceMsgInfo.voiceTime = voiceTime;
//    voiceChatVoiceMsgInfo.text = text;
//    voiceChatVoiceMsgInfo.voiceInfo = voiceInfo;
//    voiceChatVoiceMsgInfo.isVoiceMsg = true;
}

void libVoiceChat::uploadVoiceMessage(char* filePath ,  long voiceDuration , char* expand)
{
    
}

void libVoiceChat::notifyUploadVoiceMessage( int result,std::string voiceUrl, long voiceTime, std::string voiceInfo )
{
//    voiceChatUploadVoiceMessage.result = result;
//    voiceChatUploadVoiceMessage.voiceUrl = voiceUrl;
//    voiceChatUploadVoiceMessage.voiceTime = voiceTime;
//    voiceChatUploadVoiceMessage.voiceInfo = voiceInfo;
//    
//    voiceChatUploadVoiceMessage.isUploadVoice = true;
}

void libVoiceChat::notifySendTextMessage( int result, std::string msg )
{
//    voiceChatSendTextMessage.result = result;
//    voiceChatSendTextMessage.msg = msg;
//    
//    voiceChatSendTextMessage.isSendTextMessage = true;
}

void libVoiceChat::notifyReceiveTextMessage( std::string troopsId,std::string text, std::string expand )
{
//    voiceChatReceiveTextMessage.troopsId = troopsId;
//    voiceChatReceiveTextMessage.text = text;
//    voiceChatReceiveTextMessage.expand = expand;
//    
//    voiceChatReceiveTextMessage.isReceive = true;
}

void libVoiceChat::sendTextMessage( char* text , char* expand )
{
    //[[YVToCom4lovesVoiceSDK getInstance] sendTextMessage:[NSString stringWithUTF8String:text] expand:[NSString stringWithUTF8String:expand]];
}

void libVoiceChat::setSupportVoiceAndTxt(bool isSupport)
{
    //[YVToCom4lovesVoiceSDK getInstance].bSupportVoiceAndText = isSupport;
}

void libVoiceChat::notifyUploadBdVoiceMessage( int result,std::string msg,std::string voiceUrl,int voiceDuration,std::string filePath,std::string expand,std::string text )
{
//    voiceChatVoiceAndTextInfo.result = result;	
//    voiceChatVoiceAndTextInfo.msg = msg;
//    voiceChatVoiceAndTextInfo.voiceUrl = voiceUrl;
//    voiceChatVoiceAndTextInfo.voiceDuration = voiceDuration;
//    voiceChatVoiceAndTextInfo.filePath = filePath;
//    voiceChatVoiceAndTextInfo.expand =expand;
//    voiceChatVoiceAndTextInfo.text = text;
//    
//    voiceChatVoiceAndTextInfo.isNotify = true;
}

void libVoiceChat::notifyBdMineTxtMsg( std::string txtMsg )
{
//    voiceChatBdMineTxtMsg.txtMsg = txtMsg;
//    
//    voiceChatBdMineTxtMsg.isNotify = true;
}

void libVoiceChat::speakFinish()
{
   // [[YVToCom4lovesVoiceSDK getInstance] endRecord];
}

void libVoiceChat::stopVoiceRecognition()
{
    //[[YVToCom4lovesVoiceSDK getInstance] cancelRecord];
}

