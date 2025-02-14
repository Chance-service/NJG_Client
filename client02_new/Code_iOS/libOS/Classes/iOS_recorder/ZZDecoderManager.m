//
//  ZZDecoderManager.m
//  libOS
//
//  Created by com4love on 14-7-25.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZDecoderManager.h"

@implementation ZZDecoderManager

+(id)sharedDecoderManager
{
    static ZZDecoderManager* single = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{single = [[self alloc] init];});
    
    return single;
}

-(id)init
{
    if (self = [super init])
    {
        _mDecodersDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

-(void)dealloc
{
    [_mDecodersDic release];
    _mDecodersDic = nil;
    [super dealloc];
}

- (ZZDecoder*)createDecoderWithTag:(unsigned int)rTag;
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZDecoder* obj = [_mDecodersDic objectForKey:tag];
    
    if (obj != nil) {
        NSLog(@"it is have same tag decoder");
        return obj;
    }
    
    
    ZZDecoder* decoder = [[ZZDecoder alloc] initDecoderWithTag:rTag];
    
    [_mDecodersDic setObject:decoder forKey:tag];
    
    return decoder;
}

-(ZZDecoder*)getDecoderByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    return [_mDecodersDic objectForKey:tag];
}

-(void)destoryDecoderByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZDecoder* obj = [_mDecodersDic objectForKey:tag];
    [obj release];
    [_mDecodersDic removeObjectForKey:tag];
}


@end
