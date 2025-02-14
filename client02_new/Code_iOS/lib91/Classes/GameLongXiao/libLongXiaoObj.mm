//
//  libRyukObj.m
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "libLongXiaoObj.h"
#include "libOS.h"
#include "libLongXiao.h"
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
@interface libLongXiaoObj ()

@property (nonatomic,retain)AdverView *adverView;
@end

@implementation libLongXiaoObj
#pragma mark-----------------SNSInitResult------------------
-(void) SNSInitResult:(NSNotification *)notify{
    self.isInGame = NO;
    self.isReLogin = NO;
    
    self.userid = @"";
    self.token = @"";
//    self.session = @"";
    self.platformId = @"";
    self.deviceid = @"";
    self.bindGcid = @"";
    self.gcid = @"";
    self.code = @"";
    self.isEndScheduleLogin = NO;
    
    [self registerNotification];
    [self SNSInitFinish:nil];
    
    [UnKnownGame sharedPlatform].delegate = self;
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
    self.session = [userInfo objectForKey:@"sessionID"];
    self.platformId = [userInfo objectForKey:@"platformId"];
    
    NSString* md5Code = [[[[SDKUtility sharedInstance]md5HexDigest:self.deviceid] uppercaseString] substringWithRange:NSMakeRange(8, 12)];
    self.code = md5Code;
    
    if (self.userid != nil) {
        libPlatformManager::getPlatform()->_boardcastLoginResult(true, [self.code UTF8String]);
    }
}

// 登陆
- (void) RequestAccountServer:(NSString* )devicesId  gcID:(NSString* )gcId {
    [[UnKnownGame sharedPlatform] loginWithSuccessCallBack:^(NSString *sessionID, NSString *sdkUid) {
        if (sdkUid.length != 0) {
            NSLog(@"登陆成功，进入游戏");
            NSLog(@"当前的登陆的用户信息：uid = %@，sessionid = %@ ", sdkUid, sessionID);
            //NSString *tipStr = [NSString stringWithFormat:@"uid=%@\nsessionid=%@", sdkUid, sessionID];
            //UIAlertView *alertV = [[UIAlertView alloc] initWithTitle:@"提醒" message:tipStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            //[alertV show];
            
            
            NSDictionary *result = @{
                                       @"userId"          : sdkUid,
                                       @"sessionID"       : sessionID,
                                       @"token"           : @"",
                                       @"platformId"      : @"1"
                                       
                                       };
            
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:result];
        }
    }];
}

#pragma mark - delegate
- (void)PlatformBuySuccessUsePayType:(NSInteger)payType
{
    /*
     *  payType:支付方式
     *  1. 内购
     *  2. 支付宝
     *  3. 微信
     */
    NSLog(@"LongXiao    购买成功:%ld", (long)payType);
    NSString *msg = [NSString stringWithFormat:@"购买成功:%ld", (long)payType];
    UIAlertView *alV = [[UIAlertView alloc] initWithTitle:@"提醒" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alV show];
}

- (void)PlatformBuyFailure:(NSString *)errorMsg
{
    NSLog(@"LongXiao    购买失败：%@", errorMsg);
    NSString *msg = [NSString stringWithFormat:@"购买失败：%@", errorMsg];
    UIAlertView *alV = [[UIAlertView alloc] initWithTitle:@"提醒" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alV show];
}

- (void)PlatformBuyViewClose
{
    NSLog(@"LongXiao   选择支付界面关闭");
    UIAlertView *alV = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"选择支付界面关闭" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alV show];
}

- (void) EnterGame:(NSString* )meg{
    NSData * getJsonData = [meg dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * roleDict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:nil];
    
    NSMutableDictionary *roleInfo = [NSMutableDictionary dictionary];
    roleInfo[@"role_id"] = [roleDict objectForKey:@"roleId"];        // 角色id
    roleInfo[@"role_name"] = [roleDict objectForKey:@"roleName"];    // 角色名
    roleInfo[@"level"] = [roleDict objectForKey:@"roleLevel"];       // 等级
    roleInfo[@"server_id"] = [roleDict objectForKey:@"zoneId"];      // 服务器id
    
    [[UnKnownGame sharedPlatform] uploadTheGameRoleInfo:roleInfo];
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
