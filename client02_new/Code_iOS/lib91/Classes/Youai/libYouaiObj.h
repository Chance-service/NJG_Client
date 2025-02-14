//
//  libAppStoreObj.m
//  libAppStore
//
//  Created by lvjc on 13-7-25.
//  Copyright (c) 2013年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <StoreKit/StoreKit.h>
#import "com4lovesSDK.h"



@interface libYouaiObj : NSObject
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
-(void) SNSInitResult:(NSNotification *)notify;
-(void) unregisterNotification;
@end
