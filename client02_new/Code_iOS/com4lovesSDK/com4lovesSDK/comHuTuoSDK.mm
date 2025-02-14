
//
//  com4lovesSDK.m
//  com4lovesSDK
//
//  Created by fish on 13-8-20.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "comHuTuoSDK.h"
#import "DDAlertPrompt.h"
#import "JSON.h"
#import "InAppPurchaseManager.h"
#import "comHuTuo.h"

#import "GTMBase64.h"
#import "GTMDefines.h"
#import "SDKUtility.h"
#import "ServerLogic.h"
#import "HuTuoUser.h"
#import "HuTuoServerInfo.h"
#import "SimpleIni.h"






static NSString*   SDKAppKey = @"gjwow_ios";
static NSString*   SDKAppID = @"1";
static NSString*   channelID = @"1000";
static NSString*   platFormID = @"ios_huotuo";
static NSString*   appKey = @"gjwow_ios";
static BOOL        isNeedNet;

static NSString*   SDKSecret = @"gjwowappstoreeleilcoqodcq";

static NSMutableArray * userLoginedServers = [[NSMutableArray alloc] init];
static NSString*   currentServierID;
static HuTuoServerInfo *serverInfo = [[HuTuoServerInfo alloc] init];
#define APPSTORE_VERIFY_ORDER

@interface comHuTuoSDK()
{
    NSString*   productID;
    float       productPrice;
    float       productCount;
    BOOL        userLogout;
    BOOL        defautlLoginFalse;
    NSBundle               *mainBundle;
}
@property (nonatomic)    BOOL        isEnterGame;
#ifndef C4L_PURE_WITHOUT_INTERFACE

//@property (retain,nonatomic) LoginView*             viewLogin;
//@property (retain,nonatomic) RegisterView*          viewRegister;
//@property (retain,nonatomic) WebView* viewWeb;
//@property (retain,nonatomic) AccountManagerView*    viewAccountManager;
//@property (retain,nonatomic) AccountCenterView*     viewAccountCenter;
//@property (retain,nonatomic) ChangePasswordView*    viewChangePassword;
//@property (retain,nonatomic) UserListView*          viewUserList;
//@property (retain,nonatomic) SelfPayView*           viewSelfPay;
#ifdef YOUAI_KUAIYONG
@property (retain,nonatomic) OtherViewController*   viewKyPay;
#endif
@property (retain,nonatomic) UIViewController*      viewCurrent;
@property (retain,nonatomic) NSBundle               *mainBundle;

#endif

@end

@implementation comHuTuoSDK
#ifndef C4L_PURE_WITHOUT_INTERFACE
@synthesize mainBundle = _mainBundle;
#endif

+(id) sharedInstance {
    static comHuTuoSDK *_instance = nil;
    if (_instance == nil) {
        _instance = [[comHuTuoSDK alloc] init];
        [_instance initSDK];
    }
    return _instance;
}

- (BOOL)initSDK
{
#ifndef C4L_PURE_WITHOUT_INTERFACE
    self.viewCurrent = nil;
#endif
    defautlLoginFalse = false;
    _isEnterGame = false;
    userLogout = NO;
    [[InAppPurchaseManager sharedInstance] loadStore];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iapBuyDone) name:kInAppPurchaseManagerTransactionSucceededNotification object:nil];
  
    return YES;
}

+(NSString *)getPropertyFromIniFile:(NSString *)section andAttr:(NSString *)attr
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *downLoadPath = [documentsDirectory stringByAppendingString:@"/_additionalSearchPath/dynamic.ini"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downLoadPath]) {
    
        NSLog(@"%s------not find _additionalSearchPath----not-----dynamic",__FUNCTION__);
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"dynamic.ini"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            filePath = [[NSBundle mainBundle] pathForResource:@"dynamic" ofType:@"ini"];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return nil;
        }
        NSLog(@"filePath  %@",filePath);
        CSimpleIniA ini;
        ini.SetUnicode();
        ini.LoadFile([filePath UTF8String]);
        const char * pVal = ini.GetValue([section cStringUsingEncoding:NSASCIIStringEncoding],[attr cStringUsingEncoding:NSASCIIStringEncoding] );
        if (pVal==NULL) {
            return nil;
        }
        return [NSString stringWithString:[NSString stringWithCString:pVal encoding:NSUTF8StringEncoding]];
        
    }else{
        
        NSLog(@"%s------find _additionalSearchPath------ok---dynamic",__FUNCTION__);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:downLoadPath]) {
            downLoadPath = [[NSBundle mainBundle] pathForResource:@"dynamic" ofType:@"ini" inDirectory:@"_additionalSearchPath"];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:downLoadPath]) {
            return nil;
        }
        NSLog(@"filePath  %@",downLoadPath);
        CSimpleIniA ini;
        ini.SetUnicode();
        ini.LoadFile([downLoadPath UTF8String]);
        const char * pVal = ini.GetValue([section cStringUsingEncoding:NSASCIIStringEncoding],[attr cStringUsingEncoding:NSASCIIStringEncoding] );
        if (pVal==NULL) {
            return nil;
        }
        return [NSString stringWithString:[NSString stringWithCString:pVal encoding:NSUTF8StringEncoding]];
        
        
    }
    

}
+(NSString *)getPropertyFromPublicIniFile:(NSString *)section andAttr:(NSString *)attr
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *downLoadPath = [documentsDirectory stringByAppendingString:@"/_additionalSearchPath/dynamic_public.ini"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:downLoadPath]) {
        
        NSLog(@"%s------not find _additionalSearchPath----not-----dynamic_public",__FUNCTION__);
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"dynamic_public.ini"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            filePath = [[NSBundle mainBundle] pathForResource:@"dynamic_public" ofType:@"ini"];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return nil;
        }
        NSLog(@"filePath  %@",filePath);
        CSimpleIniA ini;
        ini.SetUnicode();
        ini.LoadFile([filePath UTF8String]);
        const char * pVal = ini.GetValue([section cStringUsingEncoding:NSASCIIStringEncoding],[attr cStringUsingEncoding:NSASCIIStringEncoding] );
        if (pVal==NULL) {
            return nil;
        }
        return [NSString stringWithString:[NSString stringWithCString:pVal encoding:NSUTF8StringEncoding]];
        
    }else{
        
        NSLog(@"%s------find _additionalSearchPath------ok---dynamic",__FUNCTION__);
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:downLoadPath]) {
            downLoadPath = [[NSBundle mainBundle] pathForResource:@"dynamic_public" ofType:@"ini" inDirectory:@"_additionalSearchPath"];
        }
        if (![[NSFileManager defaultManager] fileExistsAtPath:downLoadPath]) {
            return nil;
        }
        NSLog(@"filePath  %@",downLoadPath);
        CSimpleIniA ini;
        ini.SetUnicode();
        ini.LoadFile([downLoadPath UTF8String]);
        const char * pVal = ini.GetValue([section cStringUsingEncoding:NSASCIIStringEncoding],[attr cStringUsingEncoding:NSASCIIStringEncoding] );
        if (pVal==NULL) {
            return nil;
        }
        return [NSString stringWithString:[NSString stringWithCString:pVal encoding:NSUTF8StringEncoding]];
    }
}

