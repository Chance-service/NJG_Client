//
//  YvChatManage.h
//  
//
//  Created by 朱文腾 on 14-8-12.
//  Copyright (c) 2014年 . All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextMessageNotify.h"
#import "VoiceMessageNotify.h"
#import "RichMessageNotify.h"
#import "UserStateNotify.h"
#import "MicModeChangeNotify.h"
#import "YvRecognizerProtocol.h"

typedef NS_ENUM(int, ReceiveStateType)
{
    ReceiveStateType_RealVoice_Message = 1,
    ReceiveStateType_RealVoice_UnMessage = 2,
    ReceiveStateType_UnRealVoice_Message = 3,
    ReceiveStateType_UnRealVoice_UnMessage  = 4,
};

typedef enum : NSUInteger {
    kUploadFile_Retain_Time_permanent	= 0,//永久
    kUploadFile_Retain_Time_year = 1, //一年
    kUploadFile_Retain_Time_6_months	= 2,	//六个月
    kUploadFile_Retain_Time_3_months	= 3,	//3个月
    kUploadFile_Retain_Time_1_months	= 4,	//1个月
    kUploadFile_Retain_Time_2_week		= 5,	//两周
    kUploadFile_Retain_Time_1_week		= 6,	//一周
    kUploadFile_Retain_Time_3_day		= 7,	//三天
    kUploadFile_Retain_Time_1_day		= 8,	//一天
    kUploadFile_Retain_Time_6_hours	= 9,	//六小时
} E_UploadFile_Retain_Time;//文件保存时长类型

@class YvChatManage;

@protocol YvChatManageDelegate <NSObject>

@optional

/**初始化完成*/
//-(void)ChatManage:(YvChatManage *)sender initComplete:(BOOL)issuccess;

/**网络断开后，重连三次失败返回*/
-(void)ChatManage:(YvChatManage *)sender OnConnectFail:(NSString *)desc;

/*!
 @callback 该函数为回调函数 add by huangzhijun 2015.1.23
 @brief 在网络异常(如:wifi-->3G, 3G-->wifi,无网络-->3G/wifi),开始自动重新登录
 

 @param tryReLoginTimes 重新登录尝试次数
 @result
 */
-(void)ChatManage:(YvChatManage *)sender BeginAutoReLoginWithTryTimes:(NSUInteger)tryReLoginTimes;

/**登录返回LoginWithSeq、LoginBindingWithTT*/
-(void)ChatManage:(YvChatManage *)sender LoginResp:(int)result msg:(NSString *)msg yunvaid:(UInt64)yunvaid;

/**注销返回*/
-(void)ChatManage:(YvChatManage *)sender LogoutResp:(int)result msg:(NSString *)msg;

/*成功发送文本消息返回 add by huangzhijun 2015.1.19*/
-(void)ChatManage:(YvChatManage *)sender SendTextMessageSuccessWithExpand:(NSString*)expand;

/**发送消息返回，只有消息发送失败才会收到回调*/
-(void)ChatManage:(YvChatManage *)sender SendTextMessageError:(int)result msg:(NSString *)msg;
-(void)ChatManage:(YvChatManage *)sender SendTextMessageError:(int)result msg:(NSString *)msg expand:(NSString*)expand;

/**接受到文本通知*/
-(void)ChatManage:(YvChatManage *)sender TextMessageNotify:(TextMessageNotify *)TextMessageNotify;

/**上下麦返回*/
-(void)ChatManage:(YvChatManage *)sender ChatMicResp:(int)result msg:(NSString *)msg onoff:(BOOL)onoff;

/**实时语音错误返回，只有发送失败才会收到回调，注意音频是发送是频繁的，出现错误时此事件是一连串的*/
-(void)ChatManage:(YvChatManage *)sender SendRealTimeVoiceMessageError:(int)result msg:(NSString *)msg;

/**实时语音通知*/
-(void)ChatManage:(YvChatManage *)sender RealTimeVoiceMessageNotifyWithYunvaId:(UInt32)yunvaid chatroomId:(NSString *)chatroomId expand:(NSString *)expand;

/**接受语音留言通知*/
-(void)ChatManage:(YvChatManage *)sender VoiceMessageNotify:(VoiceMessageNotify *)VoiceMessageNotify;


/**发送语音留言返回,发送时会先上传到服务器并返回地址,故将上传的路径、时间返回*/
-(void)ChatManage:(YvChatManage *)sender SendVoiceMessageResp:(int)result msg:(NSString *)msg voiceUrl:(NSString *)voiceUrl voiceDuration:(UInt64)voiceDuration filePath:(NSString *)filePath expand:(NSString *)expand;

