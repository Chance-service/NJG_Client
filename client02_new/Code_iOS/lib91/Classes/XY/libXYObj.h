//
//  lib44755Obj.h
//  lib91
//
//  Created by GuoDong on 14-6-9.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <com4lovesSDK.h>
#import <XYPlatform/XYPlatform.h>
#import <XYPlatform/XYPlatformDefines.h>
@interface libXYObj : NSObject<XYPayDelegate>
{
    UIActivityIndicatorView *waitView;
}
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
@property (assign,nonatomic)BOOL isLogin;
-(void) unregisterNotification;
-(void) SNSInitResult:(NSNotification *)notify;
@end
