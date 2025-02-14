//
//  YvRecognizeManage.h
//  ChatSDK
//
//  Created by 李文杰 on 14-11-13.
//  Copyright (c) 2014年 com.yunva.yaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YvRecognizerProtocol.h"


#define API_KEY @"sNW8dhjT8NNcubgoSZiT36aX" // 请修改为您在百度开发者平台申请的API_KEY
#define SECRET_KEY @"tNNBqgdAMMkSTVC5u3LumTG9xDvDgkoF" // 请修改您在百度开发者平台申请的SECRET_KEY




@class YvRecognizeManage;

@protocol YvRecognizeManageDelegate <NSObject>
@optional
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage finishRecognizeTextResp:(NSString *)Text;

-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage finishRecognizeVoiceResp:(NSData *)recognizeVoice;

-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage finishVoiceResp:(NSData *)recognizeVoice filePath:(NSString *)path voiceDuration:(int)voiceDuration expand:(NSString *)expand;

/**录音识别回应*/
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage startRecognizeVoiceAndText:(BOOL)start;
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage finishRecognizeVoiceAndText:(BOOL)finish;

/**实时语音识别回应*/
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage startRecognizeRealVoice:(BOOL)start;
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage finishRecognizeRealVoice:(BOOL)finish;
/**连续上屏回应*/
-(void)RecognizeManage:(YvRecognizeManage *)RecognizeManage resultContinuousShow:(NSString *)voiceText;

/**
 语音识别启动失败回调
 @param startErrorStatus  枚举enum TVoiceRecognitionStartWorkResult
 */
-(void)onVoiceRecognitionClientStartError:(int)startErrorStatus;

/* 识别过程中错误的错误码:  (aStatus: 枚举enum TVoiceRecognitionClientErrorStatusClass)  (aSubStatus: 枚举enum TVoiceRecognitionClientErrorStatus)*/
-(void)onVoiceRecognitionClientErrorStatus:(int) aStatus subStatus:(int)aSubStatus;


@end

@interface YvRecognizeManage : NSObject

/**设置代理*/
@property (weak, nonatomic) id<YvRecognizeManageDelegate>textDelegate;
@property (weak, nonatomic) id<YvRecognizeManageDelegate>voiceDelegate;

@property (strong,nonatomic) NSTimer *voiceLevelMeterTimer;
/**可以动态设置录音文件保存路径*/
@property(nonatomic , strong) NSString *recognizePath;
/**设置录音最短时间 与 最长时间*/
@property (nonatomic,assign) int Minseconds;
@property (nonatomic,assign) int Maxseconds;
/**语音识别录音识别服务AK与SK*/
@property(nonatomic,strong) NSString *APIKEY;
@property(nonatomic,strong) NSString *SECRETKEY;

#pragma mark - 单例模式
+(instancetype)sharedInstance;

#pragma mark 单例模式初始化设置

/**
 * @brief 单例模式初始化
 *
 * @param aDelegate 代理
 *
 * @param recognizePath 语音保存路径
 *
 * @param minseconds 语音识别最短时间
 *
 * @param maxseconds 语音识别最长时间
 *
 * @param recognizeLanguage 语音识别语言 (即您说话的语言)
   
   @param outputLanguageType 输出文字的语言
 *
 * @return self
 */
-(instancetype)setupWithDelegate:(id<YvRecognizeManageDelegate>)aDelegate recognizePath:(NSString *)recognizePath minseconds:(int)minseconds maxseconds:(int)maxseconds RecognizeLanguage:(E_TVoiceRecognitionLanguage)recognizeLanguage OutputLanguageType: (E_OutputLanguageType)outputTextLanguageType;


/**
 * @brief 单例模式初始化(弃用)
 *
 * @param aDelegate 代理
 *
 * @param recognizePath 语音保存路径
 *
 * @param minseconds 语音识别最短时间
 *
 * @param maxseconds 语音识别最长时间
 *
 * @param apiKey API_KEY
 *
 * @param secretKey SECRET_KEY
 * @return self
 */
-(instancetype)setupWithDelegate:(id<YvRecognizeManageDelegate>)aDelegate recognizePath:(NSString *)recognizePath minseconds:(int)minseconds maxseconds:(int)maxseconds apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey  __attribute__((deprecated));


#pragma mark  释放接口(释放后，再要使用则需要再调用一次setupWithDelegate:recognizePath:minseconds:maxseconds:apiKey:secretKey:)
-(void)releaseInstance;



#pragma mark - 非单例模式 初始化 已弃用，请使用单例模式
#warning - 非单例模式初始化  已弃用，请使用单例模式
-(instancetype)initWithDelegate:(id<YvRecognizeManageDelegate>)aDelegate recognizePath:(NSString *)recognizePath minseconds:(int)minseconds maxseconds:(int)maxseconds apiKey:(NSString *)apiKey secretKey:(NSString *)secretKey  __attribute__((deprecated));



#pragma mark - 使用

/**
 开始语音识别，只会返回文字
 【注意:为不卡顿主线程界面,该启动内部已改为异步启动，所以返回值已无意义，如果启动失败会回调 -(void)onVoiceRecognitionClientStartError:(int)startErrorStatus;】
 @return 返回值  值参考 枚举类型：TVoiceRecognitionStartWorkResult
 */
-(int)startTextRecognize;
/**语音识别结束*/
-(void)finishTextRecognize;

/**开始语音识别，同时返回文字与声音*/
-(void)startVoiceAndTextRecognize;
/**语音识别结束*/
-(void)finishVoiceAndTextRecognize;

/**语音识别取消*/
- (void)cancelRecognize; // 用户点击取消动作
-(void)cancelVoiceAndTextRecognize;

/**实时语音识别开始*/
-(void)startRealVoiceRecognize;
/**实时语音识别结束*/
-(void)finishRealVoiceRecognize;



/**************录制音识别*************/
-(int)startRecordRecognize;
-(void)stopRecordRecognize;
@end
