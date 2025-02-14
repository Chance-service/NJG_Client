//
//  EfunSDK.h
//  EfunSDK_IOS
//
//  Created by czf on 13-7-31.
//  Copyright (c) 2013年 fengjiada. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EfunSDK : NSObject

/*-----------
 @abstract      回调通知
 ------------*/
#define EFUN_NOTIFICATION_SUCCESS_LOGIN             (@"Efun_httpRequest_Success")               //efun登陆成功
#define EFUN_NOTIFICATION_FAIL_LOGIN                (@"Efun_httpRequest_Fail")                  //efun登陆失败
#define EFUN_NOTIFICATION_SUCCESS_LOGOUT            (@"Efun_logoutGame")                        //efun登出成功
#define EFUN_NOTIFICATION_BACKTOHOME_LOGIN          (@"Efun_cancelLogin_and_backToHome")        //efun登陆界面返回
#define EFUN_NOTIFICATION_FACEBOOKSHARING_RESULT    (@"Efun_httpRequest_FacebookSharingResult") //Facebook分享结果
#define EFUN_NOTIFICATION_TWITTER_SHARERESULT       (@"Efun_httpRequest_TwitterSharingResult")  //Twitter分享结果
#define EFUN_NOTIFICATION_PHCHASE_SUCCESSFUL        (@"EFUNPHCHASESUCCESSFUL")                  //储值成功
#define EFUN_NOTIFICATION_PHCHASE_FAIL              (@"EFUNPHCHASEFAIL")                        //储值失败
#define EFUN_NOTIFICATION_PHCHASE_PUCHASING         (@"EFUNPHCHASING")                          //储值中

/*-----------
 @abstract      参数键
 ------------*/
#define EFUN_PRM_BASE_VIEW                          (@"baseView")                               //游戏底层View
#define EFUN_PRM_LANGUAGE                           (@"language")                               //语言类型
#define EFUN_PRM_EFUN_USER_ID                       (@"userID")                                 //efun用户ID
#define EFUN_PRM_PRODUCT_ID                         (@"productID")                              //商品ID
#define EFUN_PRM_CREDIT_ID                          (@"creditID")                               //游戏订单号
#define EFUN_PRM_SERVER_CODE                        (@"serverCode")                             //游戏服务器ID
#define EFUN_PRM_SERVER_NAME                        (@"serverName")                             //游戏服务器名
#define EFUN_PRM_ROLE_ID                            (@"roleID")                                 //游戏角色ID
#define EFUN_PRM_ROLE_LEVEL                         (@"roleLevel")                              //游戏角色等级
#define EFUN_PRM_ROLE_NAME                          (@"roleName")                               //游戏角色名
#define EFUN_PRM_VIP_LEVEL                          (@"vipLevel")                               //游戏VIP等级
#define EFUN_PRM_REMARK                             (@"remark")                                 //扩展参数。可填@""

#define EFUN_PRM_SHARE_TYPE                         (@"efun_prm_share_type")                    //分享类型
#define EFUN_PRM_SHARE_DESCRIPTION                  (@"efun_prm_share_description")             //分享内容
#define EFUN_PRM_SHARE_LINK_NAME                    (@"efun_prm_share_link_name")               //分享标题。应用名字
#define EFUN_PRM_SHARE_LINK_URL                     (@"efun_prm_share_link_url")                //分享应用链接
#define EFUN_PRM_SHARE_PICTURE_URL                  (@"efun_prm_share_picture_url")             //分享图片链接

#define EFUN_PRM_INVITE_TYPE                        (@"efun_prm_invite_type")                   //邀请类型

/*-----------
 @abstract      分享类型
 ------------*/
#define EFUN_SHARE_FACEBOOK                         (@"efun_share_facebook")                    //facebook分享
#define EFUN_SHARE_TWITTER                          (@"efun_share_twitter")                     //twitter分享
#define EFUN_SHARE_KAKAO                            (@"efun_share_kakao")                       //kakao分享
#define EFUN_SHARE_VK                               (@"efun_share_vk")                          //vk分享

