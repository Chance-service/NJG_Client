//
//  libRyukObj.m
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "libDemoObj.h"
#include "libOS.h"
#include "libDemo.h"
#import "PlatformNotificationCode.h"
#import "InAppPurchaseManager.h"
#import "AdverView.h"
#import "SDKUtility.h"
#import <CommonCrypto/CommonHMAC.h>
#import "UIHelperAlert.h"

#define TIP_GCLOGIN_ERROR @"Game Center失败"
#define TIP_GCACCOUNT_NOMATCH @"请关联登录账户，切换账户." // @"ログインしているアカウントが連携されているものと異なります アカウントを切り替えてください"
#define BIND_GC @"BINDGC"
#define TIP_STARTGAME_ERROR @"登陆失败"
#define TIP_STARTGAME_ERROR1 @"登陆失败!"
#define TIP_STARTGAME_ERROR2 @"登陆失败。"
@interface libDemoObj ()

@property (nonatomic,retain)AdverView *adverView;
@end

@implementation libDemoObj
#pragma mark-----------------SNSInitResult------------------
-(void) SNSInitResult:(NSNotification *)notify{
    self.isInGame = NO;
    self.isReLogin = NO;
    
    self.userid = @"";
    self.token = @"";
    self.platformId = @"";
    self.deviceid = @"";
    self.bindGcid = @"";
    self.gcid = @"";
    self.code = @"";
    self.isEndScheduleLogin = NO;
    
    [self registerNotification];
    [self SNSInitFinish:nil];
    
    
}

#pragma mark--------------registerNotification---------------------
-(void) registerNotification{
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:GNETOP_LOGIN_NOTIFICATION object:nil];
    
    CGRect rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
    waitView = [[UIActivityIndicatorView alloc] initWithFrame:rect];//定义图标大小，此处为32x32
    [waitView setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
    [waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置图标风格，采用灰色的，其他还有白色设置
    [waitView setBackgroundColor:[ UIColor colorWithWhite: 0.0 alpha: 0.5 ]];

    [[[UIApplication sharedApplication] keyWindow] addSubview:waitView];
    
    /*
    
     case SActionLoginSuccess:
     NSLog(@"SYSDK 登录成功，user=%@", result);
     [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:result];
     break;
     case SActionLoginFailure:
     [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR2];
     NSLog(@"SYSDK 登录失败，error=%@", result);
     break;*/

}

#pragma mark---------------unregisterNotification--------------------
-(void) unregisterNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GNETOP_LOGIN_NOTIFICATION object:nil];
}

#pragma mark--------------SNSInitFinish---------------------
-(void) SNSInitFinish:(NSNotification *)notify{
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
}

#pragma mark ----------------------------------- login call back ------------------------------
- (void)PlatformLogout:(NSNotification *)notify{
    libPlatformManager::getPlatform()->_boardcastPlatformLogout();
}

- (BOOL) isLogin{
    return self.userid.length!=0;
}

#pragma mark----------------SNSLoginResult-------------------
//登录
- (void)SNSLoginResult:(NSNotification *)notify{
    NSDictionary<NSString *, NSString *> * userInfo = notify.userInfo;
    //NSDictionary * userInfo = notify.userInfo;
    //NSLog(@"%s-----登⼊入结果:%@",__FUNCTION__,userInfo);
    self.userid = [userInfo objectForKey:@"userId"];
    self.token = [userInfo objectForKey:@"token"];
    self.platformId = [userInfo objectForKey:@"platformId"];
    
    NSString* md5Code = [[[[SDKUtility sharedInstance]md5HexDigest:self.deviceid] uppercaseString] substringWithRange:NSMakeRange(8, 12)];
    self.code = md5Code;
    
    if (self.userid != nil) {
        libPlatformManager::getPlatform()->_boardcastLoginResult(true, [self.code UTF8String]);
    }
}
- (void) RequestAccountServer:(NSString* )devicesId  gcID:(NSString* )gcId {
    //[[SYSDKPlatform getInstance] doLogin];
    
    NSDictionary * result = [[NSDictionary alloc] initWithObjectsAndKeys:self.deviceid,@"userId",@"",@"token",@"1",@"platformId", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:result];
}

- (void) EnterGame:(NSString* )meg{
    NSArray *contentArr = [meg componentsSeparatedByString:@"_"];

    NSMutableDictionary *roleInfo = [NSMutableDictionary dictionary];
    roleInfo[@"roleId"] = contentArr[0];
    roleInfo[@"roleName"] = contentArr[1];
    roleInfo[@"zoneId"] = contentArr[2];
    roleInfo[@"zoneName"] = contentArr[3];
    roleInfo[@"partyName"] = contentArr[4];
    roleInfo[@"roleLevel"] = contentArr[5];
    roleInfo[@"roleVipLevel"] = contentArr[6];
    roleInfo[@"balance"] = contentArr[7];
    roleInfo[@"isNewRole"] = contentArr[8];
    //[[SYSDKPlatform getInstance] setRoleInfo:roleInfo];
}

- (void) LevelUp:(NSString* )meg{
    NSInteger roleLevel = [meg integerValue];
    //[[SYSDKPlatform getInstance] onRoleLevelUpgrade:roleLevel];
}

- (void) ChangeName:(NSString* )meg{
    //[[SYSDKPlatform getInstance] onRoleNameUpdate:meg];
}

- (void) startScheduleLogin
{
    if(not self.isEndScheduleLogin || true){
        libOS::getInstance()->setWaiting(false);
        libPlatformManager::getPlatform()->sendMessageG2P("G2P_ACCOUNT_LOGIN", "false");
    }
}
- (void) endScheduleLogin
{
    self.isEndScheduleLogin = true;
}

-(void)onPresent{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if(self.adverView == nil)
    {
        self.adverView = [[[AdverView alloc]initWithFrame:window.rootViewController.view.frame] autorelease];
    }
    
    [window addSubview:self.adverView];
    self.adverView.hidden = NO;
}
@end
