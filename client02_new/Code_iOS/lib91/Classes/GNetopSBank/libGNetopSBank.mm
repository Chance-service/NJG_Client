//
//  libGNetopSBank.cpp
//  lib91
//
//  Created by fanleesong on 15/3/12.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#include "libGNetopSBank.h"
#include "libOS.h"
#import "libGNetopSBankObj.h"
#import "GameCenterSDK.h"
#include <com4lovesSDK.h>
#import "YouaiServerInfo.h"
#import "GNetopSBankSharedManager.h"


libGNetopSBankObj* GNetopSBank_Instance = 0;

SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libGNetopSBank::initWithConfigure(const SDK_CONFIG_STU& configure){
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
    GNetopSBank_Instance = [libGNetopSBankObj new];
    [GNetopSBank_Instance SNSInitResult:0];
    GNetopSBank_Instance.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    //    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    //    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libGNetopSBank::getLogined(){
    return [GNetopSBank_Instance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libGNetopSBank::login(){
    
    NSLog(@"%s---GNetopSBank_Instance.userid-%@",__FUNCTION__,GNetopSBank_Instance.userid);
    if(!this->getLogined()){
        NSLog(@"%s---tttttt--",__FUNCTION__);
        //每次启动游戏时调用登录游戏接口
        [[GameCenterSDK GameCenterSharedSDK] loginGameByGameCenter];
        
    }
    
}

#pragma mark ------
#pragma mark -------------------logout--------------------------
void libGNetopSBank::logout(){
    NSLog(@"%s---before---logout-%@",__FUNCTION__,GNetopSBank_Instance.userid);
    //    GNetopSBank_Instance.userid = nil;
    NSLog(@"%s---after---logout-%@",__FUNCTION__,GNetopSBank_Instance.userid);
    
}
#pragma mark ------
#pragma mark -------------------switchUsers--------------------------
void libGNetopSBank::switchUsers(){
    
    //    logout();//先注销一下再跳到r2登陆界面
    if(!this->getLogined()){
    }
    
}
#pragma mark ------------------------------- login parts ----------------------------------

#pragma mark ------
#pragma mark ------------------------------- purchage parts ----------------------------------

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libGNetopSBank::buyGoods(BUYINFO& info){
    
    if(info.cooOrderSerial==""){
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NSString *productId = [NSString stringWithUTF8String:info.productId.c_str()];
    NSString *productName = [NSString stringWithUTF8String:info.productName.c_str()];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    int zoneID = 0;
    sscanf(info.description.c_str(),"%d",&zoneID);
    NSString *orderId = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];;
    NSString *aUserID = GNetopSBank_Instance.userid,
    *aPlayerID = uin,
    *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleLevel = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].lvl ],
    *aRoleName = [com4lovesSDK getServerInfo].playerName,
    *aProductID=productId;
    std::string x = "$$";
    std::string str = "ios_gnetop"+ x + info.description + x + info.productId;
    NSString *aRemark = [NSString stringWithUTF8String:(const char *)str.c_str()];
    float productPrice = info.productPrice;
    NSLog(@"--productPrice--%.2f",productPrice);
    int  serverTime  = info.serverTime;
    
    NSLog(@"\n--aProductID=%@\n--aUserID=%@\n--aPlayerID=%@\n--aServerCode==%@\n--aRemark==%@\n--aRoleLevel==%@\n--aRoleName==%@\n--orderId==%@\n--productName==%@",aProductID,aUserID,aPlayerID,aServerCode,aRemark,aRoleLevel,aRoleName,orderId,productName);
    
    NSString* isOnAppstore = [com4lovesSDK getPropertyFromIniFile:@"OnAppstore" andAttr:@"onappstore"];
    /**
     如果本游戏未被从AppStore下架或者苹果内购依旧可以使用则用第一个内购
     否则使用日本软银支付
     **/
    if (isOnAppstore && [isOnAppstore isEqualToString:@"1"]) {
        //内购
        [[com4lovesSDK sharedInstance] appStoreBuy:productId serverID:aServerCode totalFee:productPrice orderId:orderId];
    }else{
        //软银支付
        [[GNetopSBankSharedManager shareSBankManager] showSBPaymentViewBuyForOrderId:orderId customId:aUserID productId:productId productName:productName taxMoney:@"0" amount:[NSString stringWithFormat:@"%d",(int)productPrice] payRequestDate:serverTime serverCode:aServerCode roleId:aPlayerID currencyType:@"JP" payMethod:@"" payTestModel:0];
    }
    

    
}

#pragma mark ------
#pragma mark ----------------------------- platfrom tool -------------------------------------
void libGNetopSBank::openBBS(){
}

void libGNetopSBank::userFeedBack(){
    
    /*
     http://support.r2games.com/index/mobile?game=EZ%20PZ%20RPG&userid="
     + yaLastLoginHelp.mPuid + "&gameid=242&server="
     + yaLastLoginHelp.mServerID + "&role="
     + yaLastLoginHelp.mPlayerName + "&mail=");
     */
    [[com4lovesSDK sharedInstance] showSdkFeedBackWithUserName:
     [NSString stringWithFormat:@"%@&serverID=%d",[com4lovesSDK getServerInfo].playerName ,[com4lovesSDK getServerInfo].serverID]];
    NSString *r2_url = [NSString stringWithFormat:@"http://support.r2games.com/index/mobile?game=EZ%%20PZ%%20RPG&userid=%@&gameid=242&server=%d&role=%@&mail=",GNetopSBank_Instance.userid,[com4lovesSDK getServerInfo].serverID,[com4lovesSDK getServerInfo].playerName];
    NSString *converstString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)r2_url, nil, nil, kCFStringEncodingUTF8);
    NSLog(@"GM---url--\n%@",converstString);
    NSLog(@"GM---url--\n%@",r2_url);
    [[com4lovesSDK sharedInstance] showWeb:r2_url];
    
}
void libGNetopSBank::gamePause(){
    
}

void libGNetopSBank::setToolBarVisible(bool isShow){
    
}
#pragma mark ------
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libGNetopSBank::loginUin(){
    static std::string retStr = "";
    
    NSString* retNS = GNetopSBank_Instance.userid;
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
const std::string& libGNetopSBank::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libGNetopSBank::nickName(){
    
    NSString* retNS = GNetopSBank_Instance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark ------
#pragma mark -------------------getClientChannel--------------------------
const std::string libGNetopSBank::getClientChannel(){
    return "ios_gnetop_jp";
}

#pragma mark ------
#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libGNetopSBank::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libGNetopSBank::notifyEnterGame(){
    
    GNetopSBank_Instance.isInGame = YES;
    UIView *window = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    NSString  *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleName = [NSString stringWithFormat:@"%@",[com4lovesSDK getServerInfo].playerName ];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    [[com4lovesSDK sharedInstance] notifyEnterGame];
}

bool libGNetopSBank::getIsTryUser(){
    return false;
}
void libGNetopSBank::callPlatformBindUser(){}
void libGNetopSBank::notifyGameSvrBindTryUserToOkUserResult(int result){}
void libGNetopSBank::OnKrGetInviteCount(){}
