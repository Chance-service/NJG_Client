//
//  libRyukObj.m
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "libRyukObj.h"
#include "libOS.h"
#include "libRyuk.h"
#import "GameCenterSDK.h"
#import <comHuTuoSDK.h>
#import "InAppPurchaseManager.h"
#import "ShareSDKToDifPlatform.h"
#import "AdverView.h"
#import "SDKUtility.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <CommonCrypto/CommonHMAC.h>
#import "UIHelperAlert.h"
#define TIP_GCLOGIN_ERROR @"Game Center失敗"
#define TIP_GCACCOUNT_NOMATCH @"ログインしているアカウントが連携されているものと異なります アカウントを切り替えてください"
#define BIND_GC @"BINDGC"
#define TIP_STARTGAME_ERROR @"登録失敗"
#define TIP_STARTGAME_ERROR1 @"登録失敗!"
#define TIP_STARTGAME_ERROR2 @"登録失敗。"
@interface libRyukObj ()

@property (nonatomic,retain)AdverView *adverView;

@end

@implementation libRyukObj
#pragma mark--
#pragma mark-----------------SNSInitResult------------------
-(void) SNSInitResult:(NSNotification *)notify{
    
    self.isInGame = NO;
    self.isReLogin = NO;
    self.isShowAlaterGC = NO;
    self.isInBindGC = NO;
    self.isInMainScene = NO;
    
    self.userid = @"";
    self.deviceid = @"";
    self.bindGcid = @"";
    self.gcid = @"";
    self.code = @"";
    self.newCode = @"";
    self.newBindGcid = @"";
    self.isEndScheduleLogin = NO;
    
    [self registerNotification];
    [self SNSInitFinish:nil];
    
    NSString* isReview = [comHuTuoSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
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
    //监听GC登录
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCAccountLogin:) name:GNETOP_LOGINGC object:nil];
    //GC绑定
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCAccountBind) name:BIND_GC object:nil];
    //监听GC账号切换
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(GCAccountChange:) name:GNETOP_CHANGEACCOUNT object:nil];
    //监听内购
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseSuccessful:) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
    //监听内购购买失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(phchaseFailed:) name:kInAppPurchaseManagerTransactionFailedNotification object:nil];
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:BIND_GC object:nil];
    NSString* isReview = [comHuTuoSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
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
        libPlatformManager::getPlatform()->_boardcastLoginResult(true, [self.code UTF8String]);
    }else{
        self.userid = @"";
        libPlatformManager::getPlatform()->_boardcastLoginResult(false, "");
    }
    
}
- (void) RequestAccountServer:(NSString* )devicesId  gcID:(NSString* )gcId {
    NSString *accountEnterRequest = [comHuTuoSDK getPropertyFromIniFile:@"Account" andAttr:@"accountEnterRequest"];
    if(accountEnterRequest == nil){
        accountEnterRequest = @"http://52.220.239.245:8080/RedisServer/bindingGameCenterRequest?dvid=%@&platform=ios&pid=%@";
    }
    NSString *isShen = [comHuTuoSDK getPropertyFromIniFile:@"isShen" andAttr:@"isshen"];
    if(isShen == nil){
        isShen = @"0";
    }
    NSLog(@"RequestAccountServer devicesId:%@,gcId:%@",devicesId,gcId);
    NSString *str = [NSString stringWithFormat:accountEnterRequest,devicesId,gcId];
    NSString* data = [[SDKUtility sharedInstance]httpRequest:str postData:nil];
    NSLog(@"receive data = %@",data);
    static int longinFailedCount = 0;
    int retryTimes = 1;
    if(data){
        NSArray *array = [data componentsSeparatedByString:@"|"];
        if([array count] >= 6){
            
            NSString *ok = array[0];    //成功标志 1 成功 0 失败
            NSString *error = array[1]; //失败原因 0 没有原因 成功 1 puid不合法
            NSString *isNew = array[2]; //是否新账号 1 是 2 否
            NSString *bindGcid = array[3];  //绑定的gamecenter帐号
            NSString *bindGpid = array[4];  //绑定的googleplay帐号
            NSString *code = array[5];  //code值
            
            self.code = code;
            self.bindGcid = bindGcid;;
            
            if([ok isEqualToString:@"1"]){//成功
                [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:code ,@"result",nil]];
            }
            else{
                libOS::getInstance()->setWaiting(false);
                if([isShen isEqualToString:@"1"]){
                    longinFailedCount++;
                    if(longinFailedCount < retryTimes){
                        [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR1];
                    }
                }
                else{
                    [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR1];
                }
            }
        }
        else{
            longinFailedCount++;
            libOS::getInstance()->setWaiting(false);
            if(longinFailedCount < retryTimes){
                [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR2];
            }
        }
    }
    else{
        longinFailedCount++;
        libOS::getInstance()->setWaiting(false);
        if(longinFailedCount < retryTimes){
            [UIHelperAlert ShowAlertMessage:nil message:TIP_STARTGAME_ERROR2];
        }
    }
    if(longinFailedCount >= retryTimes){  //登录多次失败后，通过客户端计算code码来登录
        NSString* md5Code = [[[[SDKUtility sharedInstance]md5HexDigest:devicesId] uppercaseString] substringWithRange:NSMakeRange(8, 12)];
        NSLog(@"md5Code : %@",md5Code);
        self.code = md5Code;
        [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self.code ,@"result",nil]];
        longinFailedCount = 0;
    }

}
#pragma mark--
#pragma mark----------------GCAccountLogin-------------------
//GC登录
- (void) GCAccountLogin:(NSNotification *)notify{
    NSLog(@"%s\n",__FUNCTION__);
    
    NSDictionary * userInfo = notify.userInfo;
    NSLog(@"%s-----登⼊入结果:%@",__FUNCTION__,userInfo);
    NSString *gcid = [userInfo objectForKey:@"result"];
    libOS::getInstance()->setWaiting(false);
    if (gcid != nil && gcid.length > 0) {
        if(self.isInBindGC){//绑定中
            self.gcid = gcid;
            [self GCAccountBindHandle];
        }else{  //登录中
            libOS::getInstance()->setWaiting(false);
//            if([self.gcid isEqualToString:self.bindGcid]){//本地GC帐号与绑定GC帐号匹配 可以进入游戏
//                self.userid = self.code;    //用code码登录游戏
//                libPlatformManager::getPlatform()->_boardcastLoginResult(true, [self.code UTF8String]);
//            }else{//本地GC帐号与绑定GC帐号不匹配 需要切换GC帐号
//                NSLog(@"need change GameCenter account.");
//                [UIHelperAlert ShowAlertMessage:nil message:TIP_GCACCOUNT_NOMATCH];
//            }
            if(not self.isInMainScene){//gcid空的时候，是第一次登录gc，如果不是空，那么就是游戏过程中后台切换了gc，这个不处理
                self.gcid = gcid;
                //[self RequestAccountServer:self.deviceid gcID:self.gcid];
                libPlatformManager::getPlatform()->sendMessageG2P("G2P_ACCOUNT_LOGIN", "true");
            }
            else{
                if([self.bindGcid isEqualToString:@""] || ![gcid isEqualToString:self.bindGcid]){//当前帐号没有绑定 或者本地GC帐号与绑定GC帐号不匹配
                    bool ret = [self RequestAccountServerTwice:self.deviceid gcID:gcid];
                    if(ret){
                        libPlatformManager::getPlatform()->sendMessageP2G("P2G_CHANGE_USER","");
                    }
                }
            }
        }
    }else{//没有登录GC
        if(not self.isInMainScene){//gcid空的时候{
            self.gcid = @"";
            NSLog(@"GameCenter login nil.");
            //[self RequestAccountServer:self.deviceid gcID:@""];
            libPlatformManager::getPlatform()->sendMessageG2P("G2P_ACCOUNT_LOGIN", "false");
        }
        
        //libOS::getInstance()->setWaiting(false);
        //[UIHelperAlert ShowAlertMessage:nil message:TIP_GCLOGIN_ERROR];
    }
}
- (BOOL) RequestAccountServerTwice:(NSString* )devicesId  gcID:(NSString* )gcId {
    bool ret = FALSE;
    NSString *accountEnterRequest = [comHuTuoSDK getPropertyFromIniFile:@"Account" andAttr:@"accountEnterRequest"];
    if(accountEnterRequest == nil){
        accountEnterRequest = @"http://52.220.239.245:8080/RedisServer/accountEnterRequest?dvid=%@&platform=ios&pid=%@";
    }
    //accountEnterRequest = @"http://52.220.239.245:8080/RedisServer/accountEnterRequest?dvid=%@&platform=ios&pid=%@";
    NSString *isShen = [comHuTuoSDK getPropertyFromIniFile:@"isShen" andAttr:@"isshen"];
    if(isShen == nil){
        isShen = @"0";
    }
    NSLog(@"RequestAccountServer devicesId:%@,gcId:%@",devicesId,gcId);
    NSString *str = [NSString stringWithFormat:accountEnterRequest,devicesId,gcId];
    NSString* data = [[SDKUtility sharedInstance]httpRequest:str postData:nil];
    NSLog(@"receive data = %@",data);
    static int longinFailedCount = 0;
    int retryTimes = 1;
    if(data){
        NSArray *array = [data componentsSeparatedByString:@"|"];
        if([array count] >= 6){
            
            NSString *ok = array[0];    //成功标志 1 成功 0 失败
            NSString *error = array[1]; //失败原因 0 没有原因 成功 1 puid不合法
            NSString *isNew = array[2]; //是否新账号 1 是 2 否
            NSString *bindGcid = array[3];  //绑定的gamecenter帐号
            NSString *bindGpid = array[4];  //绑定的googleplay帐号
            NSString *code = array[5];  //code值
            
            //self.newCode = code;
            //self.newBindGcid = bindGcid;
            if([ok isEqualToString:@"1"]){//成功
                if([bindGcid isEqualToString:@""] ){//后台登陆的GC也是没有绑定的 不处理
                    ret = FALSE;
                }
                else if([code isEqualToString:self.code]){//code码一样也不处理
                    ret = FALSE;
                }
                else if([bindGcid isEqualToString:self.bindGcid]){//gc 一样也不处理
                    ret = FALSE;
                }
                else{
                    ret = TRUE;
                    self.newCode = code;
                    self.newBindGcid = bindGcid;
                }
            }
        }
        else{
            longinFailedCount++;
        }
    }
    else{
        longinFailedCount++;
    }
    if(longinFailedCount >= retryTimes){  //登录多次失败后，通过客户端计算code码来登录
        
    }
    return ret;
    
}
#pragma mark--
#pragma mark----------------GCAccountBind-------------------
//GC绑定
- (void) GCAccountBind{
    NSLog(@"%s\n",__FUNCTION__);
    self.isInBindGC = YES;
    if ([self.gcid isEqualToString:@""]) {
        libOS::getInstance()->setWaiting(false);
        [[GameCenterSDK GameCenterSharedSDK] loginGameByGameCenter];
    }else{
        [self GCAccountBindHandle];
    }
}
- (void) GCAccountBindHandle{
    self.isInBindGC = NO;
    NSString *accountEnterRequest = [comHuTuoSDK getPropertyFromIniFile:@"Account" andAttr:@"bindingGameCenterRequest"];
    //NSString *str = [NSString stringWithFormat:@"http://52.220.239.245:8080/RedisServer/bindingGameCenterRequest?puid=%@&gameCenterId=%@",
    //                 self.deviceid,self.gcid];
    if(accountEnterRequest == nil){
        accountEnterRequest = @"http://52.220.239.245:8080/RedisServer/bindingGameCenterRequest?gameCenterId=%@&accode=%@";
    }
    //accountEnterRequest = @"http://52.220.239.245:8080/RedisServer/bindingGameCenterRequest?gameCenterId=%@&accode=%@";
    NSString *str = [NSString stringWithFormat:accountEnterRequest,self.gcid,self.code];
    
    NSString* data = [[SDKUtility sharedInstance]httpRequest:str postData:nil];
    NSLog(@"receive data = %@",data);
    NSMutableDictionary *m_dic = [NSMutableDictionary dictionary];
    if(data){
        NSArray *array = [data componentsSeparatedByString:@"|"];
        if([array count] >= 2){
            NSString *ok = array[0];//成功标志 1 成功 0 失败
            NSString *state = array[1];//失败原因 0 没有原因 成功 1 GC帐号已经绑定过其他puid帐号 3 找不到gc gc为空 4 已经绑定过当前GC
            NSString *code = [ok isEqualToString:@"1"] ? @"success" : @"failed";
            if([ok isEqualToString:@"1"]){
                self.bindGcid = self.gcid;
            }
            [m_dic setValue:code forKey:@"code"];
            [m_dic setValue:state forKey:@"state"];
        }
        else{
            [m_dic setValue:@"0" forKey:@"code"];
            [m_dic setValue:@"3" forKey:@"state"];
        }
    }
    else{
        [m_dic setValue:@"0" forKey:@"code"];
        [m_dic setValue:@"3" forKey:@"state"];
    }
    NSLog(@"--------------sendMessageP2G:----------GCAccountBind----%@",m_dic);
    NSError *parseError = nil;
    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:m_dic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    libPlatformManager::getPlatform()->sendMessageP2G("P2G_BIND_GC_GP",[productJson UTF8String]);
    libOS::getInstance()->setWaiting(false);
}
- (void) scheduleLoginHandle:(NSTimer *)timer
{
    if(not self.isEndScheduleLogin){
        libOS::getInstance()->setWaiting(false);
        libPlatformManager::getPlatform()->sendMessageG2P("G2P_ACCOUNT_LOGIN", "false");
    }
}

