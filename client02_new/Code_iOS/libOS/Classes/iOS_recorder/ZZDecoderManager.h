//
//  ZZDecoderManager.h
//  libOS
//
//  Created by com4love on 14-7-25.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZZDecoder.h"

@interface ZZDecoderManager : NSObject
{
    NSMutableDictionary* _mDecodersDic;
}

+ (id)sharedDecoderManager;

- (ZZDecoder*)createDecoderWithTag:(unsigned int)rTag;
- (ZZDecoder*)getDecoderByTag:(unsigned int)rTag;
- (void)destoryDecoderByTag:(unsigned int)rTag;


@end