/*********************************************************************/
/** 文本+语音留言 通知 (一般用于语音文字识别功能的通知) add 2014.12.5**/
-(void)ChatManage:(YvChatManage *)sender RichMessageNotifyWithTextMessage:(TextMessageNotify *)TextMessageNotify VoiceMessage:(VoiceMessageNotify *)VoiceMessageNotify;

/*发送文本+语音富消息返回，发送时会先上传语音到服务器并返回地址 add by huangzhijun 2014.12.8*/
-(void)ChatManage:(YvChatManage *)sender SendRichMessageResp:(int)result msg:(NSString *)msg textMsg:(NSString *)textMsg  voiceUrl:(NSString *)voiceUrl voiceDuration:(UInt64)voiceDuration filePath:(NSString *)filePath expand:(NSString *)expand;
/*********************************************************************/

/**当开启播放声音和录音的计量检测,返回实时语音或自动播放的峰值和平均值*/
-(void)ChatManage:(YvChatManage *)sender PlayMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;

/**当开启录音的计量检测,返回实时录音的峰值和平均值*/
-(void)ChatManage:(YvChatManage *)sender RecorderMeteringPeakPower:(float)peakPower AvgPower:(float)avgPower;

/**设置消息接收的方式返回*/
//-(void)ChatManage:(YvChatManage *)sender SetReceiveStateResp:(ReceiveStateType)setReceiveStateResp;

/**请出房间回调*/
-(void)ChatManage:(YvChatManage *)sender KickOutNotifyWithmsg:(NSString *)msg;

/**用户状态改变回调*/
-(void)ChatManage:(YvChatManage *)sender UserStateNotify:(UserStateNotify *)userStateNotify;

/**设置麦模式返回*/
-(void)ChatManage:(YvChatManage *)sender MicModeSettingResp:(int)result msg:(NSString *)msg;

/**麦模式更改通知*/
-(void)ChatManage:(YvChatManage *)sender MicModeChangeNotify:(MicModeChangeNotify *)micModeChangeNotify;


/**检测当前系统的音量*/
-(void)ChatManage:(YvChatManage *)sender CurrentSystemVolume:(float)volume;

/**
 获取聊天历史记录接口回调
 @param roomMode - 2:主播模式、1:抢麦模式 4:麦序模式
 @param result -- 返回码:0 - 成功, 非0 - 失败
 @param msg -- 错误消息
 @param historyMsgArray -- 聊天历史记录 元素类型: TextMessageNotify对象(文本对象)  或者  VoiceMessageNotify对象(语音对象)  或者  RichMessageNotify对象(文本+语音)
 */
-(void)ChatManage:(YvChatManage *)sender QueryHistoryMsgResp:(int)result msg:(NSString*)msg historyMsgArray:(NSArray*)historyMsgArray;

@end

@interface YvChatManage : NSObject 

@property (nonatomic,weak) id<YvChatManageDelegate> delegate;
@property (assign, readonly) UInt32 yunvaId;


/**初始化,避免与sharedInstance一起使用(deprecated)(请改用单例 [YvChatManage sharedInstance] SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest)
 @param
 appid  : 你的appId
 istest : yes是测试环境 no 正式环境
 例如:
 chatmanage = [[YvChatManage alloc]initWithAppId:@“你的appId” istest:是否是测试环境];
 chatmanage.delegate = self;
 [chatmanage LoginWithSeq:self.Seq hasVideo:NO position:0 videoCount:0];*/
-(id)initWithAppId:(NSString *)appid istest:(BOOL)istest __attribute__((deprecated));


#pragma mark - 初始化

/**获取一个共享实例,后续建议用此方法,单利模式可避免重新登录房间导致的多条连接
 使用例子:
 [YvChatManage SetInitParamWithAppId:@“你的appId” istest:是否是测试环境];
 [YvChatManage sharedInstance].delegate = self;
 [[YvChatManage sharedInstance] LoginWithSeq:self.Seq hasVideo:NO position:0 videoCount:0];*/
+(instancetype)sharedInstance;

/**设置初始化参数,设置之后需要重新登录*/
-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;

/**设置日志级别:0--关闭日志  1--error  2--debug(不设置为默认该级别) 3--warn  4--info  5--trace*/
-(void)setLogLevel:(int)logLevel;

/**设置支持否后台运行,默认为NO,不支持*/
@property (nonatomic,assign) BOOL supportBackgroundingOnSocket;

#pragma mark - 队伍登录
/**登录到房间，单独设计可用于切换房间*/
-(void)LoginWithSeq:(NSString *)seq hasVideo:(BOOL)hasVideo position:(UInt8)position videoCount:(int)videoCount;

