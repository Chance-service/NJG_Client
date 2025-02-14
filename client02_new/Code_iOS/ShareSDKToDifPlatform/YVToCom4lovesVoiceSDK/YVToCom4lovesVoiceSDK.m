//
//  YVToCom4lovesVoiceSDK.m
//  YVToCom4lovesVoiceSDK
//
//  Created by fanleesong on 15/4/7.
//  Copyright (c) 2015年 com4loves. All rights reserved.
//

#import "YVToCom4lovesVoiceSDK.h"
#import "YvAudioTools.h"
#import "YvRecognizeManage.h"
#import "YvChatManage.h"
#define API_KEY @"sNW8dhjT8NNcubgoSZiT36aX" // 请修改为您在百度开发者平台申请的API_KEY
#define SECRET_KEY @"tNNBqgdAMMkSTVC5u3LumTG9xDvDgkoF" // 请修改您在百度开发者平台申请的SECRET_KEY


static YVToCom4lovesVoiceSDK *s_BDVoice;

@interface YVToCom4lovesVoiceSDK ()<YvAudioToolsDelegate,YvRecognizeManageDelegate,YvChatManageDelegate,NSURLConnectionDelegate>

@property (nonatomic,copy)NSString *recoderURL;
@property (nonatomic,copy)NSString *recoderStr;
@property (nonatomic,copy)NSString *expand;
@property (nonatomic,retain)NSMutableData* connectionData;
@property (nonatomic,retain)NSURLConnection *connection;
@property (nonatomic,retain)YvAudioTools *yvaudiotools;
@property (nonatomic,retain)YvRecognizeManage *recognizemamage;
@property (nonatomic,retain)YvChatManage *yvchatmanage;
@property (nonatomic,assign)BOOL cancelVoice;
@property (nonatomic,assign)BOOL bLogin;
//@property (nonatomic,assign)BOOL barriveText;
//@property (nonatomic,assign)BOOL barriveVoice;
@end


@implementation YVToCom4lovesVoiceSDK

+(YVToCom4lovesVoiceSDK *)getInstance{

    if(s_BDVoice == nil)
    {
        s_BDVoice = [[YVToCom4lovesVoiceSDK alloc] init];
        NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"temp_audio.amr"];
        YvAudioTools* yvatools = [[YvAudioTools alloc]initWithDelegate:s_BDVoice recordfilePath:path minseconds:1 maxseconds:15];
        s_BDVoice.yvaudiotools = yvatools;
        [yvatools release];
        
        YvRecognizeManage* recmamage = [[YvRecognizeManage alloc] initWithDelegate:s_BDVoice recognizePath:path minseconds:1 maxseconds:15 apiKey:API_KEY secretKey:SECRET_KEY];
        s_BDVoice.recognizemamage = recmamage;
        [recmamage release];
        
        YvChatManage *chatmanage = [[YvChatManage alloc] initWithAppId:@"500038" istest:NO];
        chatmanage.delegate = s_BDVoice;
        s_BDVoice.yvchatmanage = chatmanage;
        [chatmanage release];
        [s_BDVoice.yvchatmanage setLogLevel:5];
        [s_BDVoice initVoice];
    }
    return s_BDVoice;
    
}
-(void)initVoice
{
    self.bSupportVoiceAndText = YES;
    self.bIsPlaying = NO;
    self.cancelVoice = YES;
    self.bLogin = NO;
    //  [self addObserver:self forKeyPath:@"recoderURL" options:NSKeyValueObservingOptionNew context:NULL];
    //  [self addObserver:self forKeyPath:@"recoderStr" options:NSKeyValueObservingOptionNew context:NULL];
}

////KVO
//-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
//{
//    if([keyPath isEqualToString:@"recoderURL"])
//    {
//        NSString *newValue = [change objectForKey:NSKeyValueChangeNewKey];
//        if(newValue && ![newValue isEqualToString:@""])
//        {
//
//        }
//    }
//    else  if([keyPath isEqualToString:@"recoderStr"])
//    {
//        if(self.barriveVoice)
//        {
//        NSString *newValue = [change objectForKey:NSKeyValueChangeNewKey];
//        if(newValue && ![newValue isEqualToString:@""])
//        {
//
//        }
//        }
//    }
//}

#pragma mark----------------------------------------- interface -------------------------------------
//登录
-(void)Login:(NSString*)Seq
{
    if(!self.bLogin)
    {
        NSLog(@"login seq:");
        self.recoderStr = @"";
        self.recoderURL = @"";
        self.expand = @"";
        [self.yvchatmanage LoginWithSeq:Seq hasVideo:NO position:0 videoCount:0];
        NSLog(@"login seqend:");
    }
}

//注销
-(void)Logout
{
    //    if(self.bLogin)
    //        [self.yvchatmanage Logout];
}

