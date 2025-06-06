
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

/*韩国kakao好友接口*/
//获得邀请次数
extern void OnKrGetInviteCountJNI();
//邀请列表
extern void OnKrgetInviteListsJNI();
//好友列表
extern void OnKrgetFriendListsJNI();
//发送邀请信息
extern void OnKrsendInviteJNI(const std::string& strUserId, const std::string& strServerId);
//获取礼物列表
extern void OnKrgetGiftListsJNI();
//接受礼物
extern void OnKrReceiveGiftJNI(const std::string& strGiftId, const std::string& strServerId);
//当前所接受礼物的个数
extern void OnKrGetGiftCountJNI();
//赠送礼物
extern void OnKrSendGiftJNI(const std::string& strUserName, const std::string& strServerId);
//屏蔽礼物
extern void OnKrGiftBlockJNI(bool bVisible);
extern void OnKrGetKakaoIdJNI();
extern void OnKrLoginGamesJNI();
extern void setLanguageNameJNI(const std::string& lang);
extern void setPlatformNameJNI(int platform);

extern void setPayUrlJNI(const std::string& url);

extern std::string getDomainIpJNI(const std::string& url);