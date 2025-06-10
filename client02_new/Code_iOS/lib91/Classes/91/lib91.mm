#import <UIKit/UIKit.h>

#include "lib91.h"
#include "libOS.h"
#include "SeverConsts.h"

#ifdef PROJECT_KUSO
#import <KUSOPlaySDK/KUSOPlaySDK.h>
#endif

#ifdef PROJECT_EROLABS
#import "analytics_sdk_ios_framework/analytics_sdk_ios_framework.m"
#endif

#import <TapDB/TapDB.h>

//lib91Obj* s_lib91Ojb = 0;
SDK_CONFIG_STU sdkConfigure;
static bool isGuest = 0;
static std::string loginName = "";
static std::string token = "";
static NSString* paymentCallbackUrl = @"https://debug.paycallback.quantagalaxies.com/KusoPay?params=";
static int serverId = 9;
static NSString* tapDBId = @"38557e71wa26gpy8";
static NSString* tapDBChannel = @"quanta";
static bool enableTapDBLog = true;
static int HoneyP = 0;

@interface Helpers : NSObject
+ (NSDictionary*) stringToDictionary:(NSString*) jsonString;
@end

@implementation Helpers
+ (NSDictionary*) stringToDictionary:(NSString*) jsonString
{
    if (jsonString == nil)
        return nil;
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];

    if (error != nil)
    {
        NSLog(@"JSON Parsing Error: %@", error.localizedDescription);
        return nil;
    }
    else
    {
        return jsonObject;
    }
}

@end

@interface StringEscaper : NSObject
+ (NSString *)escape:(NSString *)src;
@end

@implementation StringEscaper
+ (NSString *)escape:(NSString *)src {
    NSMutableString *tmp = [NSMutableString string];
    
    for (NSUInteger i = 0; i < src.length; i++) {
        unichar j = [src characterAtIndex:i];
        
        if ([[NSCharacterSet alphanumericCharacterSet] characterIsMember:j]) {
            [tmp appendFormat:@"%c", j];
        } else if (j < 256) {
            [tmp appendFormat:@"%%%02x", j];
        } else {
            [tmp appendFormat:@"%%u%04x", j];
        }
    }
    
    return tmp;
}
@end

#ifdef PROJECT_KUSO

@interface KUSOLoginListener : NSObject <PlayCenterLoginListener>
@property (nonatomic, copy) void (^onLoginSuccessBlock)
(
 BOOL success,
 NSString * _Nullable userId,
 NSString * _Nullable token,
 PlayCenterError * _Nullable error
);
@end

@implementation KUSOLoginListener

// Implement the onLoginSuccess method from the protocol
- (void)onLoginSuccess:(BOOL)success id:(NSString * _Nullable)userId token:(NSString * _Nullable)token error:(PlayCenterError * _Nullable)error
{
    if (self.onLoginSuccessBlock)
    {
        self.onLoginSuccessBlock(success, userId, token, error);
    }
}
@end

@interface KUSOLogoutListener : NSObject <PlayCenterLogoutListener>
@property (nonatomic, copy) void (^onLogoutSuccessBlock)
(
 BOOL success
);
@end

@implementation KUSOLogoutListener

// Implement the onLoginSuccess method from the protocol
- (void)onLogoutSuccess:(BOOL)success
{
    if (self.onLogoutSuccessBlock)
    {
        self.onLogoutSuccessBlock(success);
    }
}
@end

@interface KUSOPayListener : NSObject <PlayCenterPayOrderListener>
@property (nonatomic, copy) void (^onPaymentReadyBlock)
(
 BOOL success,
 NSString * _Nullable url,
 NSString * _Nullable orderId,
 PlayCenterError * _Nullable error
);
@end

@implementation KUSOPayListener

- (BOOL)onPaymentReadySuccess:(BOOL)success url:(NSString * _Nullable)url orderId:(NSString * _Nullable)orderId error:(PlayCenterError * _Nullable)error
{
    if (self.onPaymentReadyBlock)
    {
        self.onPaymentReadyBlock(success, url, orderId, error);
    }
    return !success;
}

@end

#endif

