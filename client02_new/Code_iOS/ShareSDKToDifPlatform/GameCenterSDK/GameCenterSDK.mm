//
//  GameCenterSDK.m
//  GameCenterSDK
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 com4loves. All rights reserved.
//

#import "GameCenterSDK.h"
//#include "com4lovesSDK.h"
/**
 just for gnetop of japan
 **/
#define CHANGEUSERTIPS @"GameCenter ID すでに別のアカウントのリンク。あなたはこの口座に切り替えるか？"
#define CANCLE @"キャンセル"
#define CONFIRM @"確定"
#define GOTOGAMECENTER @"で、GameCenter持ってこそ、GameCenter ID 切り開いてくれるアナライズシステム哦!"
#define TipGameCenter @"登録点検している、GameCenterアカウントの登録が必要!"


@interface GameCenterSDK ()<NSURLConnectionDelegate,UIAlertViewDelegate>{
    
    BOOL _gameCenterFeaturesEnabled;
    BOOL userAuthenticated;
    
}
/**
 is can gc?
 **/
@property (nonatomic, assign) BOOL gameCenterAvailable;
/**
 userinfo
 **/
@property (retain,nonatomic)GKLocalPlayer* localPlayer;
@property (retain,nonatomic)NSString *tempPlayerId;
@property (assign,nonatomic)BOOL  isUseGC;
/**
 model viewController
 **/
- (void)__presentViewController__:(UIViewController*)vc;
/**
 get rootviewcontroller
 **/
- (UIViewController*) __getRootViewController__;
/**
 assiant Gc
 **/
- (BOOL)isGameCenterAvailable;
/**
 create a no repeat String
 **/
- (NSString *)MagicUUIDStringRef;
- (NSDictionary *) loginGameByTempUUIDToPlayerID;
- (BOOL) checkTempAccount:(NSString *)elements;
- (NSString *)getTempAccount;
@end

@implementation GameCenterSDK


static GameCenterSDK * instance = nil;
/**
 singleton
 **/
+ (instancetype)GameCenterSharedSDK{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
    
}
#pragma mark------------------------------
#pragma mark------------------------------GameCenter------------------------------

/**
 About GameCenter
 */
- (void)loginGameByGameCenter{
    
//    NSString* tempAccount = [self getTempAccount];
    /*NSString* isReview = [comHuTuoSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
    self.isUseGC = [self checkTempAccount:isReview];
    
    NSLog(@"%s---isUseGC---%@",__FUNCTION__,self.isUseGC ? @"true" :@"false");

    [self authenticateLocalPlayer:nil];*/

}
- (void) loginGameByGameCenterIsUseGCLogin:(BOOL)isUseGCLogin{
    
    if (isUseGCLogin == YES) {//GC
        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"gamecenter:"]]; 
         [self authenticateLocalPlayer:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_TAGGCLOGIN object:nil userInfo:[NSDictionary dictionaryWithObject:@"clickgc" forKey:@"result"]];
        
    }else{//临时
        /*NSString* isReview = [comHuTuoSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
        if ([isReview isEqualToString:@"0"]){//临时
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[self loginGameByTempUUIDToPlayerID]];
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_TAGGCLOGIN object:nil userInfo:[NSDictionary dictionaryWithObject:@"clickgctemp" forKey:@"result"]];
        }else if ([isReview isEqualToString:@"1"]){
            [self authenticateLocalPlayer:nil];
        }*/
    
    }


}
-(NSString *)getTempAccount
{
    //获取包名
    NSBundle *bundle = NSBundle.mainBundle;
    NSDictionary *infoDictionary = bundle.infoDictionary;
    NSString *bundeIdentifier = [infoDictionary objectForKey:(NSString *)kCFBundleIdentifierKey];
    NSArray *bundeIdArray =  [bundeIdentifier componentsSeparatedByString:@"."];
    NSString *channelName = (NSString*)[bundeIdArray objectAtIndex:[bundeIdArray count]-1];
    //NSString *tempAccount = [comHuTuoSDK getPropertyFromIniFile:@"TempAccount" andAttr:channelName];
    return @"";//tempAccount;
}
/**
 init sth.
 **/
- (id)init {
    if ((self = [super init])) {
        NSLog(@"---init--GameCenter---%s",__FUNCTION__);
        self.gameCenterAvailable = [self isGameCenterAvailable];
        NSLog(@"---------self.gameCenterAvailable----%@",self.gameCenterAvailable  ? @"true" :@"false");
        if (self.gameCenterAvailable) {
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
            [nc addObserver:self
                   selector:@selector(authenticationChanged)
                       name:GKPlayerAuthenticationDidChangeNotificationName
                     object:nil];
        }
    }
    return self;
}
/**
 check is TempAccount
 */
