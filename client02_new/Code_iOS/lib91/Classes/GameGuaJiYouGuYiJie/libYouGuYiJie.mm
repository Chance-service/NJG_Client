
//
//  libRyukNew.cpp
//  lib91
//
//

#include "libYouGuYiJie.h"
#include "libOS.h"
#import "libYouGuObjYiJie.h"
#import "PlatformNotificationCode.h"
#import "HuTuoServerInfo.h"
#import "UIHelperAlert.h"
#import "JSON.h"
#import "FCUUID.h"
#import "SDKUtility.h"
#import <AdSupport/ASIdentifierManager.h>
#import "KeyChainData.h"
#import <comHuTuoSDK.h>
#import "OnlineAHelper/YiJieOnlineHelper.h"


#define CHANGEUSERTIPS @"GameCenter ID すでに別のアカウントのリンク。あなたはこの口座に切り替えるか？"
#define CANCLE @"取消"
#define CONFIRM @"確定"
#define GOTOGAMECENTER @"で、GameCenter持ってこそ、GameCenter ID 切り開いてくれるアナライズシステム哦!"
#define TipGameCneter @"登録点検している、GameCenterアカウントの登録が必要"

#define TIP_STARTGAME_ERROR @"登録失敗"
#define TIP_GCACCOUNT_NOMATCH @"ログインしているアカウントが連携されているものと異なります アカウントを切り替えてください"

#define BIND_GC @"BINDGC"

libYouGuObjYiJie* yougu_Instance = 0;

static bool isRelogin = false;
static bool isEnterLogin = false;       //是否走了libRyuk::login()
static bool isStartScheduleLogin = false;//是否开启了登录GC的schedule
SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libYouGuYiJie::initWithConfigure(const SDK_CONFIG_STU& configure){
    sdkConfigure = configure;

    //注册监听函数
    yougu_Instance = [libYouGuObjYiJie new];
    yougu_Instance.isReLogin = configure.platformconfig.bRelogin;
    
    // 初始化易接
    [YiJieOnlineHelper initSDKWithListener: yougu_Instance];
    
    NSString *tempdvid = [FCUUID uuidForDevice];
    UIDevice *device = [UIDevice currentDevice];
    if ([[device systemVersion] floatValue] >= 6.0){
        if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
            tempdvid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        }
    }
    
    yougu_Instance.deviceid = tempdvid;
    [[NSUserDefaults standardUserDefaults] setObject:yougu_Instance.deviceid forKey:@"CurrentDevicesId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libYouGuYiJie::getLogined(){
    return [yougu_Instance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libYouGuYiJie::login(){
    NSLog(@"%s---GNetop_Instance.userid-%@",__FUNCTION__,yougu_Instance.userid);
    if(!this->getLogined()){
        isEnterLogin = true;
        libOS::getInstance()->setWaiting(true);
        
        isStartScheduleLogin = true;
        [yougu_Instance startScheduleLogin];
    }
    else if(isRelogin){
        if(![yougu_Instance.code isEqualToString:@""]){
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:yougu_Instance.code ,@"result",nil]];
        }
        isRelogin = false;
    }
}

#pragma mark -------------------logout--------------------------
void libYouGuYiJie::logout(){

}

#pragma mark -------------------switchUsers--------------------------
void libYouGuYiJie::switchUsers(){
    isRelogin = true;
}

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libYouGuYiJie::buyGoods(BUYINFO& info){
    /*
    if (![[SYSDKPlatform getInstance] isLogined])
    {
        NSLog(@"未登录不能调用doPay");
        return;
    }
     */
    
    if(info.cooOrderSerial==""){
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    
    NSMutableDictionary *payInfo = [NSMutableDictionary dictionary];
    // productId     产品id
    payInfo[@"productId"] = [NSString stringWithUTF8String:info.productId.c_str()];
    
    // productName   产品名称
    payInfo[@"productName"] = [NSString stringWithUTF8String:info.productName.c_str()];

    // productDesc   产品描述
    payInfo[@"productDesc"] = [NSString stringWithUTF8String: info.description.c_str()];
    
    // productPrice  产品单价（元）
    payInfo[@"productPrice"] = [NSString stringWithFormat:@"%f", info.productPrice];
    
    // productCount  产品数量 (正常传 1 即可)
    payInfo[@"productCount"] = [NSString stringWithFormat:@"%d", info.productCount];
    
    NSString *extras =  [NSString stringWithUTF8String:info.extras.c_str()];
    NSData * getJsonData = [extras dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * extrasDict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:nil];
    
    // productType   产品类型 (0:普通   1:月卡   2:周卡   3:季卡   4:年卡   5:终身卡)
    payInfo[@"productType"] = [extrasDict objectForKey:@"productType"];
    
    // coinName      虚拟币名称（如：金币/钻石等）
    payInfo[@"coinName"] = @"金币";
    
    // coinRate      虚拟币比例 (如：10， 表示 1元人民币购买 10 虚拟币)
    payInfo[@"coinRate"] = @"200";
    
    NSString *name = [extrasDict objectForKey:@"name"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys: name,@"name", @"1", @"iOS",nil];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:kNilOptions error:nil];
    NSString *extenInfoStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    payInfo[@"extendInfo"] = extenInfoStr; // [NSString stringWithUTF8String:info.extras.c_str()];
    
    // roleId        角色Id
    payInfo[@"roleId"] = [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].playerID];
    
    // roleName      角色名
    payInfo[@"roleName"] = [comHuTuoSDK getServerInfo].playerName;
    
    // zonId         区服 Id
    payInfo[@"zoneId"] = [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].serverID];
    
    // zoneName      区服名称
    payInfo[@"zoneName"] = @"";
    
    // partyName     公会/帮派等
    payInfo[@"partyName"] = @"";
    
    // roleLevel     角色等级
    payInfo[@"roleLevel"] = [NSString stringWithFormat:@"%d",[comHuTuoSDK getServerInfo].lvl];
    
    // roleVipLevel  角色VIP等级
    payInfo[@"roleVipLevel"] = [NSString stringWithFormat:@"%d", [comHuTuoSDK getServerInfo].vipLvl];
    
    // balance       玩家游戏内虚拟币余额
    payInfo[@"balance"] = [NSString stringWithFormat:@"%d", [comHuTuoSDK getServerInfo].coin1];
    
    //[[SYSDKPlatform getInstance] doPay:payInfo];
}

