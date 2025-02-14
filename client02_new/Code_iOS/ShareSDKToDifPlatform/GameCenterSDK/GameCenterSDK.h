//
//  GameCenterSDK.h
//  GameCenterSDK
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 com4loves. All rights reserved.
//


/**
 deal with user login from GameCenter or user inApp purchase products of this class SDK
 **/
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
//#include "comHuTuoSDK.h"
/**
 all notification code
 */
#define GNETOP_LOGIN_NOTIFICATION @"GNETOPLOGINNOTIFICATION"
#define GNETOP_CHANGEACCOUNT @"GNETOPCHANGEACCOUNT"
#define GNETOP_TAGGCLOGIN @"GNETOPTAGGCLOGIN"
#define GNETOP_LOGINGC @"GNETOPLOGINGC"

@interface GameCenterSDK : NSObject

+ (instancetype) GameCenterSharedSDK;

/**
 About GameCenter
 */
- (void) loginGameByGameCenter;
- (void) loginGameByGameCenterIsUseGCLogin:(BOOL)isUseGCLogin;
- (void) registerForAuthenticationNotification;
- (void) authenticateLocalPlayer:(UIViewController *)rootViewController;
- (NSString*) getGcId;
@end
