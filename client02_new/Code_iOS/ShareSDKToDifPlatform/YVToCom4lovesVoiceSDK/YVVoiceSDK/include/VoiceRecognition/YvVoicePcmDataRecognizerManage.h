//
//  YvVoicePcmDataRecognizerManage.h
//  ChatSDK
//
//  Created by wind on 14-12-10.
//  Copyright (c) 2014年 com.yunva.yaya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YvRecognizerProtocol.h"

@protocol YvVoicePcmDataRecognizerManageDelegate <NSObject>

/*语音识别结束后返回的最终识别文字*/
-(void)onVoicePcmDataRecognition_FinishRecognizeTextResp:(NSString*)text;

/**在识别过程中连续上屏的文字*/
-(void)onVoicePcmDataRecognition_ContinuousRecognizeTextResp:(NSString *)continuousText;

/* 识别过程中错误的错误码:  (aStatus: 枚举enum TVoiceRecognitionClientErrorStatusClass)  (aSubStatus: 枚举enum TVoiceRecognitionClientErrorStatus)*/
-(void)onVoicePcmDataRecognition_VoiceRecognitionClientErrorStatus:(int) aStatus subStatus:(int)aSubStatus;

@end

@interface YvVoicePcmDataRecognizerManage : NSObject <YvRecognizerProtocol>

+ (instancetype)shareInstance;


/**
 * @brief 初始化识别器,设置识别出来的文字信息回调的delegate ： YvVoicePcmDataRecognizerManageDelegate 的实现者
 *
 */
-(void)setUpVoicePcmRecognizerWithRecognizeLanguage:(E_TVoiceRecognitionLanguage)recognizeLanguage OutputLanguageType: (E_OutputLanguageType)outputTextLanguageType Delegate:(id)delegate;

/**
 * @brief 开始识别
 *
 * @return 状态码 (请参考 枚举enum TVoiceRecognitionStartWorkResult)
 */
- (int)startVoicePcmDataRecognition;

/**
 * @brief 向识别器发送数据
 *
 * @param data 发送的数据
 */
- (void)sendVoicePcmDataToRecognizer:(NSData *)pcmData;

/**
 * @brief 数据发送完成
 */
- (void)allVoicePcmDataHasSent;

/**
 * @brief 释放资源接口
 */
-(void)releaseInstance;

@end
