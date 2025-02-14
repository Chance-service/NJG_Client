//
//  libGNetopSBankObj.h
//  lib91
//
//  Created by fanleesong on 15/3/12.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface libGNetopSBankObj : NSObject{
    UIActivityIndicatorView *waitView;
}

@property (copy,nonatomic)NSString* userid;
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
- (BOOL) isLogin;
- (void) unregisterNotification;
- (void) SNSInitResult:(NSNotification *)notify;

@end
