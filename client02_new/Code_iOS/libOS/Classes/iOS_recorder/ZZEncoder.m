//
//  ZZEncoder.m
//  libOS
//
//  Created by com4love on 14-7-25.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZEncoder.h"
#import "ZZController.h"

@implementation ZZEncoder


- (id)initEncoderWithTag:(unsigned int)rTag
{
    if (self = [super init]) {
        _mTag = rTag;
        _mSpeexc = [[SpeexCodec alloc] init];
        _mSpeexc.delegateEncode = self;
    }
    
    return self;
}

- (void)encodeFileWithInputName:(NSString *)iName andOutputName:(NSString *)oName
{
    // NSString *filePath = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"caf"];
    
    NSString* inUrl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString* inFileUrl = [NSString stringWithFormat:@"%@/VoiceChat/%@", inUrl, iName];
    _mOutFileUrl = [NSString stringWithFormat:@"%@/VoiceChat/%@",inUrl, oName];

    NSData* inPCMData = [NSData dataWithContentsOfFile:inFileUrl];
    //    NSLog(@"---------%d", [inPCMData length]);
    
    
    NSFileManager * fileMgr = [NSFileManager defaultManager];
    
    [fileMgr removeItemAtPath:_mOutFileUrl error:nil];
    
    [_mSpeexc EncodeWAVEToSpeex:inPCMData withChannels:1 andBitsPerSample:16];
    //    NSLog(@"---------%d", [inSpeexData length]);

}

- (void)encodeSucceed:(id)speexCodec WithData:(NSData*)outSpeexData
{
    [outSpeexData writeToFile:_mOutFileUrl atomically:YES];
    
    [[ZZController sharedController] onEncodeSucceedWithTag:_mTag];
}

- (void)encodeFailed:(id)speexCodec
{
    [[ZZController sharedController] onEncodeFailedWithTag:_mTag];
}

- (void)dealloc
{
    [_mSpeexc release];
    _mSpeexc = nil;
    
    [super dealloc];
}

@end
