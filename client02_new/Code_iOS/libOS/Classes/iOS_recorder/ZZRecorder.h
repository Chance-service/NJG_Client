//
//  ZZRecorder.h
//  libOS
//
//  Created by com4love on 14-7-13.
//  Copyright (c) 2014年 youai. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZZRecorder : NSObject<AVAudioRecorderDelegate>
{
    AVAudioRecorder* _mRecorder;//录音器
    NSURL* _mFileUrl;//录音文件存放位置
    NSTimer* _mRefreshTimer;
    
    unsigned int _mTag;
    unsigned int _mType;
    NSString* _mFileName;
    
}

@property (nonatomic, copy) NSString* mFileName;
@property (nonatomic, assign) unsigned int mType;

//filename: temp.acc
- (id)initWithType:(unsigned int)rType andTag:(unsigned int)rTag andFileName:(NSString*)fileName;
- (void)beginRecorder;
- (void)finishRecorder;
- (void)cancelRecorder;

- (void)updateVoice;

- (void)_createRecorder;

- (BOOL)canRecord;

- (void)changeToRecordVolumn;
@end
