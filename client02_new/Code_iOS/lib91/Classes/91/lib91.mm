#include "lib91.h"
#include "libOS.h"
//#include "lib91Obj.h"
//#include <comHuTuoSDK.h>
//#import <NdComPlatform/NdComPlatform.h>
//#import <NdComPlatform/NdComPlatformAPIResponse.h>
//#import <NdComPlatform/NdCPNotifications.h>

//lib91Obj* s_lib91Ojb = 0;
SDK_CONFIG_STU sdkConfigure;
static bool isGuest = 0;
static std::string loginName = "";

void lib91::initWithConfigure(const SDK_CONFIG_STU& configure)
{
    sdkConfigure = configure;
    //libIos_mLogined = false;
    _boardcastUpdateCheckDone(true, "");
    //init com4lovesSDK
    /*NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    [comHuTuoSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [comHuTuoSDK  setAppId:yaappID];
    
    //DataEyeInit
 //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    s_lib91Ojb = [lib91Obj new];
    [s_lib91Ojb SNSInitResult:0];
    s_lib91Ojb.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
    //初始化平台
    NdInitConfigure *cfg = [[NdInitConfigure alloc] init];
    cfg.appid       = [appID intValue];
    cfg.appKey      = appKey;
    cfg.versionCheckLevel = ND_VERSION_CHECK_LEVEL_STRICT;
    cfg.orientation = UIInterfaceOrientationPortrait ;
    [[NdComPlatform defaultPlatform] NdShowToolBar:NdToolBarAtTopRight];
    [[NdComPlatform defaultPlatform] NdInit:cfg];
    this->setToolBarVisible(YES);
    [[NdComPlatform defaultPlatform] NdSetScreenOrientation:UIInterfaceOrientationPortrait];
    [[NdComPlatform defaultPlatform] NdSetAutoRotation:NO];
    [cfg release];*/
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool lib91::getLogined()
{
    //libIos_mLogined = true;
    return true;//libIos_mLogined;
    //return [[NdComPlatform defaultPlatform] isLogined];
}

void lib91::login()
{
    if(!this->getLogined())
	{
        //[[NdComPlatform defaultPlatform] NdLogin:0];
    }
    _boardcastLoginResult(true, "");
}

void lib91::logout()
{
	//[[NdComPlatform defaultPlatform] NdLogout:0];
}

void lib91::switchUsers()
{
    //if(!this->getLogined())
	//{
    //    [[NdComPlatform defaultPlatform] NdLogin:0];
    //}
    //else
    //    [[NdComPlatform defaultPlatform] NdEnterPlatform:0];
}

void lib91::setLoginName(const std::string content)
{
    loginName = content;
}
std::string lib91::getLoginName()
{
    return loginName;
}
#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------

void lib91::buyGoods(BUYINFO& info)
{
    /*if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NdBuyInfo* buyinfo = [NdBuyInfo new];
    buyinfo.cooOrderSerial = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    buyinfo.productId = [NSString stringWithUTF8String:info.productId.c_str()];
    buyinfo.productName = [NSString stringWithUTF8String:info.productName.c_str()];
    buyinfo.productPrice = info.productPrice;
    buyinfo.productOrignalPrice = info.productOrignalPrice;
    if(info.productOrignalPrice == 0)
        buyinfo.productOrignalPrice = info.productPrice;
    buyinfo.productCount = 1;//info.productCount;
    buyinfo.payDescription = [NSString stringWithUTF8String:info.description.c_str()];
    int res = [[NdComPlatform defaultPlatform] NdUniPayAsyn:buyinfo];
    if(res<0)
    {
        std::string log("购买信息发送失败");
        _boardcastBuyinfoSent(false, info,log);
    }
    [buyinfo release];*/
//    else
//    {
//        //DataEye pay Statistics
//        NSString *price = [NSString stringWithFormat:@"%f",info.productPrice];
//        NSString *orderID = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
//        [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateBuyBegin object:[NSDictionary dictionaryWithObjectsAndKeys:orderID,@"orderID",price,@"price",@"ios_91",@"payType",nil]];
//    }
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------

void lib91::openBBS()
{
    //[[NdComPlatform defaultPlatform] NdEnterAppBBS:0];
}

void lib91::userFeedBack()
{
    //[[NdComPlatform defaultPlatform] NdUserFeedBack];
}
void lib91::gamePause()
{
    //[[NdComPlatform defaultPlatform] NdPause];
}

void lib91::setToolBarVisible(bool isShow)
{
    if(isShow)
    {
        //[[NdComPlatform defaultPlatform] NdShowToolBar:NdToolBarAtTopRight];
    }
    else
    {
        //[[NdComPlatform defaultPlatform] NdHideToolBar];
    }
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------

const std::string& lib91::loginUin()
{
    /*static std::string retStr = "";
    NSString* retNS = [[NdComPlatform defaultPlatform] loginUin];
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix + retStr;
    }
    return retStr;*/
    return loginName;
}
const std::string& lib91::sessionID()
{
	//NSString* retNS = [[NdComPlatform defaultPlatform] sessionId];
    //static std::string retStr;
    //if(retNS) retStr = (const char*)[retNS UTF8String];
    //return retStr;
    return "";
}
const std::string& lib91::nickName()
{
    //NSString* retNS = [[NdComPlatform defaultPlatform] nickName];
    //static std::string retStr;
    //if(retNS) retStr = [retNS UTF8String];
    //return retStr;
    return "";
}

#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------
const std::string lib91::getClientChannel()
{
    return "android_BC";//sdkConfigure.platformconfig.clientChannel;
}

const unsigned int lib91::getPlatformId()
{
    return 0u;
}

std::string lib91::getPlatformMoneyName()
{
    return sdkConfigure.platformconfig.moneyName;
}
#pragma mark
#pragma mark ----------------------------- platform -----------------------------------
void lib91::notifyEnterGame()
{
    //s_lib91Ojb.isInGame = YES;
}

bool lib91::getIsTryUser()
{
    return false;
}

void lib91::callPlatformBindUser()
{
    
}

void lib91::notifyGameSvrBindTryUserToOkUserResult(int result)
{
    
}

const std::string& lib91::getToken()
{
    return "";
}

bool lib91::getIsH365()
{
    return false;
}

int lib91::getHoneyP()
{
    return 0;
}

int lib91::getIsGuest()
{
    return isGuest;
}

void login();

void lib91::updateApp(std::string& storeUrl)
{
    
}

void lib91::setIsGuest(const int guest)
{
    isGuest = guest;
}
