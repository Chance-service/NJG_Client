#pragma once
#include <string>

//��½����
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

//ע������
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

//������Ϣ֪ͨ
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

//�ϴ�����
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

//����������Ϣ�ӿ�
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


//����������Ϣ�ӿ�
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

//����ʶ�𷵻�����������
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

//����ʶ�𵥶���������
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
	
	//��¼
	void login(char* seq);

	//ע��
	void logout(char* seq);
	
	//����&ֹͣ���� java����
	void playAudio(char* filePath);

	//ֹͣ����
	void stopAudio();

	//�ж��Ƿ񲥷�
	bool isPlayingAudio();

	//��ʼ����ʶ��
	void startVoiceRecognition(char* expand);

	//ͬʱ��������ʶ����������������
	void setSupportVoiceAndTxt(bool isSupport);

	//�ϴ�����
	void uploadVoiceMessage(char* filePath ,  long voiceDuration , char* expand);

	//��������
	void sendTextMessage( char* text , char* expand);

	//����ʶ�𽲻�����
	void speakFinish();

	//ȡ������ʶ��
	void stopVoiceRecognition();

	//��½���֪ͨ
	void notifyLoginResult(int result,std::string msg ,long yunvaId);

	//ע�����֪ͨ
	void notifyLougoutResult(int result, std::string msg);
	
	//����������Ϣ֪ͨ�ӿ�
	void notifyVoiceMessage(std::string troopsId , std::string voicePath, long voiceTime ,std::string text, std::string voiceInfo);

	//�ϴ������ص��ӿ�
	void notifyUploadVoiceMessage(int result,std::string voiceUrl, long voiceTime, std::string voiceInfo);

	// ����������Ϣ�ӿڣ���ʧ�ܵ��ã�
	void notifySendTextMessage(int result, std::string msg);

	//����������Ϣ�ӿ�
	void notifyReceiveTextMessage(std::string troopsId,std::string text, std::string expand);

	//����ʶ��ͬʱ�������������ֽӿ�
	void notifyUploadBdVoiceMessage(int result,std::string msg,std::string voiceUrl,int voiceDuration,std::string filePath,std::string expand,std::string text);

	//����ʶ�𵥶��������ֽӿ�
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
