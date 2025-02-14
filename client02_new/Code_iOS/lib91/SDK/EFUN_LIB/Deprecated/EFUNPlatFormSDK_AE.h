//
//  EFUNPlatFormSDK.h
//  EfunSDK_IOS
//
//  Created by czf on 14-6-10.
//  Copyright (c) 2014年 fengjiada. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EFUNPlatFormSDK_AE : NSObject

/**
 *	@brief	添加EFUN平台的悬浮按钮  该方法在玩家登录游戏成功后并创建的游戏角色的情况下调用
 *
 *	@param 	baseView 	传入一个在整个游戏过程中都不会销毁掉得UIView对象（例如：[UIApplication sharedApplication].keyWindow.rootViewController.view）
 *	@param 	aServerCode 	当前角色登入的伺服器的ServerCode
 *	@param 	aRoleName 	当前角色的角色名字
 *	@param 	aRoleId 	当前角色的角色id
 *  @param  aRoleLevel  当前角色的等级
 *  @param  aRemark     扩展参数
 *  @param  creditId    该参数决定了  游戏币发放给哪个玩家（如果没有特定的就传角色ID，没角色ID就传空字符串）
 */
+ (void)showPlatFormWithBaseView:(UIView *)baseView
                   andServerCode:(NSString *)aServerCode
                     andRoleName:(NSString *)aRoleName
                       andRoleId:(NSString *)aRoleId
                    andRoleLevel:(int)aRoleLevel
                       andRemark:(NSString *)aRemark
                     andCreditId:(NSString *)creditId
    __attribute__((deprecated(" use EfunSDK's + efunShowPlatform:(NSDictionary *)platformParameters")));



/**
 *	@brief	添加EFUN平台的悬浮按钮
 *
 *	@param 	baseView 	传入一个在整个游戏过程中都不会销毁掉得UIView对象
 *	@param 	aGameName 	当前游戏的游戏名称
 *	@param 	aServerName 	当前角色登入的伺服器名字
 *	@param 	aServerCode 	当前角色登入的伺服器的ServerCode
 *	@param 	aRoleName 	当前角色的角色名字
 *	@param 	aRoleId 	当前角色的角色id
 *  @param  aRoleLevel  当前角色的等级
 *  @param  aRemark     扩展参数
 *  @param  creditId    该参数决定了  游戏币发放给哪个玩家（如果没有特定的就传角色ID）
 */
+ (void)showPlatFormWithBaseView:(UIView *)baseView
                     andGameName:(NSString *)aGameName
                   andServerName:(NSString *)aServerName
                   andServerCode:(NSString *)aServerCode
                     andRoleName:(NSString *)aRoleName
                       andRoleId:(NSString *)aRoleId
                    andRoleLevel:(int)aRoleLevel
                       andRemark:(NSString *)aRemark
                     andCreditId:(NSString *)creditId
    __attribute__((deprecated(" use EfunSDK's + efunShowPlatform:(NSDictionary *)platformParameters")));

/**
 *	@brief	显示客服中心
 */
+ (void)showCustumServceCenterWithServerCode:(NSString *)aServerCode
                                 andRoleName:(NSString *)aRoleName
                                   andRoleId:(NSString *)aRoleId
        __attribute__((deprecated(" use EfunSDK's + efunCustomerService:(NSDictionary *)csParameters")));

/**
 *	@brief	让平台显示在整个游戏的最上方
 */
+ (void)bringPlatFormToFront
        __attribute__((deprecated(" use EfunSDK's + efunBringPlatformToFront")));

/**
 *	@brief	判断平台是否在使用FaceBook
 *
 *	@return  平台是否在使用FaceBook
 */
+ (BOOL)whetherPlatFormIsUsingFaceBook
        __attribute__((deprecated(" use EfunSDK's + application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation")));


/**
 *	@brief	初始化平台
 */
+ (void)initPlatForm
        __attribute__((deprecated(" use EfunSDK's + application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions")));

+ (BOOL)getURLString:(NSURL *)url
        __attribute__((deprecated(" use EfunSDK's + application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation")));


/**
 *	@brief	隐藏平台   该方法在游戏中切换游戏账号的时候使用，点击游戏中切换账号或者退出按钮的时候，调用该方法，此时，
 *                    平台按钮会被隐藏掉，当再次调用“添加EFUN的悬浮按钮“的方法的时候，会再次做判断是否显示平台！
 */
+ (void)hiddenPlatFormForChangeAccount
        __attribute__((deprecated(" use EfunSDK's + efunLogout")));

/**
 *	@brief	隐藏或者显示平台
 *
 *	@param 	aHidden   决定显示还是隐藏平台   如果为YES  隐藏平台    如果为NO  显示平台
 */
+ (void)whetherHiddenPlatForm:(BOOL)aHidden
        __attribute__((deprecated(" use EfunSDK's + efunHiddenPlatform:(BOOL)isHidePlatform")));

/**
 *	@brief	设置app支持的方向
 *
 *	@param 	application 	应用程序的app对象
 *	@param 	window 	UIWindow *
 *
 *	@return	支持的方向
 */
+ (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
        __attribute__((deprecated(" use EfunSDK's + application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window")));
@end
