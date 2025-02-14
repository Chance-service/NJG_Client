//
//  ZZRecorderManager.m
//  libOS
//
//  Created by com4love on 14-7-16.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZRecorderManager.h"

@implementation ZZRecorderManager


+(id)sharedRecorderManager
{
    static ZZRecorderManager* single = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{single = [[self alloc] init];});
    
    return single;
}

-(id)init
{
    if (self = [super init])
    {
        _mRecordersDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

-(void)dealloc
{
    [_mRecordersDic release];
    _mRecordersDic = nil;
    [super dealloc];
}

- (ZZRecorder*)createRecorderWithType:(unsigned int)rType andTag:(unsigned int)rTag andFileName:(NSString *)fileName
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZRecorder* obj = [_mRecordersDic objectForKey:tag];
    
    if (obj != nil) {
        NSLog(@"it is have same tag recoder");
        obj.mFileName = fileName;
        obj.mType = rType;
        return obj;
    }
    
    
    ZZRecorder* recorder = [[ZZRecorder alloc] initWithType:rType andTag:rTag andFileName:fileName];
    
    [_mRecordersDic setObject:recorder forKey:tag];
    
    return recorder;
}

-(ZZRecorder*)getRecorderByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    return [_mRecordersDic objectForKey:tag];
}

-(void)destoryRecorderByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZRecorder* obj = [_mRecordersDic objectForKey:tag];
    [obj release];
    [_mRecordersDic removeObjectForKey:tag];
}

@end