- (NSBundle *)mainBundle
{
#ifndef C4L_PURE_WITHOUT_INTERFACE
    if (!_mainBundle) {
        NSString* fullpath1 = [[NSBundle mainBundle] pathForResource:[NSString stringWithUTF8String:"com4lovesBundle.bundle"]
                                                              ofType:nil
                                                         inDirectory:[NSString stringWithUTF8String:""]];
        //NSString* fullpath1=@"abc";
        _mainBundle = [NSBundle bundleWithPath:fullpath1];
        //NSBundle *buddle = [NSBundle bundleWithIdentifier:@"com.loves.com4lovesBundle"];
        [self.mainBundle load];
    }
    
    return _mainBundle;
#else
    return NULL;
#endif
}
+(NSString*)getLang:(NSString *)key
{
    return NSLocalizedStringFromTableInBundle(key, nil, [[comHuTuoSDK sharedInstance] mainBundle], nil);
}
#ifndef C4L_PURE_WITHOUT_INTERFACE


#ifdef YOUAI_KUAIYONG
- (OtherViewController *)viewKyPay
{
    if (!_viewKyPay) {
        self.viewKyPay =  [[[OtherViewController alloc]init] autorelease];
    }
    return _viewKyPay;
}
#endif

#endif
- (BOOL)getIsInGame
{
    return _isEnterGame;
}
- (BOOL)getIsTryUser
{
    return [[[ServerLogic sharedInstance] getLoginUserType] intValue]==2;
}
- (BOOL)getLogined
{
    if([[ServerLogic sharedInstance] getHuTuoID]!=nil &&
       [[[ServerLogic sharedInstance] getHuTuoID] length]>0 &&
       [[ServerLogic sharedInstance] getLoginedUserName]!=nil &&
       [[[ServerLogic sharedInstance] getLoginedUserName] length]>0)
        return YES;
    else
        return  NO;
}
-(void)tryUser2SucessNotify
{
    [[NSNotificationCenter defaultCenter] postNotificationName:com4loves_tryuser2OkSucess object:nil];
}
-(void)logout
{
    [self clearLoginInfo];
    [[NSNotificationCenter defaultCenter] postNotificationName:com4loves_logout object:nil];
}
-(void)logoutInGame
{
    [self clearLoginInfo];
    //[self LoginTryUser];
    [self hideAll];
}
-(void) showWeb:(NSString*)url
{

}

+ (void)setSDKAppID:(NSString *) SDKID
          SDKAPPKey:(NSString *) SDKKey
          ChannelID:(NSString *) channel
         PlatformID:(NSString *) platform;
{
    [SDKAppKey release];
    [SDKAppID release];
    [channelID release];
    [platFormID release];
    SDKAppKey   = [SDKKey retain];
    SDKAppID    = [SDKID retain];
    channelID   = [channel retain];
    platFormID  = [platform retain];
    [comHuTuoSDK statisticsInfo];
}
    

+ (NSString *)getSignSecret 
{
    return SDKSecret;
}

+ (NSString *)getSDKAppID
{
    return SDKAppID;
}
+ (NSString *)getSDKAppKey
{
    return SDKAppKey;
}

+ (NSString *)getPlatformID
{
    return platFormID;
}

+ (NSString *)getCha25252lID
{
    return channelID;
}
+(void)setAppIdDirectly:(NSString *)paramAppKey
{
    appKey = [NSString stringWithString:paramAppKey];
    [appKey retain];
}
+ (void)setAppId:(NSString *)paramAppKey
{
    [comHuTuoSDK setAppIdDirectly:paramAppKey];
}
+(NSString*)getYouaiID
{
    return [[ServerLogic sharedInstance] getHuTuoID];
}
+(NSString*)getAppID
{
    return appKey;
}

-(NSString*)getLoginedUserName
{
    return [[ServerLogic sharedInstance] getLoginedUserName];
}

- (BOOL)getNeedNet
{
    return isNeedNet;
}
+ (void)setNeedNet:(BOOL)needNet
{
    isNeedNet = needNet;
}

#ifndef C4L_PURE_WITHOUT_INTERFACE

-(void) showPage: (UIViewController*) viewPage
{
    
}

-(void)LoginTryUser{
    [[ServerLogic sharedInstance] createOrLoginTryUser:@""];
}

