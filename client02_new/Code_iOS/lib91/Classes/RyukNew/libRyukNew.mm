
//
//  libRyukNew.cpp
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#include "libRyukNew.h"
#include "libOS.h"
#import "libRyukNewObj.h"
#import "GameCenterSDK.h"
//#include <com4lovesSDK.h>
#import "HuTuoServerInfo.h"
//#import "GNetopSBankSharedManager.h"
#import "ShareSDKToDifPlatform.h"
#import "UIHelperAlert.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "RyukNewExpand.h"
#import "JSON.h"
#import "FCUUID.h"
#import "SDKUtility.h"
#import <AdSupport/ASIdentifierManager.h>
#import "KeyChainData.h"

#define CHANGEUSERTIPS @"GameCenter ID すでに別のアカウントのリンク。あなたはこの口座に切り替えるか？"
#define CANCLE @"取消"
#define CONFIRM @"確定"
#define GOTOGAMECENTER @"で、GameCenter持ってこそ、GameCenter ID 切り開いてくれるアナライズシステム哦!"
#define TipGameCneter @"登録点検している、GameCenterアカウントの登録が必要"

#define TIP_STARTGAME_ERROR @"登録失敗"
#define TIP_GCACCOUNT_NOMATCH @"ログインしているアカウントが連携されているものと異なります アカウントを切り替えてください"

#define BIND_GC @"BINDGC"

libRyukNewObj* mRyukNewObjInstance = 0;
RyukNewExpand* RyukNewExpandInstance = 0;

static bool isRelogin = false;
static bool isCalledGameCenter = false;