void lib91::initWithConfigure(const SDK_CONFIG_STU& configure)
{
    sdkConfigure = configure;
    //libIos_mLogined = false;
    _boardcastUpdateCheckDone(true, "");
    
    //init com4lovesSDK
    /*NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    [comHuTuoSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [comHuTuoSDK  setAppId:yaappID];
    
    //DataEyeInit
 //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    s_lib91Ojb = [lib91Obj new];
    [s_lib91Ojb SNSInitResult:0];
    s_lib91Ojb.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    
    //初始化平台
    NdInitConfigure *cfg = [[NdInitConfigure alloc] init];
    cfg.appid       = [appID intValue];
    cfg.appKey      = appKey;
    cfg.versionCheckLevel = ND_VERSION_CHECK_LEVEL_STRICT;
    cfg.orientation = UIInterfaceOrientationPortrait ;
    [[NdComPlatform defaultPlatform] NdShowToolBar:NdToolBarAtTopRight];
    [[NdComPlatform defaultPlatform] NdInit:cfg];
    this->setToolBarVisible(YES);
    [[NdComPlatform defaultPlatform] NdSetScreenOrientation:UIInterfaceOrientationPortrait];
    [[NdComPlatform defaultPlatform] NdSetAutoRotation:NO];
    [cfg release];*/
}

