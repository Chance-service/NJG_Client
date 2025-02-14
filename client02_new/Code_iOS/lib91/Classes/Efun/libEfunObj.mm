//
//  libEfunObj.m
//  libEfun
//
//  Created by wzy on 13-3-5.
//  Copyright (c) 2013年 youai. All rights reserved.
//lib91.hwo
#include "libEfun.h"
#import "libEfunObj.h"
#ifndef EFUNTW
#import "EfunSDK.h"
#import "EfunSDK+Deprecated.h"
#else
#import "EfunSDK.h"
#import "EFUN_IAP_SDK.h"
#endif
//#include "EFUNPlatFormSDK_AE.h"
#include "libOS.h"
#define EFUN_FACEBOOKSHARE @"Efun_faceBookShare"
@implementation libEfunObj
-(void) SNSInitResult:(NSNotification *)notify
{
    self.isInGame = NO;
    self.isReLogin = NO;
    [self registerNotification];
    [self SNSInitFinish:nil];
}

-(void) registerNotification
{
#ifndef EFUNTW
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:EFUN_NOTIFICATION_SUCCESS_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(phchaseSuccessful) name:EFUN_NOTIFICATION_PHCHASE_SUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseFailed) name:EFUN_NOTIFICATION_PHCHASE_FAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchasing) name:EFUN_NOTIFICATION_PHCHASE_PUCHASING object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFacebookSharingResult:) name:EFUN_NOTIFICATION_FACEBOOKSHARING_RESULT object:nil];
#else
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:EFUN_NOTIFICATION_SUCCESS_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(phchaseSuccessful) name:EFUN_PHCHASE_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseFailed) name:EFUN_PHCHASE_FAIL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFacebookSharingResult:) name:EFUN_NOTIFICATION_FACEBOOKSHARE_RESULT object:nil];
#endif

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFacebookSharing:) name:EFUN_FACEBOOKSHARE object:nil];
    
    CGRect rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
    waitView = [[UIActivityIndicatorView alloc] initWithFrame:rect];//定义图标大小，此处为32x32
    [waitView setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
    [waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置图标风格，采用灰色的，其他还有白色设置
    [waitView setBackgroundColor:[ UIColor colorWithWhite: 0.0 alpha: 0.5 ]];
    //[self.view addSubview:waitView];//添加该waitView
//    if ([[UIDevice currentDevice] systemVersion].floatValue<=4.4) {
//        [waitView setBounds:CGRectMake(0, 0, 50, 50)];
//    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:waitView];

}

-(void) unregisterNotification
{
    
#ifndef EFUNTW
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_NOTIFICATION_SUCCESS_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_NOTIFICATION_PHCHASE_FAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_NOTIFICATION_PHCHASE_SUCCESSFUL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_NOTIFICATION_PHCHASE_PUCHASING object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_NOTIFICATION_FACEBOOKSHARING_RESULT object:nil];
#else
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_NOTIFICATION_SUCCESS_LOGIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_PHCHASE_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_PHCHASE_FAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_NOTIFICATION_FACEBOOKSHARE_RESULT object:nil];
#endif
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EFUN_FACEBOOKSHARE object:nil];
}

-(void) SNSInitFinish:(NSNotification *)notify
{
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
}

#pragma mark
#pragma mark ----------------------------------- login call back ----------------------------------------

- (void)PlatformLogout:(NSNotification *)notify
{
    libPlatformManager::getPlatform()->_boardcastPlatformLogout();
}
- (BOOL) isLogin
{
    return self.userid.length!=0;
}
//登录
- (void)SNSLoginResult:(NSNotification *)notify
{

#ifndef EFUNTW
    NSDictionary * userInfo = notify.userInfo;
    NSLog(@"登⼊入结果:%@",userInfo);
    NSString *userid = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"userid"]];
    [userInfo objectForKey:@"sign"];
    [userInfo objectForKey:@"timestamp"];
    NSNumber *code = [userInfo objectForKey:@"code"];
    if (([code integerValue]==1000||[code integerValue]==1006)&&userid.length!=0)
    {
        self.userid = userid;
        libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");
    }
    else {
        self.userid = @"";
        libPlatformManager::getPlatform()->_boardcastLoginResult(false, "登录失败");
    }
    
