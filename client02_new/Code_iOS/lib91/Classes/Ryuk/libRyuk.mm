
//
//  libRyuk.cpp
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#include "libRyuk.h"
#include "libOS.h"
#import "libRyukObj.h"
#import "GameCenterSDK.h"
//#include <com4lovesSDK.h>
#import "HuTuoServerInfo.h"
#import "ShareSDKToDifPlatform.h"
#import "UIHelperAlert.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "RyukExpand.h"
#import "JSON.h"
#import "FCUUID.h"
#import "SDKUtility.h"
#import <AdSupport/ASIdentifierManager.h>

#define CHANGEUSERTIPS @"GameCenter ID すでに別のアカウントのリンク。あなたはこの口座に切り替えるか？"
#define CANCLE @"キャンセル"
#define CONFIRM @"確定"
#define GOTOGAMECENTER @"で、GameCenter持ってこそ、GameCenter ID 切り開いてくれるアナライズシステム哦!"
#define TipGameCneter @"登録点検している、GameCenterアカウントの登録が必要"

#define TIP_STARTGAME_ERROR @"登録失敗"
#define TIP_GCACCOUNT_NOMATCH @"ログインしているアカウントが連携されているものと異なります アカウントを切り替えてください"

#define BIND_GC @"BINDGC"

libRyukObj* Ryuk_Instance = 0;
RyukExpand* RyukExpandInstance = 0;

static bool isRelogin = false;
static bool isCalledGameCenter = false;

