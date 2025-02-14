//
//  YvAudioTools.h
//  
//
//  Created by 朱文腾 on 14-7-13.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YvRecognizerProtocol.h"



@class YvAudioTools;

@protocol YvAudioToolsDelegate <NSObject>

@optional

/**记录声音完毕*/
-(void)AudioTools:(YvAudioTools *)audiotools RecordCompleteWithVoiceData:(NSData *)voiceData voiceDuration:(int)voiceDuration filePath:(NSString *)filePath;

/**播放声音完毕*/
-(void)AudioToolsPlayComplete:(YvAudioTools *)audiotools;
-(void)AudioToolsPlayComplete:(YvAudioTools *)audiotools WithResult:(int)result;//result: 0--成功播放  非0--播放失败

/**在播放声音的时候当贴近屏幕的时候的状态事件，yes:贴近屏幕  no:没有贴近屏幕*/
-(void)AudioTools:(YvAudioTools *)audiotools ProximityStateChange:(BOOL)state;

/**当开启播放声音和录音的计量检测,返回播放声音的峰值和平均值*/
-(void)AudioTools:(YvAudioTools *)audiotools PlayMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;

/**当开启播放声音和录音的计量检测,返回录音的峰值和平均值*/
-(void)AudioTools:(YvAudioTools *)audiotools RecorderMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;



@end


@interface YvAudioTools : NSObject

@property (nonatomic,weak) id<YvAudioToolsDelegate> delegate;
@property (nonatomic,retain) NSString * RecordfilePath;
@property (nonatomic,assign) int Minseconds;
@property (nonatomic,assign) int Maxseconds;
    
//播放声音时,是否开启屏幕贴近检测,sdk会自动切换播放模式,默认是yes
@property (nonatomic,assign) BOOL ProximityMonitoringEnabled;
/**是否开启播放声音和录音时的计量检测,默认no*/
@property (nonatomic,assign) BOOL MeteringEnabled;

/**初始化音频工具默认参数
    recordfilePath:[NSTemporaryDirectory() stringByAppendingString:@"temp_audio.amr"] 
    minseconds:2 
    maxseconds:30 */
-(instancetype)initWithDelegate:(id<YvAudioToolsDelegate>)adelegate;

-(instancetype)initWithDelegate:(id<YvAudioToolsDelegate>)adelegate recordfilePath:(NSString *)recordfilePath minseconds:(int)minseconds maxseconds:(int)maxseconds;

#pragma mark - 语音录制
-(void)startRecord;
-(void)stopRecord;
-(BOOL)isRecording;

#pragma mark - 语音播放
/**amr文件的地址*/
-(void)playAudio:(NSString *)filePath;
-(void)playOnlineAudio:(NSString *)fileurl;
-(void)stopPlayAudio;
-(BOOL)isPlaying;

#pragma mark - 需要识别录制的语音设置的识别插件(YvVoicePcmDataRecognizerManage 设置初始化后放入)
/*****************语音识别专用******************/
/*语音识别设置的插件(插件需要初始化后再设置进来)*/
-(void)setRecognizerPlugin:(id<YvRecognizerProtocol>)recognizePluginDelegate;

/**开始语音识别，同时返回文字与声音*/
-(void)startRecordAndRecognize;

/**录制+语音识别结束*/
-(void)stopRecordAndRecognize;
/***********************************/



@end
