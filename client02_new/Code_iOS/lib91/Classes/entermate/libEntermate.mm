//
//  libEntermate.cpp
//  lib91
//
//  Created by fanleesong on 15/3/18.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#include "libEntermate.h"
#include "libOS.h"
#import "libEntermateObj.h"
#include <com4lovesSDK.h>
#import "HuTuoServerInfo.h"
#import <ILoveGameSDKFramework/ILoveGameSDK.h>
#import "LoginViewController.h"


libEntermateObj* Entermate_Instance = 0;

SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libEntermate::initWithConfigure(const SDK_CONFIG_STU& configure){
    sdkConfigure = configure;
    //init com4lovesSDK
    NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    [com4lovesSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [com4lovesSDK  setAppId:yaappID];
    
    //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    Entermate_Instance = [libEntermateObj new];
    [Entermate_Instance SNSInitResult:0];
    Entermate_Instance.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    //    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    //    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libEntermate::getLogined(){
    return [Entermate_Instance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libEntermate::login(){
    
    if(!this->getLogined()){
        
//        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];

    }
    
}

#pragma mark ------
#pragma mark -------------------logout--------------------------
void libEntermate::logout(){
    NSLog(@"%s",__FUNCTION__);
}
#pragma mark ------
#pragma mark -------------------switchUsers--------------------------
void libEntermate::switchUsers(){
    
    if(!this->getLogined()){
    }
    
}
#pragma mark ------------------------------- login parts ----------------------------------

#pragma mark ------
#pragma mark ------------------------------- purchage parts ----------------------------------

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libEntermate::buyGoods(BUYINFO& info){
    
    NSLog(@"---------%s------------%@",__FUNCTION__,isCanBuyAgain ? @"true":@"false");
    if (!isCanBuyAgain) {
        isCanBuyAgain = true;
        NSLog(@"-------enter--------------%@",isCanBuyAgain ? @"true":@"false");
        if(info.cooOrderSerial==""){
            info.cooOrderSerial = libOS::getInstance()->generateSerial();
        }
        mBuyInfo = info;
        NSString *productId = [NSString stringWithUTF8String:info.productId.c_str()];
        NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
        int zoneID = 0;
        sscanf(info.description.c_str(),"%d",&zoneID);
        
        NSString *aUserID = Entermate_Instance.userid,
        *aPlayerID = uin,
        *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
        *aRoleLevel = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].lvl ],
        *aRoleName = [com4lovesSDK getServerInfo].playerName,
        *aProductID=productId;
        NSLog(@"\n--aProductID=%@\n--aUserID=%@\n--aPlayerID=%@\n--aServerCode==%@\n----aRoleLevel==%@\n--aRoleName==%@\n",aProductID,aUserID,aPlayerID,aServerCode,aRoleLevel,aRoleName);
        /**
         韩国IOS的订单Id要与 安卓保持一致规则
         serverId_username_timestamp_productId
         服务器id_用户名_时间戳_产品ID
         **/
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        NSDate *selected = [NSDate date];
        NSTimeInterval interval = 60 * 60 ;
        NSString *timestamp = [dateFormatter stringFromDate:[selected initWithTimeInterval:interval sinceDate:selected]];
        
        
        NSString *orderIdForEntermateIOS = [NSString stringWithFormat:@"%@_%@_%@_%@",aServerCode,aUserID,timestamp,productId];
        NSLog(@"orderIdForEntermateIOS-----%@",orderIdForEntermateIOS);
        
        /* tokeninfo
         pricelist =         (
         1000,
         5000,
         15000,
         25000,
         50000,
         100000
         );
         privatekey = 95362f4c68d0075c704d519f741d03615ac7b1bd76721fe4410c0f3edf7366e1;
         productid =         (
         IAP0001,
         IAP0002,
         IAP0003,
         IAP0004,
         IAP0005,
         IAP0006,
         IAP1000
         );
         */
        [[ILoveGameSDK getInstance] setServerId:aServerCode];  // 目前所在的区服ID
        [[ILoveGameSDK getInstance] setProductId:productId];  // Product ID
        [[ILoveGameSDK getInstance] setOrderID:[NSString stringWithFormat:@"%@",orderIdForEntermateIOS]];
        
        [[ILoveGameSDK getInstance] charge:^(BOOL success, NSError *error) {
            
            NSDictionary* dic = error.userInfo;
            if(success == YES && [[dic valueForKey:@"result"] intValue] == 1000) {
                NSLog(@"-----success------error----%@",[dic valueForKey:@"error"]);
                //            // 完成购买后，发出请求
                //            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                //                                                                message:[dic valueForKey:@"error"]
                //                                                               delegate:nil
                //                                                      cancelButtonTitle:@"확인"
                //                                                      otherButtonTitles:nil];
                //            [alertView show];
                isCanBuyAgain = false;
                NSLog(@"---1111-----success-------------%@",isCanBuyAgain ? @"true":@"false");
            } else {
                // 支付报错
                NSDictionary* details = [error userInfo];
                NSLog(@"-----fail-------error--------%@",[details valueForKey:@"error"]);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
                                                                    message:[details valueForKey:@"error"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"확인"
                                                          otherButtonTitles:nil];
                [alertView show];
                isCanBuyAgain = false;
                NSLog(@"---1111----fails--------------%@",isCanBuyAgain ? @"true":@"false");
            }
        } setView:[UIApplication sharedApplication].keyWindow.rootViewController.view];
        
    }
    
}

#pragma mark ------
#pragma mark ----------------------------- platfrom tool -------------------------------------
//处理审核广告问题
void libEntermate::openBBS(){
    
    //    [[NdComPlatform defaultPlatform] NdEnterAppBBS:0];
    [Entermate_Instance onPresent];
    
}

void libEntermate::userFeedBack(){
    
    [[ILoveGameSDK getInstance] openHelp:[UIApplication sharedApplication].keyWindow.rootViewController];
    
    
}
void libEntermate::gamePause(){}
void libEntermate::setToolBarVisible(bool isShow){}
#pragma mark ------
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libEntermate::loginUin(){
    static std::string retStr = "";
    
    NSString* retNS = Entermate_Instance.userid;
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix + retStr;
    }
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libEntermate::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libEntermate::nickName(){
    
    NSString* retNS = Entermate_Instance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark ------
#pragma mark -------------------getClientChannel--------------------------
const std::string libEntermate::getClientChannel(){
    return "ios_entermate_kr";
}

#pragma mark ------
#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libEntermate::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libEntermate::notifyEnterGame(){
    
    Entermate_Instance.isInGame = YES;
    UIView *window = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    NSString  *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleName = [NSString stringWithFormat:@"%@",[com4lovesSDK getServerInfo].playerName ];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    
}
bool libEntermate::getIsTryUser(){
    return false;
}
void libEntermate::callPlatformBindUser(){}
void libEntermate::notifyGameSvrBindTryUserToOkUserResult(int result){}

//Finished
/**
 *  10.context.nativeOnKrGetInviteCount(nCount);
     ToJsonAndSendP2G("P2G_KR_GET_INVITE_COUNT", "count", nCount);
 */
void libEntermate::OnKrGetInviteCount(){

    NSLog(@"%s",__FUNCTION__);
    NSUInteger inviteCount =  [[[ILoveGameSDK getInstance] get_invitelists] count];
    int realNum = [[NSNumber numberWithUnsignedInteger:inviteCount] intValue];
    NSLog(@"----%d",realNum);
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"count":[NSNumber numberWithInt:realNum]} options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *inviteJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"-----Entermate----OnKrGetInviteCount---------->%@",inviteJson);
    libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_GET_INVITE_COUNT",[inviteJson UTF8String]);
    