static bool isEnterLogin = false;       //是否走了libRyuk::login()
static bool isTmpAccountLogin = false;  //是否是临时帐号登录回调
static bool isGCAccountLogin = false;   //是否是GC帐号登录回调
static bool isStartScheduleLogin = false;//是否开启了登录GC的schedule
SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libRyuk::initWithConfigure(const SDK_CONFIG_STU& configure){
    sdkConfigure = configure;
    //init com4lovesSDK
    NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    [comHuTuoSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [comHuTuoSDK  setAppId:yaappID];
    
    //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    Ryuk_Instance = [libRyukObj new];
    [Ryuk_Instance SNSInitResult:0];
    Ryuk_Instance.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    //    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    //    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
    NSString *id = [FCUUID uuidForDevice];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device systemVersion] floatValue] < 6.0) {
        
    }
    else{
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
            id = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    //NSString* md5Code = [[[[SDKUtility sharedInstance]md5HexDigest:id] uppercaseString] substringWithRange:NSMakeRange(8, 12)];
    //NSLog(@"md5Code : %@",md5Code);
    
    NSLog(@"udid in keychain %@", id);
    Ryuk_Instance.deviceid = id;
    
    RyukExpandInstance = [RyukExpand new];
}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libRyuk::getLogined(){
    return [Ryuk_Instance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libRyuk::login(){
    
    //获取包名
//    NSBundle *bundle = NSBundle.mainBundle;
//    NSDictionary *infoDictionary = bundle.infoDictionary;
//    NSString *bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
//    NSArray *bundeIdArray =  [bundeIdentifier componentsSeparatedByString:@"."];
//    NSString *channelName = (NSString*)[bundeIdArray objectAtIndex:[bundeIdArray count]-1];
//    NSString* tempAccount = [com4lovesSDK getPropertyFromIniFile:@"TempAccount" andAttr:channelName];
//    NSLog(@"%s--tempAccount-%@",__FUNCTION__,tempAccount);
    
    NSLog(@"%s---GNetop_Instance.userid-%@",__FUNCTION__,Ryuk_Instance.userid);
    //static int longinFailedCount = 0;
    if(!this->getLogined()){
//        NSString *id = [FCUUID uuidForDevice];
//        NSLog(@"udid in keychain %@", id);
//        Ryuk_Instance.deviceid = id;
        
        //NSString *str = [NSString stringWithFormat:@"http://8080/RedisServer/accountEnterRequest?puid=%@",id];
//        NSString *accountEnterRequest = [com4lovesSDK getPropertyFromIniFile:@"Account" andAttr:@"accountEnterRequest"];
//        if(accountEnterRequest == nil){
//            accountEnterRequest = @"http:///RedisServer/accountEnterRequest?puid=%@";
//        }
//        accountEnterRequest = @"http:///RedisServer/accountEnterRequest?puid=%@&platform=ios&pid=%@";
//

        isEnterLogin = true;
        libOS::getInstance()->setWaiting(true);
        if (![GKLocalPlayer localPlayer].isAuthenticated && [Ryuk_Instance.gcid isEqualToString:@""]) {
            
        }
        else{
            libOS::getInstance()->setWaiting(false);
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGINGC object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:Ryuk_Instance.gcid,@"result",nil]];
            return;
        }
        if(isGCAccountLogin){
            libOS::getInstance()->setWaiting(false);
            [Ryuk_Instance RequestAccountServer:Ryuk_Instance.deviceid gcID:Ryuk_Instance.gcid];
        }
        else{//等待GC登录6s钟 如果未等到，则用设备码登录，如果等到了，则用GC登录
            isStartScheduleLogin = true;
            [Ryuk_Instance startScheduleLogin];
            //[Ryuk_Instance RequestAccountServer:Ryuk_Instance.deviceid gcID:Ryuk_Instance.gcid];
        }

        /*
        libOS::getInstance()->setWaiting(true);
        if(not isCalledGameCenter){
            //先检查GC有没有登录
            [[GameCenterSDK GameCenterSharedSDK] loginGameByGameCenter];
            isCalledGameCenter = true;
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGINGC object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:Ryuk_Instance.gcid,@"result",nil]];
        }
        */
        /*
        libOS::getInstance()->setWaiting(true);
        NSString *str = [NSString stringWithFormat:accountEnterRequest,id];
        NSString* data = [[SDKUtility sharedInstance]httpPost:str postData:nil md5check:nil];
        NSLog(@"receive data = %@",data);
        if(data){
            NSArray *array = [data componentsSeparatedByString:@"|"];
            if([array count] >= 6){
                
                NSString *ok = array[0];    //成功标志 1 成功 0 失败
                NSString *error = array[1]; //失败原因 0 没有原因 成功 1 puid不合法
                NSString *isNew = array[2]; //是否新账号 1 是 2 否
                NSString *bindGcid = array[3];  //绑定的gamecenter帐号
                NSString *bindGpid = array[4];  //绑定的googleplay帐号
                NSString *code = array[5];  //code值
                //bindGcid = @"1688566986";
                Ryuk_Instance.bindGcid = bindGcid;
                Ryuk_Instance.code = code;
                
                if([ok isEqualToString:@"1"]){//成功
                    if([bindGcid isEqualToString:@""]){ //未绑定GC帐号 直接登录
                        [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:code ,@"result",nil]];
                        libOS::getInstance()->setWaiting(false);
                    }
                    else{   //绑定GC帐号 去登录GC
                        libOS::getInstance()->setWaiting(false);
                        if([Ryuk_Instance.gcid isEqualToString:@""]){
                            //如果弹不出GC登录界面，提示从后台登录GC
                            [[GameCenterSDK GameCenterSharedSDK] loginGameByGameCenter];
                        }
                        else{
                            NSLog(@"need change GameCenter account.");
                            [UIHelperAlert ShowAlertMessage:nil message:TIP_GCACCOUNT_NOMATCH];
                        }
                    }
                }
                else {
                    if([error isEqualToString:@"1"]){
                        NSLog(@"puid error");
                    }
                    libOS::getInstance()->setWaiting(false);
                    [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR];
                }
            }
            else {
                longinFailedCount++;
                libOS::getInstance()->setWaiting(false);
                [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR];
            }
        }
        else{
            longinFailedCount++;
            libOS::getInstance()->setWaiting(false);
            [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR];
        }
        if(longinFailedCount >=3){  //登录多次失败后，通过客户端计算code码来登录
            NSString* md5Code = [[[[SDKUtility sharedInstance]md5HexDigest:Ryuk_Instance.deviceid] uppercaseString] substringWithRange:NSMakeRange(8, 12)];
            NSLog(@"md5Code : %@",md5Code);
            Ryuk_Instance.code = md5Code;
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:Ryuk_Instance.code ,@"result",nil]];
            //libPlatformManager::getPlatform()->_boardcastLoginResult(true, [Ryuk_Instance.code UTF8String]);
            longinFailedCount = 0;
        }
        
        */
    }
    else if(isRelogin){
        if(![Ryuk_Instance.code isEqualToString:@""]){
            //libPlatformManager::getPlatform()->_boardcastLoginResult(true, [Ryuk_Instance.code UTF8String]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:Ryuk_Instance.code ,@"result",nil]];
        }
        isRelogin = false;
    }
    
}

