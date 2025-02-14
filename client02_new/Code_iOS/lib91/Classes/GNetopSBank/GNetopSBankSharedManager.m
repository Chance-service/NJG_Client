//
//  GNetopSBankSharedManager.m
//  lib91
//
//  Created by fanleesong on 15/3/12.
//  Copyright (c) 2015年 youai. All rights reserved.
//

#import "GNetopSBankSharedManager.h"
#import "SBPaymentSDK/SBPaymentBaeView.h"
#import "SBPaymentSDK/SBPaymentViewController.h"
#import "com4lovesSDK.h"

@interface GNetopSBankSharedManager ()<SBPaymentViewDelegate>{

    BOOL isNotShowView;
    
}


@property (nonatomic, retain) SBPaymentBaeView* paymentBaseView;
@property (nonatomic, retain) SBPaymentViewController* paymentViewController;

@end

@implementation GNetopSBankSharedManager

static GNetopSBankSharedManager * instance = nil;

+(instancetype)shareSBankManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
    
}
/**
 * ---------prama-----
 --------------required--------------
 * @orderId         订单号 (订单号，不可重复，测试时可以每次加1，推荐纯数字)
 * @customId        客户ID
 * @productId       产品ID
 * @productName     产品名 (目前只支持英文)
 * @taxMoney        税额
 * @amount          购买金额(信用卡支付测试用2日币以上。 其他的支付手段用1日币测试)
 * @payRequestDate  购买日期 (请求时间，必须保持和SBPayment服务器相差不超过60秒， ※正式使用时需要游戏中自行取得日本标准时间 格式：20141105174600)
 --------------optional--------------
 * @serverCode      服务器ID  可选
 * @roleId          角色ID   可选
 * @currencyType    币种
 * @payMethod       付款方式  (Credit3d,信用卡、银行卡等，空白为多种)
 * @payModel        模式设定类型   0:测试   1:正式
 **/
