//
//  ZZDecoder.m
//  libOS
//
//  Created by com4love on 14-7-25.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZDecoder.h"
#import "ZZController.h"

@implementation ZZDecoder

- (id)initDecoderWithTag:(unsigned int)rTag
{
    if (self) {
        _mTag = rTag;
        _mSpeexc = [[SpeexCodec alloc] init];
        _mSpeexc.delegateDecode = self;
    }
    
    return self;
}

- (void)decodeFileWithInputName:(NSString *)iName andOutputName:(NSString *)oName
{
    NSString* inUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* inFileUrl = [NSString stringWithFormat:@"%@/VoiceChat/%@", inUrl, iName];
    _mOutFileUrl = [NSString stringWithFormat:@"%@/VoiceChat/%@",inUrl, oName];

    NSData* inSpeexData = [NSData dataWithContentsOfFile:inFileUrl];
    //    NSLog(@"---------%d", [inPCMData length]);
    
    if (inSpeexData) {
        SpeexHeader *header = (SpeexHeader *)[inSpeexData bytes];
        float playTime = CalculatePlayTime(inSpeexData, header->reserved1);
        NSLog(@"the speex file is play %f",playTime);
    }
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:_mOutFileUrl error:nil];
    
    [_mSpeexc DecodeSpeexToWAVE:inSpeexData];

}

- (void)decodeSucceed:(id)speexCodec WithData:(NSData*)outPCMData
{
    [outPCMData writeToFile:_mOutFileUrl atomically:YES];
    
    [[ZZController sharedController] onDecodeSucceedWithTag:_mTag];
}

- (void)decodeFailed:(id)speexCodec
{
    [[ZZController sharedController] onDecodeFailedWithTag:_mTag];
}

- (void)dealloc
{
    [_mSpeexc release];
    _mSpeexc = nil;
    
    [super dealloc];
}

@end