static bool isEnterLogin = false;       //是否走了libRyuk::login()
static bool isTmpAccountLogin = false;  //是否是临时帐号登录回调
static bool isGCAccountLogin = false;   //是否是GC帐号登录回调
static bool isStartScheduleLogin = false;//是否开启了登录GC的schedule
SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libRyukNew::initWithConfigure(const SDK_CONFIG_STU& configure){
    sdkConfigure = configure;
    //init com4lovesSDKs
    //NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() //encoding:NSASCIIStringEncoding];
    //NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() //encoding:NSASCIIStringEncoding];
    //NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() //encoding:NSASCIIStringEncoding];
    //NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() //encoding:NSASCIIStringEncoding];
    //NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() //encoding:NSASCIIStringEncoding];
    //[comHuTuoSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    //[comHuTuoSDK  setAppId:yaappID];
    
    //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    mRyukNewObjInstance = [libRyukNewObj new];
    [mRyukNewObjInstance SNSInitResult:0];
    mRyukNewObjInstance.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    //    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    //    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
    NSString *tempdvid = [FCUUID uuidForDevice];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device systemVersion] floatValue] < 6.0) {
        
    }	
    else{
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled] ){
            tempdvid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    //NSString* md5Code = [[[[SDKUtility sharedInstance]md5HexDigest:id] uppercaseString] substringWithRange:NSMakeRange(8, 12)];
    //NSLog(@"md5Code : %@",md5Code);
    //253989
    NSLog(@"udid in tempdvid %@", tempdvid);
    mRyukNewObjInstance.deviceid = tempdvid;
    //NSString* flagvalues = [comHuTuoSDK getPropertyFromPublicIniFile:@"deviceId" andAttr:@"deviceIdFlag"];
    //if(flagvalues != nil)
    //{
    //    NSLog(@"my KeyChainData flagvalues: %@", flagvalues);
    //    if([flagvalues isEqualToString:@"1"]){
    //        NSString *grop = @"2WLZ3CD2G8.jp.co.school.battle.keychainshare";
    //        NSString *keyItem = @"YAHDDVID";
    //        NSString *qData = [KeyChainData getDataFromKeyChain:keyItem grop:grop];
    //        if(qData!=nil){
    //            NSLog(@"my KeyChainData qData: %@", qData);
    //            mRyukNewObjInstance.deviceid = qData;
    //        }
    //        else{
    //            [KeyChainData setDataToKeyChain:mRyukNewObjInstance.deviceid Key:keyItem grop:grop ];
    //        }
    //    }
    //}
    [[NSUserDefaults standardUserDefaults] setObject:mRyukNewObjInstance.deviceid forKey:@"CurrentDevicesId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if(!RyukNewExpandInstance)
    {
          RyukNewExpandInstance = [RyukNewExpand new];
    }
}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libRyukNew::getLogined(){
    return [mRyukNewObjInstance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libRyukNew::login(){
    
    //获取包名
//    NSBundle *bundle = NSBundle.mainBundle;
//    NSDictionary *infoDictionary = bundle.infoDictionary;
//    NSString *bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
//    NSArray *bundeIdArray =  [bundeIdentifier componentsSeparatedByString:@"."];
//    NSString *channelName = (NSString*)[bundeIdArray objectAtIndex:[bundeIdArray count]-1];
//    NSString* tempAccount = [com4lovesSDK getPropertyFromIniFile:@"TempAccount" andAttr:channelName];
//    NSLog(@"%s--tempAccount-%@",__FUNCTION__,tempAccount);
    
    NSLog(@"%s---GNetop_Instance.userid-%@",__FUNCTION__,mRyukNewObjInstance.userid);
    //static int longinFailedCount = 0;
    if(!this->getLogined()){
        isEnterLogin = true;
        libOS::getInstance()->setWaiting(true);
        if (![GKLocalPlayer localPlayer].isAuthenticated && [mRyukNewObjInstance.gcid isEqualToString:@""]) {
            
        }
        else{
            libOS::getInstance()->setWaiting(false);
            NSString* gcid = [[GameCenterSDK GameCenterSharedSDK] getGcId];
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGINGC object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:gcid,@"result",nil]];
            
            
            //[[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"12345678" ,@"result",nil]];
            return;
        }
        if(isGCAccountLogin){
            libOS::getInstance()->setWaiting(false);
            [mRyukNewObjInstance RequestAccountServer:mRyukNewObjInstance.deviceid gcID:mRyukNewObjInstance.gcid];
        }
        else{//等待GC登录6s钟 如果未等到，则用设备码登录，如果等到了，则用GC登录
            isStartScheduleLogin = true;
            [mRyukNewObjInstance startScheduleLogin];
        }

    }
    else if(isRelogin){
        if(![mRyukNewObjInstance.code isEqualToString:@""]){
            //libPlatformManager::getPlatform()->_boardcastLoginResult(true, [RyukNew_Instance.code UTF8String]);
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:mRyukNewObjInstance.code ,@"result",nil]];
            
            
//             [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"123456" ,@"result",nil]];
        }
        isRelogin = false;
    }
    
}
//void libRyukNew::payClick(){
//    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"请输入支付密码" preferredStyle:UIAlertControllerStyleAlert];
//    [alertControlleraddAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];    [alertControlleraddAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { UITextField*userNameTextField = alertController.textFields.firstObject;
//        NSLog(@"支付密码：%@",userNameTextField.text);
//
//    }]];
//    [alertControlleraddTextFieldWithConfigurationHandler:^(UITextField*_NonnulltextField) {
//        textField.placeholder=@"请输入支付密码";
//        textField.secureTextEntry=YES;
//
//    }];
//    [self presentViewController:alertController animated:YES completion:nil];
//
//}
#pragma mark ------
#pragma mark -------------------logout--------------------------
void libRyukNew::logout(){
    NSLog(@"%s---before---logout-%@",__FUNCTION__,mRyukNewObjInstance.userid);
//    GNetop_Instance.userid = nil;
    NSLog(@"%s---after---logout-%@",__FUNCTION__,mRyukNewObjInstance.userid);
    
}
#pragma mark ------
#pragma mark -------------------switchUsers--------------------------
void libRyukNew::switchUsers(){
    
    //    logout();//先注销一下再跳到r2登陆界面
    if(!this->getLogined()){
        
    }
    isRelogin = true;
}

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libRyukNew::buyGoods(BUYINFO& info){
    
    if(info.cooOrderSerial==""){
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NSString *productId = [NSString stringWithUTF8String:info.name.c_str()];
    
    NSString *productName = [NSString stringWithUTF8String:info.productName.c_str()];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    int zoneID = 0;
    sscanf(info.description.c_str(),"%d",&zoneID);
    //NSString *orderId = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    //NSString *aUserID = mRyukNewObjInstance.userid,
    //*aPlayerID = uin,
    //*aProductID=productId;
    float productPrice = info.productPrice;
    NSLog(@"--productPrice--%.2f",productPrice);
    int  serverTime  = info.serverTime;
    
    //NSLog(@"\n--aProductID=%@\n--aUserID=%@\n--aPlayerID=%@\n--aServerCode==%@\n--aRoleLevel==%@\n--//aRoleName==%@\n--orderId==%@\n--//productName==%@",aProductID,aUserID,aPlayerID,aServerCode,aRoleLevel,aRoleName,orderId,productName);

    
    sendMessageP2G("G2P_TOUCHRECHARGE", "click_" + info.productId);
    
}

#pragma mark ------
#pragma mark ----------------------------- platfrom tool -------------------------------------
void libRyukNew::openBBS(){
    
    [mRyukNewObjInstance onPresent];
    
}

void libRyukNew::userFeedBack(){

    
}
void libRyukNew::gamePause(){
    
}

void libRyukNew::setToolBarVisible(bool isShow){
    
}
#pragma mark ------
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libRyukNew::loginUin(){
    static std::string retStr = "";
    
    NSString* retNS = mRyukNewObjInstance.userid;
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix + retStr;
    }
    //retStr = "sg_3FE00749DBB1";
    return retStr;
    
}

