//
//  ZZDecoder.h
//  libOS
//
//  Created by com4love on 14-7-25.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpeexCodec.h"

@interface ZZDecoder : NSObject<SpeexCodecDecodeDelegate>
{
    SpeexCodec* _mSpeexc;
    unsigned int _mTag;
    NSString* _mOutFileUrl;
}

- (id)initDecoderWithTag:(unsigned int)rTag;
- (void)decodeFileWithInputName:(NSString* )iName andOutputName:(NSString* )oName;

@end
