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



@interface libAppStoreObj : NSObject

-(void) unregisterNotification;
-(void) SNSInitResult:(NSNotification *)notify;
@end
