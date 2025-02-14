#include "libEfun.h"
#include "libOS.h"
#include "libEfunObj.h"
#include <com4lovesSDK.h>
#ifndef EFUNTW
#import "EfunSDK.h"
#import "EfunSDK+Deprecated.h"
#else
#import "EfunSDK.h"
#import "EfunAdSystem.h"
#import "EFUNPlatFormSDK.h"
#import "EFUN_IAP_SDK.h"
#endif
#import "HuTuoServerInfo.h"

libEfunObj* s_libEfunOjb = 0;

SDK_CONFIG_STU sdkConfigure;

void libEfun::initWithConfigure(const SDK_CONFIG_STU& configure)
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
    
 //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    s_libEfunOjb = [libEfunObj new];
    [s_libEfunOjb SNSInitResult:0];
    s_libEfunOjb.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
//    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
//    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
#ifndef EFUNTW
//    [EFUNPlatFormSDK_AE initPlatForm];
#else
    [EFUNPlatFormSDK initPlatForm];
#endif
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool libEfun::getLogined()
{
//    return [[NdComPlatform defaultPlatform] isLogined];
    return [s_libEfunOjb isLogin];
}

void libEfun::login()
{
    if(!this->getLogined())
	{
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
#ifndef EFUNTW
        
        /***
         Efun API 登陆 - 調⽤用 Login 介⾯面,傳⼊入當前 View ***/
        [EfunSDK efunLogin:[NSDictionary dictionaryWithObjectsAndKeys:window,EFUN_PRM_BASE_VIEW, nil]];
        
        
#else
        [EfunSDK ShowLoginViewWithBaseView:window];
#endif

    }
}

#pragma mark ====
#pragma mark == logout 登出
void libEfun::logout()
{
    
    s_libEfunOjb.userid = nil;
    
}

void libEfun::switchUsers()
{
    logout();//本平太注销回到主界面
    
#ifndef EFUNTW
    
    /***
     Efun API SDK 登出 ***/
    [EfunSDK efunLogout];
    
#endif
    if(!this->getLogined())
    {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        
        
#ifndef EFUNTW
        
        /***
         Efun API 登陆 - 調⽤用 Login 介⾯面,傳⼊入當前 View ***/
        [EfunSDK efunLogin:[NSDictionary dictionaryWithObjectsAndKeys:window,EFUN_PRM_BASE_VIEW, nil]];
        
#else
        [EfunSDK ShowLoginViewWithBaseView:window];
#endif
    }
    
    
}

#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------

void libEfun::buyGoods(BUYINFO& info)
{
    if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NSString *productId = [NSString stringWithUTF8String:info.productId.c_str()];
//    productId = @"se.qmgj.1usd";
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    int zoneID = 0;
    sscanf(info.description.c_str(),"%d",&zoneID);
    
    NSString *aUserID = s_libEfunOjb.userid,
    *aPlayerID = uin,
    *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleLevel = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].lvl ],
    *aRoleName = [com4lovesSDK getServerInfo].playerName,
    *aProductID=productId;
    //Byte b1[] = {0x01};
    //NSData *adata = [[NSData alloc] initWithBytes:b1 length:1];
    //NSString *aString = [[NSString alloc] initWithData:adata encoding:NSUTF8StringEncoding];
    std::string x = "$$";
    
#ifndef EFUNTW
    std::string str = "ios_efun_en"+ x + info.description + x + info.productId;
    NSString *aRemark = [NSString stringWithUTF8String:(const char *)str.c_str()];
    NSDictionary *buyinfo = [NSDictionary dictionaryWithObjectsAndKeys:
                             //商品ID
                             aProductID,EFUN_IAP_PORPERTY_PRODUCTID,
                             aUserID, EFUN_IAP_PORPERTY_USERID,
                             //⽤用户ID(EfunSDK登⼊入后获取到的UserId)
                             aPlayerID,EFUN_IAP_PORPERTY_PLAYERID, //游戏⾓角⾊色ID(当这个值为订单号时,在每次点击购买按钮后把⽣生成的订单号再次调⽤用此函数)
                             //服务器ID //玩家的等级 //玩家⾓角⾊色名字
                             aServerCode,EFUN_IAP_PORPERTY_SERVERCODE,
                             aRoleLevel,EFUN_IAP_PORPERTY_ROLELEVEL,
                             aRoleName,EFUN_IAP_PORPERTY_ROLENAME,
                             aRemark,EFUN_IAP_PORPERTY_REMARK,
                             nil];
    NSLog(@"%@",buyinfo);
    //    [EfunSDK buyProudctInAppStoreWithUserPorperty:buyinfo];//1.8.2旧版SDK内购借口
    
    
