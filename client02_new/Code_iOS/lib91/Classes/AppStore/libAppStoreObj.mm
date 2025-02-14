//
//  libAppStoreObj.m
//  libAppStore
//
//  Created by lvjc on 13-7-25.
//  Copyright (c) 2013年 youai. All rights reserved.
//
#include "libAppStore.h"
#import "libAppStoreObj.h"


@interface libAppStoreObj ()
{
    BUYINFO buyInfo;
}
@end

@implementation libAppStoreObj
-(void) SNSInitResult:(NSNotification *)notify
{
    [self registerNotification];
    std::string outstr = "";
}

-(void) registerNotification
{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginDone:) name:(NSString*)com4loves_loginDone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(buyDone:) name:(NSString*)com4loves_buyDone object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:(NSString*)com4loves_logout object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryUser2OkSuccess:) name:(NSString*)com4loves_tryuser2OkSucess object:nil];
}

-(void) unregisterNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString*)com4loves_loginDone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString*)com4loves_buyDone object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:(NSString*)com4loves_logout object:nil];

}

#pragma mark
#pragma mark ----------------------------------- login call back ----------------------------------------
- (void)LoginDone:(NSNotification *)notify
{

    libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");
}

-(void) logout:(NSNotification *)notify
{
    libPlatformManager::getPlatform()->_boardcastPlatformLogout();
}

-(void) tryUser2OkSuccess:(NSNotification *)notify
{
    libPlatformManager::getPlatform()->_boardcastOnTryUserRegistSuccess();
}

#pragma mark
#pragma mark ----------------------------------- pay call back ----------------------------------------

- (void)buyDone:(NSNotification *)notify
{
    libAppStore* plat = dynamic_cast<libAppStore*>(libPlatformManager::getPlatform());
    BUYINFO info = plat->getBuyInfo();
    std::string log("购买成功");
    libPlatformManager::getPlatform()->_boardcastBuyinfoSent(false, info, log);
}
@end