void lib91::setupSDK(int platformId)
{
#ifdef PROJECT_KUSO
    // Setup kuso sdk
    if ((SeverConsts::E_PLATFORM)platformId == SeverConsts::EP_KUSO)
    {
        UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        NSLog(@"KUSO: Setup");
        PlayCenterConfig *config = [[[PlayCenterConfig alloc]
                                     initWithAppId:@"APPncbR1hdPgUIjSKt"
                                     isSandbox:YES
                                     subId:@"NG24"
                                    ] autorelease];
        [PlayCenter.shared
         setupViewController:controller
         config:config];
    }
#endif
    
#ifdef PROJECT_EROLABS
    //[Hyena setAdvertiserIDCollectionEnabled:NO];
    [Hyena appStart:@"70A857C60DF94AACB8C48D6EE6A5C594"];
#endif
    // Init tapDB
    NSLog(@"TapDB: Setup");
    [TapDB enableLog:enableTapDBLog];
    [TapDB onStart:tapDBId channel:tapDBChannel version:nil properties:nil];
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool lib91::getLogined()
{
#ifdef PROJECT_KUSO
    return PlayCenter.shared.isLoggedIn;
#endif
    return false;
}

void lib91::login()
{
    if(!this->getLogined())
	{
        this->doSDKLogin();
    }
    
}

void lib91::logout()
{
#ifdef PROJECT_KUSO
    KUSOLogoutListener *listener = [[KUSOLogoutListener alloc] init];
    listener.onLogoutSuccessBlock = ^(BOOL success)
    {
        if (success)
        {
            NSLog(@"KUSO: Logout!");
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_PLATFORM_LOGOUT", "1");
        }
    };
    
    [PlayCenter.shared logoutListener:listener];
#endif
#ifdef PROJECT_EROLABS
    _boardcastPlatformLogout();
    libPlatformManager::getPlatform()->sendMessageP2G("P2G_PLATFORM_LOGOUT", "1");
#endif
}

void lib91::doSDKLogin()
{
#ifdef PROJECT_KUSO
    NSLog(@"KUSO: Try Login");
    UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect frame = controller.view.frame;
    //float oldY = frame.origin.y;
    //NSLog(@"KUSO: Adjust view y: %f", oldY);
    frame.origin.y = -10;
    controller.view.frame = frame;
    //NSLog(@"KUSO: Adjust view y: %f", oldY);
    KUSOLoginListener *listener = [[KUSOLoginListener alloc] init];
    listener.onLoginSuccessBlock = ^(BOOL success, NSString * _Nullable userId, NSString * _Nullable t, PlayCenterError * _Nullable error)
    {
        if (success)
        {
            NSLog(@"KUSO: Login Success! User ID: %@, Token: %@", userId, t);
            setLoginName([userId UTF8String]);
            token = [t UTF8String];
            _boardcastLoginResult(true, "Login Success!");
        } else
        {
            NSLog(@"KUSO: Login Failed: %@", error.message);
            _boardcastLoginResult(false, "Login Failed!");
        }
        CGRect f = controller.view.frame;
        f.origin.y = 30;
        //NSLog(@"KUSO: reset view y: %f", oldY);
        controller.view.frame = f;
    };
    
    [PlayCenter.shared loginListener:listener];
#endif
#ifdef PROJECT_EROLABS
    // Lua will handle the login flow, so just return success
    _boardcastLoginResult(true, "");
#endif
    
}

void lib91::switchUsers()
{
    //if(!this->getLogined())
	//{
    //    [[NdComPlatform defaultPlatform] NdLogin:0];
    //}
    //else
    //    [[NdComPlatform defaultPlatform] NdEnterPlatform:0];
}

void lib91::setLoginName(const std::string content)
{
    loginName = content;
}

std::string lib91::getLoginName()
{
    return loginName;
}

#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------

void lib91::buyGoods(BUYINFO& info)
{
    if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    NSString *orderSerial = info.cooOrderSerial.empty() ? @"" : [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    
#ifdef PROJECT_KUSO
    KUSOPayListener *listener = [[KUSOPayListener alloc] init];
    listener.onPaymentReadyBlock = ^(BOOL success, NSString * _Nullable url, NSString * _Nullable orderId, PlayCenterError * _Nullable error)
    {
        NSLog(@"KUSO: onPaymentReadyBlock: %d %s %s", success, [url UTF8String], [orderId UTF8String]);
        if (success)
        {
            NSLog(@"KUSO: payment ready success!");
            NSString* msg = [NSString stringWithFormat:@"%@|%@|%@|%@",
                             [orderId stringByReplacingOccurrencesOfString:@"\"" withString:@""],
                             [NSString stringWithUTF8String:token.c_str()],
                             orderSerial,
                             [NSString stringWithUTF8String:info.productId.c_str()]];
            libPlatform* lp =libPlatformManager::getPlatform();
            lp->sendMessageP2G("onKusoPay", [msg UTF8String]);
        }
        else
        {
            NSLog(@"%s", [error.message UTF8String]);
        }
    };
    
    NSMutableDictionary *items = [NSMutableDictionary dictionary];
    [items setObject:[NSString stringWithUTF8String:loginName.c_str()]  forKey:@"puid"];
    [items setObject:orderSerial forKey:@"orderSerial"];
    [items setObject:@"ios_kuso"  forKey:@"platform"];
    [items setObject:[NSString stringWithFormat:@"%f", info.productPrice]  forKey:@"payMoney"];
    [items setObject:[NSString stringWithUTF8String:info.name.c_str()]  forKey:@"goodsId"];
    [items setObject:@(info.productCount)  forKey:@"goodsCount"];
    [items setObject:@(serverId) forKey:@"serverId"];
    [items setObject:@"false" forKey:@"test"];
    
    NSLog(@"KUSO: buy goods");
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:items options:0 error:&error];
    NSString* itemsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    NSString *cbu =[NSString stringWithFormat:@"%@%@&user=kuso", paymentCallbackUrl, [StringEscaper escape:itemsString]];
    NSString *desc = info.description.empty() ? @"" : [NSString stringWithUTF8String:info.description.c_str()];
    NSLog(@"KUSO: cbu: %@", cbu);
    NSLog(@"KUSO: itemString: %@", itemsString);
    [PlayCenter.shared
     payOrderAmount:info.productPrice
     currency:CurrencyEnum.enum_.CNY
     gatewayCode:GatewayCodeEnum.enum_.ALL
     callbackUrl:cbu
     description:desc
     nonce:orderSerial
     items:itemsString
     listener:listener];
#endif
    /*if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NdBuyInfo* buyinfo = [NdBuyInfo new];
    buyinfo.cooOrderSerial = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    buyinfo.productId = [NSString stringWithUTF8String:info.productId.c_str()];
    buyinfo.productName = [NSString stringWithUTF8String:info.productName.c_str()];
    buyinfo.productPrice = info.productPrice;
    buyinfo.productOrignalPrice = info.productOrignalPrice;
    if(info.productOrignalPrice == 0)
        buyinfo.productOrignalPrice = info.productPrice;
    buyinfo.productCount = 1;//info.productCount;
    buyinfo.payDescription = [NSString stringWithUTF8String:info.description.c_str()];
    int res = [[NdComPlatform defaultPlatform] NdUniPayAsyn:buyinfo];
    if(res<0)
    {
        std::string log("购买信息发送失败");
        _boardcastBuyinfoSent(false, info,log);
    }
    [buyinfo release];*/
//    else
//    {
//        //DataEye pay Statistics
//        NSString *price = [NSString stringWithFormat:@"%f",info.productPrice];
//        NSString *orderID = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
//        [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateBuyBegin object:[NSDictionary dictionaryWithObjectsAndKeys:orderID,@"orderID",price,@"price",@"ios_91",@"payType",nil]];
//    }
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------

void lib91::openBBS()
{
    //[[NdComPlatform defaultPlatform] NdEnterAppBBS:0];
}

void lib91::userFeedBack()
{
    //[[NdComPlatform defaultPlatform] NdUserFeedBack];
}
void lib91::gamePause()
{
    //[[NdComPlatform defaultPlatform] NdPause];
}

void lib91::setToolBarVisible(bool isShow)
{
    if(isShow)
    {
        //[[NdComPlatform defaultPlatform] NdShowToolBar:NdToolBarAtTopRight];
    }
    else
    {
        //[[NdComPlatform defaultPlatform] NdHideToolBar];
    }
}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------

const std::string& lib91::loginUin()
{
    /*static std::string retStr = "";
    NSString* retNS = [[NdComPlatform defaultPlatform] loginUin];
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix + retStr;
    }
    return retStr;*/
    return loginName;
}
const std::string& lib91::sessionID()
{
	//NSString* retNS = [[NdComPlatform defaultPlatform] sessionId];
    //static std::string retStr;
    //if(retNS) retStr = (const char*)[retNS UTF8String];
    //return retStr;
    static std::string ret = "";
    return ret;
}
const std::string& lib91::nickName()
{
    //NSString* retNS = [[NdComPlatform defaultPlatform] nickName];
    //static std::string retStr;
    //if(retNS) retStr = [retNS UTF8String];
    //return retStr;
    static std::string ret = "";
    return ret;
}

#pragma mark
#pragma mark ----------------------------- platform data -----------------------------------
const std::string lib91::getClientChannel()
{
#ifdef PROJECT_KUSO
    return "ios_kuso";
#endif
#ifdef PROJECT_EROLABS
    return "ios_erolabs";
#endif
    return "";
}

const std::string lib91::getClientCps()
{
    return "#0";
}

const std::string lib91::getBuildType()
{
    return "release";
}



std::string lib91::getPlatformMoneyName()
{
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark
#pragma mark ----------------------------- platform -----------------------------------
void lib91::notifyEnterGame()
{
    //s_lib91Ojb.isInGame = YES;
}

bool lib91::getIsTryUser()
{
    return false;
}

void lib91::callPlatformBindUser()
{
    
}

void lib91::notifyGameSvrBindTryUserToOkUserResult(int result)
{
    
}

const std::string& lib91::getToken()
{
    return token;
}

void lib91::showPlatformProfile()
{
#ifdef PROJECT_KUSO
    [PlayCenter.shared profile];
#endif
}


bool lib91::getIsH365()
{
    return false;
}

void lib91::updateApp(std::string& storeUrl)
{
    NSString *urlStr = [NSString stringWithUTF8String:storeUrl.c_str()];
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"URL opened successfully");
            } else {
                NSLog(@"Failed to open URL");
            }
        }];
    }
}

