//
//  libRyukObj.m
//  lib91
//
//

#import "libYouGuObjYiJie.h"
#include "libOS.h"
#include "libYouGuYiJie.h"
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
@interface libYouGuObjYiJie ()

@property (nonatomic,retain)AdverView *adverView;
@end

@implementation libYouGuObjYiJie
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reEnterLoginScene:) name:GNETOP_RE_ENTER_LOADING_SCENE object:nil];
    
    CGRect rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
    waitView = [[UIActivityIndicatorView alloc] initWithFrame:rect];//定义图标大小，此处为32x32
    [waitView setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
    [waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置图标风格，采用灰色的，其他还有白色设置
    [waitView setBackgroundColor:[ UIColor colorWithWhite: 0.0 alpha: 0.5 ]];

    [[[UIApplication sharedApplication] keyWindow] addSubview:waitView];
    
    /*
    [[SYSDKPlatform getInstance] setCallback:^(SAction action, NSDictionary *result){
        switch (action) {
            case SActionInitSuccess:
                NSLog(@"SYSDK 初始化成功");
                break;
            case SActionInitFailure:
                NSLog(@"SYSDK 初始化失败，error=%@", result);
                break;
            case SActionLoginSuccess:
                NSLog(@"SYSDK 登录成功，user=%@", result);
                [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:result];
                break;
            case SActionLoginFailure:
                [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR2];
                NSLog(@"SYSDK 登录失败，error=%@", result);
                break;
            case SActionAccountSwitchLogoutSuccess:
                NSLog(@"SYSDK 账号切换-注销成功");
                [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_RE_ENTER_LOADING_SCENE object:nil userInfo:result];
                break;
            case SActionAccountSwitchFailure:
                NSLog(@"SYSDK 账号切换失败，errorb=%@", result);
                break;
            case SActionPaySuccess:
                NSLog(@"SYSDK ⽀支付成功");
                break;
            case SActionPayFailure:
                NSLog(@"SYSDK ⽀支付失败，error=%@", result);
                break;
            case SActionAntiAddictionQuerySuccess:
                NSLog(@"SYSDK 防沉迷查询成功, result=%@", result);
                break;
            case SActionAntiAddictionQueryFailure:
                NSLog(@"SYSDK 防沉迷查询失败，error=%@", result);
                break;
            default: break;
        }
    }];
     */
}

#pragma mark---------------unregisterNotification--------------------
-(void) unregisterNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GNETOP_LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GNETOP_RE_ENTER_LOADING_SCENE object:nil];
}

#pragma mark--------------SNSInitFinish---------------------
// 初始化结束
-(void) SNSInitFinish:(NSNotification *)notify{
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
}

#pragma mark ----------------------------------- login call back ------------------------------
// 平台退出
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
    // 调用SDK登陆
    //[[SYSDKPlatform getInstance] doLogin];
    [YiJieOnlineHelper setLoginListener: self];
    [YiJieOnlineHelper login:@"login"];
}

- (void) reEnterLoginScene:(NSNotification *)notify
{
    libPlatformManager::getPlatform()->sendMessageG2P("P2G_RE_ENTER_LOADING_SCENE", "");
}