-(BOOL)checkTempAccount:(NSString *)elements{

    if ([elements isEqualToString:@"0"]) {
        return false;
    }else{
        return true;
    }

}

- (NSString*) getGcId{
    return self.tempPlayerId;
}

/**
 register accountNotification
 */
- (void)registerForAuthenticationNotification{
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(authenticationChanged)
               name:GKPlayerAuthenticationDidChangeNotificationName
             object:nil];
}
/**
 show account login viewController
 */
- (void)authenticateLocalPlayer:(UIViewController *)rootViewController{
    
    
    NSLog(@"%s",__FUNCTION__);
    
    self.localPlayer = [GKLocalPlayer localPlayer];
    self.localPlayer.authenticateHandler =
    ^(UIViewController *viewController,
      NSError *error) {
        if (_localPlayer.authenticated) {
            //验证通过
            NSLog(@"check success......");
            _gameCenterFeaturesEnabled = YES;
        } else if(viewController) {
            //present user GameCenter login view
            if (rootViewController) {
                [rootViewController presentViewController:viewController animated:YES completion:nil];
            }else{
                [self __presentViewController__:viewController];
            }
            
        } else {
            //验证错误
            NSLog(@"check error......");
            _gameCenterFeaturesEnabled = NO;
        }
        if (error == nil) {
            
            NSLog(@"success......");
            NSLog(@"%s--1--alias--%@",__FUNCTION__,[GKLocalPlayer localPlayer].alias);
            NSLog(@"%s--2--authenticated--%d",__FUNCTION__,[GKLocalPlayer localPlayer].authenticated);
            NSLog(@"%s--3--playerID--%@",__FUNCTION__,[GKLocalPlayer localPlayer].playerID);
            
            if (self.isUseGC) {
                 NSLog(@"%s--------isUseGC-------",__FUNCTION__);
                if(self.tempPlayerId == nil){
                    self.tempPlayerId = [GKLocalPlayer localPlayer].playerID;
                }
            }
            
            
        }else{
            
            NSLog(@"fail.....%@",error);
        }
    };

  
    
    
    
}
/**
 notification user change
 */
- (void) authenticationChanged{
    
    
         NSLog(@"%s--------isUseGC-------",__FUNCTION__);
        
        if ([GKLocalPlayer localPlayer].isAuthenticated && !userAuthenticated) {
            // Insert code here to handle a successful authentication.
            NSLog(@"-----GC认证登陆成功----Authentication changed: player authenticated.");
            userAuthenticated = TRUE;
            
            if (self.tempPlayerId == nil) {
                self.tempPlayerId = [GKLocalPlayer localPlayer].playerID;
                NSLog(@"%s======先测试过检测到tempPlayerId重新赋值后=playerid---%@",__FUNCTION__,[GKLocalPlayer localPlayer].playerID);
                //[[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGIN_NOTIFICATION object:nil userInfo:[self getUserIdByPlayer:self.tempPlayerId]];
                [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGINGC object:nil userInfo:[self getUserIdByPlayer:self.tempPlayerId]];
                
            }else{
                
                if (![self.tempPlayerId isEqualToString:[GKLocalPlayer localPlayer].playerID]  &&  self.tempPlayerId != nil ) {
                    NSLog(@"-检测到有GC账户切换的检测-olduser--%@",self.tempPlayerId);
                    /*UIAlertView *checkUser = [[[UIAlertView alloc] initWithTitle:nil
                                                                     message:[comHuTuoSDK getLang:@"GCIDTip"]
                                                                    delegate:self
                                                           cancelButtonTitle:NSLocalizedString([comHuTuoSDK getLang:@"ok"],nil)
                                                           otherButtonTitles:nil] autorelease];
                    [checkUser setTag:2000];
                    [checkUser show];*/
                    
                }else{
                    
                    NSLog(@"---%s--tempId不为nil，且此时和GC登陆的账号完全一致------%@",__FUNCTION__,self.tempPlayerId);
                    //nomarl login
                    [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGINGC object:nil userInfo:[self getUserIdByPlayer:self.tempPlayerId]];
                    
                }
                
            }
            
        } else{
            
            
            // Insert code here to clean up any outstanding Game Center-related classes.
            NSLog(@"GC认证不成功---Authentication changed: player not authenticated");
            userAuthenticated = FALSE;
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_LOGINGC object:nil userInfo:[self getUserIdByPlayer:nil]];
        }