//    libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_INVITE_COUNT,realNum,false,"");
    
}
//邀请列表
/**
 {
 "is_visible": "0",                       // 是否可以邀请 (0 or 1)
 "user_id_string": "-88300572241583040",  // string type user id
 "supported_device": true,                // 确认该设备是否可以发送信息 (true or false)
 "nickname": "H지영",                     // nickname
 "message_blocked": false,                // 是否允许发送信息 (true or false)
 "hashed_talk_user_id": "AFEiyMgiUQA",    // 连接Kakao的hash值
 "user_id": -88300572241583040,           // user id
 "friend_nickname": "",
 "profile_image_url": "http:///qRAeykBfcvilRC31Bn9AB0/y3g0aq_110x110_c.jpg" // image url
 }
 
 {
 "friend_nickname" = "";
 "hashed_talk_user_id" = ARJKNDRKEgE;
 "is_visible" = 1;
 "message_blocked" = 0;
 nickname = "\Uae40\Uacc4\Uc625";
 "profile_image_url" = "http:///o9VL6sYES5nodD9KAInOU0/i2xl02_110x110_c.jpg";
 "supported_device" = 1;
 "user_id" = "-92693844486083488";
 }
 **/
//Finished
/**
 *  8.context.nativeOnKrGetInviteLists(strInfo);
     ToJsonAndSendP2G("P2G_KR_GET_INVITE_LIST", "invitelist",strInfo);
 */
