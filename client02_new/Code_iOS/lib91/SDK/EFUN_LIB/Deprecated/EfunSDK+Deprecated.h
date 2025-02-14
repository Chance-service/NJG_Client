//
//  EfunSDK+Deprecated.h
//  EfunSDK_iOS_SEA
//
//  Created by Coye on 1/19/15.
//  Copyright (c) 2015 Efun. All rights reserved.
//

/****************************/
//苹果储值时所需要的参数
#define EFUN_IAP_PORPERTY_PRODUCTID                 (@"productid")      //商品ID
#define EFUN_IAP_PORPERTY_USERID                    (@"uid")            //用户ID
#define EFUN_IAP_PORPERTY_PLAYERID                  (@"playerid")       //游戏角色ID/订单号
#define EFUN_IAP_PORPERTY_SERVERCODE                (@"serverCode")     //服务器ID
#define EFUN_IAP_PORPERTY_ROLELEVEL                 (@"efunLevel")      //玩家的等级
#define EFUN_IAP_PORPERTY_ROLENAME                  (@"efunRole")       //玩家角色名字
#define EFUN_IAP_PORPERTY_REMARK                    (@"remark")         //厂商的验证字符串(传入后会返回给厂商,可做标识验证)。可以不填这个参数或者写nil
/****************************/

/****************************/
//越狱储值时所需要的参数
#define EFUN_JAILBREAK_PORPERTY_UESRID              EFUN_IAP_PORPERTY_USERID
#define EFUN_JAILBREAK_PORPERTY_PLAYERID            EFUN_IAP_PORPERTY_PLAYERID
#define EFUN_JAILBREAK_PORPERTY_SERVERCODE          EFUN_IAP_PORPERTY_SERVERCODE
#define EFUN_JAILBREAK_PORPERTY_ROLELEVEL           EFUN_IAP_PORPERTY_ROLELEVEL
#define EFUN_JAILBREAK_PORPERTY_ROLENAME            EFUN_IAP_PORPERTY_ROLENAME
#define EFUN_JAILBREAK_PORPERTY_REMARK              EFUN_IAP_PORPERTY_REMARK
#define EFUN_JAILBREAK_PORPERTY_PHONENUMBER         (@"phoneNumber")
#define EFUN_JAILBREAK_PORPERTY_PHONEMODEL          (@"phoneModel")
/****************************/

#define EFUN_LOCALIZED_LANGUAGE_EN                  (@"en")                                     //英语
#define EFUN_LOCALIZED_LANGUAGE_ARAB                (@"ar")                                     //阿拉伯
#define EFUN_LOCALIZED_LANGUAGE_CN_T                (@"zh-Hant")                                //繁体
#define EFUN_LOCALIZED_LANGUAGE_CN_S                (@"zh-Hans")                                //简体
#define EFUN_LOCALIZED_LANGUAGE_VN                  (@"vi")                                     //越南
#define EFUN_LOCALIZED_LANGUAGE_THAI                (@"th")                                     //泰文
#define EFUN_LOCALIZED_LANGUAGE_JPN                 (@"ja")                                     //日文
#define EFUN_LOCALIZED_LANGUAGE_KOR                 (@"ko")                                     //韩文
#define EFUN_LOCALIZED_LANGUAGE_POR                 (@"pt")                                     //葡萄牙
#define EFUN_LOCALIZED_LANGUAGE_IND                 (@"id")                                     //印尼
#define EFUN_LOCALIZED_LANGUAGE_ES                  (@"es")                                     //西班牙
#define EFUN_LOCALIZED_LANGUAGE_RU                  (@"ru")                                     //俄文

//定义Facebook用户头像大小
typedef NS_ENUM(NSInteger, EfunFacebook_ProfileImageSize)
{
    EfunFacebook_ProfileImageSize_Square,//50px by 50px
    EfunFacebook_ProfileImageSize_Small,//50px wide, variable height
    EfunFacebook_ProfileImageSize_Normal,//100px wide, variable height
    EfunFacebook_ProfileImageSize_Large,// 200px wide, variable height
};

@interface EfunSDK (Deprecated)

// 上传推送deviceToken
+ (void)postWithDevicetokenStr:(NSString *)tokenStr
    __attribute__((deprecated(" use EfunSDK's +postWithDevicetoken:(NSString *)tokenStr")));

/*-----------
 登入功能
 ------------*/
/* 啟用EfunLogin
 调用此函数可以调出登入界面
 
 参数说明：
 (UIView *)view     传入当前使用中的view; */
+ (void)showLoginViewWithBaseView:(UIView *)baseview
    __attribute__((deprecated(" use EfunSDK's + efunLogin:(NSDictionary *)loginParameters")));
