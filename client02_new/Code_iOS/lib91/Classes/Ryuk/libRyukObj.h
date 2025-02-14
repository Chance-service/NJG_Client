//
//  libRyukObj.h
//  lib91
//
//  Created by fanleesong on 15/3/2.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
@interface libRyukObj : NSObject{
    UIActivityIndicatorView *waitView;
}

@property (copy,nonatomic)NSString* userid;//puid
@property (copy,nonatomic)NSString* deviceid;//设备号
@property (copy,nonatomic)NSString* gcid;//GameCenterId
@property (copy,nonatomic)NSString* bindGcid;//绑定的GameCenterId
@property (copy,nonatomic)NSString* code;//玩家的code码 数据移行使用
@property (copy,nonatomic)NSString* newCode;
@property (copy,nonatomic)NSString* newBindGcid;
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
@property (nonatomic,assign)BOOL isShowAlaterGC;//fro GJ
@property (nonatomic,assign)BOOL isInBindGC;
@property (nonatomic,assign)BOOL isInMainScene;//是否在主场景
@property (nonatomic,assign)BOOL isEndScheduleLogin;//是否提前结束scheduleLogin的监控
- (BOOL) isLogin;
- (void) unregisterNotification;
- (void) SNSInitResult:(NSNotification *)notify;
-(void)onPresent;
- (void) RequestAccountServer:(NSString* )devicesId  gcID:(NSString* )gcId;
- (void) startScheduleLogin;
- (void) endScheduleLogin;
- (void)getCroproCount:(NSString*)getURL cId:(NSString*)cid startAt:(NSString*)start endAt:(NSString*)end key:(NSString*)hashKey;
@end
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController : UIViewController<MFMailComposeViewControllerDelegate>

@end