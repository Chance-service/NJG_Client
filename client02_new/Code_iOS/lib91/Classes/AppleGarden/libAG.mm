#include "libAG.h"
#include "libAGObj.h"
#include <string>
#include "libOS.h"
#import <PPAppPlatformKit/PPAppPlatformKit.h>
#include <com4lovesSDK.h>

libAGObj* s_libAGOjb;
SDK_CONFIG_STU sdkConfigure;

void libAG::initWithConfigure(const SDK_CONFIG_STU& configure)
{
    sdkConfigure = configure;
    //init com4lovesSDK
    NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    [com4lovesSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [com4lovesSDK  setAppId:yaappID];
    
    //DataEyeInit
    //[[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_pp"];
    
    s_libAGOjb = [libAGObj new];
    [s_libAGOjb SNSInitResult:0];
    
    //读取平台参数
    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
    [[PPAppPlatformKit sharedInstance] setAppId:[appID intValue] AppKey:appKey];
    [[PPAppPlatformKit sharedInstance] setIsNSlogData:NO];
    [[PPAppPlatformKit sharedInstance] setIsOpenRecharge:YES];
    [[PPAppPlatformKit sharedInstance] setRechargeAmount:10];
    [[PPAppPlatformKit sharedInstance] setIsLongComet:YES];
    [[PPAppPlatformKit sharedInstance] setDelegate:s_libAGOjb];
    [[PPUIKit sharedInstance] checkGameUpdate];
}

#pragma mark
#pragma mark ------------------------------- login with ------------------------------------

bool libAG::getLogined()
{
    return [[PPAppPlatformKit sharedInstance] loginState] == 1;
}
void libAG::login()
{
    [[PPAppPlatformKit sharedInstance] showLogin];
}
void libAG::logout()
{
	[[PPAppPlatformKit sharedInstance] PPlogout];
}
void libAG::switchUsers()
{
    if(this->getLogined())
    {
        [[PPAppPlatformKit sharedInstance] showCenter];
    }
    else
    {
        [[PPAppPlatformKit sharedInstance] showLogin];
    }
}

#pragma mark
#pragma mark -------------------------------- pay with -------------------------------------
void libAG::buyGoods(BUYINFO& info)
{
    if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    //设置订单号
    NSString *billNO = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    NSString *pname = [NSString stringWithUTF8String:info.productName.c_str()];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    int zoneID = 0;
    sscanf(info.description.c_str(),"%d",&zoneID);
    //调出充值并且兑换接口
    [[PPAppPlatformKit sharedInstance] exchangeGoods:info.productPrice BillNo:billNO BillTitle:pname RoleId:uin ZoneId:zoneID];
    
    // [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateBuyBegin object:[NSDictionary dictionaryWithObjectsAndKeys:orderID,@"orderID",price,@"price",@"ios_pp",@"payType",nil]];
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------
void libAG::openBBS()
{
    libOS::getInstance()->openURL(sdkConfigure.platformconfig.bbsurl);
}

void libAG::userFeedBack()
{
    [[com4lovesSDK sharedInstance] showFeedBack];
}

void libAG::gamePause()
{
    
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------

const std::string& libAG::loginUin()
{
    NSString* retNS = [s_libAGOjb getUserID];
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    retStr = "AGUSR_"+retStr;
    return retStr;
}

const std::string& libAG::sessionID()
{
    static std::string retStr = "";
    return retStr;
}

const std::string& libAG::nickName()
{
    NSString* retNS = [s_libAGOjb getUserName];
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
}

#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------
const std::string libAG::getClientChannel()
{
    return "AppleGarden";
}

const unsigned int libAG::getPlatformId()
{
    return 0u;
}
std::string libAG::getPlatformMoneyName()
{
    return "PP币";
}