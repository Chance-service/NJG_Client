//
//  libGNetopSBankObj.m
//  lib91
//
//  Created by fanleesong on 15/3/12.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "libGNetopSBankObj.h"
#include "libOS.h"
#include "libGNetopSBank.h"
#import "GameCenterSDK.h"
#import <com4lovesSDK.h>
#import "InAppPurchaseManager.h"


@implementation libGNetopSBankObj

#pragma mark--
#pragma mark-----------------SNSInitResult------------------
-(void) SNSInitResult:(NSNotification *)notify{
    
    self.isInGame = NO;
    self.isReLogin = NO;
    [self registerNotification];
    [self SNSInitFinish:nil];
    
}
#pragma mark--
#pragma mark--------------registerNotification---------------------
-(void) registerNotification{
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:GNETOP_LOGIN_NOTIFICATION object:nil];
    //如果之后有GC切换账号的话，此处需移动到switchUsers方法中
    [[GameCenterSDK GameCenterSharedSDK] registerForAuthenticationNotification];
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [[GameCenterSDK GameCenterSharedSDK] authenticateLocalPlayer:vc];
    //监听GC账号切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCAccountChange:) name:GNETOP_CHANGEACCOUNT object:nil];
    //    BOOL authStatus = [GKLocalPlayer localPlayer].isAuthenticated;
    //    NSLog(@"--authStatus---%@",authStatus ?@"true":@"false");
    //监听内购
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseSuccessful) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    
    
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
#pragma mark--
#pragma mark---------------unregisterNotification--------------------
-(void) unregisterNotification{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GNETOP_LOGIN_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GNETOP_CHANGEACCOUNT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    
}
#pragma mark--
#pragma mark--------------SNSInitFinish---------------------
-(void) SNSInitFinish:(NSNotification *)notify{
    
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
    
}

#pragma mark
#pragma mark ----------------------------------- login call back ------------------------------
- (void)PlatformLogout:(NSNotification *)notify{
    
    libPlatformManager::getPlatform()->_boardcastPlatformLogout();
    
}
- (BOOL) isLogin{
    
    return self.userid.length!=0;
    
}
#pragma mark--
#pragma mark----------------SNSLoginResult-------------------
//登录
- (void)SNSLoginResult:(NSNotification *)notify{
    
    NSDictionary * userInfo = notify.userInfo;
    NSLog(@"登⼊入结果:%@",userInfo);
    NSString *userid = [userInfo objectForKey:@"result"];
    if (userid != nil && userid.length > 0) {
        self.userid = userid;
        libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");
    }else{
        self.userid = @"";
        libPlatformManager::getPlatform()->_boardcastLoginResult(false, "登录失败");
    }
    
    
}
#pragma mark--
#pragma mark----------------change role notice-------------------
- (void) GCAccountChange:(NSNotification *)notification{
    
    NSLog(@"%s\n",__FUNCTION__);
    NSDictionary * userInfo = notification.userInfo;
    NSLog(@"GC--登⼊入结果:%@",userInfo);
    NSString *changeUserId = [userInfo objectForKey:@"result"];
    NSLog(@"---%s--result-%@",__FUNCTION__,changeUserId);
    if (self.userid.length != 0) {
        NSLog(@"---%s--changeUserId-%@",__FUNCTION__,changeUserId);
        NSLog(@"---%s--self.userid-%@",__FUNCTION__,self.userid);
        if (![self.userid isEqualToString:changeUserId]) {
            self.userid = changeUserId;
            NSLog(@"---%s---%@",__FUNCTION__,self.userid);
            libPlatformManager::getPlatform()->_boardcastPlatfromReLogin();
        }
    }
    
}

#pragma mark--
#pragma mark----------------facebooksharecallback-------------------
- (void)userFacebookSharingResult:(NSNotification *)notification{
    
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
#pragma mark ----------------------------------- pay call back -------------------------------------
- (void)phchaseSuccessful{
    
    NSLog(@"--------------%s",__FUNCTION__);
    
    libGNetopSBank* plat = dynamic_cast<libGNetopSBank * >(libPlatformManager::getPlatform());
    if (!plat) {
        NSLog(@"----------plat---libR2------------");
        BUYINFO info = plat->getBuyInfo();
        //        NSLog(@"buyinfo---\n%s\n",info.description.c_str(),);
        NSLog(@"buyinfo---\ndescription--%s\nproductId---%s\nproductName---%s\nproductOrignalPrice---%02f\nproductPrice---%02f\n",info.description.c_str() ,info.productId.c_str(),info.productName.c_str(),info.productOrignalPrice,info.productPrice);
        libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, "");
    }
    
}
- (void)phchaseFailed{
    NSLog(@"购买失败");
}
- (void)phchasing{
    NSLog(@"正在购买");
}
#pragma mark--
#pragma mark----------------userFacebookSharing-------------------
- (void)userFacebookSharing:(NSNotification*)notify{
    
    NSDictionary* receiveDic = notify.userInfo;
    if(receiveDic){
        NSString *nsName = receiveDic[@"name"];
        NSString *nsPicture = receiveDic[@"picture"];
        NSString *nsLink = receiveDic[@"link"];
        NSString *nsDescription = receiveDic[@"description"];
    }
    
}

@end