void libEntermate::OnKrgetInviteLists(){

    NSLog(@"%s",__FUNCTION__);
    NSArray *inviteArray = [[[ILoveGameSDK getInstance] get_invitelists] copy];
    if ([inviteArray count] > 0 && ![[ILoveGameSDK getInstance] IsGuest]) {
        NSLog(@"--OnKrgetInviteLists---count---%d----%@",(int)[inviteArray count],inviteArray);
        NSError *parseError = nil;
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"invitelist":inviteArray} options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *inviteJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"-----Entermate-----OnKrgetInviteLists---------->%@",inviteJson);
        libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_GET_INVITE_LIST",[inviteJson UTF8String]);
        
//        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_INVITE_LIST,0,false,[inviteJson UTF8String]);
    }else if([[ILoveGameSDK getInstance] IsGuest]){
    }
   
    
    
}
//好友列表
/**  
 Android------
 {
 rank: 20,
 id: "88340309552546641",
 playerid: "851406",
 user_id: "88340309552546641",
 username: "4102116",
 exp: "397",
 serverid: "1",
 imageurl: "http:///wkiBFhogbh/1qkJlr5B60mjfm6TWezBok/o5cq69_110x110_c.jpg",
 name: "건호",
 character: "엘리후",
 svname: "하이드",
 nickname: "건호",
 cup: "356",
 level: "7",
 is_visible: "1"
 }
 
 iOS----rank 、imageurl、name、level、character、is_visible
 **/
//Finished
/**
 *  3.context.nativeOnKrGetFriendLists(strInfo);
     ToJsonAndSendP2G("P2G_KR_GET_FRIEND_LIST", "friendlist", strInfo);
 */
void libEntermate::OnKrgetFriendLists(){

    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@",[[ILoveGameSDK getInstance] isVisibleFriend]?@"YES":@"NO");
    //显示好友列表时
    if ([[ILoveGameSDK getInstance] isVisibleFriend]) {
        NSArray *friendArrays = [[ILoveGameSDK getInstance] get_friendlists];
        NSLog(@"-Friendscount---%d----%@",(int)[friendArrays count],friendArrays);
        if ([friendArrays count] > 0 ) {
            NSError *parseError = nil;
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"friendlist":friendArrays} options:NSJSONWritingPrettyPrinted error:&parseError];
            NSString *friendsJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"friendsJson---------->%@",friendsJson);
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_GET_FRIEND_LIST",[friendsJson UTF8String]);
//            libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_FRIEND_LIST,0,false,[friendsJson UTF8String]);
        }
    }
    

}
//发送邀请信息 //Finished
/**
 *  7.context.nativeOnKrSendInvite(strInfo);
     ToJsonAndSendP2G("P2G_KR_SEND_INVITE", "result",strInfo);
 *
 *  @param strUserId
 *  @param strServerId
 */
void libEntermate::OnKrsendInvite(const std::string& strUserId, const std::string& strServerId){

    NSLog(@"%s------------,sendinvite friends-----%s,---------selfUserId-----%@",__FUNCTION__,strUserId.c_str(),[[ILoveGameSDK getInstance] get_user_id]);
    if (strUserId.length() > 0) {
    
        //发送好友请求时让界面保持一个loadingView开启
        [[ILoveGameSDK getInstance] showCoverView:[UIApplication sharedApplication].windows.lastObject];
        [[ILoveGameSDK getInstance] sendInvite:^(BOOL success, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //请求发出后，移除loadingView
                [[ILoveGameSDK getInstance] hideCoverView:[UIApplication sharedApplication].windows.lastObject];
                
                NSString *message = @"";
                NSDictionary *info = error.userInfo;
                int result = [[info valueForKey:@"result"] intValue];
                //处理传给服务器的Json 字符串
                NSError *parseError = nil;
                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"result":info} options:NSJSONWritingPrettyPrinted error:&parseError];
                NSString *orderString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"Entermate-----OnKrsendInvite-----%@",orderString);
                if(success)
                {
                    
                    if(result == 1000)
                    {
                        message = @"초대 메시지 발송을 성공 했습니다.";
                         NSLog(@"success-----inviteFriend--error----%@",message);
                        
                    } else {
                        
                        message = [info valueForKey:@"error"];
                        NSLog(@"no--success-----inviteFriend--error----%@",message);

                    }
                   
                } else {
                    
                    message = [info valueForKey:@"error"];
                    NSLog(@"fail-----inviteFriend--error----%@",message);

                }
                
                libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_SEND_INVITE",[orderString UTF8String]);
//                libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::SEND_INVITE,0,false,[orderString UTF8String]);
                
                
            });
            
        } setUserid:[NSString stringWithUTF8String:strUserId.c_str()]];
    
    }

}
//获取礼物列表
/**
 {
 id: "787331",
 nickname: "건호!",
 itemname: "골드 X 10000",
 itemcode: "Itemcode",
 imageurl: "http:///2014_11/cfd463da73960f75c9df56022a1115ff.png"
 }
 **/
