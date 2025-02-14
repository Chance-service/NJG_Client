
//
//  libGNetop.cpp
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#include "libGNetop.h"
#include "libOS.h"
#import "libGNetopObj.h"
#import "GameCenterSDK.h"
//#include <com4lovesSDK.h>
#import "HuTuoServerInfo.h"
#import "GNetopSBankSharedManager.h"
#import "ShareSDKToDifPlatform.h"
#import "UIHelperAlert.h"


#define CHANGEUSERTIPS @"GameCenter ID すでに別のアカウントのリンク。あなたはこの口座に切り替えるか？"
#define CANCLE @"キャンセル"
#define CONFIRM @"確定"
#define GOTOGAMECENTER @"で、GameCenter持ってこそ、GameCenter ID 切り開いてくれるアナライズシステム哦!"
#define TipGameCneter @"登録点検している、GameCenterアカウントの登録が必要"

libGNetopObj* GNetop_Instance = 0;


SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libGNetop::initWithConfigure(const SDK_CONFIG_STU& configure){
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
    GNetop_Instance = [libGNetopObj new];
    [GNetop_Instance SNSInitResult:0];
    GNetop_Instance.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    //    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    //    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libGNetop::getLogined(){
    return [GNetop_Instance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libGNetop::login(){
    
    //获取包名
//    NSBundle *bundle = NSBundle.mainBundle;
//    NSDictionary *infoDictionary = bundle.infoDictionary;
//    NSString *bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
//    NSArray *bundeIdArray =  [bundeIdentifier componentsSeparatedByString:@"."];
//    NSString *channelName = (NSString*)[bundeIdArray objectAtIndex:[bundeIdArray count]-1];
//    NSString* tempAccount = [com4lovesSDK getPropertyFromIniFile:@"TempAccount" andAttr:channelName];
//    NSLog(@"%s--tempAccount-%@",__FUNCTION__,tempAccount);

    NSLog(@"%s---GNetop_Instance.userid-%@",__FUNCTION__,GNetop_Instance.userid);
    if(!this->getLogined()){
        
        NSString* isReview = [com4lovesSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
        if ([isReview isEqualToString:@"1"]) {
            NSLog(@"%s---11111111111111111111111111111--",__FUNCTION__);
            if (![GKLocalPlayer localPlayer].isAuthenticated && GNetop_Instance.userid == nil) {
                [UIHelperAlert ShowAlertMessage:nil message:[com4lovesSDK getLang:@"TipGameCenter"]];
                }
        
//            //        每次启动游戏时调用登录游戏接口
//            [[GameCenterSDK GameCenterSharedSDK] loginGameByGameCenter];

        }else{
            NSLog(@"%s---0000000000-GNetop_Instance.isShowAlaterGC-%@",__FUNCTION__,GNetop_Instance.isShowAlaterGC?@"true":@"false");
            if (![GKLocalPlayer localPlayer].isAuthenticated && GNetop_Instance.userid == nil && GNetop_Instance.isShowAlaterGC) {
                [UIHelperAlert ShowAlertMessage:nil message:[com4lovesSDK getLang:@"TipGameCenter"]];
            }
        }

        
    }
    
}

#pragma mark ------
#pragma mark -------------------logout--------------------------
void libGNetop::logout(){
    NSLog(@"%s---before---logout-%@",__FUNCTION__,GNetop_Instance.userid);
//    GNetop_Instance.userid = nil;
    NSLog(@"%s---after---logout-%@",__FUNCTION__,GNetop_Instance.userid);
    
}
#pragma mark ------
#pragma mark -------------------switchUsers--------------------------
void libGNetop::switchUsers(){
    
    //    logout();//先注销一下再跳到r2登陆界面
    if(!this->getLogined()){
    }
    
}
#pragma mark ------------------------------- login parts ----------------------------------

#pragma mark ------
#pragma mark ------------------------------- purchage parts ----------------------------------

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libGNetop::buyGoods(BUYINFO& info){
    
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
    NSString *aUserID = GNetop_Instance.userid,
    *aPlayerID = uin,
    *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleLevel = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].lvl ],
    *aRoleName = [com4lovesSDK getServerInfo].playerName,
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
    
    if (isOnpenThirdPay && [isOnpenThirdPay isEqualToString:@"0"]) {
        //内购
        [[com4lovesSDK sharedInstance] setFinalYouaiID:aPlayerID];//playerId = gnetop_1348039732
        [[com4lovesSDK sharedInstance] appStoreBuy:productId serverID:aServerCode totalFee:productPrice orderId:orderId];
        
//        [[com4lovesSDK sharedInstance] appStoreBuy:productId serverID:aServerCode totalFee:productPrice orderId:orderId puid:aPlayerID];

    }else{
        //软银支付
        /**
         * @payMethod       付款方式  (Credit3d,信用卡、银行卡等，空白为多种)
         * @payTestModel    充值模式设定类型   0:测试   1:正式
         **/
        [[GNetopSBankSharedManager shareSBankManager] showSBPaymentViewBuyForOrderId:orderId customId:aUserID productId:productId productName:productName taxMoney:@"0" amount:[NSString stringWithFormat:@"%d",(int)productPrice] payRequestDate:serverTime serverCode:aServerCode roleId:aPlayerID currencyType:@"JP" payMethod:@"" payTestModel:1];
    }
    

    
    
    
}

#pragma mark ------
#pragma mark ----------------------------- platfrom tool -------------------------------------
void libGNetop::openBBS(){
    
    [GNetop_Instance onPresent];
    
}

void libGNetop::userFeedBack(){
    
    /*
     http://mobile?game=EZ%20PZ%20RPG&userid="
     + yaLastLoginHelp.mPuid + "&gameid=242&server="
     + yaLastLoginHelp.mServerID + "&role="
     + yaLastLoginHelp.mPlayerName + "&mail=");
     */
    [[com4lovesSDK sharedInstance] showSdkFeedBackWithUserName:
     [NSString stringWithFormat:@"%@&serverID=%d",[com4lovesSDK getServerInfo].playerName ,[com4lovesSDK getServerInfo].serverID]];
    NSString *r2_url = [NSString stringWithFormat:@"http:///index/mobile?game=EZ%%20PZ%%20RPG&userid=%@&gameid=242&server=%d&role=%@&mail=",GNetop_Instance.userid,[com4lovesSDK getServerInfo].serverID,[com4lovesSDK getServerInfo].playerName];
    NSString *converstString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)r2_url, nil, nil, kCFStringEncodingUTF8);
    NSLog(@"GM---url--\n%@",converstString);
    NSLog(@"GM---url--\n%@",r2_url);
    [[com4lovesSDK sharedInstance] showWeb:r2_url];
    
}
void libGNetop::gamePause(){
    
}
const std::string& libGNetop::getToken(){
    static std::string _token;
    _token = [yougu_Instance.token UTF8String];
    return _token;
}
void libGNetop::setToolBarVisible(bool isShow){
    
}
#pragma mark ------
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libGNetop::loginUin(){
    static std::string retStr = "";
    
    NSString* retNS = GNetop_Instance.userid;
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
const std::string& libGNetop::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libGNetop::nickName(){
    
    NSString* retNS = GNetop_Instance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark ------
#pragma mark -------------------getClientChannel--------------------------
const std::string libGNetop::getClientChannel(){
    
//#if PROJECT_GNETOPSPECIAL
//    return "ios_gnetopSpecial_jp";
//#elif PROJECT_GNETOP
//    return "ios_gnetop_jp";
//#else
//    return "ios_gnetop_jp";
//#endif
    return "ios_gnetop_jp";
}

#pragma mark ------
#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libGNetop::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libGNetop::notifyEnterGame(){
    
    GNetop_Instance.isInGame = YES;
    UIView *window = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    NSString  *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleName = [NSString stringWithFormat:@"%@",[com4lovesSDK getServerInfo].playerName ];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    [[com4lovesSDK sharedInstance] notifyEnterGame];
}

bool libGNetop::getIsTryUser(){
    return false;
}
void libGNetop::callPlatformBindUser(){}
void libGNetop::notifyGameSvrBindTryUserToOkUserResult(int result){}
void libGNetop::OnKrGetInviteCount(){}
