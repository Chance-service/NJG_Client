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
#import <AsPlatformSDK.h>
@interface libAsObj : NSObject<AsPlatformSDKDelegate>
{
    UIActivityIndicatorView *waitView;
}
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
-(void) unregisterNotification;
-(void) SNSInitResult:(NSNotification *)notify;
@property (copy,nonatomic)NSString *userName;
@property (copy,nonatomic)NSString *userID;
@end
