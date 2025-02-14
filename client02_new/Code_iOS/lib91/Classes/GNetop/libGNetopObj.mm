//
//  libGNetopObj.m
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "libGNetopObj.h"
#include "libOS.h"
#include "libGNetop.h"
#import "GameCenterSDK.h"
#import <com4lovesSDK.h>
#import "InAppPurchaseManager.h"
#import "ShareSDKToDifPlatform.h"
#import "AdverView.h"

@interface libGNetopObj ()

@property (nonatomic,retain)AdverView *adverView;

@end

@implementation libGNetopObj
#pragma mark--
#pragma mark-----------------SNSInitResult------------------
-(void) SNSInitResult:(NSNotification *)notify{
    
    self.isInGame = NO;
    self.isReLogin = NO;
    self.isShowAlaterGC = NO;
    [self registerNotification];
    [self SNSInitFinish:nil];
    
    NSString* isReview = [com4lovesSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
    if ([isReview isEqualToString:@"1"]) {//GC 登录
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tempid"] != nil) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tempid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
}

#pragma mark--
#pragma mark--------------registerNotification---------------------
-(void) registerNotification{
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:GNETOP_LOGIN_NOTIFICATION object:nil];
    //监听GC账号切换
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCAccountChange:) name:GNETOP_CHANGEACCOUNT object:nil];
    //监听内购
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseSuccessful:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    //监听内购购买失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseFailed:) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
    
    NSString* isReview = [com4lovesSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
    if ([isReview isEqualToString:@"0"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isCheckClickGCBtn:) name:GNETOP_TAGGCLOGIN object:nil];
    }
    
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
    NSString* isReview = [com4lovesSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
    if ([isReview isEqualToString:@"0"]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GNETOP_TAGGCLOGIN object:nil];
    }
    
}
#pragma mark--
#pragma mark--------------SNSInitFinish---------------------
-(void) SNSInitFinish:(NSNotification *)notify{
    
    libPlatformManager::getPlatform()->_boardcastUpdateCheckDone(true,"");
    
}
///检查是否是点击GC按钮
-(void)isCheckClickGCBtn:(NSNotification *)notify{

    NSDictionary * userInfo = notify.userInfo;
    NSLog(@"%s-----:%@",__FUNCTION__,userInfo);
    NSString *userid = [userInfo objectForKey:@"result"];
    if([userid isEqualToString:@"clickgc"]){
        self.isShowAlaterGC = true;
    }else if([userid isEqualToString:@"clickgctemp"]){
        self.isShowAlaterGC = false;
    }
    
    
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
    NSLog(@"%s-----登⼊入结果:%@",__FUNCTION__,userInfo);
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
    NSLog(@"%s-----GC--登⼊入结果:%@",__FUNCTION__,userInfo);
    NSString *changeUserId = [userInfo objectForKey:@"result"];
    NSLog(@"---%s--result-%@",__FUNCTION__,changeUserId);
    if (self.userid.length != 0) {
        NSLog(@"---%s--changeUserId-%@",__FUNCTION__,changeUserId);
        NSLog(@"---%s--self.userid-%@",__FUNCTION__,self.userid);
        if (![self.userid isEqualToString:changeUserId]) {
            self.userid = changeUserId;
#if PROJECT_GNETOPSPECIAL
            [[com4lovesSDK sharedInstance] setFinalHuTuoID:[NSString stringWithFormat:@"gnetop_%@",changeUserId]];
#elif PROJECT_GNETOP
            [[com4lovesSDK sharedInstance] setFinalHuTuoID:[NSString stringWithFormat:@"gnetop_%@",changeUserId]];
#else
             [[com4lovesSDK sharedInstance] setFinalHuTuoID:[NSString stringWithFormat:@"gnetop_%@",changeUserId]];       
#endif
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
- (void)phchaseSuccessful:(NSNotification *)notification{
    
    NSLog(@"--------------%s",__FUNCTION__);
    NSLog(@"----------购买成功---------");
    NSDictionary * userInfo = notification.userInfo;
    SKPaymentTransaction *trans = (SKPaymentTransaction *)[userInfo objectForKey:@"transaction"];
    NSLog(@"购买成功log-----------transactionIdentifier----->%@\n--------transactionReceipt--->\n%@",trans.transactionIdentifier,trans.transactionReceipt);
    
    libGNetop* plat = dynamic_cast<libGNetop * >(libPlatformManager::getPlatform());
    if (plat) {
        NSLog(@"---存在改平台-------plat---libGNetop------------");
        BUYINFO info = plat->getBuyInfo();
        //        NSLog(@"buyinfo---\n%s\n",info.description.c_str(),);
        NSLog(@"buyinfo---\ndescription--%s\nproductId---%s\nproductName---%@\nproductOrignalPrice---%2f\nproductPrice---%.2f\n",info.description.c_str() ,info.productId.c_str(),[NSString stringWithUTF8String:info.productName.c_str()],info.productOrignalPrice,info.productPrice);
        libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, "");
        
        /*美元USD、人民币CNY、日元JPY、英镑GBP、欧元EUR、韩元KER、港币HKD、澳元AUD、加元CAD**/
        [[ShareSDKToDifPlatform shareSDKPlatform] setInAppPurchase:(double)info.productPrice currency:@"EUR" differentToken:GnetopAjustEventAppPurchese];
    }

    
    
}
- (void)phchaseFailed:(NSNotification *)notification{
    NSLog(@"----------购买失败---------");
    NSDictionary * userInfo = notification.userInfo;
    SKPaymentTransaction *trans = (SKPaymentTransaction *)[userInfo objectForKey:@"transaction"];
    NSLog(@"购买失败log-----------transactionIdentifier----->%@\n--------transactionReceipt--->\n%@",trans.transactionIdentifier,trans.transactionReceipt);
    
//    libGNetop* plat = dynamic_cast<libGNetop * >(libPlatformManager::getPlatform());
//    if (plat) {
//        NSLog(@"---存在改平台-------plat---libGNetop------------");
//        BUYINFO info = plat->getBuyInfo();
//        //        NSLog(@"buyinfo---\n%s\n",info.description.c_str(),);
//        NSLog(@"buyinfo---\ndescription--%s\nproductId---%s\nproductName---%@\nproductOrignalPrice---%02f\nproductPrice---%02f\n",info.description.c_str() ,info.productId.c_str(),[NSString stringWithUTF8String:info.productName.c_str()],info.productOrignalPrice,info.productPrice);
//        libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, "");
//        
//        /*美元USD、人民币CNY、日元JPY、英镑GBP、欧元EUR、韩元KER、港币HKD、澳元AUD、加元CAD**/
//    [[ShareSDKToDifPlatform shareSDKPlatform] setInAppPurchase:(double)info.productPrice currency:@"EUR" differentToken:GnetopAjustEventAppPurchese];
//
//    }
    
    
}
- (void)phchasing{
    NSLog(@"正在购买");
}
#pragma mark--
#pragma mark----------------userFacebookSharing-------------------
- (void)userFacebookSharing:(NSNotification*)notify{
    
    NSDictionary* receiveDic = notify.userInfo;
    if(receiveDic){
//        NSString *nsName = receiveDic[@"name"];
//        NSString *nsPicture = receiveDic[@"picture"];
//        NSString *nsLink = receiveDic[@"link"];
//        NSString *nsDescription = receiveDic[@"description"];
    }
    
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