//开始录音
-(void)startRecord:(NSString*)expand
{
    self.recoderStr = @"";
    if (self.isPlaying) {
        [self.yvaudiotools stopPlayAudio];
        self.bIsPlaying = NO;
    }
    //   [self.yvaudiotools startRecord];
    self.expand = expand;
    self.cancelVoice = NO;
    if(!self.bSupportVoiceAndText)
    {
        [self.recognizemamage startTextRecognize];
    }
    else
    {
        [self.recognizemamage startVoiceAndTextRecognize];
    }
    
    //    NSLog(@"###############startRecord");
}

//完成录音
-(void)endRecord
{
    //self.cancelVoice = NO;
    //   [self.yvaudiotools stopRecord];
    
    if(!self.bSupportVoiceAndText)
    {
        [self.recognizemamage finishTextRecognize];
    }
    else
    {
        [self.recognizemamage finishVoiceAndTextRecognize];
    }
    
    //    NSLog(@"###############endRecord");
}

//取消录音
-(void)cancelRecord
{
    if(self.cancelVoice == NO)
    {
        //  [self.yvaudiotools stopRecord];
        self.cancelVoice = YES;
        [self.recognizemamage cancelVoiceAndTextRecognize];
    }
    
    //
    //   self.bIsPlaying = NO;
    // [self.recognizemamage cancelVoiceAndTextRecognize];
}

//发送文本
-(void)sendTextMessage:(NSString*)text expand:(NSString*)expand
{
    //  [[YvChatManage sharedInstance]sendTextMessage:text expand:expand];
}


//开始播放
-(void)startOnlinePlayAudio:(NSString*)filepath
{
    if (self.bIsPlaying)
    {
        [self stopPlayAudio];
    }
    else {
        if(filepath != nil && ![filepath isEqualToString:@""])
            [self LoadURL:filepath];
        //[self.yvaudiotools playOnlineAudio:filepath];
    }
    
    
}

//停止播放
-(void)stopPlayAudio
{
    [self.yvaudiotools stopPlayAudio];
    self.bIsPlaying = NO;
}

//判断是否正在播放
-(BOOL)isPlaying
{
    return self.bIsPlaying;
}

#pragma mark--------------------------------------- Delegate -----------------------------------------

/**登录回调LoginWithSeq、LoginBindingWithTT*/
-(void)ChatManage:(YvChatManage *)sender LoginResp:(int)result msg:(NSString *)msg yunvaid:(UInt64)yunvaid
{
    if(result == 0)
    {
        NSLog(@"login success");
        self.bLogin = YES;
    }
    if(self.delegate)
    {
        if(msg == nil)
            msg = @"";
        [self.delegate loginResult:result MSG:msg YunvaID:yunvaid];
    }
}

/**注销回调*/
-(void)ChatManage:(YvChatManage *)sender LogoutResp:(int)result msg:(NSString *)msg
{
    if(result == 0)
        self.bLogin = NO;
    if(self.delegate)
    {
        if(msg == nil)
            msg = @"";
        [self.delegate logoutResult:result MSG:msg];
    }
}

-(void)ChatManage:(YvChatManage *)sender UserStateNotify:(UserStateNotify *)userStateNotify
{
    NSLog(@"state");
}

//录音完成回调
-(void)AudioTools:(YvAudioTools *)audiotools RecordCompleteWithVoiceData:(NSData *)voiceData voiceDuration:(int)voiceDuration filePath:(NSString *)filePath
{
    //    NSLog(@"%@",filePath);
    //发送录音
    if(self.bSupportVoiceAndText && !self.cancelVoice)
    {
        if(self.expand == nil)
            self.expand = @"";
        self.cancelVoice = YES;
        //设置延迟执行时间为1秒
        int64_t delayInSeconds = 1.0f;
        dispatch_time_t popTime =
        dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            //1秒过后执行其它操作
            NSString *mutalestr = [NSString stringWithFormat:@"%@&%@",self.expand,self.recoderStr];
            [[YvChatManage sharedInstance] sendVoiceMessage:filePath voiceDuration:voiceDuration expand:mutalestr];
        });
    }
}

/**发送语音留言回调,发送时会先上传到服务器并返回地址,故将上传的路径、时间返回*/
-(void)ChatManage:(YvChatManage *)sender SendVoiceMessageResp:(int)result msg:(NSString *)msg voiceUrl:(NSString *)voiceUrl voiceDuration:(UInt64)voiceDuration filePath:(NSString *)filePath expand:(NSString *)expand
{
    if(result == 0)
    {
        self.recoderURL = voiceUrl;
        int duration = (int)voiceDuration;
        if(self.delegate && self.bSupportVoiceAndText)
        {
            if(msg == nil)
                msg = @"";
            if(voiceUrl)
            {
                [self.delegate uploadVoiceResult:result URL:voiceUrl Time:duration Info:expand];
                [self.delegate sendtextAndVoiceResult:result MSG:msg URL:voiceUrl voiceDuration:duration FilePath:filePath Expand:self.expand Text:self.recoderStr];
            }
        }
    }
    else
    {
        NSLog(@"failue Upload");
    }
    
}