//    }
    
}
- (NSDictionary *) getUserIdByPlayer :(NSString *)playerID{
    
//    if(self.isUseGC){
    
         NSLog(@"%s--------isUseGC-------",__FUNCTION__);
        if([playerID hasPrefix:@"G"] || [playerID hasPrefix:@"g"]){
            NSLog(@"contains-----G or g----------%@",playerID);
            NSRange newRange = NSMakeRange(2, playerID.length - 2);
            self.tempPlayerId = [playerID substringWithRange:newRange];
        }else{
            self.tempPlayerId = playerID;
        }
        NSLog(@"%s---userid-%@",__FUNCTION__,self.tempPlayerId );
        NSDictionary  *userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.tempPlayerId ,@"result",nil];
        return userDic;
        
//    }
//    else{
//        return nil;
//    }

}
- (NSDictionary *) loginGameByTempUUIDToPlayerID{
    
//    NSString* tempAccount = [self getTempAccount];
    /*NSString* isReview = [comHuTuoSDK getPropertyFromIniFile:@"isReview" andAttr:@"isreview"];
    //临时账号
    if ([isReview isEqualToString:@"0"]) {
        NSString *userid = [NSString stringWithFormat:@"temp%@",[self MagicUUIDStringRef] ];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        if ([userDefault objectForKey:@"tempid"] == nil) {
            self.tempPlayerId = userid;
            [userDefault setObject:userid forKey:@"tempid"];
            [userDefault synchronize];
        }else{
            NSString *tempUserId = [userDefault objectForKey:@"tempid"];
            NSLog(@"%s-temporary--tempUserId-%@",__FUNCTION__,tempUserId);
            if (![tempUserId isEqualToString:userid]) {
                NSLog(@"%s-temporary--userid-%@",__FUNCTION__,userid);
                self.tempPlayerId = tempUserId;
                NSLog(@"%s-temporary--self.tempPlayerId-%@",__FUNCTION__,self.tempPlayerId);
            }
        }
        
    }else{
    
        self.tempPlayerId = [GKLocalPlayer localPlayer].playerID;
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"tempid"] != nil) {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"tempid"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    
    }*/

    NSDictionary  *userDic = [NSDictionary dictionaryWithObjectsAndKeys:self.tempPlayerId,@"result",nil];
    return userDic;
    
}
/**
 create a no repeat String
 **/
- (NSString *)MagicUUIDStringRef{
    
    CFStringRef uuidStr;
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    NSString *uuidString = [((NSString *)uuidStr)stringByReplacingOccurrencesOfString:@"-" withString:@""];
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return uuidString;
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
//    if (self.isUseGC) {
    
        NSLog(@"%s--------isUseGC-------",__FUNCTION__);
        if ([alertView tag] == 2000) {
            if (buttonIndex == 0) {
                self.tempPlayerId = [GKLocalPlayer localPlayer].playerID;
                NSLog(@"%s--change---%@",__FUNCTION__,self.tempPlayerId);
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:GNETOP_CHANGEACCOUNT object:nil userInfo:[self getUserIdByPlayer:self.tempPlayerId]];
            
        }else if ([alertView tag] == 1000){
            
            if (buttonIndex == 0 ) {
                NSLog(@"检测到没有登陆GC账号，一定去要登录GC账号");
            }
            
        }
        
//    }

}
/**
 model viewController
 **/
- (void)__presentViewController__:(UIViewController*)vc {
    UIViewController* rootVC = [self __getRootViewController__];
    [rootVC presentViewController:vc animated:YES completion:nil];
}
/**
 get rootviewcontroller
 **/
- (UIViewController*) __getRootViewController__ {
    return [UIApplication sharedApplication].keyWindow.rootViewController;
}
/**assiant gc**/
- (BOOL)isGameCenterAvailable {
    NSLog(@"%s",__FUNCTION__);
    // check for presence of GKLocalPlayer API
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    
    // check if the device is running iOS 4.1 or later
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer
                                           options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}
-(void)dealloc{
    [self.localPlayer release],self.localPlayer = nil;
    [self.tempPlayerId release],self.tempPlayerId = nil;
    [super dealloc];
}
#pragma mark------------------------------
#pragma mark------------------------------GameCenter------------------------------

@end
