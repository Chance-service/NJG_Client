
#include <string.h>
#include "libVoiceChat.h"

void libVoiceChat::login(char* seq)
{
	
}

void libVoiceChat::logout(char* seq)
{
}

void libVoiceChat::playAudio(char* filePath)
{
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

}

void libVoiceChat::notifyLoginResult(int result,std::string msg ,long yunvaId)
{

}

void libVoiceChat::notifyLougoutResult(int result, std::string msg)
{

}

void libVoiceChat::notifyVoiceMessage(std::string troopsId , std::string voicePath, long voiceTime ,std::string text, std::string voiceInfo)
{

}

void libVoiceChat::uploadVoiceMessage(char* filePath ,  long voiceDuration , char* expand)
{

}

void libVoiceChat::notifyUploadVoiceMessage( int result,std::string voiceUrl, long voiceTime, std::string voiceInfo )
{

}

void libVoiceChat::notifySendTextMessage( int result, std::string msg )
{

}

void libVoiceChat::notifyReceiveTextMessage( std::string troopsId,std::string text, std::string expand )
{

}

void libVoiceChat::sendTextMessage( char* text , char* expand )
{

}

void libVoiceChat::setSupportVoiceAndTxt(bool isSupport)
{

}

void libVoiceChat::notifyUploadBdVoiceMessage( int result,std::string msg,std::string voiceUrl,int voiceDuration,std::string filePath,std::string expand,std::string text )
{

}

void libVoiceChat::notifyBdMineTxtMsg( std::string txtMsg )
{

}

void libVoiceChat::speakFinish()
{

}

void libVoiceChat::stopVoiceRecognition()
{

}

void libVoiceChat::stopAudio()
{

}

bool libVoiceChat::isPlayingAudio()
{
	return false;
}

