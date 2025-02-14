//
//  ZZRecorder.m
//  libOS
//
//  Created by com4love on 14-7-13.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import "ZZRecorder.h"
#import "ZZController.h"
#import <UIKit/UIKit.h>

@implementation ZZRecorder

@synthesize mFileName = _mFileName;
@synthesize mType = _mType;

- (id)initWithType:(unsigned int)rType andTag:(unsigned int)rTag andFileName:(NSString *)fileName
{
    if (self = [super init])
    {
        _mTag = rTag;
        self.mFileName = fileName;
        _mType = rType;
        
        
        
        /**
        //录音设置
        NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc]init] autorelease];
        
        //设置录音存储格式  AVFormatIDKey==kAudioFormatLinearPCM(wav是容器格式，数据格式是PCM码)
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
        
        
        //设置录音采样率(Hz) 如：rType:AVSampleRateKey==8000/44100/96000（影响音频的质量）
        [recordSetting setValue:[NSNumber numberWithFloat:_mType] forKey:AVSampleRateKey];
        
        //录音通道数  1 或 2
        [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
        
        //线性采样位数  8、16、24、32
        [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
        
        //录音的质量
        [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
        
        NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString * fileUrl = [NSString stringWithFormat:@"%@/%@", urlStr, self.mFileName];
        NSURL *url = [NSURL fileURLWithPath: fileUrl];
        _mFileUrl = url;
        
        NSError *error;
        //初始化
        _mRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
        //开启音量检测
        _mRecorder.meteringEnabled = YES;
        _mRecorder.delegate = self;
         
         **/
    }
    
    
    return self;
}

- (void)_createRecorder
{
    
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        //7.0第一次运行会提示，是否允许使用麦克风
        AVAudioSession *session = [AVAudioSession sharedInstance];
        NSError *sessionError;
        //AVAudioSessionCategoryPlayAndRecord用于录音和播放
        [session setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
        if(session == nil)
            NSLog(@"Error creating session: %@", [sessionError description]);
        else
            [session setActive:YES error:nil];
    }
    
    
    
    if (_mRecorder != nil) {
        _mRecorder.delegate = nil;
        [_mRecorder release];
        _mRecorder = nil;
    }
    
    NSMutableDictionary *recordSetting = [[[NSMutableDictionary alloc]init] autorelease];
    
    //设置录音存储格式  AVFormatIDKey==kAudioFormatLinearPCM(wav是容器格式，数据格式是PCM码)
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    
    
    //设置录音采样率(Hz) 如：rType:AVSampleRateKey==8000/44100/96000（影响音频的质量）
    [recordSetting setValue:[NSNumber numberWithFloat:_mType] forKey:AVSampleRateKey];
    
    //录音通道数  1 或 2
    [recordSetting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    //线性采样位数  8、16、24、32
    [recordSetting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    //录音的质量
    [recordSetting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSString *urlStr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString * fileUrl = [NSString stringWithFormat:@"%@/VoiceChat/%@", urlStr, self.mFileName];
    NSURL *url = [NSURL fileURLWithPath: fileUrl];
    _mFileUrl = url;
    
    NSError *error;
    //初始化
    _mRecorder = [[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:&error];
    //开启音量检测
    _mRecorder.meteringEnabled = YES;
    _mRecorder.delegate = self;
    
}

- (void)beginRecorder
{
    [self changeToRecordVolumn];
    
    NSLog(@"begi-------------------");
    
    if ([self canRecord]) {
        [self _createRecorder];
        
        //创建录音文件，准备录音
        if ([_mRecorder prepareToRecord]) {
            
            //开始
            [_mRecorder record];
            
            [[ZZController sharedController] onRecorderStartedWithTag:_mTag];
        }
        
        //设置定时检测,取得每一time的声量
        _mRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(updateVoice) userInfo:nil repeats:YES];
    }
    

}


- (void)finishRecorder
{
    
    
    NSLog(@"en____________________d");
    //double cTime = _mRecorder.currentTime;
    
    //if (cTime > 2) {//如果录制时间<2 不发送
    //    NSLog(@"发出去");90
    //}else {
        //删除记录的文件
    //[_mRecorder deleteRecording];
       //删除存储的
   // }
    
    
    //buyaodiaoyong isRecording, zhehanshubudui
    //if ([_mRecorder isRecording]) {
        [_mRecorder stop];
        
        if (_mRefreshTimer) {
            [_mRefreshTimer invalidate];//stop新计时器
        }
    //}

}

- (void)cancelRecorder
{
    //删除录制文件
    [_mRecorder deleteRecording];
    [_mRecorder stop];
    [_mRefreshTimer invalidate];//stop计时器

}

- (void)changeToRecordVolumn
{
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryRecord error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    UInt32 doChangeDefault = 1;
    
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefault), &doChangeDefault);
}

- (void)updateVoice
{
    [_mRecorder updateMeters];//刷新音量数据
    //获取音量的平均值  [recorder averagePowerForChannel:0];
    //音量的最大值  [recorder peakPowerForChannel:0];
    
    //当前音量（0 ~ 50）
    double lowPassResults = pow(10, (0.05 * [_mRecorder peakPowerForChannel:0]));
    //double lowPassResults = pow(10, (0.05 * [_mRecorder peakPowerForChannel:0])) * 100000;
    //NSLog(@"%lf",lowPassResults);
    
    //double lowPassResults = [_mRecorder averagePowerForChannel:0];
    
    
    //最大50  0
    //图片 小-》大
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
     
    
    [[ZZController sharedController] onRecorderRecordingWithVolumn:vol andTag:_mTag];

}



- (void)dealloc
{
    [[ZZController sharedController] onRecorderDestroyedWithTag:_mTag];
    [_mRecorder release];
    _mRecorder = nil;
    
    [_mFileName release];
    _mFileName = nil;
    [super dealloc];
}


//判断是否允许使用麦克风7.0新增的方法requestRecordPermission
-(BOOL)canRecord
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[[UIAlertView alloc] initWithTitle:nil
                                                    message:@"app需要访问您的麦克风。\n请启用麦克风-设置/隐私/麦克风"
                                                   delegate:nil
                                          cancelButtonTitle:@"关闭"
                                          otherButtonTitles:nil] show];
                    });
                }
            }];
        }
    }
    
    return bCanRecord;
}



/* audioRecorderDidFinishRecording:successfully: is called when a recording has been finished or stopped. This method is NOT called if the recorder is stopped due to an interruption. */
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    if (flag) {
        [[ZZController sharedController] onRecorderSucceedWithTag:_mTag];
    }
    else
    {
        [[ZZController sharedController] onRecorderFailedWithTag:_mTag];
    }
}

/* if an error occurs while encoding it will be reported to the delegate. */
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [[ZZController sharedController] onRecorderFailedWithTag:_mTag];
}

//#if TARGET_OS_IPHONE

/* audioRecorderBeginInterruption: is called when the audio session has been interrupted while the recorder was recording. The recorded file will be closed. */
//- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder;

/* audioRecorderEndInterruption:withOptions: is called when the audio session interruption has ended and this recorder had been interrupted while recording. */
/* Currently the only flag is AVAudioSessionInterruptionFlags_ShouldResume. */
//- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags NS_AVAILABLE_IOS(6_0);

//- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags NS_DEPRECATED_IOS(4_0, 6_0);

/* audioRecorderEndInterruption: is called when the preferred method, audioRecorderEndInterruption:withFlags:, is not implemented. */
//- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder NS_DEPRECATED_IOS(2_2, 6_0);









@end
