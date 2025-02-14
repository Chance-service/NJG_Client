//
//  libXY.m
//  libXY
//
//  Created by GuoDong on 14-6-9.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "libXY.h"
#include "libXYObj.h"
#include <string>
#include "libOS.h"
#include <com4lovesSDK.h>
#import <XYPlatform/XYPlatform.h>
#import <XYPlatform/XYPlatformDefines.h>

libXYObj* s_libXYOjb;
SDK_CONFIG_STU sdkConfigure;

void libXY::initWithConfigure(const SDK_CONFIG_STU& configure)
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
    
    s_libXYOjb = [libXYObj new];
    [s_libXYOjb SNSInitResult:nil];
    s_libXYOjb.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    //SDK初始化
    [[XYPlatform defaultPlatform] initializeWithAppId:appID appKey:appKey isContinueWhenCheckUpdateFailed:YES];
    NSString *bundleId = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    [XYPlatform defaultPlatform].appScheme = [bundleId stringByAppendingString:@".alipay"];
    // 默认为正式环境, 即为NO, 测试环境为 YES
    [[XYPlatform defaultPlatform] XYSetDebugModel:NO];
    [[XYPlatform defaultPlatform] XYSetShowSDKLog:NO];
    
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool libXY::getLogined()
{
    return s_libXYOjb.isLogin;
}

void libXY::login()
{
    [[XYPlatform defaultPlatform] XYUserLogin:0];
}

void libXY::logout()
{
    [[XYPlatform defaultPlatform] XYLogout:0];
}

void libXY::switchUsers()
{
    if(this->getLogined())
        [[XYPlatform defaultPlatform] XYEnterUserCenter:0];
    else
        [[XYPlatform defaultPlatform] XYUserLogin:0];
}

#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------
void libXY::buyGoods(BUYINFO& info)
{
    if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
   // NSString* productid = [NSString stringWithUTF8String:info.productId.c_str()];
    NSString* serverid = [NSString stringWithUTF8String:info.description.c_str()];
    NSString* orderid = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    NSString* productprice = [NSString stringWithFormat:@"%.2f",info.productPrice];
    NSString* productId = [NSString stringWithUTF8String:info.productId.c_str()];
    NSString *payDes = [NSString stringWithFormat:@"%@-%@",productId,orderid];
    [[XYPlatform defaultPlatform]XYPayWithAmount:productprice
                                appServerId:serverid
                                appExtra:payDes
                                delegate:s_libXYOjb];
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------
void libXY::openBBS()
{
    [[XYPlatform defaultPlatform]XYEnterAppBBS:0];
}

void libXY::userFeedBack()
{
    [[com4lovesSDK sharedInstance] showFeedBack];
}

void libXY::gamePause()
{
    
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libXY::loginUin()
{
    static std::string retStr = "";
    NSString* retNS = [[XYPlatform defaultPlatform]XYOpenUID];
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix+retStr;
    }
    return retStr;
}
                       
const std::string& libXY::sessionID()
{
    static std::string retStr = "";
    return retStr;
}
                       
const std::string& libXY::nickName()
{
    NSString* retNS = [[XYPlatform defaultPlatform]XYLoginUserAccount];
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
}

#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------
void libXY::notifyEnterGame()
{
    s_libXYOjb.isInGame = YES;
}

const std::string libXY::getClientChannel()
{
    return sdkConfigure.platformconfig.clientChannel;;
}
const unsigned int libXY::getPlatformId()
{
    return 0u;
}

std::string libXY::getPlatformMoneyName()
{
    return sdkConfigure.platformconfig.moneyName;;
}