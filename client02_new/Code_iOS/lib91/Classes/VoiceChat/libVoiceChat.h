#pragma once
#include <string>

//语音登陆结果
struct VoiceChatLoginResultInfo
{
	VoiceChatLoginResultInfo()
		:isLoginResult(false)
	{

	}
	bool isLoginResult;

	int result;
	std::string msg;
	long yunvaId;
};

//语音退出结果
struct VoiceChatLogoutResultInfo
{
	VoiceChatLogoutResultInfo()
		:isLogoutResult(false)
	{

	}

	bool isLogoutResult;

	int result;
	std::string msg;
};

//语音聊天即时信息
struct VoiceChatVoiceMsgInfo
{
	VoiceChatVoiceMsgInfo()
		:isVoiceMsg(false)
	{

	}

	bool isVoiceMsg;

	std::string troopsId;
	std::string voicePath;
	long voiceTime;
	std::string text;
	std::string voiceInfo;
};

//语音聊天内容加载上传
struct VoiceChatUploadVoiceMessage
{
	VoiceChatUploadVoiceMessage()
		:isUploadVoice(false)
	{

	}
	bool isUploadVoice;

	int result;
	std::string voiceUrl;
	long voiceTime;
	std::string voiceInfo;
};

//发送语音文字信息
struct VoiceChatSendTextMessage
{
	VoiceChatSendTextMessage()
		:isSendTextMessage(false)
	{

	}
	bool isSendTextMessage;

	int result;
	std::string msg;
};


//接收语音文本信息
struct VoiceChatReceiveTextMessage
{
	VoiceChatReceiveTextMessage()
		:isReceive(false)
	{

	}

	bool isReceive;

	std::string troopsId;
	std::string text;
	std::string expand;

};

//语音聊天声音及文本信息
struct VoiceChatVoiceAndTextInfo
{
	VoiceChatVoiceAndTextInfo()
		:isNotify(false)
	{

	}
	bool isNotify;

	int result;
	std::string msg;
	std::string voiceUrl;
	int voiceDuration;
	std::string filePath;
	std::string expand;
	std::string text;

};

//自述文字信息
struct VoiceChatBdMineTxtMsg
{
	VoiceChatBdMineTxtMsg()
		:isNotify(false)
	{

	}
	bool isNotify;
	std::string txtMsg;
};

class libVoiceChat
{
	static libVoiceChat* mInstance;
public:
	VoiceChatLoginResultInfo voiceChatLoginResultInfo;
	VoiceChatLogoutResultInfo voiceChatLogoutResultInfo;
	VoiceChatVoiceMsgInfo voiceChatVoiceMsgInfo;
	VoiceChatUploadVoiceMessage voiceChatUploadVoiceMessage;
	VoiceChatSendTextMessage voiceChatSendTextMessage;
	VoiceChatReceiveTextMessage voiceChatReceiveTextMessage;
	VoiceChatVoiceAndTextInfo voiceChatVoiceAndTextInfo;
	VoiceChatBdMineTxtMsg voiceChatBdMineTxtMsg;
	static libVoiceChat* getInstance();
	
	//登陆
	void login(char* seq);

	//登出
	void logout(char* seq);
	
	//播放媒体
	void playAudio(char* filePath);
    
    //停止播放
    void stopAudio();
    
    //判断是否播放
    bool isPlayingAudio();
    
    //开始录制声音
    void startVoiceRecognition(char* expand);

	//设置声明支持声音和文本
	void setSupportVoiceAndTxt(bool isSupport);

	//上传声音消息
	void uploadVoiceMessage(char* filePath ,  long voiceDuration , char* expand);

	//发送文本消息
	void sendTextMessage( char* text , char* expand);

	//对讲结束
	void speakFinish();

	//停止录制
	void stopVoiceRecognition();

	//监听播报登陆结果
	void notifyLoginResult(int result,std::string msg ,long yunvaId);

	//监听播报登出结果
	void notifyLougoutResult(int result, std::string msg);
	
	//监听声音消息
	void notifyVoiceMessage(std::string troopsId , std::string voicePath, long voiceTime ,std::string text, std::string voiceInfo);

	//监听上传语音消息
	void notifyUploadVoiceMessage(int result,std::string voiceUrl, long voiceTime, std::string voiceInfo);

	//监听发送文本消息
	void notifySendTextMessage(int result, std::string msg);

	//监听接收文本消息
	void notifyReceiveTextMessage(std::string troopsId,std::string text, std::string expand);

	//监听上传百度语音消息
	void notifyUploadBdVoiceMessage(int result,std::string msg,std::string voiceUrl,int voiceDuration,std::string filePath,std::string expand,std::string text);

	//监听百度文本消息
	void notifyBdMineTxtMsg(std::string txtMsg);

	VoiceChatLoginResultInfo getVoiceChatLoginResultInfo(){ return voiceChatLoginResultInfo; };
	VoiceChatLogoutResultInfo getVoiceChatLogoutResultInfo(){ return voiceChatLogoutResultInfo; };
	VoiceChatVoiceMsgInfo getVoiceChatVoiceMsgInfo(){ return voiceChatVoiceMsgInfo; };

	VoiceChatUploadVoiceMessage getVoiceChatUploadVoiceMessage(){ return voiceChatUploadVoiceMessage; };
	VoiceChatSendTextMessage getVoiceChatSendTextMessage(){ return voiceChatSendTextMessage; };
	VoiceChatReceiveTextMessage getVoiceChatReceiveTextMessage(){ return voiceChatReceiveTextMessage; };
	VoiceChatVoiceAndTextInfo getVoiceChatVoiceAndTextInfo(){ return voiceChatVoiceAndTextInfo; }
	VoiceChatBdMineTxtMsg getVoiceChatBdMineTxtMsg(){ return voiceChatBdMineTxtMsg; }
};