/*-----------
 @abstract      邀请类型
 ------------*/
#define EFUN_INVITE_VK                              (@"efun_invite_vk")                         //vk邀请

/*-----------
 @abstract       语言类型
 ------------*/
#define EFUN_LOCALIZED_LANGUAGE_EN_US               (@"en")                                     //英语
#define EFUN_LOCALIZED_LANGUAGE_AR_AE               (@"ar")                                     //阿拉伯
#define EFUN_LOCALIZED_LANGUAGE_ZH_HK               (@"zh-Hant")                                //繁体
#define EFUN_LOCALIZED_LANGUAGE_ZH_CH               (@"zh-Hans")                                //简体
#define EFUN_LOCALIZED_LANGUAGE_VI_VN               (@"vi")                                     //越南
#define EFUN_LOCALIZED_LANGUAGE_TH_TH               (@"th")                                     //泰文
#define EFUN_LOCALIZED_LANGUAGE_JA_JP               (@"ja")                                     //日文
#define EFUN_LOCALIZED_LANGUAGE_KO_KR               (@"ko")                                     //韩文
#define EFUN_LOCALIZED_LANGUAGE_PT_PT               (@"pt")                                     //葡萄牙
#define EFUN_LOCALIZED_LANGUAGE_EN_ID               (@"id")                                     //印尼
#define EFUN_LOCALIZED_LANGUAGE_ES_ES               (@"es")                                     //西班牙
#define EFUN_LOCALIZED_LANGUAGE_RU_RU               (@"ru")                                     //俄文

#pragma mark - SDK生命周期接口
/**
 @abstract      SDK生命周期
 */