- (void) EnterGame:(NSString* )meg{
    // 玩家进入游戏向渠道发送基本数据
    // 将json字符串转换成字典
    NSData * getJsonData = [meg dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary * roleDict = [NSJSONSerialization JSONObjectWithData:getJsonData options:NSJSONReadingMutableContainers error:nil];

    NSMutableDictionary *roleInfo = [NSMutableDictionary dictionary];
    roleInfo[@"roleId"] = [roleDict objectForKey:@"roleId"];
    roleInfo[@"roleName"] = [roleDict objectForKey:@"roleName"];
    roleInfo[@"zoneId"] = [roleDict objectForKey:@"zoneId"];
    roleInfo[@"zoneName"] = [roleDict objectForKey:@"zoneName"];
    roleInfo[@"partyName"] = [roleDict objectForKey:@"partyName"];
    roleInfo[@"roleLevel"] = [roleDict objectForKey:@"roleLevel"];
    roleInfo[@"roleVipLevel"] = [roleDict objectForKey:@"roleVipLevel"];
    roleInfo[@"balance"] = [roleDict objectForKey:@"balance"];
    roleInfo[@"isNewRole"] = [roleDict objectForKey:@"isNewRole"];
    //[[SYSDKPlatform getInstance] setRoleInfo:roleInfo];
}

- (void) LevelUp:(NSString* )meg{
    // 玩家升级通知渠道
    //NSInteger roleLevel = [meg integerValue];
    //[[SYSDKPlatform getInstance] onRoleLevelUpgrade:roleLevel];
}

- (void) ChangeName:(NSString* )meg{
    // 修改名字通知渠道
    //[[SYSDKPlatform getInstance] onRoleNameUpdate:meg];
}

// 计划登陆
- (void) startScheduleLogin
{
    if(not self.isEndScheduleLogin || true){
        libOS::getInstance()->setWaiting(false);
        // 通知开始调用登陆
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

// 初始化回调
-(void) onResponse:(NSString*) tag : (NSString*) value {
    // tag :"success"  初始化成功
    // tag :"fail"     初始化失败
    // value : 如果 SDK 返回了失败原因，会给 value 赋值
    NSLog(@"sfwarning  onResponse:%@,%@", tag, value);
    if ([tag isEqualToString:@"success"])
    {
        [self SNSInitResult:0];
    }
}


// 支付失败回调
-(void) onFailed : (NSString*) msg {
    NSLog(@"sfwarning  pay onFailed:%@", msg);
}

// 支付成功回调
-(void) onSuccess : (NSString*) msg {
    NSLog(@"sfwarning  pay onSuccess:%@", msg);
}

// 订单号
-(void) onOderNo : (NSString*) msg {
    NSLog(@"sfwarning  pay onOderNo:%@", msg);
}

// 登出回调
-(void) onLogout : (NSString *) remain {
    NSLog(@"sfwarning  logout onLogout:%@", remain);
    //NEED ADD CODE:返回登陆界面
    //[self performSegueWithIdentifier:@"login" sender:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 登陆成功
-(void) onLoginSuccess : (YiJieOnlineUser*) user : (NSString *) remain {
    NSLog(@"sfwarning  onLoginSuccess:%@", remain);
    
    NSString* appId = user.productCode;
    NSString* channelId = user.channelId;
    NSString* userId = user.channelUserId;
    NSString* token = user.token;
    
    NSLog(@"登录成功，appId=%@, channelId=%@, userId=%@, appId=%@, ", appId, channelId, userId, token);
    NSDictionary *userInfo = @{
                               @"userId"      : userId,     // 渠道 SDK 标示的用户ID
                               @"token"       : token,      // 渠道 SDK 登陆完成后的 SessionID
                               @"platformId"  : channelId,  // 渠道平台标示的渠道 SDK ID
                               };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:userInfo];
    
    // 登陆验证
    // [self onLoginCheck : user];
}

// 登陆失败
-(void) onLoginFailed : (NSString*) reason : (NSString *) remain {
    NSLog(@"sfwarning  onLoginFailed:%@", remain);
    [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR2];
}

static const NSString* loginCheckUrl = @"http://user/paylog/checkLoginP";
// 登陆验证
-(void) onLoginCheck : (YiJieOnlineUser*) user {
    NSLog(@"sfwarning  onLoginCheck");
    NSString * url = [[NSString stringWithFormat:@"%@?app=%@&sdk=%@&uin=%@&sess=%@", loginCheckUrl, user.productCode, user.channelId, user.channelUserId, user.token] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    NSLog(@"sfwarning  onLoginSuccess:%@", url);
    NSLog(@"sfwarning  onLoginSuccess:%@", error);
    if (error == nil)
    {
        NSString* resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"sfwarning  onLoginSuccess:%@", resultStr);
        if ([@"SUCCESS" isEqualToString:resultStr]) {
            UIViewController* payController = [[self storyboard] instantiateViewControllerWithIdentifier: @"SFPayViewController"];
            [self presentViewController:payController animated:(NO) completion:nil];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"123456", @"roleId", @"玩家名", @"roleName", @"58", @"roleLevel", @"1", @"zoneId", @"1区", @"zoneName", nil];
            NSError* error;
            NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
            NSString* roleData = [[NSString alloc] initWithData:jsonData encoding: NSUTF8StringEncoding];
            [YiJieOnlineHelper setRoleData:roleData];
            
            return;
        }
    }
    NSLog(@"sfwarning  onLoginFailed:login fail");
}

@end