-(void) Login
{
    
    BOOL logined = NO;

    [[ServerLogic sharedInstance] initUserList];
     NSMutableDictionary *users = [[ServerLogic sharedInstance] getUserList];
    int userCount = [users count];
    YALog(@"users %@  userCount %d",users,userCount);

    //本地没有用户，显示注册界面
    if (userCount == 0) {
        logined = [[ServerLogic sharedInstance] createOrLoginTryUser:@""];
    // 如果本地有一个用户
    } else if (userCount == 1) {
        NSString *tryUser = [[ServerLogic sharedInstance] getTryUser];
        if (tryUser!=nil) {
            //试玩账户登录
            logined = [[ServerLogic sharedInstance] createOrLoginTryUser:@""];
        } else {
            //本地有一个正式账户
            if(userLogout)
            {
                [self showLogin];
            }
            else
            {
                logined = [self loginLastestUser];
                if (!logined) {

                //logined = [[ServerLogic sharedInstance] createOrLoginTryUser:@""];
                    [self showLogin];
                }
            }
        }
    }
    else if (userCount>=2) {
        if(userLogout)
        {
            [self showLogin];
        }
        else
        {
            logined = [self loginLastestUser];
            if (!logined) {
                // logined = [[ServerLogic sharedInstance] createOrLoginTryUser:@""];
                [self showLogin];
            }
        }
        
    }

    if(!logined)
    {
        if(self.viewCurrent==nil)
        {
            [self showLogin];
        }
        defautlLoginFalse = true;
    }else{
        [self hideAll];
    }
}

-(BOOL)loginLastestUser
{
    NSString* latestUser = [[ServerLogic sharedInstance] getLatestUser];
    if (latestUser!=nil && defautlLoginFalse == false)
    {
        NSString* password = [[ServerLogic sharedInstance] getLatestUserPassword];
        if(password && [password length]>0)
        {
            return [[ServerLogic sharedInstance] login:latestUser password:password];
        }
    }
    return NO;
}


-(void)showLogin
{
    //[self showPage:self.viewLogin];
    //[self.viewLogin initWithViewStyle:styleLoginWithRegister];
    NSString* latestUser = [[ServerLogic sharedInstance] getLatestUser];
    if (latestUser!=nil && [[[ServerLogic sharedInstance] getLoginUserType] intValue]!=2)
    {
        //[self.viewLogin.plainTextField setText:latestUser];
        NSString* password = [[ServerLogic sharedInstance] getLatestUserPassword];
        YALog(@"password %@",password);

        if(password)
        {
      //      [self.viewLogin.secretTextField setText:password];
        }
        
    }

}
-(void)showRegister
{

    
}

-(void)showBinding
{
  //  [self showPage:self.viewRegister];
 //   [self.viewRegister initWithViewStyle:stylePositive];
}

-(void)showAccountManager
{
            

    
}
-(void)showAccountCenter
{
    
    
}
-(void)showChangePassword
{
    
}
-(void)showUserList
{
    
}
-(void)showPay
{
}

-(void)hideAll
{
    self.viewCurrent = nil;

}
#endif
-(void)notifyEnterGame
{
    self.isEnterGame = YES;
#ifdef APPSTORE_VERIFY_ORDER
    [self enterGameVerifyOder];
#endif
}

-(void)notifyLogoutGame
{
    userLogout = YES;
    self.isEnterGame = NO;
}







#define ORDER_2_VERIFY          @"ORDER_2_VERIFY"
#define ORDER_3_VERIFY          @"ORDER_6_VERIFY"
#define ORDER_2_VERIFY_SERVERID @"ORDER_2_VERIFY_SERVERID"
#define ORDER_2_VERIFY_USERID   @"ORDER_2_VERIFY_USERID"
//把severid存到本地,防止付款的时候程序崩溃或者突然退出,下次继续付款的时候没有serverid
-(void)appStoreBuy:(NSString*)_productID serverID:(NSString*)description totalFee:(float)fee orderId:(NSString *)orderId
{
    
    NSLog(@"%s",__FUNCTION__);
        [self appBuy:_productID  serverID:description totalFee:fee orderId:orderId];
}
    