#pragma mark - EfunSDK IAP function
    [EfunSDK efunPay:@{
                       EFUN_PRM_PRODUCT_ID:aProductID,               //商品ID
                       EFUN_PRM_EFUN_USER_ID:aUserID,                          //用户ID
                       EFUN_PRM_CREDIT_ID:aPlayerID,                      //游戏角色ID(当这个值为订单号时,在每次点击购买按钮后把生成的订单号再次调用此函数)
                       EFUN_PRM_SERVER_CODE:aServerCode,             //服务器ID
                       EFUN_PRM_ROLE_LEVEL:aRoleLevel,                   //玩家的等级
                       EFUN_PRM_ROLE_NAME:aRoleName,                //玩家角色名字
                       EFUN_PRM_REMARK:aRemark}];
    
    
    
#else
    std::string str = "ios_efun_tw" + x + info.description + x + info.productId;
    NSString *aRemark = [NSString stringWithUTF8String:(const char *)str.c_str()];
    
    NSLog(@"\n--aProductID=%@\n--aUserID=%@\n--aPlayerID=%@\n--aServerCode==%@\n--aRemark==%@\n--aRoleLevel==%@\n--aRoleName==%@\n",aProductID,aUserID,aPlayerID,aServerCode,aRemark,aRoleLevel,aRoleName);
    
    [EFUN_IAP_SDK userDidClickBuyBtnWithProductID:aProductID
                                        andUserID:aUserID
                                      andPlayerID:aPlayerID
                                    andServerCode:aServerCode
                                           remark:aRemark
                                           aLevel:aRoleLevel
                                            aRole:aRoleName];
#endif
    
    
    
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------

void libEfun::openBBS()
{
//    [[NdComPlatform defaultPlatform] NdEnterAppBBS:0];
}

void libEfun::userFeedBack()
{
//    [[NdComPlatform defaultPlatform] NdUserFeedBack];
   
    [[com4lovesSDK sharedInstance] showSdkFeedBackWithUserName:
     [NSString stringWithFormat:@"%@&serverId=%d",[com4lovesSDK getServerInfo].playerName ,[com4lovesSDK getServerInfo].serverID]];
}
void libEfun::gamePause()
{
//    [[NdComPlatform defaultPlatform] NdPause];
}

void libEfun::setToolBarVisible(bool isShow)
{
    
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------

const std::string& libEfun::loginUin()
{
    static std::string retStr = "";
    
    NSString* retNS = s_libEfunOjb.userid;
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix + retStr;
    }
    return retStr;
}
const std::string& libEfun::sessionID()
{
	NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
}
const std::string& libEfun::nickName()
{
    NSString* retNS = s_libEfunOjb.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
}

#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------
const std::string libEfun::getClientChannel()
{
#ifndef EFUNTW
    return "ios_efun_en";
#else
    return "ios_efun_tw";
#endif
}

std::string libEfun::getPlatformMoneyName()
{
    return sdkConfigure.platformconfig.moneyName;
}
#pragma mark
#pragma mark ----------------------------- platform -----------------------------------
void libEfun::notifyEnterGame()
{
    s_libEfunOjb.isInGame = YES;
    UIView *window = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
    NSString  *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleName = [NSString stringWithFormat:@"%@",[com4lovesSDK getServerInfo].playerName ];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
#ifndef EFUNTW
    
    if(window && aServerCode && aRoleName && uin){
        /***
         Efun API 平台 - 显⽰示 efun 平台的悬浮按钮 ***/
        NSString *playerLevel = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].lvl];
        [EfunSDK efunShowPlatform:@{
                                    EFUN_PRM_BASE_VIEW:window,
                                    EFUN_PRM_SERVER_CODE:aServerCode,
                                    EFUN_PRM_ROLE_NAME:aRoleName,
                                    EFUN_PRM_ROLE_LEVEL:playerLevel,
                                    EFUN_PRM_ROLE_ID:uin,
                                    EFUN_PRM_REMARK:@"1",
                                    EFUN_PRM_CREDIT_ID:uin
                                    }];
        /***
         Efun API 平台 - 将 efun 平台悬浮按钮顶置 ***/
        //        [EfunSDK efunBringPlatformToFront];
        
    }
    
#else
    [EFUNPlatFormSDK showPlatFormWithBaseView:window
                                andServerCode:aServerCode
                                  andRoleName:aRoleName
                                 andRoleLevel:[com4lovesSDK getServerInfo].lvl
                                    andRoleId:uin
                                    andRemark:@"1"
                                  andCreditId:uin];
    
#endif
    
    
}

bool libEfun::getIsTryUser()
{
    return false;
}

void libEfun::callPlatformBindUser()
{
    
}

void libEfun::notifyGameSvrBindTryUserToOkUserResult(int result)
{
    
}

