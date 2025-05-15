#import <UIKit/UIKit.h>

#include "libErolabs.h"
#include "libOS.h"
#include "SeverConsts.h"

//#import <KUSOPlaySDK/KUSOPlaySDK.h>
#import <TapDB/TapDB.h>

SDK_CONFIG_STU sdkConfigure;
static bool isGuest = 0;
static std::string loginName = "";
static std::string token = "";
static NSString* paymentCallbackUrl = @"https://debug.paycallback.quantagalaxies.com/KusoPay?params=";
static int serverId = 9;
static NSString* tapDBId = @"38557e71wa26gpy8";
static NSString* tapDBChannel = @"quanta";
static bool enableTapDBLog = true;

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
/*
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
*/
void libErolabs::initWithConfigure(const SDK_CONFIG_STU& configure)
{
    sdkConfigure = configure;
    //libIos_mLogined = false;
    _boardcastUpdateCheckDone(true, "");
}

void libErolabs::setupSDK(int platformId)
{
    // Setup kuso sdk
    if ((SeverConsts::E_PLATFORM)platformId == SeverConsts::EP_EROLABS)
    {
        UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
        NSLog(@"Erolabs: Setup");
        // TODO:
        //PlayCenterConfig *config = [[[PlayCenterConfig alloc]
        //                             initWithAppId:@"APPncbR1hdPgUIjSKt"
        //                             isSandbox:YES
        //                             subId:@"NG24"
        //                            ] autorelease];
        //[PlayCenter.shared
        // setupViewController:controller
        // config:config];
    }
    // Init tapDB
    NSLog(@"TapDB: Setup");
    [TapDB enableLog:enableTapDBLog];
    [TapDB onStart:tapDBId channel:tapDBChannel version:nil properties:nil];
}

#pragma mark
#pragma mark ------------------------------- login with ----------------------------------

bool libErolabs::getLogined()
{
    // TODO:
    return true;
    //return PlayCenter.shared.isLoggedIn;
}

void libErolabs::login()
{
    if(!this->getLogined())
	{
        this->doSDKLogin();
    }
    
}

void libErolabs::logout()
{
    // TODO:
    /*
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
     */
}

void libErolabs::doSDKLogin()
{
    NSLog(@"Erolabs: Try Login");
    UIViewController* controller = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect frame = controller.view.frame;
    //float oldY = frame.origin.y;
    //NSLog(@"KUSO: Adjust view y: %f", oldY);
    frame.origin.y = -10;
    controller.view.frame = frame;
    //NSLog(@"KUSO: Adjust view y: %f", oldY);
    /*
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
     */
}

void libErolabs::switchUsers()
{
    //if(!this->getLogined())
	//{
    //    [[NdComPlatform defaultPlatform] NdLogin:0];
    //}
    //else
    //    [[NdComPlatform defaultPlatform] NdEnterPlatform:0];
}

void libErolabs::setLoginName(const std::string content)
{
    loginName = content;
}

std::string libErolabs::getLoginName()
{
    return loginName;
}

#pragma mark
#pragma mark ------------------------------- pay with ----------------------------------

void libErolabs::buyGoods(BUYINFO& info)
{
    if(info.cooOrderSerial=="")
    {
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    NSString *orderSerial = info.cooOrderSerial.empty() ? @"" : [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    
    // TODO:
    /*
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
    
    NSLog(@"buy goods");
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
    */
    
    
}

#pragma mark
#pragma mark ----------------------------- platfrom tool -------------------------------------

void libErolabs::openBBS()
{

}

void libErolabs::userFeedBack()
{

}
void libErolabs::gamePause()
{

}

void libErolabs::setToolBarVisible(bool isShow)
{

}

#pragma mark
#pragma mark ----------------------------- login user data ----------------------------------

const std::string& libErolabs::loginUin()
{
    return loginName;
}
const std::string& libErolabs::sessionID()
{
	//NSString* retNS = [[NdComPlatform defaultPlatform] sessionId];
    //static std::string retStr;
    //if(retNS) retStr = (const char*)[retNS UTF8String];
    //return retStr;
    static std::string ret = "";
    return ret;
}
const std::string& libErolabs::nickName()
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
const std::string libErolabs::getClientChannel()
{
    return "ios_erolabs";
}

const std::string libErolabs::getClientCps()
{
    return "#0";
}



std::string libErolabs::getPlatformMoneyName()
{
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark
#pragma mark ----------------------------- platform -----------------------------------
void libErolabs::notifyEnterGame()
{
    //s_lib91Ojb.isInGame = YES;
}

bool libErolabs::getIsTryUser()
{
    return false;
}

void libErolabs::callPlatformBindUser()
{
    
}

void libErolabs::notifyGameSvrBindTryUserToOkUserResult(int result)
{
    
}

const std::string& libErolabs::getToken()
{
    return token;
}

void libErolabs::showPlatformProfile()
{
    // TODO: 
    //[PlayCenter.shared profile];
}


bool libErolabs::getIsH365()
{
    return false;
}

void libErolabs::updateApp(std::string& storeUrl)
{
}

int libErolabs::getIsGuest()
{
    return isGuest;
}


const unsigned int libErolabs::getPlatformId()
{

    return SeverConsts::EP_EROLABS;
}

void libErolabs::setIsGuest(const int guest)
{
    isGuest = guest;
}

std::string libErolabs::sendMessageG2P(const std::string& tag, const std::string& msg)
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
    return "";
}

void libErolabs::OnKrGetInviteCount(){}
void libErolabs::OnKrgetInviteLists(){}
void libErolabs::OnKrgetFriendLists(){}
void libErolabs::OnKrsendInvite(const std::string& strUserId, const std::string& strServerId){}
void libErolabs::OnKrgetGiftLists(){}
void libErolabs::OnKrReceiveGift(const std::string& strGiftId, const std::string& strServerId){}
void libErolabs::OnKrGetGiftCount(){}
void libErolabs::OnKrSendGift(const std::string& strUserName, const std::string& strServerId){}
void libErolabs::OnKrGiftBlock(bool bVisible){}
void libErolabs::OnKrGetKakaoId(){}
void libErolabs::OnKrLoginGames(){}
void libErolabs::OnKrIsShowFucForIOS(){}

void libErolabs::setLanguageName(const std::string& lang){}
void libErolabs::setPlatformName(int platform){}
void libErolabs::setPayH365(const std::string& url){}
void libErolabs::setPayR18(int mid, int serverid, const std::string& url){}
    
int libErolabs::getHoneyP()
{
    return 0;
}
void libErolabs::setHoneyP(int aMoney)
{
}
