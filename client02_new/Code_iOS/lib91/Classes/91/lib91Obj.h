//
//  lib91Obj.h
//  lib91
//
//  Created by wzy on 13-3-5.
//  Copyright (c) 2013年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <NdComPlatform/NdComPlatform.h>
#import <NdComPlatform/NdComPlatformAPIResponse.h>
#import <NdComPlatform/NdCPNotifications.h>

@interface lib91Obj : NSObject
{
    UIActivityIndicatorView *waitView;
}
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
-(void) unregisterNotification;
-(void) SNSInitResult:(NSNotification *)notify;
@end
