//
//  libR2Obj.m
//  lib91
//
//  Created by fanleesong on 15-1-16.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "libR2Obj.h"
#include "libOS.h"
#include "libR2.h"
#import <R2SDKLoginKit/R2SDK.h>
#import <R2SDKLoginKit/R2SDKLoginKit.h>
#import "AdverView.h"

#define R2UIDCODEWRONG (-4)
#define R2UIDCODEWRONG2 (-11)
#define R2UIDNOFIND (-3)
#define R2UIDORCODENULL (-2)
#define R2UIDEXCEPT (-5)
#define R2UIDFORBIDDEN (-7)
#define R2UIDNOSTRING (-1)

//#define R2LastLogin @"R2LastLogin"
//#define R2ChangeAccount @"R2ChangeAccount"
#define R2inAppPurchase @"R2inAppPurchase"
#define R2LastLoginFlag @"R2LastLogin"


#define R2_AppIconURL @"http:///gjabd/android_R2Game_en/2.147/icon.png"
#define R2_AppDownloadLink @"http://ezpzrpg.r2games.com/"
#define R2_AppShareName @"Share"
#define R2_AppDec @"You just got an Heirloom item! Wanna share it with your friends?"
#define R2_AppCapital @"Share"

@interface libR2Obj ()
@property (nonatomic,retain)AdverView *adverView;
@end

@implementation libR2Obj
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:R2LastLoginFlag object:nil];
    //如果之后有GC切换账号的话，此处需移动到switchUsers方法中
//    [[R2SDK sharedR2SDK] registerForAuthenticationNotification];
//    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
//    [[R2SDK sharedR2SDK] authenticateLocalPlayer:vc];
    //监听GC账号切换
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCAccountChange:) name:R2LastLogin object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCAccountChange:) name:R2ChangeAccount object:nil];
    //监听内购
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseSuccessful) name:R2inAppPurchase object:nil];
    
    //facebook
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFacebookLoginResult:) name:FacebookLogin object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFacebookInvitateResult:) name:FacebookInvitate object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFacebookSharing:) name:@"R2FacebookShare" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userFacebookSharingResult:) name:@"R2FacebookShare" object:nil];

    
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
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:R2LastLogin object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:R2ChangeAccount object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:R2inAppPurchase object:nil];
    
}

-(void)onPresent
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if(self.adverView == nil)
    {
        self.adverView = [[AdverView alloc]initWithFrame:window.rootViewController.view.frame];
    }
    [window addSubview:self.adverView];
    self.adverView.hidden = NO;
    
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
    NSLog(@"SNSLoginResult---登⼊入结果:%@",userInfo);
    NSNumber *userid = [userInfo objectForKey:@"result"];
//    NSNumber *userid = [[userInfo objectForKey:@"data"] objectForKey:@"muid"];
    int uid = [userid intValue];
    if ( uid > 0) {
        NSString *tempUserId = [NSString stringWithFormat:@"%d",uid];
        self.userid = tempUserId;
//        libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");
    }else{
        self.userid = @"";
//        libPlatformManager::getPlatform()->_boardcastLoginResult(false, "登录失败");
    }

    
}
#pragma mark--
#pragma mark----------------change role notice-------------------
- (void) GCAccountChange:(NSNotification *)notification{
    
    NSLog(@"%s\n",__FUNCTION__);
    NSDictionary * userInfo = notification.userInfo;
    NSLog(@"GCAccountChange----GC--登⼊入结果:%@",userInfo);
    NSNumber *userid = [[userInfo objectForKey:@"data"] objectForKey:@"muid"];
//    NSNumber *userid = [userInfo objectForKey:@"result"];
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
#pragma mark----------------facebookLogincallback-------------------
- (void)userFacebookLoginResult:(NSNotification *) notifaction{

    NSLog(@"%s---FBloginRes---%@",__FUNCTION__,notifaction);
    
}

#pragma mark--
#pragma mark----------------userFacebookInvitatecallBack-------------------
- (void) userFacebookInvitateResult:(NSNotification *)notification{
    
    NSLog(@"%s---FBInvitateRes---%@",__FUNCTION__,notification);
    
}

#pragma mark--
#pragma mark----------------facebooksharecallback-------------------
- (void)userFacebookSharingResult:(NSNotification *)notification{
    
    
    NSLog(@"%s---FBShareRes---%@",__FUNCTION__,notification);
    
        NSString *sharingResult = [notification.userInfo objectForKey:@"result"];
        NSLog(@"sharingResult==%@",sharingResult);
//    NSError *error = nil;
//    NSDictionary *shareDic = [NSJSONSerialization JSONObjectWithData:[[notification.userInfo objectForKey:@"sharingResult"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
//    NSString *shareCode = [shareDic objectForKey:@"code"];
//    NSString *shareResult = [shareDic objectForKey:@"message"];
//    NSLog(@"shareCode==%@",shareCode);
//    NSLog(@"shareResult==%@",shareResult);
    if([sharingResult isEqualToString:@"succed"]){
        libOS::getInstance()->boardcastMessageonFBShareBack(true);
    }else{
        libOS::getInstance()->boardcastMessageonFBShareBack(false);
    }
    
}

#pragma mark
#pragma mark ----------------------------------- pay call back -------------------------------------
- (void)phchaseSuccessful{
    
    NSLog(@"--------------%s",__FUNCTION__);
    
    libR2* plat = dynamic_cast<libR2 * >(libPlatformManager::getPlatform());
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
    
    /**
     {@"name":nsName,
     @"picture":nsPicture,
     @"link":nsLink,
     @"description":nsDescription};
     **/
    NSDictionary* receiveDic = notify.userInfo;
    NSLog(@"---%s--%@",__FUNCTION__,receiveDic);
    if(receiveDic){
        NSString *nsName = receiveDic[@"name"];
        NSString *nsPicture = receiveDic[@"picture"];
        NSString *nsLink = receiveDic[@"link"];
        NSString *nsDescription = receiveDic[@"description"];
        NSLog(@"%s---FBSharingRes---%@",__FUNCTION__,notify);
        [[R2SDK sharedR2SDK] shareFacebookWithContentURL:nsLink contentTitle:nsName imageURL:nsPicture conetentDescription:nsDescription handle:^(NSDictionary *result, NSError *error) {
            if (result) {
                NSLog(@"share:%@",result);
                
                NSString *sharingResult = (NSString *)[result valueForKey:@"result"];
                //Succed  Failed
                NSLog(@"sharingResult:%@",sharingResult);
                if([sharingResult isEqualToString:@"succed"]){
                    libOS::getInstance()->boardcastMessageonFBShareBack(true);
                }else{
                    libOS::getInstance()->boardcastMessageonFBShareBack(false);
                }
            }
            else{
                NSLog(@"error :%@",[error localizedDescription]);
            }
        }];
    }
    

    
    

}

@end
