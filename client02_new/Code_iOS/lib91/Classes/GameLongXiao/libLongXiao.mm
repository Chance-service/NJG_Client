
//
//  libRyukNew.cpp
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#include "libLongXiao.h"
#include "libOS.h"
#import "libLongXiaoObj.h"
#import "PlatformNotificationCode.h"
#import "HuTuoServerInfo.h"
#import "UIHelperAlert.h"
#import "JSON.h"
#import "FCUUID.h"
#import "SDKUtility.h"
#import <AdSupport/ASIdentifierManager.h>
#import "KeyChainData.h"
#import <comHuTuoSDK.h>
#import <UnKnownGame/UnKnownGame.h>


#define CHANGEUSERTIPS @"GameCenter ID すでに別のアカウントのリンク。あなたはこの口座に切り替えるか？"
#define CANCLE @"取消"
#define CONFIRM @"确定"
#define GOTOGAMECENTER @"で、GameCenter持ってこそ、GameCenter ID 切り開いてくれるアナライズシステム哦!"
#define TipGameCneter @"登録点検している、GameCenterアカウントの登録が必要"

#define TIP_STARTGAME_ERROR @"登陆失败"
#define TIP_GCACCOUNT_NOMATCH @"ログインしているアカウントが連携されているものと異なります アカウントを切り替えてください"

#define BIND_GC @"BINDGC"

libLongXiaoObj* longxiao_Instance = 0;

static bool isRelogin = false;
static bool isEnterLogin = false;       //是否走了libRyuk::login()
static bool isStartScheduleLogin = false;//是否开启了登录GC的schedule
SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libLongXiao::initWithConfigure(const SDK_CONFIG_STU& configure){
    sdkConfigure = configure;

    //注册监听函数
    longxiao_Instance = [libLongXiaoObj new];
    [longxiao_Instance SNSInitResult:0];
    longxiao_Instance.isReLogin = configure.platformconfig.bRelogin;

    NSString *tempdvid = [FCUUID uuidForDevice];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device systemVersion] floatValue] >= 6.0){
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
            tempdvid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    
    longxiao_Instance.deviceid = tempdvid;
    [[NSUserDefaults standardUserDefaults] setObject:longxiao_Instance.deviceid forKey:@"CurrentDevicesId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libLongXiao::getLogined(){
    return [longxiao_Instance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libLongXiao::login(){
    NSLog(@"%s---GNetop_Instance.userid-%@",__FUNCTION__,longxiao_Instance.userid);
    if(!this->getLogined()){
        isEnterLogin = true;
        libOS::getInstance()->setWaiting(true);
        
        isStartScheduleLogin = true;
        [longxiao_Instance startScheduleLogin];
    }
    else if(isRelogin){
        if(![longxiao_Instance.code isEqualToString:@""]){
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:longxiao_Instance.code ,@"result",nil]];
        }
        isRelogin = false;
    }
}

#pragma mark -------------------logout--------------------------
void libLongXiao::logout(){

}

#pragma mark -------------------switchUsers--------------------------
void libLongXiao::switchUsers(){
    isRelogin = true;
}

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libLongXiao::buyGoods(BUYINFO& info){
    
    
    if(info.cooOrderSerial==""){
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    
    
    // 用户点击购买按钮SDK会添加一个遮罩层，防止用户的多次点击，该笔订单结束后遮罩层会自动消失
    // 此处游戏本身也可根据需要来自定义添加loading动画（为了更好的展现，建议添加）
    
    /**
     支付下单
     
     money          金额
     server_id      服务器id
     gold           金币
     role_id        角色id
     role_name      角色名
     cp_order_id    订单
     product_id     productid(苹果后台商品档次)
     product_name   商品名
     ext            透传字段         // 此字段为可选字段 根据游戏自身需要添加
     */
    
    NSString* extras = [NSString stringWithUTF8String:info.extras.c_str()];
    NSData * getJsonData = [extras dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * extrasDict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSString *name = [extrasDict objectForKey:@"name"];
    NSDictionary *dict = @{
                           @"name" : name,
                           @"iOS"  : @"1",
                           };
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString *extenInfoStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary *infoDict = @{
                               @"money"          : [NSString stringWithFormat:@"%f", info.productPrice],                        // 以元为单位
                               @"server_id"      : [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].serverID],     // 必传
                               @"gold"           : [NSNumber numberWithInt: comHuTuoSDK.getServerInfo.coin1],       // 必传
                               @"role_id"        : [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].playerID],     // 必传
                               @"role_name"      : [comHuTuoSDK getServerInfo].playerName,                                     // 必传
                               @"cp_order_id"    : [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]],                      // 必传
                               @"product_id"     : [extrasDict objectForKey:@"name"],                                           //@"com.klxx.ios004", //@"com.sdk.demo.6",  // 必传
                               @"product_name"   : [NSString stringWithUTF8String:info.productName.c_str()],                    // 必传
                               @"ext"            : extenInfoStr,      // 如不需要可不添加此字段
                               };
    NSLog(@"stgmoney:%f",info.productPrice);
    NSLog(@"stgserver_id:%i",[comHuTuoSDK getServerInfo].serverID);
    NSLog(@"stggold:%i",comHuTuoSDK.getServerInfo.coin1);
    NSLog(@"stgrole_id:%i",[comHuTuoSDK getServerInfo].playerID);
    NSLog(@"stgrole_name:%@",[comHuTuoSDK getServerInfo].playerName);
    NSLog(@"stgcp_order_id:%s",info.productId.c_str());
    NSLog(@"stgproduct_id:%@",name);
    NSLog(@"stgproduct_name:%@",[NSString stringWithUTF8String:info.productName.c_str()]);
    [[UnKnownGame sharedPlatform] buyGoods:infoDict];
}