/**登录绑定，用于第三方登录*/
-(void)LoginBindingWithTT:(NSString *)tt seq:(NSString *)seq hasVideo:(BOOL)hasVideo position:(UInt8)position videoCount:(int)videoCount;

/**注销，用于切换房间*/
-(void)Logout;

#pragma mark - 获取历史消息
/*获取聊天历史记录接口*/
-(void)queryHistoryMsgReqWithPageIndex:(int)pageIndex PageSize:(int)pageSize;

#pragma mark - 发送消息接口
/**发送文本信息*/
-(void)sendTextMessage:(NSString *)text expand:(NSString *)expand;

/**发送语音留言*/
-(void)sendVoiceMessage:(NSString *)filePath voiceDuration:(int)voiceDuration expand:(NSString *)expand;

/**发送文字+语音留言*/
-(void)sendRichMessageWithTextMsg:(NSString *)text VoiceMsg:(NSString *)filePath voiceDuration:(int)voiceDuration expand:(NSString *)expand;

/**设置是否自动播放收到的语音留言消息,默认为NO*/
@property (nonatomic,assign) BOOL isAutoPlayVoiceMessage;

#pragma mark - 实时语音接口
/**聊天中的实时语音上麦，下麦*/
-(void)ChatMic:(BOOL)onoff expand:(NSString *)expand;

/**设置是否暂停播放实时语音聊天*/
-(void)setPausePlayRealAudio:(BOOL)isPasue;
/**获取当前是否已经暂停播放实时语音*/
-(BOOL)isPausePlayAudio;

/**设置麦模式，mode:0自由模式，1抢麦模式，2指挥模式*/
-(void)MicModeSettingWithmodeType:(UInt8)modeType;

/**获取当前是否是上麦状态**/
-(BOOL)getCurrentMicState;

/**是否开启实时语音的计量检测,默认NO*/
@property (nonatomic,assign) BOOL MeteringEnabled;


#pragma mark - 对实时语音进行语音识别插件
-(void)setRecognizerPlugin:(id<YvRecognizerProtocol>)recognizePlugin;
-(int)startRealVoiceRecognize; //在上麦，并且设置了才能后调用实时语音识别
-(void)stopRealVoiceRecognize;  //结束实时语音识别


#pragma mark - 文件上传接口
/**********/

/*!
 @method
 @brief 上传语音文件
        注意:调用本函数前请确认已调用初始化函数:-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
 
 @param voiceFilePath 语音文件全路径
 @param fileRetainTimeType  文件保存时长类型
 @param success 语音文件上传成功后的回调, 参数voiceUrl是语音文件保存在服务器的url
 @param failure 上传失败的回调
 @result
 */
-(void)uploadVoiceMessage:(NSString *)voiceFilePath
           retainTimeType:(E_UploadFile_Retain_Time)fileRetainTimeType
                  success:(void (^)(NSString * voiceUrl))success
                  failure:(void (^)( NSError *error))failure;


/*!
 @method
 @brief 上传图片
        注意:调用本函数前请确认已调用初始化函数:-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
 
 @param fileData 图片数据
 @param fileType 图片类型,支持: @"jpg"  @"png"

 @param fileRetainTimeType  文件保存时长类型
 @param success 语音文件上传成功后的回调, 参数pictureUrl是原图url 
 @param failure 上传失败的回调
 @result
 */
-(void)uploadPictureWithFileData:(NSData *)fileData
                        FileType:(NSString *)fileType
                  retainTimeType:(E_UploadFile_Retain_Time)fileRetainTimeType
                         success:(void (^)(NSString * pictureUrl))success
                         failure:(void (^)( NSError *error))failure;


/*!
 @method
 @brief 上传图片(服务器实现缩略图功能，但不稳定，建议缩略图客户端自己实现，调用上面的单纯图片上传功能)
        注意:调用本函数前请确认已调用初始化函数:-(void)SetInitParamWithAppId:(NSString *)appid istest:(BOOL)istest;
 
 @param fileData 图片数据
 @param fileType 图片类型,支持: @"jpg"  @"png"
 @param scaleToSize 缩略图大小，比如缩略图是114x114 则填114
 @param fileRetainTimeType  文件保存时长类型
 @param success 语音文件上传成功后的回调, 参数pictureUrl是原图url  thumbnailPictureUrl 是缩略图url
 @param failure 上传失败的回调
 @result
 */
-(void)uploadPictureWithFileData:(NSData *)fileData
                        FileType:(NSString *)fileType
                     scaleToSize:(int)scaleToSize
                  retainTimeType:(E_UploadFile_Retain_Time)fileRetainTimeType
                         success:(void (^)(NSString * pictureUrl, NSString * thumbnailPictureUrl))success
                         failure:(void (^)( NSError *error))failure;
/**********/

@end