#pragma mark ------
#pragma mark -------------------logout--------------------------
void libRyuk::logout(){
    NSLog(@"%s---before---logout-%@",__FUNCTION__,Ryuk_Instance.userid);
//    GNetop_Instance.userid = nil;
    NSLog(@"%s---after---logout-%@",__FUNCTION__,Ryuk_Instance.userid);
    
}
#pragma mark ------
#pragma mark -------------------switchUsers--------------------------
void libRyuk::switchUsers(){
    
    //    logout();//先注销一下再跳到r2登陆界面
    if(!this->getLogined()){
        
    }
    isRelogin = true;
}

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libRyuk::buyGoods(BUYINFO& info){
    
    if(info.cooOrderSerial==""){
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NSString *productId = [NSString stringWithUTF8String:info.productId.c_str()];
    NSString *productName = [NSString stringWithUTF8String:info.productName.c_str()];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    int zoneID = 0;
    sscanf(info.description.c_str(),"%d",&zoneID);
    NSString *orderId = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    NSString *aUserID = Ryuk_Instance.userid,
    *aPlayerID = uin,
    *aServerCode = [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].serverID ],
    *aRoleLevel = [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].lvl ],
    *aRoleName = [comHuTuoSDK getServerInfo].playerName,
    *aProductID=productId;
    float productPrice = info.productPrice;
    NSLog(@"--productPrice--%.2f",productPrice);
    int  serverTime  = info.serverTime;
    
    NSLog(@"\n--aProductID=%@\n--aUserID=%@\n--aPlayerID=%@\n--aServerCode==%@\n--aRoleLevel==%@\n--aRoleName==%@\n--orderId==%@\n--productName==%@",aProductID,aUserID,aPlayerID,aServerCode,aRoleLevel,aRoleName,orderId,productName);
    /**
     如果本游戏未被从AppStore下架或者苹果内购依旧可以使用则用第一个内购
     否则使用日本软银支付
     **/
    //NSString* isOnAppstore = [com4lovesSDK getPropertyFromIniFile:@"OnAppstore" andAttr:@"onappstore"];
    //获取扩展参数
    NSString *extras = [NSString stringWithUTF8String:info.extras.c_str()];
    NSArray *extrasArray = [extras componentsSeparatedByString:@","];
    
    NSString *isOnpenThirdPay = [extrasArray count]>0?[extrasArray objectAtIndex:0]:@"0";
    
    //if (isOnpenThirdPay && [isOnpenThirdPay isEqualToString:@"0"]) {
        //内购
        [[comHuTuoSDK sharedInstance] setFinalHuTuoID:aPlayerID];//playerId = gnetop_1348039732
        [[comHuTuoSDK sharedInstance] appStoreBuy:productId serverID:aServerCode totalFee:productPrice orderId:orderId];
    
    sendMessageP2G("G2P_TOUCHRECHARGE", "click_" + info.productId);
    //NSString* token = @"7db0g7";
    //[[ShareSDKToDifPlatform shareSDKPlatform] setTrackingLevelByToken:token];
    //NSLog(@"--------------sendMessageP2G:----------G2P_RECORDING_ADJUST_EVENT----token:%@",token);
    
}

#pragma mark ------
#pragma mark ----------------------------- platfrom tool -------------------------------------
void libRyuk::openBBS(){
    
    [Ryuk_Instance onPresent];
    
}

