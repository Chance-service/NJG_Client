
#pragma once


/************************************************************************/
/*
	
*/
extern bool isTryUserJni();
/*
	
*/
extern void notifyGameSvrBindTryUserToOkUserResultJni(int result);
/*

*/
extern void callPlatformBindUserJni();
/************************************************************************/

extern void callPlatToolsJni(bool visible);

/*
	
*/
extern void onShareEngineMessage(bool _result);

/*

*/
extern void onPlayMovieEnd();
/**/
extern void onMotionShake();

extern void onFBShareBack(bool success);

/*����kakao���ѽӿ�*/
//����������
extern void OnKrGetInviteCountJNI();
//�����б�
extern void OnKrgetInviteListsJNI();
//�����б�
extern void OnKrgetFriendListsJNI();
//����������Ϣ
extern void OnKrsendInviteJNI(const std::string& strUserId, const std::string& strServerId);
//��ȡ�����б�
extern void OnKrgetGiftListsJNI();
//��������
extern void OnKrReceiveGiftJNI(const std::string& strGiftId, const std::string& strServerId);
//��ǰ����������ĸ���
extern void OnKrGetGiftCountJNI();
//��������
extern void OnKrSendGiftJNI(const std::string& strUserName, const std::string& strServerId);
//��������
extern void OnKrGiftBlockJNI(bool bVisible);
extern void OnKrGetKakaoIdJNI();
extern void OnKrLoginGamesJNI();
extern void setLanguageNameJNI(const std::string& lang);
extern void setPlatformNameJNI(int platform);

extern void setPayUrlJNI(const std::string& url);

extern std::string getDomainIpJNI(const std::string& url);