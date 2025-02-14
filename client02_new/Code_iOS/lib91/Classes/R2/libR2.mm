//
//  libR2.cpp
//  lib91
//
//  Created by fanleesong on 15-1-16.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#include "libR2.h"
#include "libOS.h"
#import "libR2Obj.h"
#import <R2SDKLoginKit/R2SDK.h>
#import <R2SDKLoginKit/R2SDKLoginKit.h>
#import <R2SDKFramework/R2SDKFramework.h>
#import "ShareSDKToDifPlatform.h"
#include <com4lovesSDK.h>
#import "HuTuoServerInfo.h"
#import "JSON.h"

#pragma mark--r2 --产品ID
#define ProductID786_IAPGrade0_99  @"786"//$0.99     1.qmgj.jtsd  60钻石
#define ProductID790_IAPGrade4_99  @"790" //$4.99    30.qmgj.jtsd 月卡
#define ProductID794_IAPGrade9_99  @"794" //$9.99    2.qmgj.jtsd  600钻石
#define ProductID798_IAPGrade19_99  @"798" //$19.99   3.qmgj.jtsd  1200钻石
#define ProductID802_IAPGrade49_99  @"802" //49.99    4.qmgj.jtsd  3000钻石
#define ProductID806_IAPGrade99_99  @"806" //$99.99   5.qmgj.jtsd  6000钻石


#define SERVER_ProductID_IAPGrade1  @"1.qmgj.jtsd"//$0.99     1.qmgj.jtsd  60钻石
#define SERVER_ProductID_IAPGrade6  @"30.qmgj.jtsd" //$4.99    30.qmgj.jtsd 月卡
#define SERVER_ProductID_IAPGrade2  @"2.qmgj.jtsd" //$9.99    2.qmgj.jtsd  600钻石
#define SERVER_ProductID_IAPGrade3  @"3.qmgj.jtsd" //$19.99   3.qmgj.jtsd  1200钻石
#define SERVER_ProductID_IAPGrade4  @"4.qmgj.jtsd" //49.99    4.qmgj.jtsd  3000钻石
#define SERVER_ProductID_IAPGrade5  @"5.qmgj.jtsd" //$99.99   5.qmgj.jtsd  6000钻石



#define R2_AppIconURL @"http:///icon.png"
#define R2_AppDownloadLink @"http:///"
#define R2_AppShareName @"Share"
#define R2_AppDec @"You just got an Heirloom item! Wanna share it with your friends?"
#define R2_AppCapital @"Share"
#define R2_AppInviteLink @"https://"

//R2 notifacation
#define R2LastLoginFlag @"R2LastLogin"
//#define R2ChangeAccount @"R2ChangeAccount"
#define R2inAppPurchase @"R2inAppPurchase"



libR2Obj* R2_Instance = 0;

SDK_CONFIG_STU sdkConfigure;
#pragma mark ------
#pragma mark -------------------initWithConfigure--------------------------
void libR2::initWithConfigure(const SDK_CONFIG_STU& configure){
    sdkConfigure = configure;
    //init com4lovesSDK
    NSString *yaappID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.appid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaSDKAppKey = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.sdkappkey.c_str() encoding:NSASCIIStringEncoding];
    NSString *yachannelID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.channelid.c_str() encoding:NSASCIIStringEncoding];
    NSString *yaplatformID = [NSString stringWithCString:(const char*)sdkConfigure.com4lovesconfig.platformid.c_str() encoding:NSASCIIStringEncoding];
    [com4lovesSDK  setSDKAppID:yaSDKAppID SDKAPPKey:yaSDKAppKey ChannelID:yachannelID PlatformID:yaplatformID];
    [com4lovesSDK  setAppId:yaappID];
    
    //   [[NSNotificationCenter defaultCenter] postNotificationName:YAPlatformStateInitDone object:@"ios_91"];
    //注册监听函数
    R2_Instance = [libR2Obj new];
    [R2_Instance SNSInitResult:0];
    R2_Instance.isReLogin = configure.platformconfig.bRelogin;
    //读取平台参数
    //    NSString *appKey = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appkey.c_str() encoding:NSASCIIStringEncoding];
    //    NSString *appID = [NSString stringWithCString:(const char*)sdkConfigure.platformconfig.appid.c_str() encoding:NSASCIIStringEncoding];

}