#else
    NSLog(@"userInfo == %@",[notify.userInfo objectForKey:@"userInfo"]);
    NSError *error = nil;
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:[[notify.userInfo objectForKey:@"userInfo"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    NSLog(@"error == %@ ",error.description);

    NSString *userid = [NSString stringWithFormat:@"%@",[userInfo objectForKey:@"userid"]];
    [userInfo objectForKey:@"sign"];
    [userInfo objectForKey:@"timestamp"];
    NSNumber *code = [userInfo objectForKey:@"code"];
    if (([code integerValue]==1000||[code integerValue]==1006)&&userid.length!=0){
        
        self.userid = userid;
        libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");
        
    }else {
        self.userid = @"";
        libPlatformManager::getPlatform()->_boardcastLoginResult(false, "登录失败");
    }
    [EFUN_IAP_SDK start];

#endif
    
}
#pragma facebooksharecallback
- (void)userFacebookSharingResult:(NSNotification *)notification
{
//    NSString *sharingResult = [notification.userInfo objectForKey:@"sharingResult"];
//    NSLog(@"sharingResult==%@",sharingResult);
    NSError *error = nil;
    NSDictionary *shareDic = [NSJSONSerialization JSONObjectWithData:[[notification.userInfo objectForKey:@"sharingResult"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    NSString *shareCode = [shareDic objectForKey:@"code"];
    NSString *shareResult = [shareDic objectForKey:@"message"];
    NSLog(@"shareCode==%@",shareCode);
    NSLog(@"shareResult==%@",shareResult);
    if([shareCode isEqualToString:@"1000"]){
        libOS::getInstance()->boardcastMessageonFBShareBack(true);
    }else{
        libOS::getInstance()->boardcastMessageonFBShareBack(false);
    }

}

#pragma mark
#pragma mark ----------------------------------- pay call back ----------------------------------------
- (void)phchaseSuccessful{
    libEfun* plat = dynamic_cast<libEfun*>(libPlatformManager::getPlatform());
    if (!plat) {
        BUYINFO info = plat->getBuyInfo();
        libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, "");
        
    }

}
- (void)phchaseFailed
{
    NSLog(@"购买失败");
}

- (void)phchasing
{
    NSLog(@"正在购买");
}

- (void)userFacebookSharing:(NSNotification*)notify
{
    NSDictionary* receiveDic = notify.userInfo;
    if(receiveDic)
    {
        NSString *nsName = receiveDic[@"name"];
        NSString *nsPicture = receiveDic[@"picture"];
        NSString *nsLink = receiveDic[@"link"];
        NSString *nsDescription = receiveDic[@"description"];




#ifdef EFUNTW
        [EfunSDK facebookDialogShareWithAppName:nsName
                                           text:nsDescription
                                         picUrl:nsPicture
                                         appUrl:nsLink];
#else
        
        
#pragma mark - EfunSDK sociel share (facebook share)
        [EfunSDK efunShare:@{
                             EFUN_PRM_SHARE_TYPE:EFUN_SHARE_FACEBOOK,
                             EFUN_PRM_SHARE_LINK_URL:nsLink,
                             EFUN_PRM_SHARE_LINK_NAME:nsName,
                             EFUN_PRM_SHARE_DESCRIPTION:nsDescription,
                             EFUN_PRM_SHARE_PICTURE_URL:nsPicture}];
        
        //        NSDictionary *tmpDic = [NSDictionary dictionaryWithObjectsAndKeys:EFUN_SHARE_FACEBOOK,EFUN_PRM_SHARE_TYPE,
        //                                nsDescription,EFUN_PRM_SHARE_DESCRIPTION,
        //                                nsName,EFUN_PRM_SHARE_LINK_NAME,
        //                                nsLink,EFUN_PRM_SHARE_LINK_URL,
        //                                nsPicture,EFUN_PRM_SHARE_PICTURE_URL, nil];
        //        [EfunSDK efunShare:tmpDic];
        
        
#endif
    

    }
}

@end
