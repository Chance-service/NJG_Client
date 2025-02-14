//
//  BDVoice.h
//  BDVoice
//
//  Created by GuoDong on 14-12-1.
//  Copyright (c) 2014年 com4loves. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol BDVoiceDelegate <NSObject>
//登录结果回调
-(void)loginResult:(int)result MSG:(NSString*)msg YunvaID:(long)yunvaID;
//注销结果回调
-(void)logoutResult:(int)result MSG:(NSString*)msg;
//上传语音结果回调
-(void)uploadVoiceResult:(int)result URL:(NSString*)voiceURL Time:(long)voiceTime Info:(NSString*)voiceInfo;
//发送文本结果回调
-(void)sendTextResult:(int)result MSG:(NSString*)msg;
//发送文本和语音结果回调
-(void)sendtextAndVoiceResult:(int)result MSG:(NSString*)msg URL:(NSString*)url voiceDuration:(int)voiceduration FilePath:(NSString*)filepath Expand:(NSString*)expand Text:(NSString*)text;
//收到文本消息
-(void)receiveTextTroopsID:(NSString*)troopsID Text:(NSString*)text Expand:(NSString*)expand;
//收到语音信息
-(void)receiveVoiceTroopsID:(NSString*)troopsID Path:(NSString*)voicePath Time:(long)voiceTime text:(NSString*)text Info:(NSString*)voiceInfo;
//语音识别后，如果只发送文字，将文字返回
-(void)BDMineText:(NSString*)msg;
@end

@interface BDVoice : NSObject
@property (nonatomic,assign)id<BDVoiceDelegate> delegate;
@property (nonatomic,assign)BOOL bSupportVoiceAndText;  //判断发送文字或者发送文字语音
@property (nonatomic,assign)BOOL bIsPlaying;//判断语音是否在播放
+(BDVoice*)getInstance;                         //对象实例
-(void)Login:(NSString*)Seq;                    //登录
-(void)Logout;                                  //注销
-(void)startRecord:(NSString*)expand;           //开始录音
-(void)endRecord;                               //完成录音
-(void)cancelRecord;                            //取消录音
-(void)startOnlinePlayAudio:(NSString*)filepath;//开始播放
-(void)stopPlayAudio;                           //停止播放
-(BOOL)isPlaying;                               //判断是否正在播放
-(void)sendTextMessage:(NSString*)text expand:(NSString*)expand;//发送文本
@end