void libRyuk::userFeedBack(){
    
    /*
     http://index/mobile?game=EZ%20PZ%20RPG&userid="
     + yaLastLoginHelp.mPuid + "&gameid=242&server="
     + yaLastLoginHelp.mServerID + "&role="
     + yaLastLoginHelp.mPlayerName + "&mail=");
     */
//    [[com4lovesSDK sharedInstance] showSdkFeedBackWithUserName:
//     [NSString stringWithFormat:@"%@&serverID=%d",[com4lovesSDK getServerInfo].playerName ,[com4lovesSDK getServerInfo].serverID]];
//    NSString *r2_url = [NSString stringWithFormat:@"http:///index/mobile?game=EZ%%20PZ%%20RPG&userid=%@&gameid=242&server=%d&role=%@&mail=",Ryuk_Instance.userid,[com4lovesSDK getServerInfo].serverID,[com4lovesSDK getServerInfo].playerName];
//    NSString *converstString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)r2_url, nil, nil, kCFStringEncodingUTF8);
//    NSLog(@"GM---url--\n%@",converstString);
//    NSLog(@"GM---url--\n%@",r2_url);
//    [[com4lovesSDK sharedInstance] showWeb:r2_url];
    
}
void libRyuk::gamePause(){
    
}

void libRyuk::setToolBarVisible(bool isShow){
    
}
#pragma mark ------
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libRyuk::loginUin(){
    static std::string retStr = "";
    
    NSString* retNS = Ryuk_Instance.userid;
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
const std::string& libRyuk::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libRyuk::nickName(){
    
    NSString* retNS = Ryuk_Instance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark ------
#pragma mark -------------------getClientChannel--------------------------
const std::string libRyuk::getClientChannel(){
    
    return sdkConfigure.com4lovesconfig.platformid ;//"ios_ryuk_jp";
}

#pragma mark ------
#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libRyuk::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libRyuk::notifyEnterGame(){
    
    Ryuk_Instance.isInGame = YES;
    UIView *window = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    NSString  *aServerCode = [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].serverID ],
    *aRoleName = [NSString stringWithFormat:@"%@",[comHuTuoSDK getServerInfo].playerName ];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    [[comHuTuoSDK sharedInstance] notifyEnterGame];
}

