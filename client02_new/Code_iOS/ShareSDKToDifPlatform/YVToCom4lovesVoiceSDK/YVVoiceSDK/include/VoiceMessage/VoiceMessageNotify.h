//
//  VoiceMessageNotify.h
//  ChatSDK
//
//  Created by 朱文腾 on 14-8-19.
//  Copyright (c) 2014年 yunva.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceMessageNotify : NSObject

@property (assign, nonatomic) UInt32 yunvaId;
@property (retain, nonatomic) NSString * chatRoomId;
@property (retain, nonatomic) NSString * voiceUrl;
@property (assign, nonatomic) UInt64 voiceTime;
@property (assign, nonatomic) UInt64 time;
@property (retain, nonatomic) NSString * expand;

@end