#pragma mark ----
#pragma mark ------------------------------- login parts ----------------------------------
bool libR2::getLogined(){
    return [R2_Instance isLogin];
}
#pragma mark ------
#pragma mark -------------------login--------------------------
void libR2::login(){
    if(!this->getLogined()){
 /*
        //每次启动游戏时调用登录游戏接口
        [[R2SDK sharedR2SDK] loginGame:[[[UIApplication sharedApplication] delegate] window].rootViewController quichLogin:NO handle:^(id result, NSError *error) {
            if (result) {
                if ([[result objectForKey:@"code"] intValue] == 0) {
                    //登陆成功，uid获取
                    NSNumber *userid = [[result objectForKey:@"data"] objectForKey:@"muid"];
                    int uid = [userid intValue];
                    if ( uid > 0) {
                        
                        NSString *tempUserId = [NSString stringWithFormat:@"%d",uid];
                        if(R2_Instance.userid == nil){
                            NSLog(@"-000000000--%s---%@",__FUNCTION__,R2_Instance.userid);
                            R2_Instance.userid = tempUserId;
                            NSDictionary *userinfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",userid] forKey:@"result"];
                            [[NSNotificationCenter defaultCenter] postNotificationName:R2LastLoginFlag object:nil userInfo:userinfo];
                            libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");

                        }else{
                        
                            if (uid != [R2_Instance.userid intValue]) {
                                R2_Instance.userid = [NSString stringWithFormat:@"%d",uid];
                                NSLog(@"-111111111--%s---%@",__FUNCTION__,R2_Instance.userid);
                                libPlatformManager::getPlatform()->_boardcastPlatfromReLogin();
                            }
                        }
                        
                        
                    }else{
                        R2_Instance.userid = @"";
                        libPlatformManager::getPlatform()->_boardcastLoginResult(false, "登录失败");
                    }
                }
                else{
                    //返回错误码
                    NSLog(@"%s----R2SDK-----登录失败",__FUNCTION__);
                }
            }
            else{
                //请求失败
                NSLog(@"请求失败----error: %@",[error localizedDescription]);
            }
        }];*/
        [R2SDKApi loginWithGameCenter:[[[UIApplication sharedApplication] delegate] window].rootViewController completionHandler:^(int code, NSString *msg, R2LoginResponse *result) {
            if(code==0){
                //login successfully
                //拿到 r2 uid 作为登陆依据
                NSString* currentR2Uid = result.r2Uid;
                NSLog(@"login successfully,r2 user ID -> %@",currentR2Uid);
                NSString *tempUserId = currentR2Uid;
                if(R2_Instance.userid == nil){
                    NSLog(@"-000000000--%s---%@",__FUNCTION__,R2_Instance.userid);
                    R2_Instance.userid = tempUserId;
                    NSDictionary *userinfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@",currentR2Uid] forKey:@"result"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:R2LastLoginFlag object:nil userInfo:userinfo];
                    libPlatformManager::getPlatform()->_boardcastLoginResult(true, "登录成功");
                    
                }else{
                    
                    if (![currentR2Uid isEqualToString:(R2_Instance.userid)]) {
                        R2_Instance.userid = currentR2Uid;
                        NSLog(@"-111111111--%s---%@",__FUNCTION__,R2_Instance.userid);
                        libPlatformManager::getPlatform()->_boardcastPlatfromReLogin();
                    }
                }

            }
            
            else{
                //login failed for some reasons
                //处理错误
                NSLog(@"login failed because of %@",msg);
                libPlatformManager::getPlatform()->_boardcastLoginResult(false, "登录失败");
            }
            
            
        }];
    }
    
}

#pragma mark ------
#pragma mark -------------------logout--------------------------
void libR2::logout(){

    R2_Instance.userid = nil;
    
}
#pragma mark ------
#pragma mark -------------------switchUsers--------------------------
void libR2::switchUsers(){
    
//    logout();//先注销一下再跳到r2登陆界面
    if(!this->getLogined()){
        
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    }
    
}
#pragma mark ------------------------------- login parts ----------------------------------

#pragma mark ------
#pragma mark ------------------------------- purchage parts ----------------------------------

#pragma mark ------IAP--
#pragma mark -----------------------------IAP------ buyGoods -----------------------------------
void libR2::buyGoods(BUYINFO& info){
    
    if(info.cooOrderSerial==""){
        info.cooOrderSerial = libOS::getInstance()->generateSerial();
    }
    mBuyInfo = info;
    NSString *productId = [NSString stringWithUTF8String:info.productId.c_str()];
    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];
    int zoneID = 0;
    sscanf(info.description.c_str(),"%d",&zoneID);
    NSString *orderId = [NSString stringWithUTF8String:info.cooOrderSerial.c_str()];
    NSString *aUserID = R2_Instance.userid,
    *aPlayerID = uin,
    *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
    *aRoleLevel = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].lvl ],
    *aRoleName = [com4lovesSDK getServerInfo].playerName,
    *aProductID=productId;
    NSLog(@"\n--aProductID=%@\n--aUserID=%@\n--aPlayerID=%@\n--aServerCode==%@\n--aRoleLevel==%@\n--aRoleName==%@\n",aProductID,aUserID,aPlayerID,aServerCode,aRoleLevel,aRoleName);

    
    //调用R2支付接口
//    [[R2SDK sharedR2SDK] inAppPurchaseWithProductID:aProductID userid:aUserID serve:aServerCode role:aRoleName mobile_transid:nil];

//#define ProductID_IAPGrade1  @"786"//$0.99     1.qmgj.jtsd  60钻石
//#define ProductID_IAPGrade6  @"790" //$4.99    30.qmgj.jtsd 月卡
//#define ProductID_IAPGrade2  @"794" //$9.99    2.qmgj.jtsd  600钻石
//#define ProductID_IAPGrade3  @"798" //$19.99   3.qmgj.jtsd  1200钻石
//#define ProductID_IAPGrade4  @"802" //49.99    4.qmgj.jtsd  3000钻石
//#define ProductID_IAPGrade5  @"806" //$99.99   5.qmgj.jtsd  6000钻石
    NSString *r2AjustToken = nil;
    if ([productId isEqualToString:ProductID786_IAPGrade0_99]) {//$0.99     1.qmgj.jtsd  60钻石
        r2AjustToken = R2_AjustEventAppPurchese0_99;
    }else if([productId isEqualToString:ProductID794_IAPGrade9_99]){//$9.99    2.qmgj.jtsd  600钻石
        r2AjustToken = R2_AjustEventAppPurchese9_99;
    }else if([productId isEqualToString:ProductID798_IAPGrade19_99]){//$19.99   3.qmgj.jtsd  1200钻石
        r2AjustToken = R2_AjustEventAppPurchese19_99;
    }else if([productId isEqualToString:ProductID802_IAPGrade49_99]){//49.99    4.qmgj.jtsd  3000钻石
        r2AjustToken = R2_AjustEventAppPurchese49_99;
    }else if([productId isEqualToString:ProductID806_IAPGrade99_99]){//$99.99   5.qmgj.jtsd  6000钻石
        r2AjustToken = R2_AjustEventAppPurchese99_99;
    }else if([productId isEqualToString:ProductID790_IAPGrade4_99]){//$4.99    30.qmgj.jtsd 月卡
        r2AjustToken = R2_AjustEventAppPurchese4_99;
    }
    NSLog(@"----r2AjustToken------%@",r2AjustToken);
    //最新支付
    [[R2SDK sharedR2SDK] inAppPurchaseWithProductID:aProductID
                                             userid:aUserID
                                              serve:aServerCode
                                               role:aRoleName
                                     mobile_transid:orderId
                                             handle:^(id result, NSError *error) {
        if (result) {
            if([[result objectForKey:@"code"] intValue] == 1 || [[result objectForKey:@"code"] intValue] == 0){
                //充值成功
                /*美元USD、人民币CNY、日元JPY、英镑GBP、欧元EUR、韩元KER、港币HKD、澳元AUD、加元CAD**/
                //此处根据Ajust提供的SDK中API说明适用的是一直使用欧元表示
                NSLog(@"--------r2AjustToken------>%@",r2AjustToken);
                [[ShareSDKToDifPlatform shareSDKPlatform] setInAppPurchase:(double)info.productPrice currency:@"EUR" differentToken:r2AjustToken];
            
            }else{
                //订单验证不成功
                NSLog(@"%s---充值不成功不做任何处理---",__FUNCTION__);
            }
        }else{
            //请求失败
            NSLog(@"%s---请求失败---error-%@",__FUNCTION__,[error localizedDescription]);
        }
    }];
    
    
    
    
}

