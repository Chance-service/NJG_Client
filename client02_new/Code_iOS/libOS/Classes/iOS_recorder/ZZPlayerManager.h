//
//  ZZPlayerManager.h
//  libOS
//
//  Created by com4love on 14-7-16.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "ZZPlayer.h"

@interface ZZPlayerManager : NSObject
{
    NSMutableDictionary* _mPlayersDic;
}

+(id)sharedPlayerManager;


- (ZZPlayer*)createPlayerWithType:(unsigned int)rType andTag:(unsigned int)rTag;
- (ZZPlayer*)getPlayerByTag:(unsigned int)rTag;
- (void)destoryPlayerByTag:(unsigned int)rTag;

@end