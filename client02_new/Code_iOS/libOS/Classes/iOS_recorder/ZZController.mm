//
//  ZZController.m
//  libOS
//
//  Created by com4love on 14-7-16.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZController.h"
//#import "libOS.h"
#include "RecorderController.h"
#include "PlayerControllerManager.h"
#include "PlayerController.h"
#include "DecodeControllerManager.h"
#include "DecodeController.h"
#include "EncodeControllerManager.h"
#include "EncodeController.h"
#include "RecorderControllerManager.h"
@implementation ZZController

+(id)sharedController
{
    static ZZController* single = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{single = [[self alloc] init];});
    
    return single;
}

-(id)init
{
    if (self = [super init])
    {

    }
    
    return self;
}

-(void)dealloc
{
    [super dealloc];
}

//recorder
- (void)onRecorderStartedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onRecorderStarted(rTag);
    RecorderController* controller = RecorderControllerManager::getInstance()->getRecorderControllerByTag(rTag);
    if (controller)
    {
        controller->onRecorderStarted(rTag);
    }
}

- (void)onRecorderRecordingWithVolumn:(double)rVolumn andTag:(unsigned int)rTag
{
//    libOS::getInstance()->onRecorderRecording(rVolumn,rTag);
    RecorderController* controller = RecorderControllerManager::getInstance()->getRecorderControllerByTag(rTag);
    if (controller)
    {
        controller->onRecorderRecording(rVolumn, rTag);
    }
}

- (void)onRecorderSucceedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onRecorderSucceed(rTag);
    RecorderController* controller = RecorderControllerManager::getInstance()->getRecorderControllerByTag(rTag);
    if (controller)
    {
        controller->onRecorderSucceed(rTag);
    }
}

- (void)onRecorderFailedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onRecorderFailed(rTag);
    RecorderController* controller = RecorderControllerManager::getInstance()->getRecorderControllerByTag(rTag);
    if (controller)
    {
        controller->onRecorderFailed(rTag);
    }
}

- (void)onRecorderDestroyedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onRecorderDestroyed(rTag);
    RecorderController* controller = RecorderControllerManager::getInstance()->getRecorderControllerByTag(rTag);
    if (controller)
    {
        controller->onRecorderDestroyed(rTag);
    }
}

//player
- (void)onPlayerDidStarted:(unsigned int)rTag
{
//    libOS::getInstance()->onPlayerDidStarted(rTag);
    PlayerController* controller = PlayerControllerManager::Get()->getPlayerControllerByTag(rTag);
    if (controller)
    {
        controller->onPlayerDidStarted(rTag);
    }
}

- (void)onPlayerPlayingWithVolumn:(double)rVolumn andTag:(unsigned int)rTag
{
//    libOS::getInstance()->onPlayerPlaying(rVolumn, rTag);
    PlayerController* controller = PlayerControllerManager::Get()->getPlayerControllerByTag(rTag);
    if (controller)
    {
        controller->onPlayerPlaying(rVolumn, rTag);
    }
}

- (void)onPlayerDidFinishPlayingWithTag:(unsigned int)rTag andResult:(bool)successfully
{
//    libOS::getInstance()->onPlayerDidFinishPlaying(rTag, successfully);
    PlayerController* controller = PlayerControllerManager::Get()->getPlayerControllerByTag(rTag);
    if (controller)
    {
        controller->onPlayerDidFinishPlayering(successfully,rTag);
    }
}

- (void)audioPlayerDecodeErrorWithTag:(unsigned int)rTag andErrorCode:(unsigned int)errorCode
{
//    libOS::getInstance()->audioPlayerDecodeError(rTag, errorCode);
    PlayerController* controller = PlayerControllerManager::Get()->getPlayerControllerByTag(rTag);
    if (controller)
    {
        controller->audioPlayerDecodeError(errorCode, rTag);
    }
}

//encode
- (void)onEncodeSucceedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onEncodeSucceed(rTag);
    EncodeController* controller = EncodeControllerManager::Get()->getEncodeControllerByTag(rTag);
    if (controller)
    {
        controller->onEncodeSucceed(rTag);
    }
}

- (void)onEncodeFailedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onEncodeFailed(rTag);
    EncodeController* controller = EncodeControllerManager::Get()->getEncodeControllerByTag(rTag);
    if (controller)
    {
        controller->onEncodeFailed(rTag);
    }
}

//decode
- (void)onDecodeSucceedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onDecodeSucceed(rTag);
    DecodeController* controller = DecodeControllerManager::Get()->getDecodeControllerByTag(rTag);
    if (controller)
    {
        controller->onDecodeSucceed(rTag);
    }
}

- (void)onDecodeFailedWithTag:(unsigned int)rTag
{
//    libOS::getInstance()->onDecodeFailed(rTag);
    DecodeController* controller = DecodeControllerManager::Get()->getDecodeControllerByTag(rTag);
    if (controller)
    {
        controller->onDecodeFailed(rTag);
    }
}

@end
