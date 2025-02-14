//
//  ZZPlayer.h
//  libOS
//
//  Created by com4love on 14-7-13.
//  Copyright (c) 2014年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface ZZPlayer : NSObject<AVAudioPlayerDelegate>
{
    AVAudioPlayer* _mPlayer;//播放器
    NSURL* _mFileUrl;//播放文件存放位置
    
    NSTimer* _mRefreshTimer;//音量刷新
    unsigned int _mTag;
    
}

- (id)initPlayerWithTag:(unsigned int)rTag;
- (void)playSoundWithName:(NSString* )fileName;
- (void)stopPlaying;

- (void)updateVoice;

- (void)changeToPlayVolumn;

@end