/**发送文本消息返回，只有消息发送失败才会收到回调*/
-(void)ChatManage:(YvChatManage *)sender SendTextMessageError:(int)result msg:(NSString *)msg
{
    if(self.delegate)
    {
        if(msg == nil)
            msg = @"";
        [self.delegate sendTextResult:result MSG:msg];
    }
}

/**接受到文本通知*/
-(void)ChatManage:(YvChatManage *)sender TextMessageNotify:(TextMessageNotify *)TextMessageNotify
{
    if(self.delegate)
    {
        [self.delegate receiveTextTroopsID:TextMessageNotify.chatRoomId Text:TextMessageNotify.text Expand:TextMessageNotify.expand];
    }
}

/**接受语音留言通知*/
-(void)ChatManage:(YvChatManage *)sender VoiceMessageNotify:(VoiceMessageNotify *)VoiceMessageNotify
{
    if(self.delegate)
    {
        NSString* notifyexpand = VoiceMessageNotify.expand;
        if(notifyexpand)
        {
            NSArray *list=[notifyexpand componentsSeparatedByString:@"&"];
            NSString* expand = [list objectAtIndex:0];
            NSString* text = [list objectAtIndex:1];
            [self.delegate receiveVoiceTroopsID:VoiceMessageNotify.chatRoomId Path:VoiceMessageNotify.voiceUrl Time:VoiceMessageNotify.voiceTime text:text Info:expand];
        }
    }
}

/**播放声音完毕*/
-(void)AudioToolsPlayComplete:(YvAudioTools *)audiotools
{
    self.bIsPlaying = NO;
}

#pragma mark--------------------------------- recognize delegate ------------------------------------
//文字识别回调
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage finishRecognizeTextResp:(NSString *)Text
{
    NSLog(@"%@",Text);
    self.recoderStr = Text;
    if(!self.bSupportVoiceAndText && self.delegate)
    {
        [self.delegate BDMineText:self.recoderStr];
        [self sendTextMessage:self.recoderStr expand:self.expand];
        //        NSLog(@"###################RecognizeManage");
    }
}

//开始识别回调
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage startRecognizeVoiceAndText:(BOOL)start
{
    if(start)
    {
        [self.yvaudiotools startRecord];
    }
}

//结束识别回调
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage finishRecognizeVoiceAndText:(BOOL)finish
{
    if(finish)
    {
        [self.yvaudiotools stopRecord];
    }
}

//-----------------------------------------------------------------------------------------
- (void)LoadURL:(NSString*)URL
{
    //文件地址
    NSString *urlAsString = URL;
    NSURL    *url = [NSURL URLWithString:urlAsString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSMutableData *data = [[NSMutableData alloc] init];
    self.connectionData = data;
    [data release];
    NSURLConnection *newConnection = [[NSURLConnection alloc]
                                      initWithRequest:request
                                      delegate:self
                                      startImmediately:YES];
    self.connection = newConnection;
    [newConnection release];
    if (self.connection != nil){
        NSLog(@"Successfully created the connection");
    } else {
        NSLog(@"Could not create the connection");
    }
}




- (void) connection:(NSURLConnection *)connection
   didFailWithError:(NSError *)error{
    NSLog(@"An error happened");
    NSLog(@"%@", error);
}
- (void) connection:(NSURLConnection *)connection
     didReceiveData:(NSData *)data{
    NSLog(@"Received data");
    [self.connectionData appendData:data];
}
- (void) connectionDidFinishLoading
:(NSURLConnection *)connection{
    /* 下载的数据 */
    
    NSLog(@"下载成功");
    NSString *path = [NSTemporaryDirectory() stringByAppendingString:@"temp_audio.amr"];
    if ([self.connectionData writeToFile:path atomically:YES]) {
        NSLog(@"保存成功.");
        self.bIsPlaying = YES;
        [self.yvaudiotools playAudio:path];
        
    }
    else
    {
        NSLog(@"保存失败.");
    }
    
    /* do something with the data here */
}
- (void) connection:(NSURLConnection *)connection
 didReceiveResponse:(NSURLResponse *)response{
    [self.connectionData setLength:0];
}

-(void)dealloc
{
    self.yvchatmanage = nil;
    self.yvaudiotools = nil;
    self.recognizemamage = nil;
    // [self removeObserver:self forKeyPath:@"recoderURL"];
    // [self removeObserver:self forKeyPath:@"recoderStr"];
    [super dealloc];
}

@end


