//
//  lib44755.m
//  lib44755
//
//  Created by GuoDong on 14-6-9.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "libAs.h"
#include "libAsObj.h"
#include <string>
#include "libOS.h"
#include <AsPlatformSDK.h>
#include <AsInfoKit.h>
#include <com4lovesSDK.h>

libAsObj* s_libAsOjb;
SDK_CONFIG_STU sdkConfigure;

void libAs::initWithConfigure(const SDK_CONFIG_STU& configure)
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
    //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    s_libAsOjb = [libAsObj new];
    [s_libAsOjb SNSInitResult:0];
    s_libAsOjb.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
    [[AsInfoKit sharedInstance] setAppId:[appID intValue]];
    [[AsInfoKit sharedInstance] setAppKey:appKey];
    [[AsInfoKit sharedInstance] setLogData:YES];
    [[AsInfoKit sharedInstance] setCloseRecharge:NO];
    [[AsInfoKit sharedInstance] setLongComet:NO];
    [[AsPlatformSDK sharedInstance] setDelegate:s_libAsOjb];
    /*
     是否屏蔽登录页面右上角的“X”按钮
     YES:屏蔽、 NO：显示“X”按钮
     */
    [[AsInfoKit sharedInstance] setIsHiddenCloseButtonOnAsLoginView:NO];
    /*
     * 设置游戏的方向
     * orientationOfGame 游戏支持的方向 :
     * UIInterfaceOrientationMaskPortrait : 正立
     * UIInterfaceOrientationMaskLandscapeLeft : 左横屏
     * UIInterfaceOrientationMaskLandscapeRight : 右横屏
     * UIInterfaceOrientationMaskLandscape : 横屏（可上下翻转）
     */
    [[AsInfoKit sharedInstance] updateSDKOperatingEnvironment:YES andOrientationOfGame:UIInterfaceOrientationMaskPortrait];
    libPlatformManager::getPlatform()->_boardcastInitDone(true,"");
    [[AsPlatformSDK sharedInstance] checkGameUpdate];
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool libAs::getLogined()
{
    return s_libAsOjb.userID != nil;
}

void libAs::login()
{
    [[AsPlatformSDK sharedInstance] showLogin];
}

void libAs::logout()
{
    [[AsPlatformSDK sharedInstance] asLogout];
}

void libAs::switchUsers()
{
    if(s_libAsOjb.userID != nil)
        [[AsPlatformSDK sharedInstance] showCenter];
    else
        [[AsPlatformSDK sharedInstance] showLogin];
}

#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------

void libAs::buyGoods(BUYINFO& info)
{
    if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
  //  NSString* productid = [NSString stringWithUTF8String:info.productId.c_str()];
    NSString* productName = [NSString stringWithUTF8String:info.productName.c_str()];
    int serverid = [[NSString stringWithUTF8String:info.description.c_str()] intValue];
    NSString* orderid = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    orderid = [orderid substringWithRange:NSMakeRange(0, 28)];
   // NSLog(@"%d",[orderid length]);
    NSString* playerid = [com4lovesSDK getYouaiID];
    int price = info.productPrice;
    [[AsPlatformSDK sharedInstance] exchangeGoods:price BillNo:orderid BillTitle:productName RoleId:playerid ZoneId:serverid];
    //        //DataEye pay Statistics
    //        NSString *price = [NSString stringWithFormat:@"%f",info.productPrice];
    //        NSString *orderID = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    //        [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateBuyBegin object:[NSDictionary dictionaryWithObjectsAndKeys:orderID,@"orderID",price,@"price",@"ios_91",@"payType",nil]];
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------

void libAs::openBBS()
{
    libOS::getInstance()->openURL(sdkConfigure.platformconfig.bbsurl);
}

void libAs::userFeedBack()
{
    [[com4lovesSDK sharedInstance] showFeedBack];
}

void libAs::gamePause()
{
    
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------

const std::string& libAs::loginUin()
{
    static std::string retStr = "";
    NSString* retNS = s_libAsOjb.userID;
    if(retNS != nil)
    {
        retStr = (const char*)[retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix+retStr;
    }
    return retStr;
}

const std::string& libAs::sessionID()
{
    static std::string retStr = "";
    return retStr;
}

const std::string& libAs::nickName()
{
    NSString* retNS = s_libAsOjb.userName;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
}

#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------

void libAs::notifyEnterGame()
{
    s_libAsOjb.isInGame = YES;
}

const std::string libAs::getClientChannel()
{
    return sdkConfigure.platformconfig.clientChannel;
}
const unsigned int libAs::getPlatformId()
{
    return 0u;
}

std::string libAs::getPlatformMoneyName()
{
    return sdkConfigure.platformconfig.moneyName;
}