- (void) startScheduleLogin
{
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(scheduleLoginHandle:)
                                                userInfo:nil repeats:NO] ;
}
- (void) endScheduleLogin
{
    self.isEndScheduleLogin = true;
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
            [[comHuTuoSDK sharedInstance] setFinalHuTuoID:[NSString stringWithFormat:@"gnetop_%@",changeUserId]];
#elif PROJECT_GNETOP
            [[com4lovesSDK sharedInstance] setFinalYouaiID:[NSString stringWithFormat:@"gnetop_%@",changeUserId]];
#else
             [[com4lovesSDK sharedInstance] setFinalYouaiID:[NSString stringWithFormat:@"gnetop_%@",changeUserId]];       
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
    
    libRyuk* plat = dynamic_cast<libRyuk * >(libPlatformManager::getPlatform());
    if (plat) {
        NSLog(@"---存在改平台-------plat---libGNetop------------");
        BUYINFO info = plat->getBuyInfo();
        //        NSLog(@"buyinfo---\n%s\n",info.description.c_str(),);
        NSLog(@"buyinfo---\ndescription--%s\nproductId---%s\nproductName---%@\nproductOrignalPrice---%2f\nproductPrice---%.2f\n",info.description.c_str() ,info.productId.c_str(),[NSString stringWithUTF8String:info.productName.c_str()],info.productOrignalPrice,info.productPrice);
        libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, "");
        
        /*美元USD、人民币CNY、日元JPY、英镑GBP、欧元EUR、韩元KER、港币HKD、澳元AUD、加元CAD**/
        [[ShareSDKToDifPlatform shareSDKPlatform] setInAppPurchase:(double)info.productPrice currency:@"JPY" differentToken:RYUKAdjustAppToken transactionId:trans.transactionIdentifier];
        
        
        //玩家第一次充值记录一次
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:self.code] == nil){
//            [[ShareSDKToDifPlatform shareSDKPlatform] setTrackingLevelByToken:(NSString*)RYUKAdjustNewAppToken];
//            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:self.code];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//        }
        //libOS::getInstance()->setWaiting(true);
        libPlatformManager::getPlatform()->sendMessageP2G("G2P_TOUCHRECHARGE", "buy_" + info.productId);
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

- (void)getCroproCount:(NSString*)getURL cId:(NSString*)cid startAt:(NSString*)start endAt:(NSString*)end key:(NSString*)hashKey{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
        NSString* data = [NSString stringWithFormat:@"cid=%@&end_at=%@&start_at=%@",cid,end,start];
    
        const char *cKey = [hashKey cStringUsingEncoding:NSASCIIStringEncoding];
        const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
        unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
        CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
        //NSData *hash = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];

        NSString *hash;
    
        NSMutableString* output = [NSMutableString   stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
        for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++)
            [output appendFormat:@"%02x", cHMAC[i]];
        hash = output;
        NSLog(@"getCroproCount %@", hash);
    
        NSString *str = [NSString stringWithFormat:getURL,cid,start,end,hash];
        NSString* recData = [[SDKUtility sharedInstance]httpRequest:str postData:nil];
        NSLog(@"receive data = %@",recData);
        if (not [recData isEqualToString:@""]) {
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_CROPRO_COUNT", [recData UTF8String]);
        }else{
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_CROPRO_COUNT", "false");
        }
    });

}


@end
