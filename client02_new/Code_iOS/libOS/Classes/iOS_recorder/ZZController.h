//
//  ZZController.h
//  libOS
//
//  Created by com4love on 14-7-16.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZZController : NSObject

+(id)sharedController;

//recorder
- (void)onRecorderStartedWithTag:(unsigned int)rTag;
- (void)onRecorderRecordingWithVolumn:(double)rVolumn andTag:(unsigned int)rTag;
- (void)onRecorderSucceedWithTag:(unsigned int)rTag;
- (void)onRecorderFailedWithTag:(unsigned int)rTag;
- (void)onRecorderDestroyedWithTag:(unsigned int)rTag;

//player
- (void)onPlayerDidStarted:(unsigned int)rTag;
- (void)onPlayerPlayingWithVolumn:(double)rVolumn andTag:(unsigned int)rTag;
- (void)onPlayerDidFinishPlayingWithTag:(unsigned int)rTag andResult:(bool)successfully;
- (void)audioPlayerDecodeErrorWithTag:(unsigned int)rTag andErrorCode:(unsigned int)errorCode;

//encode
- (void)onEncodeSucceedWithTag:(unsigned int)rTag;
- (void)onEncodeFailedWithTag:(unsigned int)rTag;

//decode
- (void)onDecodeSucceedWithTag:(unsigned int)rTag;
- (void)onDecodeFailedWithTag:(unsigned int)rTag;


@end
