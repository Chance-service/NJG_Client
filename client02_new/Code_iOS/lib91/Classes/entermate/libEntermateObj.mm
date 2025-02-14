//
//  libEntermateObj.m
//  lib91
//
//  Created by fanleesong on 15/3/18.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "libEntermateObj.h"
#include "libOS.h"
#include "libEntermate.h"
#import "AdverView.h"
//#import <ILoveGameSDKFramework/ILoveGameSDK.h>

#define ENTERMATELOGINNOTIFACATION @"ENTERMATELOGINNOTIFACATION"

@interface libEntermateObj ()

@property (nonatomic,retain)AdverView *adverView;

@end

@implementation libEntermateObj
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:ENTERMATELOGINNOTIFACATION object:nil];
    
    
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
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:ENTERMATELOGINNOTIFACATION object:nil];
    
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
    NSNumber *userid = [userInfo objectForKey:@"result"];
    int uid = [userid intValue];
    if ( uid > 0) {
        NSString *tempUserId = [NSString stringWithFormat:@"%d",uid];
        self.userid = tempUserId;
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
    NSNumber *userid = [userInfo objectForKey:@"result"];
    int changeUserId = [userid intValue];
    if (self.userid.length != 0) {
        int oldUserId = [self.userid intValue];
        if (oldUserId != changeUserId) {
            self.userid = [NSString stringWithFormat:@"%d",changeUserId];
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
    
    libEntermate* plat = dynamic_cast<libEntermate * >(libPlatformManager::getPlatform());
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
    
    
    
//    [[ILoveGameSDK getInstance] sendPosting:^(BOOL success, NSError *error) {
//        if(success)
//        {
//            libOS::getInstance()->boardcastMessageonFBShareBack(true);
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                message:@"포스팅에 성공 하였습니다."
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"확인"
//                                                      otherButtonTitles:nil];
//            [alertView show];
//        }
//        else
//        {
//            libOS::getInstance()->boardcastMessageonFBShareBack(false);
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
//                                                                message:[error domain]
//                                                               delegate:nil
//                                                      cancelButtonTitle:@"확인"
//                                                      otherButtonTitles:nil];
//            [alertView show];
//        }
//    } setName:@"Venus" setCaption:@"비너스 테스트 메세지" setDescription:@"비너스 테스트 메세지 입니다." setLink:@"https://developers.facebook.com/docs/ios/share/" setPictureURL:@"http://i.imgur.com/g3Qc1HN.png" setMode:POSTMODE_WEBDIALOGPOST setType:@"pst0001"];
    
    NSDictionary* receiveDic = notify.userInfo;
    if(receiveDic){
//        NSString *nsName = receiveDic[@"name"];
//        NSString *nsPicture = receiveDic[@"picture"];
//        NSString *nsLink = receiveDic[@"link"];
//        NSString *nsDescription = receiveDic[@"description"];
    }
    
}
//处理审核广告
- (void)onPresent{

    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if(self.adverView == nil)
    {
        self.adverView = [[AdverView alloc]initWithFrame:window.rootViewController.view.frame];
    }
    [window addSubview:self.adverView];
    self.adverView.hidden = NO;


}

@end