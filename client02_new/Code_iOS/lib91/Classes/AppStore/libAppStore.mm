#include "libAppStore.h"
#include "libAppStoreObj.h"
#include <string>
#include "libOS.h"

#include <com4lovesSDK.h>

libAppStoreObj* s_libAppStoreOjb;
SDK_CONFIG_STU sdkConfigure;

void libAppStore::initWithConfigure(const SDK_CONFIG_STU& configure)
{
    sdkConfigure = configure;
    //init com4lovesSDK
    NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    NSString *appstorePHPIP = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appstore_phpIP.c_str() encoding:NSASCIIStringEncoding];
    NSString *appstorePHPURL = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appstore_phpURL.c_str() encoding:NSASCIIStringEncoding];
    [com4lovesSDK  setAppstorePHPIP:appstorePHPIP];
    [com4lovesSDK  setAppstorePHPURL:appstorePHPURL];
    [com4lovesSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [com4lovesSDK  setAppId:yaappID];
    
  //  [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_appstore"];
    s_libAppStoreOjb  =  [libAppStoreObj alloc];
    [s_libAppStoreOjb SNSInitResult:0];

    libPlatformManager::getPlatform()->_boardcastInitDone(true,"");
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
    
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool libAppStore::getLogined()
{
    return [[com4lovesSDK sharedInstance] getLogined] == YES;
}

void libAppStore::login()
{
    if([[com4lovesSDK sharedInstance] getLogined] == NO)
        [[com4lovesSDK sharedInstance] Login];
}

void libAppStore::logout()
{
    [[com4lovesSDK sharedInstance] showAccountManager];
}

void libAppStore::switchUsers()
{
    if([[com4lovesSDK sharedInstance] getLogined] == NO)
        [[com4lovesSDK sharedInstance] Login];
    else
        [[com4lovesSDK sharedInstance] showAccountManager];
}

#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------

void libAppStore::buyGoods(BUYINFO& info)
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
void libAppStore::openBBS()
{
    NSString *bbsURL = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.bbsurl.c_str() encoding:NSASCIIStringEncoding];
    [[com4lovesSDK sharedInstance] showWeb:bbsURL];
}

void libAppStore::userFeedBack()
{
    [[com4lovesSDK sharedInstance] showFeedBack];
}

void libAppStore::gamePause()
{
    
}

bool libAppStore::getIsTryUser()
{
    return [[com4lovesSDK sharedInstance] getIsTryUser];
}

void libAppStore::notifyEnterGame()
{
    [[com4lovesSDK sharedInstance] notifyEnterGame];
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libAppStore::loginUin()
{
    static std::string ret = "";
    NSString *userID = [com4lovesSDK  getYouaiID];
    if(userID != nil)
        ret = std::string([userID UTF8String]);
    return ret;
}

const std::string& libAppStore::sessionID()
{
    static std::string ret = "";
    
   return ret;
}

const std::string& libAppStore::nickName()
{
    static std::string ret;
    ret = std::string([[[com4lovesSDK sharedInstance] getLoginedUserName] UTF8String]);
    return ret;
}

#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------
const std::string libAppStore::getClientChannel()
{
    return sdkConfigure.platformconfig.clientChannel;
}

const unsigned int libAppStore::getPlatformId()
{
    return 0u;
}

std::string libAppStore::getPlatformMoneyName()
{
    return  sdkConfigure.platformconfig.clientChannel;
}