bool libRyuk::getIsTryUser(){
    return false;
}
void libRyuk::callPlatformBindUser(){}
void libRyuk::notifyGameSvrBindTryUserToOkUserResult(int result){}
void libRyuk::OnKrGetInviteCount(){}
//G2P means Game to Platform
std::string libRyuk::sendMessageG2P(const std::string& tag, const std::string& msg){
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"tag---->%@----msg--->%@",[NSString stringWithUTF8String:tag.c_str()],[NSString stringWithUTF8String:msg.c_str()]);
    
    if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_FACEBOOK_SHARE"]) {
        NSString *askMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveAskDic = [parser objectWithString:askMsg];
        NSString *picture = [receiveAskDic valueForKey:@"picture"];
        NSString *caption = [receiveAskDic valueForKey:@"caption"];
        NSDictionary* postDic = @{@"picture":picture,
                                    @"caption":caption};
        [RyukExpandInstance FBSharePhoto:postDic];

        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_SEND_EMAIL"]) {
        NSString *Msg = [NSString stringWithUTF8String:msg.c_str()];
        [RyukExpandInstance sendEmail:Msg];
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_GET_BIND_STATE"]) {
        NSString *ret;
        if([Ryuk_Instance.bindGcid isEqualToString:@""]){//未绑定
            ret = @"false";
        }else{
            ret = @"true";
        }
        NSLog(@"--------------sendMessageP2G:----------P2G_GET_BIND_STATE----%@",ret);
        
        return libPlatformManager::getPlatform()->sendMessageP2G("P2G_GET_BIND_STATE",[ret UTF8String]);
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_BIND_GC_GP"]) {
        libOS::getInstance()->setWaiting(true);
        [[NSNotificationCenter defaultCenter] postNotificationName:BIND_GC object:nil];
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_EnterMainScene"]) {
        if(msg == "true"){
            Ryuk_Instance.isInMainScene = YES;
        }
        else{
            Ryuk_Instance.isInMainScene = NO;
        }
        
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ACCOUNT_LOGIN"]) {
        if(isEnterLogin){
            libOS::getInstance()->setWaiting(false);
            if(isStartScheduleLogin){
                [Ryuk_Instance endScheduleLogin];
                isStartScheduleLogin = false;
                [Ryuk_Instance RequestAccountServer:Ryuk_Instance.deviceid gcID:Ryuk_Instance.gcid];
            }
            else{
                [Ryuk_Instance RequestAccountServer:Ryuk_Instance.deviceid gcID:Ryuk_Instance.gcid];
            }
        }
        else{
            
            if(msg == "true"){
                isGCAccountLogin = true;
            }
            else{
                isTmpAccountLogin = true;
            }
        }
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_RECORDING_ADJUST_EVENT"]) {
        NSString *askMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveAskDic = [parser objectWithString:askMsg];
        NSString *token = [receiveAskDic valueForKey:@"token"];

        [[ShareSDKToDifPlatform shareSDKPlatform] setTrackingLevelByToken:token];
        NSLog(@"--------------sendMessageP2G:----------G2P_RECORDING_ADJUST_EVENT----token:%@",token);
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_RECORDING_ADJUST_EVENT_FIRST_RECHARGE"]) {
        NSString *askMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveAskDic = [parser objectWithString:askMsg];
        NSString *token = [receiveAskDic valueForKey:@"token"];
        NSString *priceStr = [receiveAskDic valueForKey:@"price"];
        float price = [priceStr floatValue];
        NSLog(@"--------------sendMessageP2G:----------G2P_RECORDING_ADJUST_EVENT_FIRST_RECHARGE----token:%@,price:%@",token,priceStr);
        //[[ShareSDKToDifPlatform shareSDKPlatform] setTrackingLevelByToken:token];
        [[ShareSDKToDifPlatform shareSDKPlatform] setInAppPurchase:(double)price currency:@"JPY" differentToken:token transactionId:@""];
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_CHANGE_USER"]) {
        if(msg == "true"){
            Ryuk_Instance.code = Ryuk_Instance.newCode;
            Ryuk_Instance.gcid = Ryuk_Instance.newBindGcid;
            Ryuk_Instance.bindGcid = Ryuk_Instance.newBindGcid;
        }
        else{
            
        }
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_SET_ADJUST_CROPRO"]) {
        NSString *recMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveDic = [parser objectWithString:recMsg];
        NSString *token = [receiveDic valueForKey:@"token"];
        NSString *cpn = [receiveDic valueForKey:@"cpn"];
        NSString *pid = [receiveDic valueForKey:@"pid"];
        NSLog(@"--------------sendMessageP2G:----------G2P_SET_ADJUST_CROPRO----token %@ cpn %@ pid %@",token,cpn,pid);
        [[ShareSDKToDifPlatform shareSDKPlatform] setAdjustCroPro:token cpn:cpn pid:pid];
    }else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_CROPRO_COUNT"]) {
        NSString *recMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveDic = [parser objectWithString:recMsg];
        NSString *url = [receiveDic valueForKey:@"url"];
        NSString *cid = [receiveDic valueForKey:@"cid"];
        NSString *start = [receiveDic valueForKey:@"startAt"];
        NSString *end = [receiveDic valueForKey:@"endAt"];
        NSString *hashKey = [receiveDic valueForKey:@"hashKey"];
        NSLog(@"--------------sendMessageP2G:----------G2P_CROPRO_COUNT----url:%@ cpn:%@ start:%@ end:%@ hashKey:%@",url,cid,start,end,hashKey);
        [Ryuk_Instance getCroproCount:url cId:cid startAt:start endAt:end key:hashKey];
    }
    else {
        return sendMessageP2G(tag, msg);
    }
    return sendMessageP2G(tag, msg);
}
