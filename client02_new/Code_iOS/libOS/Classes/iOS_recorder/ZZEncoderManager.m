//
//  ZZEncoderManager.m
//  libOS
//
//  Created by com4love on 14-7-25.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZEncoderManager.h"

@implementation ZZEncoderManager

+(id)sharedEncoderManager
{
    static ZZEncoderManager* single = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{single = [[self alloc] init];});
    
    return single;
}

-(id)init
{
    if (self = [super init])
    {
        _mEncodersDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

-(void)dealloc
{
    [_mEncodersDic release];
    _mEncodersDic = nil;
    [super dealloc];
}

- (ZZEncoder*)createEncoderWithTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZEncoder* obj = [_mEncodersDic objectForKey:tag];
    
    if (obj != nil) {
        NSLog(@"it is have same tag encoder");
        return obj;
    }
    
    
    ZZEncoder* encoder = [[ZZEncoder alloc] initEncoderWithTag:rTag];
    
    [_mEncodersDic setObject:encoder forKey:tag];
    
    return encoder;
}

-(ZZEncoder*)getEncoderByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    return [_mEncodersDic objectForKey:tag];
}

-(void)destoryEncoderByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZEncoder* obj = [_mEncodersDic objectForKey:tag];
    [obj release];
    [_mEncodersDic removeObjectForKey:tag];
}



@end