-(void)showSBPaymentViewBuyForOrderId:(NSString *) orderId
                              customId:(NSString *) customId
                             productId:(NSString *) productId
                           productName:(NSString *) productName
                              taxMoney:(NSString *) taxMoney
                                amount:(NSString *) amount
                        payRequestDate:(int) payRequestDate
                            serverCode:(NSString *) serverCode
                                roleId:(NSString *) roleId
                          currencyType:(NSString *) currencyType
                             payMethod:(NSString *) payMethod
                              payTestModel:(int) payModel{

    
    if (!isNotShowView) {
        
        NSLog(@"\n%s",__FUNCTION__);
        
        self.paymentBaseView = [[SBPaymentBaeView alloc] init];
        self.paymentBaseView.delegate = self;
        
        self.paymentBaseView.animationOption = JFDepthViewAnimationOptionPushBack;
        self.paymentBaseView.blurAmount = JFDepthViewBlurAmountLight;
        
        self.paymentViewController = [[SBPaymentViewController alloc] init];
        self.paymentViewController.depthViewReference = self.paymentBaseView;
        self.paymentViewController.presentedInView = [UIApplication sharedApplication].keyWindow.rootViewController.view;
        
        [self.paymentViewController setPayMethod:payMethod];// Credit3d,空白为多种
        
        //订单号，不可重复，测试时可以每次加1，推荐纯数字
        [self.paymentViewController setOrderId:orderId];
        
        [self.paymentViewController setCustCode:customId];
        
        //购买项目ID
        [self.paymentViewController setItemId:productId];
        
        //购买项目名，目前只支持英文
        if ([productId isEqualToString:@"1"] || [productId isEqualToString:@"2"] ||
            [productId isEqualToString:@"3"] || [productId isEqualToString:@"4"] ||
            [productId isEqualToString:@"5"] || [productId isEqualToString:@"30"] ) {
            
            if ([productName isEqualToString:@"ダイヤカード"] || [productName hasPrefix:@"ダイヤカード"]){
                productName  = @"MonthCard";
            }else if([productName hasPrefix:@"钻石"]){
                NSRange newRange = NSMakeRange(2, productName.length - 2);
                NSString *dimanod = [productName substringWithRange:newRange];
                productName  = [NSString stringWithFormat:@"Diamond%@",dimanod];
            }
            
        }
        [self.paymentViewController setItemName:productName];
        
        //税额
        [self.paymentViewController setTax:taxMoney];
        
        //金额 (信用卡支付测试用2日币以上。 其他的支付手段用1日币测试)
        [self.paymentViewController setAmount:amount];
        
        //模式设定
        /****************************************************************************/
        /*                                                                          */
        /*                         0:测试   1:正式                                   */
        /*                                                                          */
        /*                                                                          */
        /****************************************************************************/
//        [self.paymentViewController setMode:payModel];
        [self.paymentViewController setMode:1];
        
        //请求时间，必须保持和SBPayment服务器相差不超过60秒， ※正式使用时需要游戏中自行取得日本标准时间 格式：20141105174600
        /**[getCurrentFromServerTime：<服务器时间> timeZone：<时区> ]将格林威治时间转日本的东九区时间**/
        [self.paymentViewController setRequestDate:[self getCurrentFromServerTime:payRequestDate timeZone:9]];
        
        //
		NSString* addressUrlSuccess = [com4lovesSDK getPropertyFromIniFile:@"RechargeAddressBak" andAttr:@"otherpayUrlSuccess"];
		NSString* addressUrlFail = [com4lovesSDK getPropertyFromIniFile:@"RechargeAddressBak" andAttr:@"otherpayFail"];
		NSString* addressUrlCancel = [com4lovesSDK getPropertyFromIniFile:@"RechargeAddressBak" andAttr:@"otherpayCancel"];
		if (addressUrlSuccess==nil)
		{
			addressUrlSuccess =  @"https://update-gs-ef.foxugame.com/jp_success/change";
		}
		if (addressUrlFail==nil)
		{
			addressUrlFail =  @"https://update-gs-ef.foxugame.com/jp_fail/change";
		}
		if (addressUrlCancel==nil)
		{
			addressUrlCancel =  @"https://update-gs-ef.foxugame.com/jp_cancel/change";
		}
        //成功后返回页面
        [self.paymentViewController setSuccessUrl : addressUrlSuccess];
        
        //取消后返回页面
        [self.paymentViewController setCancelUrl : addressUrlFail];
        
        //失败后返回页面
        [self.paymentViewController setErrorUrl : addressUrlCancel];
        
        //付款通知页面
        //付款通知页面,必须使用SSL,须提前购买,并于游戏服务器端设置
        //网页中接收软银传来的res_result参数,如果是OK则表示支付成功。
        //如果软银发过来OK,游戏服务器端处理也OK,就在HTTP的body中返回OK,否则返回NG
        //如果软银发过来NG,游戏服务器端返回OK
        //写成我们自己的游戏服务器的支付回调地址
        NSString* addressIp = [com4lovesSDK getPropertyFromIniFile:@"RechargeAddressBak" andAttr:@"otherpayUrl"];

        if (addressIp==nil)
        {
            addressIp =  @"http://54.92.67.99/Callback/gnetopGJABDPay";
        }

        [self.paymentViewController setPageconUrl : addressIp];

//        [self.paymentViewController setPageconUrl : @"http://54.92.67.99/Callback/appstoreGJABDPay"];
        
        
        
        //自由栏1 服务器ID
        [self.paymentViewController setFree1:serverCode];
        
        //自由栏2 角色ID
        [self.paymentViewController setFree2:roleId];
        
        //自由栏2 充值货币类型
        [self.paymentViewController setFree3:currencyType];
        
        //调出支付页面
        
        [self.paymentBaseView presentViewController:self.paymentViewController inView:[UIApplication sharedApplication].keyWindow.rootViewController.view animated:NO];
       NSLog(@"\n%s",__FUNCTION__);

    }

}
#pragma mark--
#pragma mark----------SBPayment delegate------------
- (void)willPresentSBPaymentView:(SBPaymentBaeView*)depthView {
    NSLog(@"willPresentView called!!!");
    isNotShowView = YES;
}

- (void)didPresentSBPaymentView:(SBPaymentBaeView*)depthView {
    NSLog(@"didPresentView called!!!");
}

- (void)willDismissSBPaymentView:(SBPaymentBaeView*)depthView {
    NSLog(@"willDismissView called!!!");
}

