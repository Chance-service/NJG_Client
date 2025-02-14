//
//  ZZPlayer.m
//  libOS
//
//  Created by com4love on 14-7-13.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZPlayer.h"
#import "ZZController.h"

@implementation ZZPlayer

- (id)initPlayerWithTag:(unsigned int)rTag
{
    if (self = [super init])
    {
        _mTag = rTag;
        //NSURL* u = [NSURL URLWithString:@""];
        //_mPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:u error:nil];
        
        //_mRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateVoice) userInfo:nil repeats:YES];
    }
    
    return self;
}


- (void)playSoundWithName:(NSString *)fileName
{
    
    [self changeToPlayVolumn];
    
    if ([_mPlayer isPlaying])
    {
        
        [_mPlayer stop];
        return;
    }
    
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * fileUrl = [NSString stringWithFormat:@"%@/VoiceChat/%@", urlStr, fileName];
    NSURL *url = [NSURL fileURLWithPath: fileUrl];
    _mFileUrl = url;
    
    _mPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:_mFileUrl error:nil];
    _mRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateVoice) userInfo:nil repeats:YES];
    
    if (_mPlayer) {
        [_mPlayer setDelegate:self];
        [_mPlayer setVolume:1.0f];
        
        [_mPlayer play];
        //设置定时检测,取得每一time的声量
        
        [[ZZController sharedController] onPlayerDidStarted:_mTag];
    }

    
}

- (void)changeToPlayVolumn
{
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
}

- (void)stopPlaying
{
    if ([_mPlayer isPlaying]) {
        [_mPlayer stop];
        [_mRefreshTimer invalidate];
        [_mPlayer release];
        _mPlayer = nil;
    }
}

- (void)dealloc
{
    [_mPlayer release];
    _mPlayer = nil;
    [super dealloc];
}


- (void)updateVoice
{
    if (_mPlayer.playing)
    {
        [_mPlayer updateMeters];//刷新音量数据
        //获取音量的平均值  [recorder averagePowerForChannel:0];
        //音量的最大值  [recorder peakPowerForChannel:0];
        
        //当前音量（0 ~ 50）
        double lowPassResults = pow(10, (0.05 * [_mPlayer peakPowerForChannel:0]));
        //double lowPassResults = pow(10, (0.05 * [_mPlayer peakPowerForChannel:0]));
        //NSLog(@"%lf",lowPassResults);
        
        
        double vol = 0;
        if (0<lowPassResults<=0.06) {
            vol = 0.1f;
        }else if (0.06<lowPassResults<=0.13) {
            vol = 0.15f;
        }else if (0.13<lowPassResults<=0.20) {
            vol = 0.2f;
        }else if (0.20<lowPassResults<=0.27) {
            vol = 0.3f;
        }else if (0.27<lowPassResults<=0.34) {
            vol = 0.4f;
        }else if (0.34<lowPassResults<=0.41) {
            vol = 0.5f;
        }else if (0.41<lowPassResults<=0.48) {
            vol = 0.55f;
        }else if (0.48<lowPassResults<=0.55) {
            vol = 0.6f;
        }else if (0.55<lowPassResults<=0.62) {
            vol = 0.7f;
        }else if (0.62<lowPassResults<=0.69) {
            vol = 0.8f;
        }else if (0.69<lowPassResults<=0.76) {
            vol = 0.9f;
        }else if (0.76<lowPassResults<=0.83) {
            vol = 0.92f;
        }else if (0.83<lowPassResults<=0.9) {
            vol = 0.93f;
        }else {
            vol = 0.1f;
        }
        
        [[ZZController sharedController] onPlayerPlayingWithVolumn:lowPassResults andTag:_mTag];
        
        
    }
    
}










- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [[ZZController sharedController] onPlayerDidFinishPlayingWithTag:_mTag andResult:flag];
    [_mRefreshTimer invalidate];
    [_mPlayer release];
    _mPlayer =nil;
}

/* if an error occurs while decoding it will be reported to the delegate. */
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
{
    [[ZZController sharedController] audioPlayerDecodeErrorWithTag:_mTag andErrorCode:error];
    [_mRefreshTimer invalidate];
    [_mPlayer release];
    _mPlayer = nil;
}



@end
