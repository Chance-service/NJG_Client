//
//  SLog.h
//
//  Created by dev on 2017/8/15.
//  Copyright © 2017年 . All rights reserved.
//

#ifndef SLog_h
#define SLog_h

#import "SDataCenter.h"
#import "SConst.h"

#define SDLog(format, ...) if([SDataCenter getInstance].debugEnabled) NSLog(@"%@:%@", SSDKTag, [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define SELog(format, ...) NSLog(@"%@:%@", SSDKTag, [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define SILog(format, ...) NSLog(@"%@:%@", SSDKTag, [NSString stringWithFormat:format, ## __VA_ARGS__]);
#define SWLog(format, ...) NSLog(@"%@:%@", SSDKTag, [NSString stringWithFormat:format, ## __VA_ARGS__]);

#endif /* SLog_h */
