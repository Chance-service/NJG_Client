//
//  ShareSDKToDifPlatform.m
//  ShareSDKToDifPlatform
//
//  Created by fanleesong on 15/4/20.
//  Copyright (c) 2015年 com4loves. All rights reserved.
//

#import "ShareSDKToDifPlatform.h"
#import "Adjust.h"

@interface ShareSDKToDifPlatform ()<AdjustDelegate>
/**
 You can disable the adjust SDK from tracking any activities of the current device by calling setEnabled with parameter NO.
 This setting is remembered between sessions, but it can only be activated after the first session.
 **/
- (void)setDisableAjustTracking:(BOOL)isAbled;
/**
 Enable event buffering
 If your app makes heavy use of event tracking, you might want to delay some HTTP requests in order to send them in one batch every minute. You can enable event buffering with your ADJConfig instance:
 ***/
- (void)setBufferAjustEnabled:(ADJConfig *)adjustConfig isOpenBuffer:(BOOL)isOpenBuffer;
@end

@implementation ShareSDKToDifPlatform

static ShareSDKToDifPlatform * instance = nil;

/***
 singleton
 **/
+(instancetype)shareSDKPlatform{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;

}
/** important------
 You can disable the adjust SDK from tracking any activities of the current device by calling setEnabled with parameter NO.
 This setting is remembered between sessions, but it can only be activated after the first session.
 **/
- (void)setDisableAjustTracking:(BOOL)isAbled{
    
    NSLog(@"------%s------",__FUNCTION__);
    [Adjust setEnabled:isAbled];
    
}
/** important------
 * init Adjust   and anlaytics some download....datas
 In the Project Navigator, open the source file of your application delegate. Add the import statement at the top of
 the file, then add the following call to Adjust in the didFinishLaunching or didFinishLaunchingWithOptions method of your app delegate
 *（notice：sandbox setMode  YES, onAppstore setMode NO）
 **/
-(void)setAdjustEnvironmentWithState:(BOOL)isSandBox isOpenAjustTracking:(BOOL)isOpenAjustTracking differentToken:(NSString *)differentToken{
    
        NSLog(@"can tracking----------%s",__FUNCTION__);
        //control app token
        NSString *yourAppToken = differentToken;
        NSString *environment = nil;
        if ( isSandBox) {
            environment = ADJEnvironmentSandbox;
        }else{
            environment = ADJEnvironmentProduction;
        }
        ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                                    environment:environment];
        //Adjust Logging
        [adjustConfig setLogLevel:ADJLogLevelVerbose]; // enable all logging
        [adjustConfig setLogLevel:ADJLogLevelDebug];   // enable more logging
//        [adjustConfig setLogLevel:ADJLogLevelInfo];    // the default
//        [adjustConfig setLogLevel:ADJLogLevelWarn];    // disable info logging
//        [adjustConfig setLogLevel:ADJLogLevelError];   // disable warnings as well
//        [adjustConfig setLogLevel:ADJLogLevelAssert];  // disable errors as well
//        [adjustConfig setEventBufferingEnabled:YES];
        //init adjust before launch app
        [Adjust appDidLaunch:adjustConfig];
    
}
/**
 Enable event buffering
 If your app makes heavy use of event tracking, you might want to delay some HTTP requests in order to send them in one batch every minute. You can enable event buffering with your ADJConfig instance:
 ***/
- (void)setBufferAjustEnabled:(ADJConfig *)adjustConfig isOpenBuffer:(BOOL)isOpenBuffer{

    NSLog(@"------%s------",__FUNCTION__);
//    if ([Adjust isEnabled]) {
       [adjustConfig setEventBufferingEnabled:isOpenBuffer];
//    }
    
}
/** important------
 *You can use adjust to track events. Lets say you want to track every tap on a particular button.
  You would create a new event token in your dashboard, which has an associated event token - looking
  something like abc123. In your button's buttonDown method you would then add the following lines to track the tap:
 **/
- (void)setTrackingLevelByToken:(NSString *)differenToken{

    NSLog(@"------%s------",__FUNCTION__);
    ADJEvent *event = [ADJEvent eventWithEventToken:differenToken];
    [Adjust trackEvent:event];

    
}
/** important------
 If your users can generate revenue by tapping on advertisements or making in-app purchases you can track those revenues with events.
 Lets say a tap is worth one Euro cent. You could then track the revenue event like this:
 **/