- (void)didDismissSBPaymentView:(SBPaymentBaeView*)depthView {
    NSLog(@"didDismissView called!!!");
    isNotShowView = NO;
}
#pragma mark----------SBPayment delegate------------

#pragma mark---
#pragma mark------------serials of encode methods-----------------

#define SBank_AppKey @"76f487cb98e51e89ae9ac2ff560b25272666d275"
//parase String
-(NSString *) parseDictinaryToFormatedString:(NSDictionary *)dic{
    
    NSMutableArray *typeArray = [NSMutableArray array];
    NSArray *keysArray = [dic allKeys];
    for (NSString *key in keysArray) {
        NSString *valueString = [dic objectForKey: key];
        NSString *formatString = [NSString stringWithFormat:@"%@=%@",key,valueString];
        [typeArray addObject:formatString];
    }
    //通过调用componentsJoinedByString:方法可以将数组的每一个子字符串中间拼接&得到最终格式的字符串 EG:key1=value1&key2=value2
    NSString *finalString = [typeArray componentsJoinedByString:@"&"];
    return finalString;
}
//16位MD5加密方式
- (NSString *)getMd5_16Bit_String:(NSString *)srcString{
    
    //提取32位MD5散列的中间16位
    NSString *md5_32Bit_String=[self getMd5_32Bit_String:srcString];
    NSString *result = [[md5_32Bit_String substringToIndex:24] substringFromIndex:8];//即9～25位
    return result;
    
}
//32位MD5加密方式
- (NSString *)getMd5_32Bit_String:(NSString *)srcString{
    
    const char *cStr = [srcString UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest );
    NSMutableString *result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
    
}
//sha1加密
-(NSString *)getSha1String:(NSString *)srcString{
    
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
    
}
//sha256加密方式
- (NSString *)getSha256String:(NSString *)srcString {
    
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    
    uint8_t digest[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

//sha384加密方式
- (NSString *)getSha384String:(NSString *)srcString {
    
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    
    uint8_t digest[CC_SHA384_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA384_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA384_DIGEST_LENGTH; i++) {
        [result appendFormat:@"%02x", digest[i]];
    }
    
    return result;
}

//sha512加密方式
- (NSString*) getSha512String:(NSString*)srcString {
    const char *cstr = [srcString cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:srcString.length];
    uint8_t digest[CC_SHA512_DIGEST_LENGTH];
    
    CC_SHA512(data.bytes, data.length, digest);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_SHA512_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA512_DIGEST_LENGTH; i++)
        [result appendFormat:@"%02x", digest[i]];
    return result;
}
/**
 get serverTime timestamp to formatter
 **/
-(NSString *) getCurrentFromServerTime:(int)serverTime timeZone:(int)timeZone{
    
    
    /**服务器时间**/
//    NSInteger dTime = serverTime;
//    long long lTime = [[NSNumber numberWithInteger:dTime] longLongValue]; // 将double转为long long型
//    NSString *curTime = [NSString stringWithFormat:@"%llu",lTime];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *theDate = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:[curTime floatValue]]];
//    NSLog(@"------serverTime----%@",theDate);
    
    /**将格林威治时间转日本的东九区时间**/
    time_t tick=(time_t)(serverTime + timeZone * 3600);
    struct tm * timeinfo;
    timeinfo = gmtime ( &tick );
    char buf[128];
    strftime(buf,80,"%Y%m%d%H%M%S",timeinfo);
    NSString *timeString = [NSString stringWithFormat:@"%s",buf];
    NSLog(@"------timeString----%@",timeString);
    
    return timeString;
}
//获取当前时间戳
-(NSString *)getCurrentTimestamp{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f", a];
    NSString *finalTime = [timeString substringToIndex:13];
    return finalTime;
}

//模拟取得服务器当前时间 日本时区
-(NSString*)getDateTimeStr{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate *selected = [NSDate date];
    NSTimeInterval interval = 60 * 60 ;
    
    NSString *theDate = [dateFormatter stringFromDate:[selected initWithTimeInterval:interval sinceDate:selected]];
    
    return theDate;
}
#pragma mark------------serials of encode methods-----------------


@end
