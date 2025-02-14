//
//  EFUNPlatFormSDK.h
//  EfunPlatForm
//
//  Created by TangTieshan on 14-2-20.
//  Copyright (c) 2014年 TangTieshan. All rights reserved.
//

/*
    平台的对外接口
 */


#import <UIKit/UIKit.h>

@interface EFUNPlatFormSDK : NSObject

/**
 *	@brief	添加EFUN平台的悬浮按钮
 *
 *	@param 	baseView 	传入一个在整个游戏过程中都不会销毁掉得UIView对象
 *	@param 	aServerCode 	当前角色登入的伺服器的ServerCode
 *	@param 	aRoleName 	当前角色的角色名字
 *  @param  aRoleLevel  当前角色的等级
 *	@param 	aRoleId 	当前角色的角色id
 *  @param  aRemark     扩展参数
 *  @param  creditId    该参数决定游戏币发放给哪一个玩家
 */
+ (void)showPlatFormWithBaseView:(UIView *)baseView
                   andServerCode:(NSString *)aServerCode
                     andRoleName:(NSString *)aRoleName
                    andRoleLevel:(int)aRoleLevel
                       andRoleId:(NSString *)aRoleId
                       andRemark:(NSString *)aRemark
                     andCreditId:(NSString *)creditId;


/**
 *	@brief	让平台显示在整个游戏的最上方
 */
+ (void)bringPlatFormToFront;

/**
 *	@brief	判断平台是否在使用FaceBook
 *
 *	@return  平台是否在使用FaceBook
 */
+ (BOOL)whetherPlatFormIsUsingFaceBook;


/**
 *	@brief	初始化平台
 */
+ (void)initPlatForm;

/**
 *	@brief
 *
 *	@param 	url
 *
 *	@return
 */
+ (BOOL)getURLString:(NSURL *)url;

/**
 *	@brief	隐藏平台   该方法在游戏中切换游戏账号的时候使用，点击游戏中切换账号或者退出按钮的时候，调用该方法，此时，
 *                    平台按钮会被隐藏掉，当再次调用“添加EFUN的悬浮按钮“的方法
 *                   （showPlatFormWithBaseView: andServerCode: andRoleName: andRoleLevel: andRoleId: andRemark: andCreditId: ）的时候，
 *                    会再次做判断是否显示平台！
 */
+ (void)hiddenPlatFormForChangeAccount;

/**
 *	@brief	隐藏或者显示平台
 *
 *	@param 	aHidden   决定显示还是隐藏平台   如果为YES  隐藏平台    如果为NO  显示平台
 */
+ (void)whetherHiddenPlatForm:(BOOL)aHidden;


/**
 *	@brief	设置app支持的方向
 *
 *	@param 	application 	应用程序的app对象
 *	@param 	window 	UIWindow *
 *
 *	@return	支持的方向
 */
+ (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window;

@end