- (void)sendTrackEventXX:(double)salePrice currency:(NSString *)currency differentToken:(NSString *)differentToken transactionId:(NSString *)transactionId{
    
    NSLog(@"------%s------",__FUNCTION__);
    /*
     美元USD、人民币CNY、日元JPY、英镑GBP、欧元EUR、韩元KER、港币HKD、澳元AUD、加元CAD
    
    //1美元 = 100美分
    //1日元 = 0.0084美元 = 0.0084 *100 = 0.84美分
    //1人民币 = 0.1613美元 = 0.1613 * 100 = 16.13美分
    //1欧元 = 1.0725美元 = 1.0725 * 100 = 10.725美分
    //1港元 = 0.129美元 = 0.129 * 100 = 12.9美分
    //1英镑 = 1.4881美元 = 1.4881 * 100 = 14.881美分
    
     以上仅为当前SDK时汇率计算出的结果，详细根据实际情况计算
     
     */
//    ADJEvent *event =[ADJEvent eventWithEventToken:AjustEventAppPurchese];
     ADJEvent *event =[ADJEvent eventWithEventToken:differentToken];
    [event setRevenue:salePrice  currency:currency];
    //[event setTransactionId:transactionId];
    [Adjust trackEvent:event];
    
}
/**
 You can also pass in an optional transaction ID to avoid tracking duplicate revenues. The last ten transaction IDs are remembered and revenue events with duplicate transaction IDs are skipped. This is especially useful for in-app purchase tracking. See an example below.
 
 If you want to track in-app purchases, please make sure to call trackEvent after finishTransaction in paymentQueue:updatedTransaction only if the state changed to SKPaymentTransactionStatePurchased. That way you can avoid tracking revenue that is not actually being generated.
 **/
- (void)sendTrackEventXX:(double)salePrice currency:(NSString *)currency SKTransactionIdentifier:(NSString *)SKTransactionIdentifier differentToken:(NSString *)differentToken{

    NSLog(@"------%s------",__FUNCTION__);
    ADJEvent *event = [ADJEvent eventWithEventToken:differentToken];
    [event setRevenue:salePrice currency:currency];
    [event setTransactionId:SKTransactionIdentifier]; // avoid duplicates
    [Adjust trackEvent:event];
    
}
/**
 If you track in-app purchases, you can also attach the receipt to the tracked event. In that case our servers will verify that receipt with Apple and discard the event if the verification failed. To make this work, you also need to send us the transaction ID of the purchase. The transaction ID will also be used for SDK side deduplication as explained above:
 **/
- (void)sendTrackEventXX:(double)salePrice currency:(NSString *)currency SKTransactionIdentifier:(NSString *)SKTransactionIdentifier SKtransactionReceipt:(NSData *)transactionReceipt differentToken:(NSString *)differentToken{

    NSLog(@"------%s------",__FUNCTION__);

    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    
    ADJEvent *event = [ADJEvent eventWithEventToken:differentToken];
    [event setRevenue:salePrice currency:currency];
    [event setReceipt:receipt transactionId:SKTransactionIdentifier];
    
    [Adjust trackEvent:event];
    
}
/**
 Set up deep link reattributions
 
 You can set up the adjust SDK to handle deep links that are used to open your app via a custom URL scheme. We will only read certain adjust 
 specific parameters. This is essential if you are planning to run retargeting or re-engagement campaigns with deep links.
 In the Project Navigator open the source file your Application Delegate. Find or add the method openURL and add the following call to adjust:
 **/
- (void) setDeepLinkOpenUrl:(NSURL *)url{
    
    NSLog(@"------%s------",__FUNCTION__);
    [Adjust appWillOpenUrl:url];

    
}
/**
 *
 You can register a callback URL for your events in your dashboard. We will send a GET request to that URL whenever the
 event gets tracked. You can add callback parameters to that event by calling addCallbackParameter on the event before
 tracking it. We will then append these parameters to your callback URL.
 & like this url:  http://www.adjust.com/callback?key=value&foo=bar
 **/
- (void)eventAjustCallbackParamter:(NSString *)differentToken{

    NSLog(@"------%s------",__FUNCTION__);
    ADJEvent *event = [ADJEvent eventWithEventToken:differentToken];
    [event addCallbackParameter:@"key" value:@"value"];
    [Adjust trackEvent:event];

}
/**
 Partner parameters
 You can also add parameters to be transmitted to network partners, for the integrations that have been activated in your adjust dashboard.
 This works similarly to the callback parameters mentioned above, but can be added by calling the addPartnerParameter method on your ADJEvent instance.
 ***/
- (void)setPartnerParameters:(NSString *)differentToken{

    NSLog(@"------%s------",__FUNCTION__);
    ADJEvent *event = [ADJEvent eventWithEventToken:differentToken];
    [event addPartnerParameter:@"key" value:@"value"];
    [Adjust trackEvent:event];

}
/**
 a interface just for Ajust retained that deal with delegate's method (optional method)
 **/
- (void)adjustAttributionChanged:(ADJAttribution *)attribution {
    
    NSLog(@"%s-----ADJAttribution--->\n%@",__FUNCTION__,attribution);
    
}

- (void)setAdjustCroPro:(NSString *)token cpn:(NSString *)cpn pid:(NSString *)pid {
    NSLog(@"%s-----setAdjustCroPro--- token %@ cpn %@ pid %@>\n",__FUNCTION__,token,cpn,pid);
    ADJEvent *event = [ADJEvent eventWithEventToken:token];
    [event addCallbackParameter:@"cpn" value:cpn];
    [event addCallbackParameter:@"pid" value:pid];
    [Adjust trackEvent:event];
}
@end

