+ (void)_showLoginViewWithBaseView:(UIView *)baseview autoLogin:(BOOL)isAutoLogin;
+ (void)showFansPageViewWithBaseView:(UIView *)baseView url:(NSString *)fansPageUrl;
+ (void)showVKSocialViewWithBaseView:(UIView *)baseView
                              userId:(NSString *)userid
                              roleId:(NSString *)roleid
                          serverCode:(NSString *)serverCode
        __attribute__((deprecated(" use EfunSDK's + efunInvitation:(NSDictionary *)inviteParameters")));
//

/*
 @abstract      设置SDK语言
 
 @param         kEfunSDKLocalizedLanguage   传入语言类型:
 EFUN_LOCALIZED_LANGUAGE_EN
 EFUN_LOCALIZED_LANGUAGE_ARAB
 EFUN_LOCALIZED_LANGUAGE_CN_T
 EFUN_LOCALIZED_LANGUAGE_CN_S
 EFUN_LOCALIZED_LANGUAGE_VN
 EFUN_LOCALIZED_LANGUAGE_THAI
 EFUN_LOCALIZED_LANGUAGE_JPN
 EFUN_LOCALIZED_LANGUAGE_KOR
 EFUN_LOCALIZED_LANGUAGE_POR
 EFUN_LOCALIZED_LANGUAGE_IND
 EFUN_LOCALIZED_LANGUAGE_ES
 EFUN_LOCALIZED_LANGUAGE_RU
 */
#pragma mark - 设置SDK的语言（旧接口保留）
+ (void)setEfunSDKLanguageByEfunSupportedString:(NSString *)kEfunSDKLocalizedLanguage
__attribute__((deprecated(" use EfunSDK's +efunLogin:(NSDictionary *)loginParameters")));

//当程序关闭时调用
+ (void)appWillTerminate
    __attribute__((deprecated(" use EfunSDK's +applicationWillTerminate:")));

//当程序被唤醒时调用
+ (void)appDidBecomeActive
    __attribute__((deprecated(" use EfunSDK's +applicationDidBecomeActive:")));

//用于获取Efun的唯一标识
+ (NSString *)efunUid
    __attribute__((deprecated(" use EfunSDK's +efunDeviceID")));

//用于获取facebook名字
+ (NSString *)facebookUserName
    __attribute__((deprecated));

+ (NSString*)facebookProfileImageURLWithSize:(EfunFacebook_ProfileImageSize)size
    __attribute__((deprecated));

/*-----------
 登入功能   END
 ------------*/

/*-----------
 储值功能
 ------------*/
+ (void)initEfunIAP
    __attribute__((deprecated(" use EfunSDK's +application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions")));
+ (void)buyProudctInAppStoreWithUserPorperty:(NSDictionary*)userPorperty
    __attribute__((deprecated(" use EfunSDK's + efunPay:(NSDictionary *)payParameters")));

+ (void)buyProudctOnJailBreakPhoneWithUserPorperty:(NSDictionary*)userPorperty andCloseHandler:(void (^)(void))closeHandler
    __attribute__((deprecated));
//返回EfunProductsInfo的goods數組
//+ (NSArray *)efunProductsInfo;

//XX
+(void)getTheFirstPrizeWithPlayerID:(NSString*)PlayerID andUserID:(NSString *)UserID andServerID:(NSString *)aserverID
    __attribute__((deprecated));
/*-----------
 储值功能   END
 ------------*/

/*-----------
 分享功能
 ------------*/
/* Facebook分享接口(会弹出用户输入页面)
 参数说明：
 (NSString*)appName 应用的App名字;
 (NSString*)message 应用的描述;
 (NSString*)picUrl 应用的图片
 (NSString*)appUrl 应用的下载地址; */
+ (void)facebookFeedShareAndShowDialogWithAppName:(NSString*)appName andMessage:(NSString*)message andPictureURL:(NSString*)picUrl andAppDownloadURL:(NSString*)appUrl
    __attribute__((deprecated(" use EfunSDK's + efunShare:(NSDictionary *)shareParameters")));
/* Facebook图片分享接口
 
 参数说明：
 (UIImage *)image 分享的图片
 (NSString*)message 分享的描述;*/
+(void)shareImage:(UIImage *)image WithMessage:(NSString *)message;
/* Facebook图片分享接口
 
 参数说明：
 (NSString*)picUrl 分享的图片地址
 (NSString*)message 分享的描述;*/
+(void)shareImageUrl:(NSString *)url WithMessage:(NSString *)message;

/* kakaoLink分享功能
 
 参数说明：
 (NSString*)content 发送链接信息给好友时信息里对程序的描述或宣传语;*/
+ (void)kakaoSendLink:(NSString*)discription;


/* Line分享
 */
+ (BOOL)lineShareText:(NSString *)text;
+ (BOOL)lineShareImage:(UIImage *)image;

//imessage&sms短信分享
+ (void)showMessageViewMessage:(NSString*)message;
/*-----------
 分享功能    END
 ------------*/

/*----- 广告AD ---初始化
 说明：请在应用启动的时候调用。例如：
 - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions */

+(void)initAD
__attribute__((deprecated(" use EfunSDK's +application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions")));

/*-----AD end---*/

@end
