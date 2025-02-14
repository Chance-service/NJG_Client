//
//  libRyukObj.h
//  lib91
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OnlineAHelper/YiJieOnlineHelper.h"

@interface libYouGuObjYiJie : NSObject<YiJieOnlineInitDelegate, YiJieOnlinePayResultDelegate, YiJieOnlineLoginDelegate, YiJieOnlineExtendDelegate>
{
    UIActivityIndicatorView *waitView;
}

@property (copy,nonatomic)NSString* userid;//puid
@property (copy,nonatomic)NSString* token;//token
@property (copy,nonatomic)NSString* platformId;//platformId
@property (copy,nonatomic)NSString* deviceid;//设备号
@property (copy,nonatomic)NSString* gcid;//GameCenterId
@property (copy,nonatomic)NSString* bindGcid;//绑定的GameCenterId
@property (copy,nonatomic)NSString* code;//玩家的code码 数据移行使用
@property (nonatomic,assign)BOOL isInGame;
@property (nonatomic,assign)BOOL isReLogin;//fro GJ
@property (nonatomic,assign)BOOL isEndScheduleLogin;//是否提前结束scheduleLogin的监控
- (BOOL) isLogin;
- (void) unregisterNotification;
- (void) SNSInitResult:(NSNotification *)notify;
- (void) onPresent;
- (void) RequestAccountServer:(NSString* )devicesId  gcID:(NSString* )gcId;
- (void) EnterGame:(NSString* )meg;
- (void) LevelUp:(NSString* )meg;
- (void) ChangeName:(NSString* )meg;
- (void) startScheduleLogin;
- (void) endScheduleLogin;
- (void) reEnterLoginScene:(NSNotification *)notify;
@end
#import <MessageUI/MFMailComposeViewController.h>

@interface ViewController : UIViewController<MFMailComposeViewControllerDelegate>

@end
