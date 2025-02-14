//
//  ZZPlayerManager.m
//  libOS
//
//  Created by com4love on 14-7-16.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZPlayerManager.h"

@implementation ZZPlayerManager

+(id)sharedPlayerManager
{
    static ZZPlayerManager* single = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{single = [[self alloc] init];});
    
    return single;
}

-(id)init
{
    if (self = [super init])
    {
        _mPlayersDic = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    
    return self;
}

-(void)dealloc
{
    [_mPlayersDic release];
    _mPlayersDic = nil;
    [super dealloc];
}

- (ZZPlayer*)createPlayerWithType:(unsigned int)rType andTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZPlayer* obj = [_mPlayersDic objectForKey:tag];
    
    if (obj != nil) {
        NSLog(@"it is have same tag player");
        return obj;
    }
    
    
    ZZPlayer* player = [[ZZPlayer alloc] initPlayerWithTag:rTag];
    
    [_mPlayersDic setObject:player forKey:tag];
    
    return player;
}

-(ZZPlayer*)getPlayerByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    return [_mPlayersDic objectForKey:tag];
}

-(void)destoryPlayerByTag:(unsigned int)rTag
{
    NSNumber* tag = [NSNumber numberWithUnsignedInt:rTag];
    
    ZZPlayer* obj = [_mPlayersDic objectForKey:tag];
    [obj release];
    [_mPlayersDic removeObjectForKey:tag];
}



@end
