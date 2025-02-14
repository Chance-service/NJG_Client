//
//  R2SDK.h
//  R2SDK
//
//  Created by Edward on 15-1-19.
//  Copyright (c) 2015年 edward. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <StoreKit/StoreKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import <GameKit/GameKit.h>

typedef void (^R2SDKHandler)(id result, NSError *error);

@interface R2SDK : NSObject <
    NSCopying,
    NSURLConnectionDelegate,
    UIAlertViewDelegate,
    SKPaymentTransactionObserver,
    SKProductsRequestDelegate,
    FBSDKGameRequestDialogDelegate,
    FBSDKSharingDelegate,
    FBSDKAppInviteDialogDelegate
>
//初始化单例
+ (R2SDK *)sharedR2SDK;

//-------------------Facebook 相关接口------------------------//
//Facebook登陆
- (void)FBlogin:(R2SDKHandler)handle;

//Facebook登出
- (void)FBlogOut;

//Facebook登陆状态
- (BOOL)isFacebookLogined;

//Facebook设置
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation;
- (void) applicationDidBecomeActive:(UIApplication *)application;

//Facebook 分享
- (void)shareFacebookWithContentURL:(NSString *)contentURL contentTitle:(NSString *)title imageURL:(NSString *)url conetentDescription:(NSString *)description handle:(R2SDKHandler)handle;

//Facebook 获取玩此游戏的好友列表
- (NSArray *)requestForMyFriends;

//Facebook 获取好友R2平台的ID
- (void)getUIDfromFacebookID:(NSArray *)friendIDs handle:(R2SDKHandler)handle;

//Facebook 邀请
- (void)invitateFacebookFriendsWithAppLink:(NSString *)appLink imageURL:(NSString *)imageURL handle:(R2SDKHandler)handle;

//向好友发出请求或发送物品
- (void)FbGameRequestType:(FBSDKGameRequestActionType) actionType title:(NSString *)title objectID:(NSString *)objectID mesage:(NSString *)message to:(NSArray *)friendsID  extraData:(NSString *)extraData handle:(R2SDKHandler)handle;

//Facebook 获取请求 (须在FB登陆后才能调用)
- (NSArray *)notificationGet;

//Facebook 删除处理过的请求 (须在FB登陆后才能调用)
- (NSDictionary *)notificationClear:(NSString *)requestid;

//-----------------------------------游戏基础接口-------------------------------------//
//激活统计接口
- (void)trackAppActive;

//检查当前设备是否存储有token，用当前token登陆，调系统GC的登陆；否：调用临时账号接口登陆，调系统GC的登陆
- (void)loginGame:(UIViewController *)viewController quichLogin:(BOOL)isQuick handle:(R2SDKHandler)handle;


//Game Center账号登陆
- (void)gameCenterLogin:(UIViewController *)viewController handle:(R2SDKHandler)handle;

//重置为正式账号
- (void)reSetUser:(NSString *)mail password:(NSString *)password uid:(NSString *)r2UID handle:(R2SDKHandler)handle;

//绑定到R2平台账号
- (void)bindUser:(NSString *)mail password:(NSString *)password uid:(NSString *)r2UID handle:(R2SDKHandler)handle;

//uid或第三方账号绑定查询
- (void)bindQueryWithUID:(NSString *)uid ThirdPlatID:(NSString *)platID type:(int)type handle:(R2SDKHandler)handle;//(uid和platID只能传其一)

//第三方账号绑定
- (void)bindThirdPlatID:(NSString *)playerID uid:(NSString *)uid type:(int)type handle:(R2SDKHandler)handle;

//第三方账号登陆
- (void)thirdPlatLogin:(NSString *)platID type:(int)type handle:(R2SDKHandler)handle;

//获取第三方账号好友的平台ID
- (void)getUIDFromThirdIDs:(NSArray *)friendIDs type:(int)type handle:(R2SDKHandler)handle;

//注册正式账号
- (void)registerWithEmail:(NSString *)email password:(NSString *)password handle:(R2SDKHandler)handle;

//用户名密码登陆
- (void)loginwithUserName:(NSString *)name  password:(NSString *)password handle:(R2SDKHandler)handle;

//重置密码
- (void)reGetPassword:(NSString *)email handle:(R2SDKHandler)handle;

//-------------------------------in App purchase 相关接口---------------------------------//
//获取内购商品对应本地apple账号的信息
- (void) getLoaclIAPProductsInfo:(NSArray *)productIDArray handle:(R2SDKHandler)handle;

//发起应用内购买
- (void) inAppPurchaseWithProductID:(NSString *)productID userid:(NSString *)uid serve:(NSString *)serve role:(NSString *)role mobile_transid:(NSString *)orderID handle:(R2SDKHandler)handle;

@end