+ (void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
+ (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;
+ (void)applicationWillTerminate:(UIApplication *)application;
+ (void)applicationDidBecomeActive:(UIApplication *)application;
+ (void)applicationDidEnterBackground:(UIApplication *)application;

#pragma mark - 登陆功能
/**
 @abstract      登陆功能
 
 @param         EFUN_PRM_BASE_VIEW          游戏底层View
 @param         EFUN_PRM_LANGUAGE           语言类型，传入语言类型:
 EFUN_LOCALIZED_LANGUAGE_EN_US
 EFUN_LOCALIZED_LANGUAGE_AR_AE
 EFUN_LOCALIZED_LANGUAGE_ZH_HK
 EFUN_LOCALIZED_LANGUAGE_ZH_CH
 EFUN_LOCALIZED_LANGUAGE_VI_VN
 EFUN_LOCALIZED_LANGUAGE_TH_TH
 EFUN_LOCALIZED_LANGUAGE_JA_JP
 EFUN_LOCALIZED_LANGUAGE_KO_KR
 EFUN_LOCALIZED_LANGUAGE_PT_PT
 EFUN_LOCALIZED_LANGUAGE_EN_ID
 EFUN_LOCALIZED_LANGUAGE_ES_ES
 EFUN_LOCALIZED_LANGUAGE_RU_RU
 @return
 */
+ (void)efunLogin:(NSDictionary *)loginParameters;

#pragma mark - 储值功能
/**
 @abstract      储值功能
 
 @param         EFUN_PRM_EFUN_USER_ID       efun用户ID
 @param         EFUN_PRM_PRODUCT_ID         商品ID
 @param         EFUN_PRM_CREDIT_ID          游戏订单号
 @param         EFUN_PRM_SERVER_CODE        游戏服务器ID
 @param         EFUN_PRM_ROLE_LEVEL         游戏角色等级
 @param         EFUN_PRM_ROLE_NAME          游戏角色名
 @param         EFUN_PRM_REMARK             扩展参数。可作为厂商的验证字符串(传入后服务端会返回给厂商,可做标识验证)。可填@""
 */
+ (void)efunPay:(NSDictionary *)payParameters;

/**
 @abstract      获取Efun商品列表
 */
+ (NSArray *)efunProductsInfo;

#pragma mark - 客服功能/个人中心
/**
 @abstract      客服功能/个人中心
 
 @param         EFUN_PRM_EFUN_USER_ID       efun用户ID
 @param         EFUN_PRM_SERVER_CODE        游戏服务器ID
 @param         EFUN_PRM_SERVER_NAME        游戏服务器名
 @param         EFUN_PRM_ROLE_ID            游戏角色ID
 @param         EFUN_PRM_ROLE_NAME          游戏角色名
 @param         EFUN_PRM_VIP_LEVEL          游戏VIP等级
 @param         EFUN_PRM_REMARK             扩展参数。可填@""
 */
+ (void)efunCustomerService:(NSDictionary *)csParameters;

#pragma mark - Efun邀请功能
/**
 @abstract      邀请功能
 
 @param         EFUN_PRM_INVITE_TYPE        邀请类型
 @param         EFUN_PRM_BASE_VIEW          游戏底层View
 @param         EFUN_PRM_EFUN_USER_ID       efun用户ID
 @param         EFUN_PRM_SERVER_CODE        游戏服务器ID
 @param         EFUN_PRM_ROLE_ID            游戏角色ID
 */
+ (void)efunInvitation:(NSDictionary *)inviteParameters;

#pragma mark - Efun推送
/**
 @abstract      Efun推送
 */
+ (void)postWithDevicetoken:(id)token;

#pragma mark - Efun平台悬浮按钮接口
/**
 @abstract      Efun平台悬浮按钮显示
 
 @param         EFUN_PRM_BASE_VIEW          游戏底层View
 @param         EFUN_PRM_SERVER_CODE        游戏服务器ID
 @param         EFUN_PRM_ROLE_ID            游戏角色ID
 @param         EFUN_PRM_ROLE_NAME          游戏角色名
 @param         EFUN_PRM_ROLE_LEVEL         游戏角色等级
 @param         EFUN_PRM_CREDIT_ID          游戏订单号。若是用角色ID作为订单号则传角色ID，否则传@""
 @param         EFUN_PRM_REMARK             扩展参数。可填@""
 */
+ (void)efunShowPlatform:(NSDictionary *)platformParameters;

/**
 @abstract      Efun平台悬浮按钮隐藏
 */
+ (void)efunHiddenPlatform:(BOOL)isHidePlatform;

/**
 @abstract      Efun平台悬浮按钮顶置
 */
+ (void)efunBringPlatformToFront;

/**
 @abstract      Efun平台悬浮按钮适配设备方向
 */
+ (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;

#pragma mark - Efun分享接口
/**
 @abstract      Efun平台悬浮按钮显示
 
 @param         EFUN_PRM_SHARE_TYPE          分享类型(EFUN_SHARE_FACEBOOK/EFUN_SHARE_TWITTER/EFUN_SHARE_KAKAO)
 @param         EFUN_PRM_SHARE_DESCRIPTION   分享内容
 @param         EFUN_PRM_SHARE_LINK_NAME     分享标题。应用名字
 @param         EFUN_PRM_SHARE_LINK_URL      分享应用链接
 @param         EFUN_PRM_SHARE_PICTURE_URL   分享图片链接
 */
+ (void)efunShare:(NSDictionary *)shareParameters;

#pragma mark - 其它功能接口
/**
 @abstract      获取Efun设备ID
 */
+ (NSString *)efunDeviceID;

/**
 @abstract      注销/登出功能
 */
+ (void)efunLogout;

/**
 @abstract      判断是否自动登录
 */
+ (BOOL)efunHasUser;

#pragma mark - 韩国SDK API
/**
 @abstract      显示Efun广告墙
 
 @param         completionBlock       关闭广告墙后的回调代码块
 */
+ (void)showPromotionAndAnnounceWebviewWithcompletionHandler:(void(^)(void))completionBlock;

/**
 @abstract      显示Efun公告界面
 */
+ (void)showAnnounceWebview;

@end