int lib91::getIsGuest()
{
    return isGuest;
}


const unsigned int lib91::getPlatformId()
{
#ifdef PROJECT_KUSO
    return SeverConsts::EP_KUSO;
#endif
#ifdef PROJECT_EROLABS
    return SeverConsts::EP_EROLABS;
#endif
    return SeverConsts::EP_NONE;
}

void lib91::setIsGuest(const int guest)
{
    isGuest = guest;
}

std::string lib91::sendMessageG2P(const std::string& tag, const std::string& msg)
{
    //NSLog(@"sendMessageG2P: %s %s", tag.c_str(), msg.c_str());
    if(tag == "G2P_TAPDB_HANDLER")
    {
        NSLog(@"TapDB: message: %s", msg.c_str());
        NSDictionary* jsonObject = [Helpers stringToDictionary:[NSString stringWithUTF8String:msg.c_str()]];

        if (jsonObject == nil)
            return nil;
        
        NSString* key = jsonObject[@"funtion"];
        if ([key isEqualToString:@"trackEvent"])
        {
            NSString* eventName = jsonObject[@"param"];
            NSString* jsonStr = jsonObject[@"properties"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            
            if (jsonDict != nil)
            {
                [TapDB trackEvent:eventName properties:jsonDict];
            }
            
        }
        else if ([key isEqualToString:@"setUser"])
        {
            NSString* userId = jsonObject[@"param"];
            NSString* jsonStr = jsonObject[@"properties"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            if (jsonDict == nil)
            {
                [TapDB setUser:userId];
            }
            else
            {
                [TapDB setUser:userId properties:jsonDict];
            }
            
        }
        else if ([key isEqualToString:@"setName"])
        {
            NSString* name = jsonObject[@"param"];
            [TapDB setName:name];

        }
        else if ([key isEqualToString:@"setServer"])
        {
            NSString* server = jsonObject[@"param"];
            [TapDB setServer:server];
        }
        else if ([key isEqualToString:@"setLevel"])
        {
            NSNumber* level = jsonObject[@"param"];
            [TapDB setLevel:[level intValue]];
        }
        else if ([key isEqualToString:@"deviceUpdate"])
        {
            NSString* jsonStr = jsonObject[@"param"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            if (jsonDict != nil)
            {
                [TapDB deviceUpdate:jsonDict];
            }
        }
        else if ([key isEqualToString:@"deviceInitialize"])
        {
            NSString* jsonStr = jsonObject[@"param"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            
            if (jsonDict != nil)
            {
                [TapDB deviceInitialize:jsonDict];
            }
        }
        else if ([key isEqualToString:@"deviceAdd"])
        {
            NSString* jsonStr = jsonObject[@"param"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            if (jsonDict != nil)
            {
                [TapDB deviceAdd:jsonDict];
            }
        }
        else if ([key isEqualToString:@"userUpdate"])
        {
            NSString* jsonStr = jsonObject[@"param"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            if (jsonDict != nil)
            {
                [TapDB userUpdate:jsonDict];
            }
        }
        else if ([key isEqualToString:@"userInitialize"])
        {
            NSString* jsonStr = jsonObject[@"param"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            if (jsonDict != nil)
            {
                [TapDB userInitialize:jsonDict];
            }
        }
        else if ([key isEqualToString:@"userAdd"])
        {
            NSString* jsonStr = jsonObject[@"param"];
            NSDictionary* jsonDict = [Helpers stringToDictionary:jsonStr];
            if (jsonDict != nil)
            {
                [TapDB userAdd:jsonDict];
            }
        }
    }
    if(tag == "G2P_REPORT_HANDLER")
    {
        NSDictionary* jsonObject = [Helpers stringToDictionary:[NSString stringWithUTF8String:msg.c_str()]];
        NSNumber *eventIdNumber = jsonObject[@"eventId"];
        if ([eventIdNumber intValue] == 2) { // report hyena login
            NSString *userId = jsonObject[@"userId"];
            NSString *platformUserId = jsonObject[@"userId"];  // assuming same field as in Java code
            [[Hyena getTracker] login:userId and:platformUserId];
        }
    }
        
    return "";
}

void lib91::OnKrGetInviteCount(){}
void lib91::OnKrgetInviteLists(){}
void lib91::OnKrgetFriendLists(){}
void lib91::OnKrsendInvite(const std::string& strUserId, const std::string& strServerId){}
void lib91::OnKrgetGiftLists(){}
void lib91::OnKrReceiveGift(const std::string& strGiftId, const std::string& strServerId){}
void lib91::OnKrGetGiftCount(){}
void lib91::OnKrSendGift(const std::string& strUserName, const std::string& strServerId){}
void lib91::OnKrGiftBlock(bool bVisible){}
void lib91::OnKrGetKakaoId(){}
void lib91::OnKrLoginGames(){}
void lib91::OnKrIsShowFucForIOS(){}

void lib91::setLanguageName(const std::string& lang){}
void lib91::setPlatformName(int platform){}
void lib91::setPayH365(const std::string& url){}
void lib91::setPayR18(int mid, int serverid, const std::string& url){}
    
int lib91::getHoneyP()
{
    return HoneyP;
}
void lib91::setHoneyP(int aMoney)
{
    HoneyP = aMoney;
}