#pragma mark ----------------------------- platfrom tool -------------------------------------
void libLongXiao::openBBS(){
    [longxiao_Instance onPresent];
}

void libLongXiao::userFeedBack(){}
void libLongXiao::gamePause(){}
void libLongXiao::setToolBarVisible(bool isShow){}

#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libLongXiao::loginUin(){
    static std::string retStr = "";
    
    NSString* retNS = longxiao_Instance.userid;
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix + retStr;
    }
    return retStr;
}

const std::string& libLongXiao::getToken(){
    static std::string _session;
    _session = [longxiao_Instance.session UTF8String];
    return _session;
}


#pragma mark ----------------------------- platform -----------------------------------
const std::string& libLongXiao::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
}
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libLongXiao::nickName(){
    
    NSString* retNS = longxiao_Instance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark -------------------getClientChannel--------------------------
const std::string libLongXiao::getClientChannel(){
    return sdkConfigure.platformconfig.clientChannel;//"ios_ryuk_jp";
}

#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libLongXiao::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libLongXiao::notifyEnterGame(){
    longxiao_Instance.isInGame = YES;
}

bool libLongXiao::getIsTryUser(){
    return false;
}
void libLongXiao::callPlatformBindUser(){}
void libLongXiao::notifyGameSvrBindTryUserToOkUserResult(int result){}
void libLongXiao::OnKrGetInviteCount(){}
//G2P means Game to Platform
std::string libLongXiao::sendMessageG2P(const std::string& tag, const std::string& msg){
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"tag---->%@----msg--->%@",[NSString stringWithUTF8String:tag.c_str()],[NSString stringWithUTF8String:msg.c_str()]);
    
    if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_EnterMainScene"]) {
        //longxiao_Instance.isInMainScene = [msg isEqualToString:@"true"];
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ACCOUNT_LOGIN"]) {
        if(isEnterLogin){
            libOS::getInstance()->setWaiting(false);
            if(isStartScheduleLogin){
                [longxiao_Instance endScheduleLogin];
                isStartScheduleLogin = false;
                [longxiao_Instance RequestAccountServer:longxiao_Instance.deviceid gcID:longxiao_Instance.gcid];
            }
            else{
                [longxiao_Instance RequestAccountServer:longxiao_Instance.deviceid gcID:longxiao_Instance.gcid];
            }
        }
        return "";
    }
    else if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ENTER_GAME"])
    {
        NSString* content = [NSString stringWithUTF8String:msg.c_str()];
        [longxiao_Instance EnterGame:content];
        return "";
    }
    

    return sendMessageP2G(tag, msg);
}