#pragma mark-------------------------------支付处理接口-------------------------------------------
-(void)appBuy:(NSString*)_productID  serverID:(NSString*)description totalFee:(float)fee orderId:(NSString *)orderId
{
    NSString* youaiID = [[ServerLogic sharedInstance] getHuTuoID];
    NSLog(@"%s--------puid--%@",__FUNCTION__,youaiID);
    if (youaiID == nil) {
        return;
    }
    if(description == nil)
    {
        return;
    }
    productID =  [NSString stringWithString: _productID];
    currentServierID = [NSString stringWithString: description];
    [productID retain];
    [currentServierID retain];
    [[NSUserDefaults standardUserDefaults] setObject:currentServierID forKey:ORDER_2_VERIFY_SERVERID];
    [[NSUserDefaults standardUserDefaults] setObject:youaiID forKey:ORDER_2_VERIFY_USERID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    //检测是否有未完成的交易 有的话去掉
    NSArray* transactions = [SKPaymentQueue defaultQueue].transactions;
    if (transactions.count > 0) {
        SKPaymentTransaction* transaction = [transactions firstObject];
        if (transaction.transactionState == SKPaymentTransactionStatePurchased)
        {
            [[InAppPurchaseManager sharedInstance] completeTransaction:transaction];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            return;
        }  
    }
    
    [[InAppPurchaseManager sharedInstance] purchaseProduct:productID price:fee];
    
}


-(void) iapBuyDone
{

    NSString* youaiID = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_2_VERIFY_USERID];
    NSLog(@"%s--------puid--%@",__FUNCTION__,youaiID);
    //记录的服务器id
    currentServierID = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_2_VERIFY_SERVERID];
    
    if(currentServierID != nil)
        [currentServierID retain];
    //获取苹果支付完成后的 验证串 然后base64编码
    NSString *receiptBase64= [GTMBase64 stringByEncodingData:[[InAppPurchaseManager sharedInstance] getRecept]] ;
    //NSString *receiptBase64  = [[SDKUtility sharedInstance] base64forData: [[InAppPurchaseManager sharedInstance] getRecept]];
    //获取商品价格
    float price = [[InAppPurchaseManager sharedInstance] getLastProductPrice];
    //获取商品id
    NSString* productID = [[InAppPurchaseManager sharedInstance] getLastProductID];
    //获取当前ios系统版本号
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    //获取项目版本号
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    //定义ext信息
    NSDictionary *dictExt = @{@"os" : currSysVer, @"version" : version};
    NSData *jsonDataExt = [NSJSONSerialization dataWithJSONObject:dictExt options:0 error:nil];
    NSString * extJsonString = [[NSString alloc]initWithData:jsonDataExt encoding:NSUTF8StringEncoding];
    //获取platformdChannel
    NSString *platformChannel = [comHuTuoSDK getPlatformID];
    
   //NSString* postStr =[[NSString alloc]initWithFormat:@"uin=%@&serverID=%@&receipt=%@",youaiID,currentServierID,receiptBase64];
    NSString *secruity = @"3d1b05aee18b9870a52b733ccedc11bf";
    //NSString *_json =  [extJsonString stringByReplacingOccurrencesOfString:@"\" withString:@""];
    //NSString *result = [extJsonString replaceOccurrencesOfString:@"\\" withString:@"" options:1 range:NSMakeRange(0, extJsonString.length)];
    NSString *result = [extJsonString stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSString * md5Str = [[NSString alloc]initWithFormat:@"%@%@%@%@%f%@%@%@%@%@",secruity,youaiID,currentServierID,productID,price,@"JPY",@"1",result,platformChannel,receiptBase64];
   
    
    
    
    NSString* postStr_MD5Use =[[NSString alloc]initWithFormat:@"%@uid=%@&serverId=%@&productid=%@&price=%f&currencyCode=%@&amount=%@&ext=%@&platform=%@&receipt=%@",secruity,youaiID,currentServierID,productID,price,@"JPY",@"1",extJsonString,platformChannel,receiptBase64];
    //NSString *result_1 = [postStr_MD5Use stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    NSString *result_2 = [postStr_MD5Use stringByReplacingOccurrencesOfString:@"&" withString:@""];
    NSString * md5 = [[SDKUtility sharedInstance] md5HexDigest:result_2];
    
    
    
    NSString* postStr =[[NSString alloc]initWithFormat:@"uid=%@&serverId=%@&productid=%@&price=%f&currencyCode=%@&amount=%@&ext=%@&platform=%@&receipt=%@&sign=%@",youaiID,currentServierID,productID,price,@"JPY",@"1",extJsonString,platformChannel,receiptBase64,md5];
    
    
    //新订单添加到本地
    NSArray *orders = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_2_VERIFY];
    NSMutableArray *addOrders = [[NSMutableArray alloc] initWithArray:orders];
    [addOrders addObject:postStr];
    [[NSUserDefaults standardUserDefaults] setObject:addOrders forKey:ORDER_2_VERIFY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [addOrders release];
    [postStr release];

    //如果现在在游戏里面 那么去服务器验证,如果不在服务器里面即使验单成功也不会加钻
    if ([self isEnterGame]) {
        [self verifyOrders];
    }

}

- (void)enterGameVerifyOder
{
    [self verifyOrders];
}
- (NSString *)getRechargeUrl
{
    NSString* addressUrl = [comHuTuoSDK getPropertyFromIniFile:@"RechargeAddress" andAttr:@"applePayCallBack"];
    NSString* projectName = [comHuTuoSDK getPropertyFromIniFile:@"Project" andAttr:@"projectName"];

    if (addressUrl&&[addressUrl hasPrefix:@"http"]&&projectName)
    {
        return [NSString stringWithFormat:@"%@%@",addressUrl,projectName];
    }
    return nil;
}
- (NSString *)getRechargeIP
{
    NSString                                                                                               * addressIp = [comHuTuoSDK getPropertyFromIniFile:@"RechargeAddress" andAttr:@"addressIp"];
    NSString* projectName = [comHuTuoSDK getPropertyFromIniFile:@"Project" andAttr:@"projectName"];

    if (addressIp&&[addressIp hasPrefix:@"http"]&&projectName)
    {
        return [NSString stringWithFormat:@"%@%@",addressIp,projectName];
    }
    return nil;
}