//----Finished:
/**
 *  6.context.nativeOnKrGetGiftLists(strInfo);
     ToJsonAndSendP2G("P2G_KR_GET_GIFT_LIST", "giftlist",strInfo);
 */
void libEntermate::OnKrgetGiftLists(){
    
    NSLog(@"%s",__FUNCTION__);
    NSArray *giftsArray = [[ILoveGameSDK getInstance] get_giftlists];
    NSLog(@"giftCount------>%d----%@",(int)[giftsArray count],giftsArray);
    if ([giftsArray count] > 0) {
        NSError *parseError = nil;
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"giftlist":giftsArray} options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *giftJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Entermate-----OnKrgetGiftLists-----%@",giftJson);
        libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_GET_GIFT_LIST",[giftJson UTF8String]);
        
//        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_GIFT_LIST,0,false,[giftJson UTF8String]);
    }

}
//接受礼物
/**
 {
 id: "787331",
 nickname: "건호!",
 itemname: "골드 X 10000",
 itemcode: "Itemcode",
 imageurl: "http:///img/2014_11/cfd463da73960f75c9df56022a1115ff.png"
 }
 **/
//----Finished:
/**
 *  5.context.nativeOnKrReceiveGift(false);
     ToJsonAndSendP2G("P2G_KR_RECEIVE_GIFT", "result",result.toString());
 *
 *  @param strGiftId
 *  @param strServerId
 */
void libEntermate::OnKrReceiveGift(const std::string& strGiftId, const std::string& strServerId){

    
    
    NSLog(@"%s",__FUNCTION__);
    NSArray* giftList = [[ILoveGameSDK getInstance] get_giftlists];
    NSLog(@"--giftList-----%@",giftList);
    
    NSString *giftId = [NSString stringWithUTF8String:strGiftId.c_str()];
    NSString *serverId = [NSString stringWithUTF8String:strServerId.c_str()];
    
    [[ILoveGameSDK getInstance] receiveGift:^(BOOL success, NSError *error) {
        NSString *message = @"";
        if(success)
        {
            NSDictionary *info = error.userInfo;
            int result = [[info valueForKey:@"result"] intValue];
            if(result == 1000) // Success
            {
                message = [info valueForKey:@"error"];
                NSError *parseError = nil;
                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"result":[NSNumber numberWithBool:true]} options:NSJSONWritingPrettyPrinted error:&parseError];
                NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"——Entermate—————OnKrReceiveGift---------->%@",productJson);
                libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_RECEIVE_GIFT",[productJson UTF8String]);
//                libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::RECEIVE_GIFT,0,true,"");
                
            } else { // Fail
                message = [info valueForKey:@"error"];
                
                NSError *parseError = nil;
                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"result":[NSNumber numberWithBool:false]} options:NSJSONWritingPrettyPrinted error:&parseError];
                NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"——Entermate—————OnKrReceiveGift---------->%@",productJson);
                libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_RECEIVE_GIFT",[productJson UTF8String]);
                
//                libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::RECEIVE_GIFT,0,false,"");
            }
        } else { // Fail
            message = [NSString stringWithFormat:@"%@", [error.userInfo valueForKey:@"error"]];
            
            NSError *parseError = nil;
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"result":[NSNumber numberWithBool:false]} options:NSJSONWritingPrettyPrinted error:&parseError];
            NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"——Entermate—————OnKrReceiveGift---------->%@",productJson);
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_RECEIVE_GIFT",[productJson UTF8String]);
            
//            libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::RECEIVE_GIFT,0,false,"");
        }
        
        NSLog(@"----receivegift----result---%@",message);
        
    } setGiftId:giftId/*lists信息的ID*/ setServerId:serverId];
    
   
}
//当前所接受礼物的个数
//----Finished:
/**
 *  10.context.nativeOnKrGetGiftCount(nCount);
     ToJsonAndSendP2G("P2G_KR_GET_GIFT_COUNT", "count",nCount);
 */
