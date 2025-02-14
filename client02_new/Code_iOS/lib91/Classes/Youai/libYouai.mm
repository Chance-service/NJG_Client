#include "libYouai.h"
#include "libYouaiObj.h"
#include <string>
#include "libOS.h"

#include <com4lovesSDK.h>

libYouaiObj* s_libYouaiOjb;
SDK_CONFIG_STU sdkConfigure;
std::string channelID;
void libYouai::initWithConfigure(const SDK_CONFIG_STU& configure)
{
    sdkConfigure = configure;
    //init com4lovesSDK
    NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
   // NSString *yachannelID = [[NSString alloc] initWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    NSString *AlipayUrlScheme = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *SignSecret = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    //plist get channelID
    NSString *dataPath = [[NSBundle mainBundle]  pathForResource:@"channel" ofType:@"plist"];
    NSMutableDictionary *  dict = [NSMutableDictionary dictionaryWithContentsOfFile:dataPath];
    NSString *yachannelID = [dict objectForKey:@"channel"];
    channelID = [yachannelID UTF8String];
    [com4lovesSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [com4lovesSDK  setAppId:yaappID];
    [com4lovesSDK setAlipayUrlScheme:AlipayUrlScheme andSignSecret:SignSecret];
    
    //DataEyeInit
    //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    s_libYouaiOjb  =  [libYouaiObj alloc];
    [s_libYouaiOjb SNSInitResult:0];
    s_libYouaiOjb.isReLogin = configure.platformconfig.bRelogin;
    libPlatformManager::getPlatform()->_boardcastInitDone(true,"");
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool libYouai::getLogined()
{
    return [[com4lovesSDK sharedInstance] getLogined] == YES;
}

void libYouai::login()
{
    if(!this->getLogined())
        [[com4lovesSDK sharedInstance] Login];
}

void libYouai::logout()
{
    [[com4lovesSDK sharedInstance] showAccountManager];
}

void libYouai::switchUsers()
{
    if(!this->getLogined())
        [[com4lovesSDK sharedInstance] Login];
    else
        [[com4lovesSDK sharedInstance] showAccountManager];
}

#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------

void libYouai::buyGoods(BUYINFO& info)
{
    if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NSString* productid = [NSString stringWithUTF8String:info.productId.c_str()];
    NSString* serverid = [NSString stringWithUTF8String:info.description.c_str()];
    [[com4lovesSDK sharedInstance] iapBuy:productid serverID:serverid totalFee:info.productPrice orderId:@""];
    //DataEye pay Statistics
    //        NSString *price = [NSString stringWithFormat:@"%f",info.productPrice];
    //        NSString *orderID = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    //        [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateBuyBegin object:[NSDictionary dictionaryWithObjectsAndKeys:orderID,@"orderID",price,@"price",@"ios_91",@"payType",nil]];
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------

void libYouai::openBBS()
{
    NSString *bbsURL = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.bbsurl.c_str() encoding:NSASCIIStringEncoding];
    [[com4lovesSDK sharedInstance] showWeb:bbsURL];
}

void libYouai::userFeedBack()
{
    [[com4lovesSDK sharedInstance] showFeedBack];
}

void libYouai::gamePause()
{
    
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------

const std::string& libYouai::loginUin()
{
    static std::string ret = "";
    NSString *userID = [com4lovesSDK  getYouaiID];
    if(userID != nil)
    {
        ret = std::string([userID UTF8String]);
        if(ret != "")
            ret = sdkConfigure.platformconfig.uidPrefix + ret;
    }
    return ret;
}

const std::string& libYouai::sessionID()
{
    static std::string ret = "";
    
   return ret;
}

const std::string& libYouai::nickName()
{
    static std::string ret;
    ret = std::string([[[com4lovesSDK sharedInstance] getLoginedUserName] UTF8String]);
    return ret;
}

bool libYouai::getIsTryUser()
{
    return [[com4lovesSDK sharedInstance] getIsTryUser];
}
#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------

void libYouai::notifyEnterGame()
{
    s_libYouaiOjb.isInGame = YES;
}

const std::string libYouai::getClientChannel()
{
    return sdkConfigure.platformconfig.clientChannel;
}

const unsigned int libYouai::getPlatformId()
{
    return 0u;
}

std::string libYouai::getPlatformMoneyName()
{
    return sdkConfigure.platformconfig.moneyName;
}

const std::string libYouai::getChannelID()
{
    return channelID;
}