#pragma mark ----------------------------- platfrom tool -------------------------------------
void libYouGuYiJie::openBBS(){
    [yougu_Instance onPresent];
}

void libYouGuYiJie::userFeedBack(){}
void libYouGuYiJie::gamePause(){}
void libYouGuYiJie::setToolBarVisible(bool isShow){}

#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libYouGuYiJie::loginUin(){
    static std::string _uid;
    _uid = [yougu_Instance.userid UTF8String];
    return _uid;
}

const std::string& libYouGuYiJie::getToken(){
    static std::string _token;
    _token = [yougu_Instance.token UTF8String];
    return _token;
}

#pragma mark ----------------------------- platform -----------------------------------
const std::string& libYouGuYiJie::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
}
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libYouGuYiJie::nickName(){
    
    NSString* retNS = yougu_Instance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark -------------------getClientChannel--------------------------
const std::string libYouGuYiJie::getClientChannel(){
    return sdkConfigure.com4lovesconfig.platformid ;//"ios_ryuk_jp";
}

#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libYouGuYiJie::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libYouGuYiJie::notifyEnterGame(){
    yougu_Instance.isInGame = YES;
}

bool libYouGuYiJie::getIsTryUser(){
    return false;
}
void libYouGuYiJie::callPlatformBindUser(){}
void libYouGuYiJie::notifyGameSvrBindTryUserToOkUserResult(int result){}
void libYouGuYiJie::OnKrGetInviteCount(){}
//G2P means Game to Platform
std::string libYouGuYiJie::sendMessageG2P(const std::string& tag, const std::string& msg){
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"tag---->%@----msg--->%@",[NSString stringWithUTF8String:tag.c_str()],[NSString stringWithUTF8String:msg.c_str()]);
    
    if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_EnterMainScene"]) {
        //yougu_Instance.isInMainScene = [msg isEqualToString:@"true"];
        return "";
    }
    else if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ACCOUNT_LOGIN"]) {
        if(isEnterLogin){
            libOS::getInstance()->setWaiting(false);
            if(isStartScheduleLogin){
                [yougu_Instance endScheduleLogin];
                isStartScheduleLogin = false;
                // 请求登陆
                [yougu_Instance RequestAccountServer:yougu_Instance.deviceid gcID:yougu_Instance.gcid];
            }
            else{
                // 请求登陆
                [yougu_Instance RequestAccountServer:yougu_Instance.deviceid gcID:yougu_Instance.gcid];
            }
        }
        return "";
    }
    else if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ENTER_GAME"])
    {
        NSString* content = [NSString stringWithUTF8String:msg.c_str()];
        [yougu_Instance EnterGame:content];
        return "";
    }
    else if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_Level_Up"])
    {
        NSString* content = [NSString stringWithUTF8String:msg.c_str()];
        [yougu_Instance LevelUp:content];
        return "";
    }
    else if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_CHANGE_ROLE_NAME"])
    {
        NSString* content = [NSString stringWithUTF8String:msg.c_str()];
        [yougu_Instance ChangeName:content];
        return "";
    }
    else if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_HAS_PLATFORM_USER_CENTER"])
    {
        //BOOL hasPlatformUserCenter = [[SYSDKPlatform getInstance] hasPlatformUserCenter];
        //sendMessageP2G("P2G_HAS_PLATFORM_USER_CENTER", (hasPlatformUserCenter == TRUE ? "1" : "0"));
        return "";
    }
    else if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_TEST_GOTO_LOADINGFRAME"])
    {
        return "";
    }
    
    return sendMessageP2G(tag, msg);
}

void libYouGuYiJie::updateApp(std::string &storeUrl)
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