#pragma mark ------
#pragma mark ----------------------------- platfrom tool -------------------------------------
void libR2::openBBS(){
    
    //    [[NdComPlatform defaultPlatform] NdEnterAppBBS:0];
    [R2_Instance onPresent];
}

void libR2::userFeedBack(){
    
    /*
     http://mobile?game=EZ%20PZ%20RPG&userid="
     + yaLastLoginHelp.mPuid + "&gameid=242&server="
     + yaLastLoginHelp.mServerID + "&role="
     + yaLastLoginHelp.mPlayerName + "&mail=");
     */
//    [[com4lovesSDK sharedInstance] showSdkFeedBackWithUserName:
//     [NSString stringWithFormat:@"%@&serverID=%d",[com4lovesSDK getServerInfo].playerName ,[com4lovesSDK getServerInfo].serverID]];
    NSString *r2_url = [NSString stringWithFormat:@"http://mobile?game=EZ%%20PZ%%20RPG&userid=%@&gameid=242&server=%d&role=%@&lang=%@&mail=",R2_Instance.userid,[com4lovesSDK getServerInfo].serverID,[com4lovesSDK getServerInfo].playerName,[NSString stringWithFormat:@"%s",r2_platformName.c_str()]];
    NSString *converstString = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)r2_url, nil, nil, kCFStringEncodingUTF8);
    NSLog(@"GM---url--\n%@",converstString);
    NSLog(@"GM---url--\n%@",r2_url);
    [[com4lovesSDK sharedInstance] showWeb:converstString];
    
}
void libR2::gamePause(){
    
}

