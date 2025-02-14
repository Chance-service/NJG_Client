//
//  ComXGSDK.h
//  Com4lovesXG
//
//  Created by finn on 2017/6/30.
//  Copyright © 2017年 wzm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XGPush.h"
#import "XGSetting.h"
#import <UIKit/UIKit.h>

@interface ComXGSDK : NSObject


/**
 创建单例

 @return 单例
 */
+ (ComXGSDK *)sharedObject;


/**
 信鸽初始化之前设置，为上报数据

 @param appId 游戏id 例如200026
 @param channelId 渠道标识 APPSTOREJPN
 */
- (void)setInfoAppID:(int)appId WithChannelID:(NSString *)channelId;

/**
 设置Debug模式，可以在终端看到详细的信鸽debug信息，方便定位问题

 @param debug 是否打开 YES/NO
 */
- (void)setXGDebug:(BOOL)debug;


/**
 查看信鸽debug开关是否打开

 @return YES/NO
 */
- (BOOL)isXGDebguEnable;


/**
 查询推送是否打开

 */
- (void)isXGPushONResult:(void (^)(BOOL isOn))Result;


/**
 初始化信鸽 在didFinishLaunchingWithOptions中调用初始化后，才能正常使用信鸽

 @param appId 前台申请的应用ID
 @param appKey 前台申请的appKey
 */
- (void)initXGSDKWithAPP:(uint32_t)appId AppKey:(nonnull NSString *)appKey DeviceID:(nonnull NSString *)deviceID;


/**
 上报收到的信鸽信息

 @param dict 返回的信息
 */
- (void)uploadReceiveInfoWithMessage:(nonnull NSDictionary *)dict;

/**
 注册设备
 
 @param deviceToken 通过appdelegate的didRegisterForRemoteNotificationsWithDeviceToken
 回调的获取
 @param successCallback 成功回调
 @param errorCallback 失败回调
 @return 获取的 deviceToken 字符串
 */
-(nullable NSString *)registerDeviceToken:(nonnull NSData *)deviceToken
                     successCallback:(nullable void (^)(void)) successCallback
                       errorCallback:(nullable void (^)(void)) errorCallback;

/**
 注册设备并且设置账号

 @param deviceToken  通过app delegate的didRegisterForRemoteNotificationsWithDeviceToken回调的获取
 @param account 需要设置的账号,长度为2个字节以上，不要使用"test","123456"这种过于简单的字符串,
 若不想设置账号,请传入nil
 @param callBackSuccess 成功回调
 @param callBackError 失败回调
 @return 获取的 deviceToken 字符串
 */
- (nullable NSString *)registerXGSDKWithDevice:(nonnull NSData *)deviceToken accoount:(nullable NSString *)account callBackSuccess:(nullable void (^)(void))callBackSuccess callBackError:(nullable void(^)(void))callBackError;

#pragma mark 设置/删除 标签

/**
 设置tag

 @param tag 需要删除的tag
 @param successCallBack 成功回调
 @param errorCallBack 失败回调
 */
- (void)setTag:(nonnull NSString *)tag successCallBack:(nullable void (^)(void))successCallBack errorCallBack:(nullable void (^)(void))errorCallBack;


/**
 删除tag

 @param tag 需要删除的tag
 @param successCallBack 成功回调
 @param errorCallBack 失败回调
 */
- (void)deleteTag:(nonnull NSString *)tag successCallBack:(nullable void (^)(void))successCallBack errorCallBack:(nullable void (^)(void))errorCallBack;

#pragma mark 设置删除账号

/**
 设置设备账号 ，设置账号前需要调用一次registerDevice

 @param account 需要设置的账号,长度为2个字节以上，不要使用"test","123456"这种过于简单的字符串,
 若不想设置账号,请传入nil
 @param successCallBack 成功回调
 @param errorCallBack 失败回到
 @param XGToken 用于上报的token
 */
- (void)setXGAccount:(nonnull NSString *)account successCallBack:(nullable void (^)(void))successCallBack errorCallBack:(nullable void(^)(void))errorCallBack WithXGToken:(nonnull NSString *)XGToken;

/**
 删除已经设置的账号

 @param successCallBack 成功回调
 @param errorCallBack 失败回调
 */
- (void)deleteAccount:(nullable void (^)(void))successCallBack errorCallBack:(nullable void (^)(void))errorCallBack;


/**
 在didFinishLaunchingWithOptions中调用，用于推送反馈.(app没有运行时，点击推送启动时)

 @param launchOptions didFinishLaunchingWithOptions中的userinfo参数
 @param successCallBack 成功回调
 @param errorCallBack 失败回调
 */
- (void)xghandleLaunching:(nonnull NSDictionary *)launchOptions successCallback:(nullable void (^)(void))successCallBack errorCallBack:(nullable void (^)(void))errorCallBack;


/**
 在didReceiveRemoteNotification中调用，用于推送反馈。(app在运行时) 对于iOS 10, UNUserNotificationCenterDelegate 的userNotificationCenter中调用

 @param userInfo userInfo 苹果 apns 的推送信息
 @param successCallBack 成功回调
 @param errorCallBack 失败回调
 */
- (void)xghandleReceiveNotification:(nonnull NSDictionary *)userInfo successCallBack:(nullable void (^)(void))successCallBack errorCallBack:(nullable void (^)(void))errorCallBack;


/**
 用于游戏内上报信鸽推送的状态

 @param moduleName 模块名字
 @param log 上报的log
 @param status 状态
 */
- (void)uploadXGInfoWithModule:(NSString *)moduleName WithLog:(NSString *)log WithStatus:(int)status;

@end
