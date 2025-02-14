//
//  SShareError.h
//  SPluginShare
//
//  Created by dev on 2017/9/27.
//  Copyright © 2017年 dev. All rights reserved.
//

#import <SCore/SCore.h>

@interface SShareError : SError

typedef NS_ENUM(NSInteger, SErrorShareCode)
{
    /** 分享取消 */
    SErrorShareCodeCancel = 10,
    /** 分享失败 */
    SErrorShareCodeFailure = 11
};

+ (SShareError *)getShareCancel;
+ (SShareError *)getShareFailure;
+ (SShareError *)getShareFailure:(NSString *)message;

@end
