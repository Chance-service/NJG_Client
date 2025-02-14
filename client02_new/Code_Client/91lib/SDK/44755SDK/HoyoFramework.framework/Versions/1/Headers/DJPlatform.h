//
//  DJPlatform.h
//  DownjoySDK20
//
//  Created by tech on 13-2-28.
//  Copyright (c) 2013年 downjoy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface DJPlatform : UIViewController<UITextFieldDelegate>

-(void) setMerchantId : (NSString *) merchantId;
-(void) setAppId : (NSString *) appId;
-(void) setAppKey : (NSString *) appKey;
-(void) setServerId : (NSString *) serverId;
-(void) setTapBackgroundHideView : (BOOL) hidden;

-(void) setSdkDebug : (BOOL) debug;
-(BOOL) isSdkDebug;

-(void) DJDebug;
//登陆
-(void) DJLogin;
//获取用户Mid
-(NSNumber *) getCurrentMemberId;
//获取用户Token
-(NSString *) getCurrentToken;
//获取用户信息
-(void) DJReadMemberInfo;
//注销
-(void) DJLogout;
//下订单
-(void) DJPayment : (float) money productName : (NSString *) productName extInfo : (NSString *) extInfo serverid:(NSString *) serverid rate:(int)rate;
// 判断是否登陆状态
-(BOOL) DJIsLogin;

// save current game and server id
-(void) saveCurrentGameInfo;

-(void) appStorePay: (NSString *) productid exInfo :(NSString *) extInfo playerid:(NSString *) playerid serverid:(NSString *) serverid;

+(DJPlatform *) defaultDJPlatform;

-(void)tranks;

@property(strong,nonatomic) id temp;






@end