void libEntermate::OnKrGetGiftCount(){

    NSLog(@"%s",__FUNCTION__);
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"count":[NSNumber numberWithInt:[[ILoveGameSDK getInstance] get_gift_count]]} options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"——Entermate—————OnKrGetGiftCount---------->%@",productJson);
    libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_GET_GIFT_COUNT",[productJson UTF8String]);
//    libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GET_GIFT_COUNT,[[ILoveGameSDK getInstance] get_gift_count],false,"");
    
}
//赠送礼物
//----Finished:
/**
 *  2.context.nativeOnKrSendGift(strInfo);
     ToJsonAndSendP2G("P2G_KR_SEND_GIFT", "result",strInfo);
 *
 *  @param strUserName
 *  @param strServerId
 */
void libEntermate::OnKrSendGift(const std::string& strUserName, const std::string& strServerId){

    NSLog(@"%s-------sendGift--%s,myself-----%@",__FUNCTION__,strUserName.c_str(),[[ILoveGameSDK getInstance] get_username]);
    //赠送时弹出框的提示内容
    //NSString* message = [[NSString alloc] initWithFormat:[[ILoveGameSDK getInstance] getConfirmMessage:MESSAGE_SOCIAL_SENDGIFT], /*user nickname*/];
    NSString* nsUserName = [NSString stringWithUTF8String:strUserName.c_str()];// 친구 정보의 username 값
    NSLog(@"------nsUserName-----%@",nsUserName);
    //发送好友赠送礼物请求时让界面保持一个loadingView开启
    [[ILoveGameSDK getInstance] showCoverView:[UIApplication sharedApplication].windows.lastObject];
    [[ILoveGameSDK getInstance] sendGift:^(BOOL success, NSError *error) {
        //请求发出后，移除loadingView
        [[ILoveGameSDK getInstance] hideCoverView:[UIApplication sharedApplication].windows.lastObject];
        NSDictionary *info = error.userInfo;
        int result = [[info valueForKey:@"result"] intValue];
        //处理传给服务器的Json 字符串
        NSError *parseError = nil;
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"result":info} options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *orderString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Entermate-----OnKrSendGift-----%@",orderString);
        NSString *message = @"";
        if (success) {
            if(result == 1000){
                message = @"선물 성공";
            }else{
                message = [info objectForKey:@"error"];
            }
        }else{
            message = [info objectForKey:@"error"];
        }
        NSLog(@"-------send result---------%@",message);
        libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_SEND_GIFT",[orderString UTF8String]);
//        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::SEND_GIFT,0,false,[orderString UTF8String]);
    } setUserid:nsUserName];
    
    
}
//屏蔽礼物
//好友列表里，如果是本人的话，就不显示送礼按钮，而是显示屏蔽送礼按钮
//----Finished:
/**
 *  4.context.nativeOnKrGiftBlock(result.toString());
     ToJsonAndSendP2G("P2G_KR_GIFT_BLOCK", "result",result.toString());
 *
 *  @param bVisible controlShow or Not
 */
void libEntermate::OnKrGiftBlock(bool bVisible){

    NSLog(@"%s",__FUNCTION__);
    //发送好友赠送礼物请求时让界面保持一个loadingView开启
    [[ILoveGameSDK getInstance] showCoverView:[UIApplication sharedApplication].windows.lastObject];
    [[ILoveGameSDK getInstance] setMessageBlock:^(BOOL success, NSError *error)
    {
        //请求发出后，移除loadingView
        [[ILoveGameSDK getInstance] hideCoverView:[UIApplication sharedApplication].windows.lastObject];
        NSDictionary *info = error.userInfo;
        int result = [[info valueForKey:@"result"] intValue];
        //处理传给服务器的Json 字符串
        NSError *parseError = nil;
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"result":info} options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *orderString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"-------Entermate-----orderString------%@",orderString);
        NSString *message = @"";
        if(success)
        {
            // TODO : 친구 리스트 갱신
            if (result == 1000) {
                message = [info valueForKey:@"error"];
            }else{
                message = [info valueForKey:@"error"];
            }
        }
        else
        {
            message = [info valueForKey:@"error"];
            // message 내용을 게임 팝업 형태로 보여준다.
        }
        libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_GIFT_BLOCK",[orderString UTF8String]);
//        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::GIFT_BLOCK,0,false,[orderString UTF8String]);
        
    } enable:bVisible]; // true or false
    

}
//请求kakaoId //Finished
/**
 *  1.context.nativeOnKrGetKakaoIdBack(strId);
     ToJsonAndSendP2G("P2G_KR_KAKAO_ID_BACK", "strid",strId);
 */