const std::string& libRyukNew::getToken(){
    static std::string _session("");

    return _session;
}

#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libRyukNew::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libRyukNew::nickName(){
    
    NSString* retNS = mRyukNewObjInstance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark ------
#pragma mark -------------------getClientChannel--------------------------
const std::string libRyukNew::getClientChannel(){
    
    return sdkConfigure.com4lovesconfig.platformid ;//"ios_ryuk_jp";
}

#pragma mark ------
#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libRyukNew::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libRyukNew::notifyEnterGame(){
    
    mRyukNewObjInstance.isInGame = YES;
    UIView *window = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    //NSString  *aServerCode = [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].serverID ],
    //*aRoleName = [NSString stringWithFormat:@"%@",[comHuTuoSDK getServerInfo].playerName ];
    //NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    //[[comHuTuoSDK sharedInstance] notifyEnterGame];
}

bool libRyukNew::getIsTryUser(){
    return false;
}
void libRyukNew::updateApp(std::string &storeUrl)
{
    NSString* str = [NSString stringWithCString:storeUrl.c_str() encoding:[NSString defaultCStringEncoding]];
    NSURL *url = [NSURL URLWithString:str];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"URL opened successfully");
            } else {
                NSLog(@"Failed to open URL");
            }
        }];
    }
}
void libRyukNew::callPlatformBindUser(){}
void libRyukNew::notifyGameSvrBindTryUserToOkUserResult(int result){}
void libRyukNew::OnKrGetInviteCount(){}
//G2P means Game to Platform
std::string libRyukNew::sendMessageG2P(const std::string& tag, const std::string& msg){
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
        [RyukNewExpandInstance FBSharePhoto:postDic];

        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_SEND_EMAIL"]) {
        NSString *Msg = [NSString stringWithUTF8String:msg.c_str()];
        if(!RyukNewExpandInstance)
        {
            RyukNewExpandInstance = [RyukNewExpand new];
        }
        [RyukNewExpandInstance sendEmail:Msg];
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_GET_BIND_STATE"]) {
        NSString *ret;
        if([mRyukNewObjInstance.bindGcid isEqualToString:@""]){//未绑定
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
            mRyukNewObjInstance.isInMainScene = YES;
        }
        else{
            mRyukNewObjInstance.isInMainScene = NO;
        }
        
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ACCOUNT_LOGIN"]) {
        if(isEnterLogin){
            libOS::getInstance()->setWaiting(false);
            if(isStartScheduleLogin){
                [mRyukNewObjInstance endScheduleLogin];
                isStartScheduleLogin = false;
                [mRyukNewObjInstance RequestAccountServer:mRyukNewObjInstance.deviceid gcID:mRyukNewObjInstance.gcid];
            }
            else{
                [mRyukNewObjInstance RequestAccountServer:mRyukNewObjInstance.deviceid gcID:mRyukNewObjInstance.gcid];
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
        [[ShareSDKToDifPlatform shareSDKPlatform] sendTrackEventXX:(double)price currency:@"JPY" differentToken:token transactionId:@""];
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_CHANGE_USER"]) {
        if(msg == "true"){
            mRyukNewObjInstance.code = mRyukNewObjInstance.newCode;
            mRyukNewObjInstance.gcid = mRyukNewObjInstance.newBindGcid;
            mRyukNewObjInstance.bindGcid = mRyukNewObjInstance.newBindGcid;
        }
        else{
            
        }
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_SET_ADJUST_CROPRO"]) {//请求联携
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
        [mRyukNewObjInstance getCroproCount:url cId:cid startAt:start endAt:end key:hashKey];
    }else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_SHOW_TOAST"]) {//提示Tips
        NSString *recMsg = [NSString stringWithUTF8String:msg.c_str()];
        NSLog(@"--------------sendMessageP2G:----------G2P_SHOW_TOAST----mes:%@",recMsg);
        [UIHelperAlert ShowAlertMessage:nil message:recMsg];
    }else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_DATA_TRANSFER"]) {//请求数据移行
        NSString *recMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveDic = [parser objectWithString:recMsg];
        NSString *code = [receiveDic valueForKey:@"code"];
        NSString *pwd = [receiveDic valueForKey:@"pwd"];
        NSLog(@"--------------sendMessageP2G:----------G2P_DATA_TRANSFER----code:%@ pwd:%@",code,pwd);
        [mRyukNewObjInstance changeCode:code pWd:pwd];
    }else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_CHANGE_PWD"]) {//请求修改移行码
        NSString *recMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveDic = [parser objectWithString:recMsg];
        NSString *pwd = [receiveDic valueForKey:@"pwd"];
        NSLog(@"--------------sendMessageP2G:----------G2P_CHANGE_PWD----pwd:%@",pwd);
        [mRyukNewObjInstance changePwd:pwd];
    }
    else {
        return sendMessageP2G(tag, msg);
    }
    return sendMessageP2G(tag, msg);
}
