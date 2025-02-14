//
//  EfunSDK.h
//  Efun_Login_TCSample
//
//  Created by 谢 京文 on 13-12-23.
//  Copyright (c) 2013年 谢 京文. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define EFUN_NOTIFICATION_SUCCESS_LOGIN (@"EFUN_SUCCESSFULLYLOGIN")           //登录成功的结果
#define EFUN_NOTIFICATION_FACEBOOKSHARE_RESULT (@"FACEBOOK_SHARE_RESULT")        //FACEBOOK分享结果

typedef NS_ENUM(NSInteger, EfunLoginType) {
    EFUN_LOGIN = 0,
    RES_LOGIN,
    FB_LOGIN,
    BAHA_LOGIN,
    GOOGLEPLUS_LOGIN,
    EVATAR_LOGIN,
    TWITTER_LOGIN,
    BAND_LOGIN,
    YAHOO_LOGIN,
};


@interface EfunSDK : NSObject
/**
 *	@brief	登录接口
 *
 *	@param 	baseview 	 baseView:登录界面的父视图
 */
+(void)ShowLoginViewWithBaseView:(UIView *)baseview;


/**
 *	@brief	追踪通过多分享渠道 的玩家  (多分享记录接口)------有多分享必须要调用这个接口
 *
 *	@param 	application 	参数可为nil
 *	@param 	launchOptions 	参数可为nil
 */
+(void)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;


+(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation;


+(void)applicationWillTerminate:(UIApplication *)application;

+(void)applicationDidBecomeActive:(UIApplication *)application;


//facebook分享接口--2
/*
 name: 应用名字  可 nil
 text: 分享内容 可nil
 picUrl: 图片的链接 可 nil
 appUrl: 游戏下载地址 可 nil
 */

+(void)facebookDialogShareWithAppName:(NSString *)name
                                 text:(NSString *)text
                               picUrl:(NSString *)picUrl
                               appUrl:(NSString *)appUrl;

+(void)postWithDevicetoken:(NSString *)token;  //推送token 传入接口
+(void)setDelegate:(id)delegate;    //设置代理（摩卡幻想）

+(NSString *)efunUID;    //获取设备的唯一表示

/*
 gameType:游戏缩写
 uid:efun的userID
 roleid:游戏角色ID
 roleName:角色名
 sid:玩家所在游戏服务器id
 sname:服务器名字
 vipl: 玩家VIP等级
 */

+ (void)showQuestionWebViewWithGameType:(NSString *)gametype
                                    Uid:(NSString *)uid
                                 Roleid:(NSString *)roleid
                               Rolename:(NSString *)rolename
                                    Sid:(NSString *)sid
                                  Sname:(NSString *)sname
                                 Viplvl:(NSString *)vipl;

/*
 serverCode:服务器码
 roleName:角色名
 roleLevel:角色等级
 roleId:角色ID
 uId:efun的userID
 */

+ (void)showBuiltInPayWebView:(NSString *)serverCode RoleName:(NSString *)roleName RoleLevel:(NSString *)roleLevel RoleId:(NSString *)roleId uId:(NSString *)uId;


@end