void libEntermate::OnKrGetKakaoId(){
    
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"----KakaoID-------%@",[[ILoveGameSDK getInstance] get_user_id]);
//    if ([[ ILoveGameSDK getInstance] isVisibleGuest] || [[ ILoveGameSDK getInstance] IsGuest]) {
//        if ( [[ILoveGameSDK getInstance] get_user_id].length > 17) {
//            NSString *tempString = [[[ILoveGameSDK getInstance] get_user_id] substringToIndex:17];
//            libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::Get_KakaoId,0,false,[tempString cStringUsingEncoding:NSUTF8StringEncoding]);
//        }else{
//            libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::Get_KakaoId,0,false,[[[ILoveGameSDK getInstance] get_user_id] cStringUsingEncoding:NSUTF8StringEncoding]);
//        }
//    }else{
//        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::Get_KakaoId,0,false,[[[ILoveGameSDK getInstance] get_user_id] cStringUsingEncoding:NSUTF8StringEncoding]);
//    }
    
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    NSError *parseError = nil;
    
    if ([[ ILoveGameSDK getInstance] isVisibleGuest] || [[ ILoveGameSDK getInstance] IsGuest]) {
        if ( [[ILoveGameSDK getInstance] get_user_id].length > 17) {
            
            NSString *tempString = [[[ILoveGameSDK getInstance] get_user_id] substringToIndex:17];
            [jsonDic setValue:tempString forKey:@"strid"];
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&parseError];
            NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"——Entermate—————finalJson---------->%@",productJson);
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_KAKAO_ID_BACK",[productJson UTF8String]);
            
        }else{
            
            [jsonDic setValue:[[ILoveGameSDK getInstance] get_user_id] forKey:@"strid"];
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&parseError];
            NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"——Entermate—————finalJson---------->%@",productJson);
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_KAKAO_ID_BACK",[productJson UTF8String]);
        }
    }else{
        
        [jsonDic setValue:[[ILoveGameSDK getInstance] get_user_id] forKey:@"strid"];
        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&parseError];
        NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"——Entermate—————finalJson---------->%@",productJson);
        libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_KAKAO_ID_BACK",[productJson UTF8String]);
        
    }

  
    
    
}

//kakao处理iOS部分审核时控制显示隐藏的功能按钮
//Finished
/**
 *  P2G_KR_IS_SHOW_FUN_IOS_BACK   result
     local strResult = listener:getResult()
     local strTable = json.decode(strResult)
     local result = strTable.result
 */
void libEntermate::OnKrIsShowFucForIOS(){

    NSLog(@"%s-------isVisibleFriends---%@",__FUNCTION__,[[ILoveGameSDK getInstance] isVisibleFriend]?@"true":@"false");
    
//    if ([[ILoveGameSDK getInstance] isVisibleFriend]) {
//        NSLog(@"------------this  is true-------");
//        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::KAKAO_IOS_ISSHOWFUC,0,true,"");
//    }else{
//        NSLog(@"------------this  is false-------");
//        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::KAKAO_IOS_ISSHOWFUC,0,false,"");
//    }
    
    
    NSMutableDictionary *jsonDic = [NSMutableDictionary dictionary];
    if ([[ILoveGameSDK getInstance] isVisibleFriend]) {
        NSLog(@"------------this  is true-------");
        [jsonDic setObject:[NSNumber numberWithBool:true] forKey:@"result"];
        
        libPlatformManager::getPlatform()->_boardcastOnKrCallBack(libPlatform::KAKAO_IOS_ISSHOWFUC,0,true,"");
    }else{
        NSLog(@"------------this  is false-------");
        [jsonDic setObject:[NSNumber numberWithBool:false] forKey:@"result"];
     
    }
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"——Entermate—————:-------------finalJson---------->%@",productJson);
    libPlatformManager::getPlatform()->sendMessageP2G("P2G_KR_IS_SHOW_FUN_IOS_BACK",[productJson UTF8String]);
    

}
const std::string libEntermate::getPlatformInfo(){
    NSLog(@"%s",__FUNCTION__);
    

return "";
    
}
//进入游戏第一时间调用kakao
void libEntermate::OnKrLoginGames(){
    
    NSLog(@"%s",__FUNCTION__);
    
    
}
