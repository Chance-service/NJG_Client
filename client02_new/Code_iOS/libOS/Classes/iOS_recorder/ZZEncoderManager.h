//
//  ZZEncoderManager.h
//  libOS
//
//  Created by com4love on 14-7-25.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZEncoder.h"

@interface ZZEncoderManager : NSObject
{
    NSMutableDictionary* _mEncodersDic;
}

+ (id)sharedEncoderManager;

- (ZZEncoder*)createEncoderWithTag:(unsigned int)rTag;
- (ZZEncoder*)getEncoderByTag:(unsigned int)rTag;
- (void)destoryEncoderByTag:(unsigned int)rTag;
@end
