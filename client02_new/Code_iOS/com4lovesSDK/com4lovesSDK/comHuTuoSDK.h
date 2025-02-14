//
//  com4lovesSDK.h
//  com4lovesSDK
//
//  Created by fish on 13-8-20.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HuTuoServerInfo;
#define com4loves_loginDone             @"huTuo_loginDone"
#define com4loves_logout                @"huTuo_loginOut"
#define com4loves_tryuser2OkSucess      @"huTuo_tryuser2OkSucess"
#define com4loves_buyDone               @"huTuo_buyDone"
#define com4loves_serverList            @"huTuo_serverList"


@interface comHuTuoSDK : NSObject

+ (comHuTuoSDK *)sharedInstance;

+ (NSString *)getCha25252lID;  //platform_youai  下的各个小渠道区分
+ (NSString *)getPlatformID;  //平台区分 platform 91，pp，appstore，youai等等

+ (NSString *)getSDKAppID;   //有爱 后台统计用的appid
+ (NSString *)getSDKAppKey;  //有爱 后台统计用的appkey
+ (NSString *)getSignSecret;  

+ (void)setSDKAppID:(NSString *) SDKID
          SDKAPPKey:(NSString *) SDKKey
          ChannelID:(NSString *) channel
         PlatformID:(NSString *) platform;
+ (void)setAppId:(NSString *)paramAppKey;
- (BOOL)getLogined;
- (BOOL)getIsInGame;
- (BOOL)getIsTryUser;
- (void)setFinalYouaiID:(NSString*)youaiID;//设置有爱ID
+(NSString*)getYouaiID;
-(NSString*)getLoginedUserName;
+(NSString*)getAppID;

//-(void) showWeb:(NSString*)url;

-(void)Login;
-(void)LoginTryUser;
-(void)showLogin;
-(void)showRegister;
-(void)showAccountManager;
-(void)showAccountCenter;
-(void)showChangePassword;
-(void)showUserList;
-(void)showPay;
-(void)showBinding;
-(void)notifyEnterGame;
-(void)notifyLogoutGame;
-(void)hideAll;

-(void)clearLoginInfo;
-(void)logout;
-(void)logoutInGame;
-(void)tryUser2SucessNotify;
//-(void)iapBuy:(NSString*)productID serverID:(NSString*)description ;
-(void)appStoreBuy:(NSString*)_productID serverID:(NSString*)description totalFee:(float)fee orderId:(NSString *)orderId;
/**
 *  处理日本支付问题
 *
 *  @param _productID  产品id
 *  @param description 产品描述
 *  @param fee         价格
 *  @param orderId     订单id
 *  @param puid        登陆时处理的puid
 */
//-(void)appStoreBuy:(NSString*)_productID serverID:(NSString*)description totalFee:(float)fee orderId:(NSString *)orderId puid:(NSString *)puid;
-(void)appBuy:(NSString*)_productID  serverID:(NSString*)description totalFee:(float)fee orderId:(NSString *)orderId;
+(void)updateServerInfo:(int)serverID playerName:(NSString*)playerName playerID:(int)playerID lvl:(int)lvl vipLvl:(int)vipLvl coin1:(int)coin1 coin2:(int)coin2 pushSer:(BOOL) isPush;
+(void)refreshServerInfo:(NSString*) gameID puid:(NSString*)puid pushSer:(BOOL) isPush;
+(int)getServerInfoCount;
+(int)getServerUserByIndex:(int)index;
+(HuTuoServerInfo *)getServerInfo;
- (void)parseURL:(NSURL *)url;
-(void)showFeedBack;
-(void)showSdkFeedBackWithUserName:(NSString *)userName;
+(NSString *)getPropertyFromIniFile:(NSString *)section andAttr:(NSString *)attr;
+(NSString *)getPropertyFromPublicIniFile:(NSString *)section andAttr:(NSString *)attr;
- (NSBundle *)mainBundle;
+(NSString*)getLang:(NSString *)key;
-(BOOL)putStringToItunes:(NSData*)iapData;
@end