- (void) verifyOrders
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *orders = [[NSUserDefaults standardUserDefaults] objectForKey:ORDER_2_VERIFY];
        NSMutableArray *addOrders = [[NSMutableArray alloc] init];
        NSString *rechargeUrl = [self getRechargeUrl];
        //[[NSUserDefaults standardUserDefaults] setObject:nil forKey:ORDER_2_VERIFY];
        for (NSString* temp in orders) {
            
            BOOL success = false;
            success = [self verifyOneOrder:rechargeUrl andData:temp];
            if (!success)
            {
                [addOrders addObject:temp];
            }
        }
        //剩余订单再存储
        [[NSUserDefaults standardUserDefaults] setObject:addOrders forKey:ORDER_2_VERIFY];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [addOrders release];
    });
   
}
//客户端测试receipt串的有效性
-(BOOL)putStringToItunes:(NSData*)iapData{//用户购成功的transactionReceipt
    
    //NSString*encodingStr = [iapData base64EncodedString];
    NSString *encodingStr=@"MIIT8AYJKoZIhvcNAQcCoIIT4TCCE90CAQExCzAJBgUrDgMCGgUAMIIDkQYJKoZIhvcNAQcBoIIDggSCA34xggN6MAoCAQgCAQEEAhYAMAoCARQCAQEEAgwAMAsCAQECAQEEAwIBADALAgEDAgEBBAMMATEwCwIBCwIBAQQDAgEAMAsCAQ8CAQEEAwIBADALAgEQAgEBBAMCAQAwCwIBGQIBAQQDAgEDMAwCAQoCAQEEBBYCNCswDAIBDgIBAQQEAgIAjjANAgENAgEBBAUCAwHVKDANAgETAgEBBAUMAzEuMDAOAgEJAgEBBAYCBFAyNTAwGAIBBAIBAgQQbKsezfbKzCnXJT0rjxmtfTAbAgEAAgEBBBMMEVByb2R1Y3Rpb25TYW5kYm94MBwCAQUCAQEEFAVOy7a7n56dMPVmdaAggEiHUra5MB0CAQICAQEEFQwTanAuY28uc2Nob29sLmJhdHRsZTAeAgEMAgEBBBYWFDIwMTktMDItMTVUMDM6NDA6MzNaMB4CARICAQEEFhYUMjAxMy0wOC0wMVQwNzowMDowMFowTQIBBwIBAQRFwbOoKISjDHyqztw7+B3SuyxboRNDm8UIjxTkd2srmIvhu3f7IKDTOvxhG682usZQLemTrc9wKXA1EMhP6sfMuQCva7arMGYCAQYCAQEEXgzLPABbkLBpOfWD4TvM326QK/Mq1+wGqCue1VS8R+j/a+T3TSXCHpg4HbF2Snr6OQdG65CjcZxOIS4fDr4KxhLBnH/j+eXlbq89//Hwx3LlsYOw3WozymEMoirUmlYwggFbAgERAgEBBIIBUTGCAU0wCwICBqwCAQEEAhYAMAsCAgatAgEBBAIMADALAgIGsAIBAQQCFgAwCwICBrICAQEEAgwAMAsCAgazAgEBBAIMADALAgIGtAIBAQQCDAAwCwICBrUCAQEEAgwAMAsCAga2AgEBBAIMADAMAgIGpQIBAQQDAgEBMAwCAgarAgEBBAMCAQEwDAICBq4CAQEEAwIBADAMAgIGrwIBAQQDAgEAMAwCAgaxAgEBBAMCAQAwGwICBqcCAQEEEgwQMTAwMDAwMDUwMjYxODkzNDAbAgIGqQIBAQQSDBAxMDAwMDAwNTAyNjE4OTM0MB8CAgaoAgEBBBYWFDIwMTktMDItMTVUMDM6NDA6MzNaMB8CAgaqAgEBBBYWFDIwMTktMDItMTVUMDM6NDA6MzNaMCECAgamAgEBBBgMFmpwLmNvLnNjaG9vbC5iYXR0bGUuNjCggg5lMIIFfDCCBGSgAwIBAgIIDutXh+eeCY0wDQYJKoZIhvcNAQEFBQAwgZYxCzAJBgNVBAYTAlVTMRMwEQYDVQQKDApBcHBsZSBJbmMuMSwwKgYDVQQLDCNBcHBsZSBXb3JsZHdpZGUgRGV2ZWxvcGVyIFJlbGF0aW9uczFEMEIGA1UEAww7QXBwbGUgV29ybGR3aWRlIERldmVsb3BlciBSZWxhdGlvbnMgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTUxMTEzMDIxNTA5WhcNMjMwMjA3MjE0ODQ3WjCBiTE3MDUGA1UEAwwuTWFjIEFwcCBTdG9yZSBhbmQgaVR1bmVzIFN0b3JlIFJlY2VpcHQgU2lnbmluZzEsMCoGA1UECwwjQXBwbGUgV29ybGR3aWRlIERldmVsb3BlciBSZWxhdGlvbnMxEzARBgNVBAoMCkFwcGxlIEluYy4xCzAJBgNVBAYTAlVTMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEApc+B/SWigVvWh+0j2jMcjuIjwKXEJss9xp/sSg1Vhv+kAteXyjlUbX1/slQYncQsUnGOZHuCzom6SdYI5bSIcc8/W0YuxsQduAOpWKIEPiF41du30I4SjYNMWypoN5PC8r0exNKhDEpYUqsS4+3dH5gVkDUtwswSyo1IgfdYeFRr6IwxNh9KBgxHVPM3kLiykol9X6SFSuHAnOC6pLuCl2P0K5PB/T5vysH1PKmPUhrAJQp2Dt7+mf7/wmv1W16sc1FJCFaJzEOQzI6BAtCgl7ZcsaFpaYeQEGgmJjm4HRBzsApdxXPQ33Y72C3ZiB7j7AfP4o7Q0/omVYHv4gNJIwIDAQABo4IB1zCCAdMwPwYIKwYBBQUHAQEEMzAxMC8GCCsGAQUFBzABhiNodHRwOi8vb2NzcC5hcHBsZS5jb20vb2NzcDAzLXd3ZHIwNDAdBgNVHQ4EFgQUkaSc/MR2t5+givRN9Y82Xe0rBIUwDAYDVR0TAQH/BAIwADAfBgNVHSMEGDAWgBSIJxcJqbYYYIvs67r2R1nFUlSjtzCCAR4GA1UdIASCARUwggERMIIBDQYKKoZIhvdjZAUGATCB/jCBwwYIKwYBBQUHAgIwgbYMgbNSZWxpYW5jZSBvbiB0aGlzIGNlcnRpZmljYXRlIGJ5IGFueSBwYXJ0eSBhc3N1bWVzIGFjY2VwdGFuY2Ugb2YgdGhlIHRoZW4gYXBwbGljYWJsZSBzdGFuZGFyZCB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB1c2UsIGNlcnRpZmljYXRlIHBvbGljeSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0ZW1lbnRzLjA2BggrBgEFBQcCARYqaHR0cDovL3d3dy5hcHBsZS5jb20vY2VydGlmaWNhdGVhdXRob3JpdHkvMA4GA1UdDwEB/wQEAwIHgDAQBgoqhkiG92NkBgsBBAIFADANBgkqhkiG9w0BAQUFAAOCAQEADaYb0y4941srB25ClmzT6IxDMIJf4FzRjb69D70a/CWS24yFw4BZ3+Pi1y4FFKwN27a4/vw1LnzLrRdrjn8f5He5sWeVtBNephmGdvhaIJXnY4wPc/zo7cYfrpn4ZUhcoOAoOsAQNy25oAQ5H3O5yAX98t5/GioqbisB/KAgXNnrfSemM/j1mOC+RNuxTGf8bgpPyeIGqNKX86eOa1GiWoR1ZdEWBGLjwV/1CKnPaNmSAMnBjLP4jQBkulhgwHyvj3XKablbKtYdaG6YQvVMpzcZm8w7HHoZQ/Ojbb9IYAYMNpIr7N4YtRHaLSPQjvygaZwXG56AezlHRTBhL8cTqDCCBCIwggMKoAMCAQICCAHevMQ5baAQMA0GCSqGSIb3DQEBBQUAMGIxCzAJBgNVBAYTAlVTMRMwEQYDVQQKEwpBcHBsZSBJbmMuMSYwJAYDVQQLEx1BcHBsZSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eTEWMBQGA1UEAxMNQXBwbGUgUm9vdCBDQTAeFw0xMzAyMDcyMTQ4NDdaFw0yMzAyMDcyMTQ4NDdaMIGWMQswCQYDVQQGEwJVUzETMBEGA1UECgwKQXBwbGUgSW5jLjEsMCoGA1UECwwjQXBwbGUgV29ybGR3aWRlIERldmVsb3BlciBSZWxhdGlvbnMxRDBCBgNVBAMMO0FwcGxlIFdvcmxkd2lkZSBEZXZlbG9wZXIgUmVsYXRpb25zIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyjhUpstWqsgkOUjpjO7sX7h/JpG8NFN6znxjgGF3ZF6lByO2Of5QLRVWWHAtfsRuwUqFPi/w3oQaoVfJr3sY/2r6FRJJFQgZrKrbKjLtlmNoUhU9jIrsv2sYleADrAF9lwVnzg6FlTdq7Qm2rmfNUWSfxlzRvFduZzWAdjakh4FuOI/YKxVOeyXYWr9Og8GN0pPVGnG1YJydM05V+RJYDIa4Fg3B5XdFjVBIuist5JSF4ejEncZopbCj/Gd+cLoCWUt3QpE5ufXN4UzvwDtIjKblIV39amq7pxY1YNLmrfNGKcnow4vpecBqYWcVsvD95Wi8Yl9uz5nd7xtj/pJlqwIDAQABo4GmMIGjMB0GA1UdDgQWBBSIJxcJqbYYYIvs67r2R1nFUlSjtzAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQYMBaAFCvQaUeUdgn+9GuNLkCm90dNfwheMC4GA1UdHwQnMCUwI6AhoB+GHWh0dHA6Ly9jcmwuYXBwbGUuY29tL3Jvb3QuY3JsMA4GA1UdDwEB/wQEAwIBhjAQBgoqhkiG92NkBgIBBAIFADANBgkqhkiG9w0BAQUFAAOCAQEAT8/vWb4s9bJsL4/uE4cy6AU1qG6LfclpDLnZF7x3LNRn4v2abTpZXN+DAb2yriphcrGvzcNFMI+jgw3OHUe08ZOKo3SbpMOYcoc7Pq9FC5JUuTK7kBhTawpOELbZHVBsIYAKiU5XjGtbPD2m/d73DSMdC0omhz+6kZJMpBkSGW1X9XpYh3toiuSGjErr4kkUqqXdVQCprrtLMK7hoLG8KYDmCXflvjSiAcp/3OIK5ju4u+y6YpXzBWNBgs0POx1MlaTbq/nJlelP5E3nJpmB6bz5tCnSAXpm4S6M9iGKxfh44YGuv9OQnamt86/9OBqWZzAcUaVc7HGKgrRsDwwVHzCCBLswggOjoAMCAQICAQIwDQYJKoZIhvcNAQEFBQAwYjELMAkGA1UEBhMCVVMxEzARBgNVBAoTCkFwcGxlIEluYy4xJjAkBgNVBAsTHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRYwFAYDVQQDEw1BcHBsZSBSb290IENBMB4XDTA2MDQyNTIxNDAzNloXDTM1MDIwOTIxNDAzNlowYjELMAkGA1UEBhMCVVMxEzARBgNVBAoTCkFwcGxlIEluYy4xJjAkBgNVBAsTHUFwcGxlIENlcnRpZmljYXRpb24gQXV0aG9yaXR5MRYwFAYDVQQDEw1BcHBsZSBSb290IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5JGpCR+R2x5HUOsF7V55hC3rNqJXTFXsixmJ3vlLbPUHqyIwAugYPvhQCdN/QaiY+dHKZpwkaxHQo7vkGyrDH5WeegykR4tb1BY3M8vED03OFGnRyRly9V0O1X9fm/IlA7pVj01dDfFkNSMVSxVZHbOU9/acns9QusFYUGePCLQg98usLCBvcLY/ATCMt0PPD5098ytJKBrI/s61uQ7ZXhzWyz21Oq30Dw4AkguxIRYudNU8DdtiFqujcZJHU1XBry9Bs/j743DN5qNMRX4fTGtQlkGJxHRiCxCDQYczioGxMFjsWgQyjGizjx3eZXP/Z15lvEnYdp8zFGWhd5TJLQIDAQABo4IBejCCAXYwDgYDVR0PAQH/BAQDAgEGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFCvQaUeUdgn+9GuNLkCm90dNfwheMB8GA1UdIwQYMBaAFCvQaUeUdgn+9GuNLkCm90dNfwheMIIBEQYDVR0gBIIBCDCCAQQwggEABgkqhkiG92NkBQEwgfIwKgYIKwYBBQUHAgEWHmh0dHBzOi8vd3d3LmFwcGxlLmNvbS9hcHBsZWNhLzCBwwYIKwYBBQUHAgIwgbYagbNSZWxpYW5jZSBvbiB0aGlzIGNlcnRpZmljYXRlIGJ5IGFueSBwYXJ0eSBhc3N1bWVzIGFjY2VwdGFuY2Ugb2YgdGhlIHRoZW4gYXBwbGljYWJsZSBzdGFuZGFyZCB0ZXJtcyBhbmQgY29uZGl0aW9ucyBvZiB1c2UsIGNlcnRpZmljYXRlIHBvbGljeSBhbmQgY2VydGlmaWNhdGlvbiBwcmFjdGljZSBzdGF0ZW1lbnRzLjANBgkqhkiG9w0BAQUFAAOCAQEAXDaZTC14t+2Mm9zzd5vydtJ3ME/BH4WDhRuZPUc38qmbQI4s1LGQEti+9HOb7tJkD8t5TzTYoj75eP9ryAfsfTmDi1Mg0zjEsb+aTwpr/yv8WacFCXwXQFYRHnTTt4sjO0ej1W8k4uvRt3DfD0XhJ8rxbXjt57UXF6jcfiI1yiXV2Q/Wa9SiJCMR96Gsj3OBYMYbWwkvkrL4REjwYDieFfU9JmcgijNq9w2Cz97roy/5U2pbZMBjM3f3OgcsVuvaDyEO2rpzGU+12TZ/wYdV2aeZuTJC+9jVcZ5+oVK3G72TQiQSKscPHbZNnF5jyEuAF1CqitXa5PzQCQc3sHV1ITGCAcswggHHAgEBMIGjMIGWMQswCQYDVQQGEwJVUzETMBEGA1UECgwKQXBwbGUgSW5jLjEsMCoGA1UECwwjQXBwbGUgV29ybGR3aWRlIERldmVsb3BlciBSZWxhdGlvbnMxRDBCBgNVBAMMO0FwcGxlIFdvcmxkd2lkZSBEZXZlbG9wZXIgUmVsYXRpb25zIENlcnRpZmljYXRpb24gQXV0aG9yaXR5AggO61eH554JjTAJBgUrDgMCGgUAMA0GCSqGSIb3DQEBAQUABIIBAHCS0DwiNNrdCoVIcxKTxaf8kCurrVM4ZLap15QBXMBbzdLEzuei69IslG0bnGG7VRAeRyPhkET/FTP2es+EfVjFhYACJRcmNZkvGzaDYRtoyg6jMQoVOqLThplcmrF3MdsDO58NiBNXWPmle2my6A1QFSUrVAz/VdevqZY3g04udQkHJCUMvyj0cEU/MWVEATA0alDN/aL6B+JcAv4GinbsAeHAULz6pmLnLHdK7amSbai5VB0Fq16hEudYiWLSoqKcaej8PSSvZ5XewDEU7WZz3+vs3jROz1O59yPQjIbuLo3uaRzMwEyepvQ2+ltkG0ls955ai90U8pcgGEWjpDg=" ;
    //NSString *encodingStr  = [GTMBase64 stringByEncodingData:iapData];
    NSString *URL=@"https://sandbox.itunes.apple.com/verifyReceipt";
    //https://buy.itunes.apple.com/verifyReceipt
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];// autorelease];
    [request setURL:[NSURL URLWithString:URL]];
    [request setHTTPMethod:@"POST"];
    //设置contentType
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%d", [encodingStr length]] forHTTPHeaderField:@"Content-Length"];
    
    NSDictionary* body = [NSDictionary dictionaryWithObjectsAndKeys:encodingStr, @"receipt-data", nil];
    SBJsonWriter *writer = [SBJsonWriter new];
    [request setHTTPBody:[[writer stringWithObject:body] dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES]];
    NSHTTPURLResponse *urlResponse=nil;
    NSError *errorr=nil;
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request
                                                 returningResponse:&urlResponse
                                                             error:&errorr];
    
    //解析
    NSString *results=[[NSString alloc]initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
   //CCLOG(@"-Himi-  %@",results);
    NSDictionary*dic = [results JSONValue];
    if([[dic objectForKey:@"status"] intValue]==0){//注意，status=@"0" 是验证收据成功
        return true;
    }
    return false;
}
//验单失败返回NO,成功返回YES
- (BOOL)verifyOneOrder:(NSString *)actionUrl andData:(NSString *)postStr
{
    //验证的时候 用户肯定在游戏内  一定要取得当前的userid和serverID 不然的话验单不好使
    NSString* youaiID = [comHuTuoSDK  getYouaiID];
    //serverID
    NSLog(@"%@",currentServierID);
    if (!youaiID||!currentServierID) {
        return NO;
    }
//    uin=%@&serverID=
    //如果不在当前用户, 或者是当前服务器 取消验单
    if ([postStr rangeOfString:[NSString stringWithFormat:@"uid=%@",youaiID]].location==NSNotFound||[postStr rangeOfString:[NSString stringWithFormat:@"serverId=%@",currentServierID]].location==NSNotFound ) {
        YALog(@"不是当前用户或者服务器  --->  跳过验单");
        return NO;
    }
    NSData *postdata=[postStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString* verifyUrl = actionUrl;
    for (int i = 1; i<=6; i++)
    {
        if (i==4)
        {
            NSString *addressIp = [self getRechargeIP];
            if (addressIp)
            {
                verifyUrl = addressIp;
            }
        }
        //NSData * dataD = [[InAppPurchaseManager sharedInstance] getRecept];
        //[self putStringToItunes:dataD];
        int httpCode = [[SDKUtility sharedInstance]httpPostForStatus:verifyUrl postData:postdata md5check:nil];
        if (httpCode==200)
        {
            YALog(@"第  %d  次验证 成功 %@",i,verifyUrl);
            return YES;
        }
        else
        {
            YALog(@"第  %d  次验证 失败 %@ ",i,verifyUrl);
        }
    }
    return NO;
}


#ifndef C4L_PURE_WITHOUT_INTERFACE
-(void)clearLoginInfo
{
    
    [[ServerLogic sharedInstance] clearLoginInfo];
    //[self.viewLogin.plainTextField setText:@""];
    //[self.viewLogin.secretTextField setText:@""];
   // [self.viewLogin clearInfo];
    [[ServerLogic sharedInstance] updateUserList];
    
}
#endif

+(NSString*) getServerListUserDefaultKey
{
    NSMutableString* str = [NSMutableString stringWithString:com4loves_serverList];
    NSString* youaiId = [[ServerLogic sharedInstance] getHuTuoID];
    if (youaiId) {
        [str appendFormat:@"_%@", youaiId];
    }
    YALog(@"getServerListUserDefaultKey %@",str);
    return str;
}

+(void)updateServerInfo:(int)serverID playerName:(NSString*)playerName playerID:(int)playerID lvl:(int)lvl vipLvl:(int)vipLvl coin1:(int)coin1 coin2:(int)coin2 pushSer:(BOOL) isPush
{
    //local save
    YALog(@"serverID %d ",serverID);
    YALog(@"[com4lovesSDK sharedInstance].userLoginedServers %@",userLoginedServers);
    currentServierID = [[NSString stringWithFormat:@"%d",serverID] retain];
    NSMutableArray* serversSave = [[NSMutableArray alloc] initWithCapacity:[userLoginedServers count]];
    NSNumber* num = [NSNumber numberWithInt:serverID];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:@"aaa",@"name",num,@"serverId", nil];
    [serversSave addObject:dic];
    for (NSDictionary* dic in userLoginedServers) {
        NSNumber* num = [dic objectForKey:@"serverId"];
        if([num intValue]!=serverID)
        {
            [serversSave addObject:dic];
        }
    }
    [userLoginedServers release];
    userLoginedServers = [serversSave retain];
    [serversSave release];
    
    [[NSUserDefaults standardUserDefaults] setObject:userLoginedServers forKey:[comHuTuoSDK getServerListUserDefaultKey]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (isPush) {
        [[ServerLogic sharedInstance] pushForClient:serverID playername:playerName playerID:playerID rmbMoney:coin1 gameCoin:coin2 vipLevel:vipLvl playerLevel:lvl pushSer:isPush];
    }

}

+(void)refreshServerInfo:(NSString*) gameID puid:(NSString*)puid pushSer:(BOOL) isPush
{
    
    [comHuTuoSDK setNeedNet:isPush];
    [[ServerLogic sharedInstance] setYouaiID:puid];
    [comHuTuoSDK  setAppIdDirectly:gameID];
    [userLoginedServers release];
    userLoginedServers  = [[[NSUserDefaults standardUserDefaults] objectForKey:[comHuTuoSDK getServerListUserDefaultKey]] retain] ;
    //本地没有存储
    if(!userLoginedServers)
    {
        NSArray * servers = [[ServerLogic sharedInstance] getUserLoginedServers];
        [userLoginedServers release];
        userLoginedServers = [[NSMutableArray alloc] initWithCapacity:[servers count]];
        [userLoginedServers addObjectsFromArray:servers];
//        [com4lovesSDK sharedInstance].userLoginedServers = [[[NSMutableArray alloc] init] autorelease];

    }
}
+(int)getServerInfoCount
{
    if (userLoginedServers) {
        return [userLoginedServers count];
    } else {
        return 0;
    }
}
+(int)getServerUserByIndex:(int)index
{
    if(userLoginedServers)
    {
        if ([userLoginedServers count]>index) {
            NSDictionary* dic = [userLoginedServers objectAtIndex:index];
            NSNumber* num = [dic objectForKey:@"serverId"];
            return [num intValue];
        }
    }else{
        return -1;
    }
     return -1;
}
- (void)dealloc{
    [super dealloc];
}
- (void)parseURL:(NSURL *)url
{
}

+(HuTuoServerInfo *)getServerInfo
{
    return serverInfo;
}
- (void) showFeedBack
{
    NSString* enableFeedback = [comHuTuoSDK getPropertyFromIniFile:@"FeedBackEnable" andAttr:@"feedback"];
    if (enableFeedback&&[enableFeedback isEqualToString:@"1"]) {
    NSString *url = [NSString stringWithFormat:@"%@feedback/querydetailbygameinfo?puid=%@&gameId=%@&serverId=%d&playerId=%d&playerName=%@&vipLvl=%d&platformId=%@",[[ServerLogic sharedInstance]getServerUrl],[comHuTuoSDK getServerInfo].puid,[comHuTuoSDK getAppID],[comHuTuoSDK getServerInfo].serverID,[comHuTuoSDK getServerInfo].playerID,[comHuTuoSDK getServerInfo].playerName,[comHuTuoSDK getServerInfo].vipLvl,platFormID];
    [[comHuTuoSDK sharedInstance] showWeb:[self urlEncode:url]];
    }
}
-(void)showSdkFeedBackWithUserName:(NSString *)userName
{
    NSString* enableFeedback = [comHuTuoSDK getPropertyFromIniFile:@"FeedBackEnable" andAttr:@"feedback"];
    if (enableFeedback&&[enableFeedback isEqualToString:@"1"]) {
        NSString *url = [NSString stringWithFormat:@"%@?gameId=%@&platformId=%@&puid=%@&playerName=%@&vipLvl=%d&playerId=%d",[[ServerLogic sharedInstance]getFeedBackUrl],[comHuTuoSDK getServerInfo].gameid,platFormID,[comHuTuoSDK getServerInfo].puid,userName,[comHuTuoSDK getServerInfo].lvl,[comHuTuoSDK getServerInfo].playerID];
        [[comHuTuoSDK sharedInstance] showWeb:[self urlEncode:url]];
    }
  
}
- (NSString *) urlEncode:(NSString *) url
{
    return (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)url, nil, nil, kCFStringEncodingUTF8);
}

+(void)statisticsInfo
{
    //[[ServerLogic sharedInstance] putToServerForDeviceInfo];
}

-(void)setFinalYouaiID:(NSString*)youaiID
{
    [[ServerLogic sharedInstance] setYouaiID:youaiID];
}

@end

