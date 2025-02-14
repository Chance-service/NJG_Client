//
//  libYouaiObj.m
//  libYouai
//
//  Created by lvjc on 13-7-25.
//  Copyright (c) 2013年 youai. All rights reserved.
//
#include "libYouai.h"
#import "libYouaiObj.h"

@implementation libYouaiObj
-(void) SNSInitResult:(NSNotification *)notify
{
    self.isInGame = NO;
    self.isReLogin = NO;
    [self registerNotification];
}

-(void) registerNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SNSLoginResult:) name:(NSString*)com4loves_loginDone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NdUniPayAysnResult:) name:(NSString*)com4loves_buyDone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(PlatformLogout:) name:(NSString*)com4loves_logout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryUser2OkSuccess:) name:(NSString*)com4loves_tryuser2OkSucess object:nil];
}

-(void) unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString*)com4loves_loginDone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString*)com4loves_buyDone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString*)com4loves_logout object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString*)com4loves_tryuser2OkSucess object:nil];
}

#pragma mark
#pragma mark ----------------------------------- login call back ----------------------------------------

-(void) PlatformLogout:(NSNotification *)notify
{
//    libPlatformManager::getPlatform()->_boardcastPlatformLogout();
        if(self.isInGame)
        {
            self.isInGame = false;
            libPlatformManager::getPlatform()->_boardcastPlatfromReLogin();
        }
        else
            libPlatformManager::getPlatform()->_boardcastPlatformLogout();
}

- (void)SNSLoginResult:(NSNotification *)notify
{
    libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");
}

#pragma mark
#pragma mark ----------------------------------- pay call back ----------------------------------------
- (void)NdUniPayAysnResult:(NSNotification *)notify
{
    libYouai* plat = dynamic_cast<libYouai*>(libPlatformManager::getPlatform());
    BUYINFO info = plat->getBuyInfo();
    libPlatformManager::getPlatform()->_boardcastBuyinfoSent(true, info, "购买成功");
}

-(void) tryUser2OkSuccess:(NSNotification *)notify
{
    libPlatformManager::getPlatform()->_boardcastOnTryUserRegistSuccess();
}

@end
