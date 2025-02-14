//
//  ZZRecorderManager.h
//  libOS
//
//  Created by com4love on 14-7-16.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZRecorder.h"

@interface ZZRecorderManager : NSObject
{
    NSMutableDictionary* _mRecordersDic;
}

+(id)sharedRecorderManager;


- (ZZRecorder*)createRecorderWithType:(unsigned int)rType andTag:(unsigned int)rTag andFileName:(NSString*)fileName;
- (ZZRecorder*)getRecorderByTag:(unsigned int)rTag;
- (void)destoryRecorderByTag:(unsigned int)rTag;

@end
