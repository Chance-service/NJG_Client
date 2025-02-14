//
//  libEfunObj.h
//  libEfun
//
//  Created by wzy on 13-3-5.
//  Copyright (c) 2013年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface libEfunObj : NSObject
{
    UIActivityIndicatorView *waitView;
}
@property (copy,nonatomic)NSString* userid;
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
- (BOOL) isLogin;
-(void) unregisterNotification;
-(void) SNSInitResult:(NSNotification *)notify;
@end