void libR2::setToolBarVisible(bool isShow){
    
}
#pragma mark ------
#pragma mark ----------------------------- login user data ----------------------------------
const std::string& libR2::loginUin(){
    static std::string retStr = "";
    
    NSString* retNS = R2_Instance.userid;
    if(retNS != nil)
    {
        retStr = [retNS UTF8String];
        if(retStr != "")
            retStr = sdkConfigure.platformconfig.uidPrefix + retStr;
    }
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libR2::sessionID(){
    
    NSString* retNS = @"";
    static std::string retStr;
    if(retNS) retStr = (const char*)[retNS UTF8String];
    return retStr;
    
}
#pragma mark ------
#pragma mark ----------------------------- platform -----------------------------------
const std::string& libR2::nickName(){
    
    NSString* retNS = R2_Instance.userid;
    static std::string retStr;
    if(retNS) retStr = [retNS UTF8String];
    return retStr;
    
}
#pragma mark ----------------------------- platform data -----------------------------------
#pragma mark ------
#pragma mark -------------------getClientChannel--------------------------
const std::string libR2::getClientChannel(){
    return "ios_r2_en";
}

#pragma mark ------
#pragma mark -------------------getPlatformMoneyName--------------------------
std::string libR2::getPlatformMoneyName(){
    return sdkConfigure.platformconfig.moneyName;
}

#pragma mark ------platform relative---
#pragma mark ----------------------------- notifyEnterGame -----------------------------------
void libR2::notifyEnterGame(){
    
    R2_Instance.isInGame = YES;
//    UIView *window = [[UIApplication sharedApplication] keyWindow].rootViewController.view;
//    NSString  *aServerCode = [NSString stringWithFormat:@"%d",[com4lovesSDK getServerInfo].serverID ],
//    *aRoleName = [NSString stringWithFormat:@"%@",[com4lovesSDK getServerInfo].playerName ];
//    NSString *uin = [NSString stringWithUTF8String:loginUin().c_str()];

}

bool libR2::getIsTryUser(){
    return false;
}

void libR2::callPlatformBindUser(){
    
}

void libR2::notifyGameSvrBindTryUserToOkUserResult(int result){
    
}

void libR2::OnKrGetInviteCount(){}
void libR2::setLanguageName(const std::string& lang){

    if (lang.empty()) {
        r2_platformName = "en";
    }else{
        r2_platformName = lang;
    }
    
}
//G2P means Game to Platform
std::string libR2::sendMessageG2P(const std::string& tag, const std::string& msg){

    
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"tag---->%@----msg--->%@",[NSString stringWithUTF8String:tag.c_str()],[NSString stringWithUTF8String:msg.c_str()]);

    if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_R2_PURCHASELIST"]) {
        //登陆成功后直接1返回一个商品列表
        [[R2SDK sharedR2SDK] getLoaclIAPProductsInfo:@[@"786",@"794",@"798",@"802",@"806",@"790"] handle:^(NSDictionary *result, NSError *error) {
            
            NSLog(@"----R2_SDK----------getLoaclIAPProductsInfo:-----");
            NSMutableArray *jsonArray = [NSMutableArray array];
            
            NSLog(@"product: %@",[result objectForKey:@"product"]);
            NSArray *array = [result objectForKey:@"product"];
            for(SKProduct *product in array){
                /**
                 {
                 "productDec" : "You recharged, and should have received 6000 Gems. If not, let us know.",
                 "productTitle" : "Chest of Gems",
                 "productPrice" : 99.99,
                 "productLocalId" : "en_MY@currency=USD",
                 "productId" : "806"
                 }
                 **/
                NSLog(@"product info");
                //NSLog(@"SKProduct 描述信息%@", [product description]);
                NSLog(@"产品标题 %@" , product.localizedTitle);
                NSLog(@"产品描述信息: %@" , product.localizedDescription);
                NSLog(@"价格: %@" , product.price);
                NSLog(@"local: %@" , product.priceLocale.localeIdentifier);
                NSLog(@"Product id: %@" , product.productIdentifier);
        
                NSLog(@"------->localeIdentifier---> %@" , product.priceLocale.localeIdentifier);
                NSString *newLocalId = nil;
                NSRange localIdRange = [product.priceLocale.localeIdentifier rangeOfString:@"="];//匹配得到的下标
                if (localIdRange.location > 1) {
                    NSLog(@"-----range:%@",NSStringFromRange(localIdRange));
                    NSRange newRange = NSMakeRange(localIdRange.location + 1, product.priceLocale.localeIdentifier.length - localIdRange.location -1);
                    newLocalId = [product.priceLocale.localeIdentifier substringWithRange:newRange];
                }else{
                    newLocalId = @"";
                }
                
                NSLog(@"-----lcoal id---->%@",newLocalId);
                
                NSMutableDictionary *m_dic = [NSMutableDictionary dictionary];
                [m_dic setValue:product.productIdentifier forKey:@"productId"];
                [m_dic setValue:product.price forKey:@"productPrice"];
                [m_dic setValue:product.localizedDescription forKey:@"productDec"];
                [m_dic setValue:product.localizedTitle forKey:@"productTitle"];
                [m_dic setValue:newLocalId forKey:@"productLocalId"];
                [jsonArray addObject:m_dic];
                
            }
            
            NSLog(@"----R2_SDK----------getLoaclIAPProductsInfo:----------JsonArray----%@",jsonArray);
            NSError *parseError = nil;
            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:&parseError];
            NSString *productJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"----R2_SDK----------getLoaclIAPProductsInfo:-------------productJson---------->%@",productJson);
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_R2_PURCHASELIST",[productJson UTF8String]);
            
            
        }];
       
    }
    /**
     iOS如下：
     {
     "name" : "Hohua  Huang",
     "uid" : "77753141",
     "url" : "https:\/\/graph.facebook.com\/264820740375184\/picture",
     "fbid" : "264820740375184"
     }
     邀请--》
     [{
     "name" : "Hohua  Huang",
     "uid" : "77753141",
     "url" : "https:\/\/graph.facebook.com\/264820740375184\/picture",
     "fbid" : "264820740375184"
     }，
     {
     "name" : "Eddy  Wong",
     "uid" : "77753142",
     "url" : "https:\/\/graph.facebook.com\/264820740375124\/picture",
     "fbid" : "264820740375124"
     }… ]
     
     安卓如下：
     
     array info =========== [{"fbname":"房海瑞","uid":"0","fbid":"1408855526100072","fburl":"https:\/\/graph.facebook.com\/1408855526100072\/picture"},
     {"fbname":"Anita  Jiang","uid":"r2_","fbid":"664644046972919","fburl":"https:\/\/graph.facebook.com\/664644046972919\/picture"},
     {"fbname":"Huang Summer","uid":"r2_127614161","fbid":"1580121272265782","fburl":"https:\/\/graph.facebook.com\/1580121272265782\/picture"}]
     **/
    
    if([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_Friend_List"]){
        
        if ([FBSDKAccessToken currentAccessToken]){
            
            NSString * str=[NSString stringWithFormat:@"https://graph.facebook.com/me?access_token=%@",
                            [FBSDKAccessToken currentAccessToken].tokenString];
            NSURL *url =[NSURL URLWithString:str];
            NSURLRequest *request = [NSURLRequest requestWithURL:url];
            NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
            if(data != nil){
                NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
                NSLog(@"fbInfo : %@",jsonDic);
                NSString * fbID = [jsonDic objectForKey:@"id"];
                NSString * fbName = [jsonDic objectForKey:@"name"];
                NSString * fbUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",fbID];
                //            NSDictionary *dic = @{
                //                                  @"fbid":fbID,
                //                                  @"name":fbName,
                //                                  @"url":[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture",fbID]
                //                                  };
                //            NSLog(@"result : %@",dic);
                
                __block NSMutableDictionary *FB_myinfoDic = [NSMutableDictionary dictionary];//my fb info
                __block NSArray * friendsArray = [[R2SDK sharedR2SDK] requestForMyFriends];//friend fb info
                __block NSMutableDictionary  *requestFriUID = [NSMutableDictionary dictionary];//friend puid
                [requestFriUID retain];
                [friendsArray retain];
                [FB_myinfoDic retain];
                [FB_myinfoDic setValue:fbName forKey:@"fbname"];
                [FB_myinfoDic setValue:fbID forKey:@"fbid"];
                [FB_myinfoDic setValue:fbUrl forKey:@"fburl"];
                
                if(R2_Instance.userid != nil){
                    
                    [[R2SDK sharedR2SDK] bindThirdPlatID:fbID uid:R2_Instance.userid type:2 handle:^(NSDictionary *result, NSError *error) {
                        
                        NSLog(@"-----the two getmyinfo---------1%@",result);
                        //如果result返回是传入的UID,绑定成功
                        NSLog(@"the userid------%@",R2_Instance.userid);
                        NSLog(@"the FB_myinfoDic1------%@",FB_myinfoDic);

                        //NSString *tempUserId = [NSString stringWithFormat:@"%@",[result objectForKey:@"result"]];
                        if (result && [[result objectForKey:@"code"] intValue] == 0) {
                            //[FB_myinfoDic setValue:@"r2_1148103413" forKey:@"uid"];
                            [FB_myinfoDic setValue:[NSString stringWithFormat:@"r2_%@",R2_Instance.userid] forKey:@"uid"];
                            NSLog(@"my FB_myinfoDic444444444 = %@",FB_myinfoDic);
                            NSMutableArray *finalArray = [NSMutableArray array];
                            
                            NSLog(@"-------have---login------yes------");
                            NSLog(@"----the first--friendsArray-----%@",friendsArray);
                            if(friendsArray && [friendsArray count] > 0){
                                
                                NSMutableArray *friendFBIDArr = [NSMutableArray array];
                                for (int i = 0 ;  i < [friendsArray count]; i++) {
                                    [friendFBIDArr addObject: [[friendsArray objectAtIndex:i] objectForKey:@"fbid"]];
                                }
                                NSLog(@"----temp---friendFBIDArr-----%@",friendFBIDArr);
                                /**
                                 {"code":0,"msg":"Success","data":{"264820740375184":"111021665","306817302860593":"109076973"}}
                                 */
                                [[R2SDK sharedR2SDK] getUIDFromThirdIDs:friendFBIDArr type:2 handle:^(NSDictionary *result, NSError *error) {
                                     NSLog(@"----temp---friendFBIDArr-----%@",result);
                                    if(result && [[result objectForKey:@"code"] intValue] == 0 && [result objectForKey:@"data"]){
                                        NSLog(@"frienduid-------->result:%@",result);
                                        [requestFriUID setValuesForKeysWithDictionary:(NSDictionary *)[result objectForKey:@"data"]];
                                        NSLog(@"-------requestFriUID---->%@",requestFriUID);
                                        
                                        NSMutableArray *FB_requstFriendsArr = [NSMutableArray array];
                                        for (int i = 0; i < [friendsArray count]; i++) {
                                            NSDictionary *tempFriendsDic = (NSDictionary *)[friendsArray objectAtIndex:i];
                                            NSMutableDictionary *tempFinalDic = [NSMutableDictionary dictionary];
                                            if ([requestFriUID objectForKey:[tempFriendsDic objectForKey:@"fbid"]] != nil) {
                                                
                                                [tempFinalDic setValue:[NSString stringWithFormat:@"%@",[tempFriendsDic objectForKey:@"name"]] forKey:@"fbname"];
                                                [tempFinalDic setValue:[NSString stringWithFormat:@"%@",[tempFriendsDic objectForKey:@"fbid"]] forKey:@"fbid"];
                                                [tempFinalDic setValue:[NSString stringWithFormat:@"%@",[tempFriendsDic objectForKey:@"url"]] forKey:@"fburl"];
                                                [tempFinalDic setValue:[NSString stringWithFormat:@"r2_%@",[requestFriUID objectForKey:[tempFriendsDic objectForKey:@"fbid"]]] forKey:@"uid"];
                                                [FB_requstFriendsArr addObject:tempFinalDic];
                                                
                                            }
                                            
                                        }
                                        NSLog(@"---final---------friendsArray-----%@",friendsArray);
                                        NSLog(@"---myuid---------result----%@",result);
                                        NSLog(@"---new-----------myInfo----%@",FB_myinfoDic);
                                        NSLog(@"------------FB_requstFriendsArr-----%@",FB_requstFriendsArr);
                                        [finalArray addObject:FB_myinfoDic];
                                        [finalArray addObjectsFromArray:FB_requstFriendsArr];
                                        NSError *parseError = nil;
                                        NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:finalArray options:NSJSONWritingPrettyPrinted error:&parseError];
                                        NSString *fbJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                        NSLog(@"----R2_SDK---has friends-------fbJson---------->%@",fbJson);
                                        libPlatformManager::getPlatform()->sendMessageP2G("P2G_Friend_List",[fbJson UTF8String]);
                                        
                                        
                                    }else{
                                        NSLog(@"error :%@",[error localizedDescription]);
                                        if (requestFriUID) {
                                            [requestFriUID release];
                                        }
                                        if (friendsArray) {
                                            [friendsArray release];
                                        }
                                        if (FB_myinfoDic) {
                                            [FB_myinfoDic release];
                                        } }
                                }];
                                
                                
                            }else{
                                [finalArray addObject:FB_myinfoDic];
                                NSError *parseError = nil;
                                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:finalArray options:NSJSONWritingPrettyPrinted error:&parseError];
                                NSString *fbJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                NSLog(@"----R2_SDK---only send my info to game---------->%@",fbJson);
                                libPlatformManager::getPlatform()->sendMessageP2G("P2G_Friend_List",[fbJson UTF8String]);
                                NSLog(@"no");
                                if (requestFriUID) {
                                    [requestFriUID release];
                                }
                                if (friendsArray) {
                                    [friendsArray release];
                                }
                                if (FB_myinfoDic) {
                                    [FB_myinfoDic release];
                                }
                            }
                            
                        }else{
                            //处理绑定失败 <无法获取R2登陆时的 userId ，此种情况几乎不存在>
                            NSLog(@"----处理绑定失败 <无法获取R2登陆时的 userId ，此种情况几乎不存在>---error :%@",[error localizedDescription]);
                            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                                 message:[com4lovesSDK getLang:@"R2FBTips"]
                                                                                delegate:nil
                                                                       cancelButtonTitle:[com4lovesSDK getLang:@"R2FBOK"]
                                                                       otherButtonTitles:nil] autorelease];
                            [alertView show];
                            if (requestFriUID) {
                                [requestFriUID release];
                            }
                            if (friendsArray) {
                                [friendsArray release];
                            }
                            if (FB_myinfoDic) {
                                [FB_myinfoDic release];
                            }
                        }
                    }];
                    
                }

            }
            else{
                //处理登陆失败
                NSLog(@"%s---login ----FB ---再次请求FB时，网络问题-failed--",__FUNCTION__);
                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                     message:[com4lovesSDK getLang:@"R2FBRelinkTip"]
                                                                    delegate:nil
                                                           cancelButtonTitle:[com4lovesSDK getLang:@"R2FBOK"]
                                                           otherButtonTitles:nil] autorelease];
                [alertView show];
            
            }
            
        }else{
        
            //调用FB登陆方法
            [[R2SDK sharedR2SDK] FBlogin:^(NSDictionary *result, NSError *error) {
                if (result) {
                    
                    NSLog(@"----the first result55555-----%@",result);
                    __block NSArray * friendsArray = [[R2SDK sharedR2SDK] requestForMyFriends];//friend fb info
                    __block NSMutableDictionary  *requestFriUID = [NSMutableDictionary dictionary];//friend puid
                    __block NSMutableDictionary *FB_myinfoDic = [NSMutableDictionary dictionary];
                    [FB_myinfoDic setValue:[NSString stringWithFormat:@"%@",[result objectForKey:@"name"]] forKey:@"fbname"];
                    [FB_myinfoDic setValue:[NSString stringWithFormat:@"%@",[result objectForKey:@"fbid"]] forKey:@"fbid"];
                    [FB_myinfoDic setValue:[NSString stringWithFormat:@"%@",[result objectForKey:@"url"]] forKey:@"fburl"];

                    [requestFriUID retain];
                    [friendsArray retain];
                    [FB_myinfoDic retain];
                    if(R2_Instance.userid != nil){
                        
                        [[R2SDK sharedR2SDK] bindThirdPlatID:[result objectForKey:@"fbid"] uid:R2_Instance.userid type:2 handle:^(NSDictionary *result, NSError *error) {
                            
                            NSLog(@"-----the two getmyinfo---------1%@",result);
                            //如果result返回是传入的UID,绑定成功
                            NSLog(@"the userid------%@",R2_Instance.userid);
                            NSLog(@"the FB_myinfoDic1------%@",FB_myinfoDic);
                            
                            //NSString *tempUserId = [NSString stringWithFormat:@"%@",[result objectForKey:@"result"]];
                            if (result && [[result objectForKey:@"code"] intValue] == 0) {
                                //[FB_myinfoDic setValue:@"r2_1148103413" forKey:@"uid"];
                                [FB_myinfoDic setValue:[NSString stringWithFormat:@"r2_%@",R2_Instance.userid] forKey:@"uid"];
                                NSLog(@"my FB_myinfoDic5555555 = %@",FB_myinfoDic);
                                NSMutableArray *finalArray = [NSMutableArray array];
                                
                                NSLog(@"-------have---login------yes------");
                                NSLog(@"----the first--friendsArray-----%@",friendsArray);
                                if(friendsArray && [friendsArray count] > 0){
                                    
                                    NSMutableArray *friendFBIDArr = [NSMutableArray array];
                                    for (int i = 0 ;  i < [friendsArray count]; i++) {
                                        [friendFBIDArr addObject: [[friendsArray objectAtIndex:i] objectForKey:@"fbid"]];
                                    }
                                    NSLog(@"----temp---friendFBIDArr-----%@",friendFBIDArr);
                                    /**
                                     {"code":0,"msg":"Success","data":{"264820740375184":"111021665","306817302860593":"109076973"}}
                                     */
                                    [[R2SDK sharedR2SDK] getUIDFromThirdIDs:friendFBIDArr type:2 handle:^(NSDictionary *result, NSError *error) {
                                        NSLog(@"----temp---friendFBIDArr-----%@",result);
                                        if(result && [[result objectForKey:@"code"] intValue] == 0 && [result objectForKey:@"data"]){
                                            NSLog(@"frienduid-------->result:%@",result);
                                            [requestFriUID setValuesForKeysWithDictionary:(NSDictionary *)[result objectForKey:@"data"]];
                                            NSLog(@"-------requestFriUID---->%@",requestFriUID);
                                            
                                            NSMutableArray *FB_requstFriendsArr = [NSMutableArray array];
                                            for (int i = 0; i < [friendsArray count]; i++) {
                                                NSDictionary *tempFriendsDic = (NSDictionary *)[friendsArray objectAtIndex:i];
                                                NSMutableDictionary *tempFinalDic = [NSMutableDictionary dictionary];
                                                if ([requestFriUID objectForKey:[tempFriendsDic objectForKey:@"fbid"]] != nil) {
                                                    
                                                    [tempFinalDic setValue:[NSString stringWithFormat:@"%@",[tempFriendsDic objectForKey:@"name"]] forKey:@"fbname"];
                                                    [tempFinalDic setValue:[NSString stringWithFormat:@"%@",[tempFriendsDic objectForKey:@"fbid"]] forKey:@"fbid"];
                                                    [tempFinalDic setValue:[NSString stringWithFormat:@"%@",[tempFriendsDic objectForKey:@"url"]] forKey:@"fburl"];
                                                    [tempFinalDic setValue:[NSString stringWithFormat:@"r2_%@",[requestFriUID objectForKey:[tempFriendsDic objectForKey:@"fbid"]]] forKey:@"uid"];
                                                    [FB_requstFriendsArr addObject:tempFinalDic];
                                                    
                                                }
                                                
                                            }
                                            NSLog(@"---final---------friendsArray-----%@",friendsArray);
                                            NSLog(@"---myuid---------result----%@",result);
                                            NSLog(@"---new-----------myInfo----%@",FB_myinfoDic);
                                            NSLog(@"------------FB_requstFriendsArr-----%@",FB_requstFriendsArr);
                                            [finalArray addObject:FB_myinfoDic];
                                            [finalArray addObjectsFromArray:FB_requstFriendsArr];
                                            NSError *parseError = nil;
                                            NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:finalArray options:NSJSONWritingPrettyPrinted error:&parseError];
                                            NSString *fbJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                            NSLog(@"----R2_SDK---has friends-------fbJson555555---------->%@",fbJson);
                                            libPlatformManager::getPlatform()->sendMessageP2G("P2G_Friend_List",[fbJson UTF8String]);
                                            
                                            
                                        }else{
                                            NSLog(@"error :%@",[error localizedDescription]);
                                            if (requestFriUID) {
                                                [requestFriUID release];
                                            }
                                            if (friendsArray) {
                                                [friendsArray release];
                                            }
                                            if (FB_myinfoDic) {
                                                [FB_myinfoDic release];
                                            } }
                                    }];
                                    
                                    
                                }else{
                                    [finalArray addObject:FB_myinfoDic];
                                    NSError *parseError = nil;
                                    NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:finalArray options:NSJSONWritingPrettyPrinted error:&parseError];
                                    NSString *fbJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                    NSLog(@"----R2_SDK---only send my info to game5555---------->%@",fbJson);
                                    libPlatformManager::getPlatform()->sendMessageP2G("P2G_Friend_List",[fbJson UTF8String]);
                                    NSLog(@"no");
                                    if (requestFriUID) {
                                        [requestFriUID release];
                                    }
                                    if (friendsArray) {
                                        [friendsArray release];
                                    }
                                    if (FB_myinfoDic) {
                                        [FB_myinfoDic release];
                                    }
                                }
                                
                            }else{
                                //处理绑定失败 <无法获取R2登陆时的 userId ，此种情况几乎不存在>
                                NSLog(@"----处理绑定失败 <无法获取R2登陆时的 userId ，此种情况几乎不存在>---error :%@",[error localizedDescription]);
                                UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                                     message:[com4lovesSDK getLang:@"R2FBTips"]
                                                                                    delegate:nil
                                                                           cancelButtonTitle:[com4lovesSDK getLang:@"R2FBOK"]
                                                                           otherButtonTitles:nil] autorelease];
                                [alertView show];
                                if (requestFriUID) {
                                    [requestFriUID release];
                                }
                                if (friendsArray) {
                                    [friendsArray release];
                                }
                                if (FB_myinfoDic) {
                                    [FB_myinfoDic release];
                                }
                            }
                        }];
                        
                    }
                }else{
                    //处理登陆失败
                    NSLog(@"%s---login ----FB ----failed--",__FUNCTION__);
                    NSLog(@"----error :%@",[error localizedDescription]);
                    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:nil
                                                                         message:[com4lovesSDK getLang:@"R2FBRelinkTip"]
                                                                        delegate:nil
                                                               cancelButtonTitle:[com4lovesSDK getLang:@"R2FBOK"]
                                                               otherButtonTitles:nil] autorelease];
                    [alertView show];
                    
                }
            }];
            
            
        }
    }
    
    if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_Invild_Friend"]) {
        /**
         local strtable = {
             pic = platformInfo.FbInvitePic,
             url = platformInfo.FbInviteUrl,
         }
         **/
        NSString *askMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveAskDic = [parser objectWithString:askMsg];
        NSString *appInviteLink = [receiveAskDic valueForKey:@"url"];
        NSString *appIconURl = [receiveAskDic valueForKey:@"pic"];
        [[R2SDK sharedR2SDK] invitateFacebookFriendsWithAppLink:appInviteLink imageURL:appIconURl handle:^(NSDictionary *result, NSError *error) {
            if (result) {
                // 如果result为succed为邀请成功
                NSLog(@"share:%@",result);
            }
            else{
                NSLog(@"error :%@",[error localizedDescription]);
            }
        }];
    }
    
    //获得所有的索取请求
    /**
     {
         fromUserFbName="Test00",
         fromUserFbId = "123566",
         data="askRequstr2_1111",
         requestId = "123456",
     },
     
     {
         application =         {
             id = 411866752302478;
             name = "EZ PZ RPG";
             namespace = "ez_pz_rpg";
         };
         "created_time" = "2015-04-29T07:29:19+0000";
         data = "askRequst,r2_128548789";
         from =         {
             id = 1426164707691368;
             name = "Vega Karel";
         };
         id = "633565450108132_371110843079506";
         message = "Enjoy the free boost! ";
         to =         {
             id = 371110843079506;
             name = "Hohua  Huang";
         };
     }
     **/
    if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_GET_ALL_REQUEST"]) {
       
        NSArray * getAllRequest =  (NSArray *)[[R2SDK sharedR2SDK] notificationGet];
        if([getAllRequest count] > 0){
            
            NSMutableArray *finalArr = [NSMutableArray array];
            for ( int i= 0; i < [getAllRequest count]; i++) {
             
                NSDictionary *tempDic = (NSDictionary *)[getAllRequest objectAtIndex:i];
                NSMutableDictionary *finalDic = [NSMutableDictionary dictionary];
                if([tempDic objectForKey:@"data"] != nil){
//                    [finalDic setValue:[tempDic objectForKey:@"application"] forKey:@"application"];
//                    [finalDic setValue:[tempDic objectForKey:@"created_time"] forKey:@"created_time"];
//                    [finalDic setValue:[tempDic objectForKey:@"message"] forKey:@"message"];
//                    [finalDic setValue:[tempDic objectForKey:@"to"] forKey:@"to"];
                    NSDictionary *fromDic = (NSDictionary *)[tempDic objectForKey:@"from"];
                    [finalDic setValue:[fromDic objectForKey:@"name"] forKey:@"fromUserFbName"];
                    [finalDic setValue:[fromDic objectForKey:@"id"] forKey:@"fromUserFbId"];
                    [finalDic setValue:[tempDic objectForKey:@"data"] forKey:@"data"];
                    [finalDic setValue:[tempDic objectForKey:@"id"] forKey:@"requestId"];
                    [finalArr addObject:finalDic];
                }
            }
        
            NSLog(@"getAllRequest----%@",getAllRequest);
            NSLog(@"finalArr----%@",finalArr);
            if ([finalArr count] > 0) {
                NSError *parseError = nil;
                NSData  *jsonData = [NSJSONSerialization dataWithJSONObject:finalArr options:NSJSONWritingPrettyPrinted error:&parseError];
                NSString *fbJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                NSLog(@"fbJson------------%@",fbJson);
                libPlatformManager::getPlatform()->sendMessageP2G("P2G_GET_ALL_REQUEST",[fbJson UTF8String]);
            }else{
                libPlatformManager::getPlatform()->sendMessageP2G("P2G_GET_ALL_REQUEST","");
            }
            
        }else{
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_GET_ALL_REQUEST","");
        }
        
        
        

        

    }
    //删除同样的 索取请求，不需要向服务器反馈信息
    /**
     local strtable = {
         requestid = deleteinfo[i].requestId,
     }
     **/
    if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_DEL_SAME_REQUEST"]) {
        
        NSLog(@"tag---->%@----msg--->%@",[NSString stringWithUTF8String:tag.c_str()],[NSString stringWithUTF8String:msg.c_str()]);
        NSString *askMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveAskDic = [parser objectWithString:askMsg];
        NSString *requestStr = [receiveAskDic valueForKey:@"requestid"];
        [[R2SDK sharedR2SDK] notificationClear:requestStr];
        
    }
    
    //需要向服务器反馈信息
    /**
     local strtable = {
         requestId = fbinfo.requestId
     }
     **/
    if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_DELETE_REQUEST"]) {
     
        NSLog(@"tag---->%@----msg--->%@",[NSString stringWithUTF8String:tag.c_str()],[NSString stringWithUTF8String:msg.c_str()]);
        NSString *askMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveAskDic = [parser objectWithString:askMsg];
        NSString *requestStr = [receiveAskDic valueForKey:@"requestId"];
        NSDictionary *delDic = [[R2SDK sharedR2SDK] notificationClear:requestStr];
        if ([[delDic objectForKey:@"success"] intValue] == 1) {
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_DELETE_REQUEST","succes");
        }else{
            libPlatformManager::getPlatform()->sendMessageP2G("P2G_DELETE_REQUEST","faild");
        }
        
        
    }
    
    
    //索取快速战斗券
    if ([[NSString stringWithUTF8String:tag.c_str()] isEqualToString:@"G2P_ASKFOR_TICKET"]) {
        /**
         
         to: 你可以指定一些特定的发送对象，传入相应的FB UID即可，以逗号隔开。如果传入“”，则表示让玩家自行去选择该游戏请求发送给那些玩家。
         
         objectId :  该ID 代表是此次游戏请求中的一个实体对象，比如本次需求中的 “1/4战斗卷”。该ID具体生成过程是需要在FACEBOOK DEVELOPER CONSOLE
                     中配置相关信息后才能由FACEBOOK生成的。 此处传入的具体值，请联系运营或者SDK开发人员。
         
         actionType ：FBSDKGameRequestActionTypeAskFor表示该游戏请求是一个ASKFOR类型的请求。
         
         mesage : 可自定义的数据，可用来跟踪此游戏
         
         results : {
             request = 101166043550679;
             "to[0]" = 1556010831327419;
         }
         **/
        /**
         local strtable = {
             message = askMessage,
             friendid = tostring(friendInfo.fbid),
             objectId = tostring(askObjectId),
             asktype = "1",
             title = tostring(friendInfo.fbid),
             extraData = "askRequst,"..friendInfo.uid,
             requestId = ""
         }
         **/
        
        NSLog(@"tag---->%@----msg--->%@",[NSString stringWithUTF8String:tag.c_str()],[NSString stringWithUTF8String:msg.c_str()]);
        NSString *askMsg = [NSString stringWithUTF8String:msg.c_str()];
        SBJsonParser* parser = [[[SBJsonParser alloc] init] autorelease];
        NSDictionary *receiveAskDic = [parser objectWithString:askMsg];
        NSLog(@"receiveAskDic------%@",receiveAskDic);
        NSString *askMessage = [receiveAskDic valueForKey:@"message"];
        NSString *friendFBId = [receiveAskDic valueForKey:@"friendid"];
        NSString *askObjectId = [receiveAskDic valueForKey:@"objectId"];
        NSString *msgType = [receiveAskDic valueForKey:@"asktype"];
        
        if ([msgType intValue] == 1) {//索取
            
            // 发送  local askMsg = askMessage.."$"..friendInfo.fbid.."$"..askObjectId.."$".."1".."$"..askTitle.."$".."askRequst,"..friendInfo.uid;
            NSString *askTitle = [receiveAskDic valueForKey:@"title"];
            NSString *friendUID = [receiveAskDic valueForKey:@"extraData"];
//            NSString *requestID = [receiveAskDic valueForKey:@"requestId"];
            NSArray *FBID = [NSArray arrayWithObjects:friendFBId,nil];
            
            [[R2SDK sharedR2SDK] FbGameRequestType:FBSDKGameRequestActionTypeAskFor title:askTitle objectID:askObjectId mesage:askMessage to:FBID extraData:friendUID handle:^(NSDictionary *result, NSError *error) {
                if (result) {
                    NSLog(@"result:%@",result);
                }
                else{
                    NSLog(@"error :%@",[error localizedDescription]);
                }
            }];
            
            
        }else if([msgType intValue] == 2){//获取
            //接收  local askMsg = "message".."$"..fbinfo.fromUserFbId.."$".."1844478939110805".."$".."2".."$".."title".."$".."sendRequst,"..datainfo[2].."$"..fbinfo.requestId
            NSString *askTitle = [receiveAskDic valueForKey:@"title"];
            NSString *friendUID = [receiveAskDic valueForKey:@"extraData"];
            NSString *requestID = [receiveAskDic valueForKey:@"requestId"];
            NSArray *FBID = [NSArray arrayWithObjects:friendFBId,nil];

            [[R2SDK sharedR2SDK] FbGameRequestType:FBSDKGameRequestActionTypeSend title:askTitle objectID:askObjectId mesage:askMessage to:FBID extraData:friendUID handle:^(NSDictionary *result, NSError *error) {
                if (result) {
                    NSLog(@"result:%@",result);
                    
                }
                else{
                    NSLog(@"error :%@",[error localizedDescription]);
                }
            }];
            if([msgType intValue] == 2){
                //索取之后，删除对应的 请求
                NSLog(@"-------have finish request------");
                [[R2SDK sharedR2SDK] notificationClear:requestID];
            }
            
        }
        
        
        
    }

    
    
    return "";
    
}








