//
//  libEntermate.h
//  lib91
//
//  Created by fanleesong on 15/3/18.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#ifndef __lib91__libEntermate__
#define __lib91__libEntermate__

#include "libPlatform.h"

class libEntermate: public libPlatform{
    
    BUYINFO mBuyInfo;
public:
    BUYINFO getBuyInfo(){return mBuyInfo;}
    /**
     call this function first of all.
     NOTICE: Platform should call _boardcastInitDone to notify client logic WHEN initialization is done.
     */
    virtual void initWithConfigure(const SDK_CONFIG_STU& configure);
    
    /** check whether is logined */
    virtual bool getLogined();
    
    /**
     MUST call this function AFTER updating is done(after call back function).
     NOTICE: Platform should call _boardcastLoginResult to notify client logic WHEN login is done.
     */
    
    virtual void login();
    
    /** logout platform*/
    virtual void logout();
    
    /** show the platform window to switch users */
    virtual void switchUsers();
    
    /** buy platform RMB*/
    virtual void buyGoods(BUYINFO&);
    
    /** call platform open bbs function. if the platform doesn't have this usage, just open an url! */
    virtual void openBBS();
    
    /** call platform open feedback function. if the platform doesn't have this usage, just open an email link! */
    virtual void userFeedBack();
    
    /** optional: call platform open game pause function.*/
    virtual void gamePause();
    
    virtual void setToolBarVisible(bool isShow);
    
    /** IMPORTANT: get the only ID for game. MUST be unique! */
    virtual const std::string& loginUin();
    
    /** optional: get the session ID.*/
    virtual const std::string& sessionID();
    
    /** optional: get the nick name. which is shown on the loading scene */
    virtual const std::string& nickName();
    
    virtual const std::string getClientChannel();
    
    virtual std::string getPlatformMoneyName();
    
#ifdef WIN32
    //∑Ω±„win32œ¬µ˜ ‘£¨º«¬ºœ¬…œ¥Œµ«¬º≥…π¶µƒpuid£¨œ¬¥ŒΩ¯”Œœ∑ƒ¨»œŒ™…œ¥Œµ«¬ºµƒpuid, by zhenhui 2014/5/20
    static void libR2::setLoginName(const std::string content);
#endif
    virtual void notifyEnterGame();
    
    virtual bool getIsTryUser();
    
    virtual void callPlatformBindUser();
    
    virtual void notifyGameSvrBindTryUserToOkUserResult(int result);
    /************************************************************/
    /*韩国kakao好友接口*/
    
    //获得邀请次数
    virtual void OnKrGetInviteCount();
    //邀请列表
    virtual void OnKrgetInviteLists();
    //好友列表
    virtual void OnKrgetFriendLists();
    //发送邀请信息
    virtual void OnKrsendInvite(const std::string& strUserId, const std::string& strServerId);
    //获取礼物列表
    virtual void OnKrgetGiftLists();
    //接受礼物
    virtual void OnKrReceiveGift(const std::string& strGiftId, const std::string& strServerId);
    //当前所接受礼物的个数
    virtual void OnKrGetGiftCount();
    //赠送礼物
    virtual void OnKrSendGift(const std::string& strUserName, const std::string& strServerId);
    //屏蔽礼物
    virtual void OnKrGiftBlock(bool bVisible);
    //请求kakaoId
    virtual void OnKrGetKakaoId();
    //进入游戏第一时间调用kakao
    virtual void OnKrLoginGames();
    //kakao处理iOS部分审核时控制显示隐藏的功能按钮
    virtual void OnKrIsShowFucForIOS();
    
    const std::string getPlatformInfo();
    
public:
    __block bool isCanBuyAgain;
    
};


#endif /* defined(__lib91__libEntermate__) */
