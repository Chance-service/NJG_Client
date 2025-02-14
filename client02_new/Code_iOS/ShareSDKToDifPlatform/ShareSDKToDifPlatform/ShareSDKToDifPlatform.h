//
//  ShareSDKToDifPlatform.h
//  ShareSDKToDifPlatform
//
//  Created by fanleesong on 15/4/20.
//  Copyright (c) 2015年 com4loves. All rights reserved.
//

#import <Foundation/Foundation.h>

//日本token
#define GnetopAjustEventAppToken @"buzztyj25frh"
#define GnetopAjustEventAppPurchese @"4mlbzf"
#define GnetopAjustEventClick @"rx8wwt"
#define GnetopAjustEventInstanll @"kis0mg"
#define GnetopAjustEventSession @"sefks9"
#define GnetopAjustEventSignUp @"hnruqc"
//日本ryuk
#define RYUKAdjustAppToken @"b1g264"
#define RYUKAdjustNewAppToken @"iswg90"


@interface ShareSDKToDifPlatform : NSObject

+ (instancetype) shareSDKPlatform;

#pragma mark--- Ajust----
/**
 * init Adjust   and anlaytics some download....datas
 In the Project Navigator, open the source file of your application delegate. Add the import statement at the top of
 the file, then add the following call to Adjust in the didFinishLaunching or didFinishLaunchingWithOptions method of your app delegate
 *（notice：sandbox setMode  YES, onAppstore setMode NO）
**/
-(void)setAdjustEnvironmentWithState:(BOOL)isSandBox isOpenAjustTracking:(BOOL)isOpenAjustTracking differentToken:(NSString *)differentToken;
/**
 *You can use adjust to track events. Lets say you want to track every tap on a particular button.
  You would create a new event token in your dashboard, which has an associated event token - looking 
  something like abc123. In your button's buttonDown method you would then add the following lines to track the tap:
 *
 **/
- (void)setTrackingLevelByToken:(NSString *)differenToken;
/**
 If your users can generate revenue by tapping on advertisements or making in-app purchases you can track those revenues with events.
 Lets say a tap is worth one Euro cent. You could then track the revenue event like this:
 **/
- (void)sendTrackEventXX:(double)salePrice currency:(NSString *)currency differentToken:(NSString *)differentToken transactionId:(NSString *)transactionId;
/**
 You can also pass in an optional transaction ID to avoid tracking duplicate revenues. The last ten transaction IDs are remembered and revenue events with duplicate transaction IDs are skipped. This is especially useful for in-app purchase tracking. See an example below.
 
 If you want to track in-app purchases, please make sure to call trackEvent after finishTransaction in paymentQueue:updatedTransaction only if the state changed to SKPaymentTransactionStatePurchased. That way you can avoid tracking revenue that is not actually being generated.
 **/
- (void)sendTrackEventXX:(double)salePrice currency:(NSString *)currency SKTransactionIdentifier:(NSString *)SKTransactionIdentifier differentToken:(NSString *)differentToken;
/**
 If you track in-app purchases, you can also attach the receipt to the tracked event. In that case our servers will verify that receipt with Apple and discard the event if the verification failed. To make this work, you also need to send us the transaction ID of the purchase. The transaction ID will also be used for SDK side deduplication as explained above:
 **/
- (void)sendTrackEventXX:(double)salePrice currency:(NSString *)currency SKTransactionIdentifier:(NSString *)SKTransactionIdentifier SKtransactionReceipt:(NSData *)transactionReceipt differentToken:(NSString *)differentToken;
/**
 Set up deep link reattributions
 
 You can set up the adjust SDK to handle deep links that are used to open your app via a custom URL scheme. We will only read certain adjust specific parameters. This is essential if you are planning to run retargeting or re-engagement campaigns with deep links.
 In the Project Navigator open the source file your Application Delegate. Find or add the method openURL and add the following call to adjust:
 **/
- (void) setDeepLinkOpenUrl:(NSURL *)url;
/**
 *
 You can register a callback URL for your events in your dashboard. We will send a GET request to that URL whenever the
 event gets tracked. You can add callback parameters to that event by calling addCallbackParameter on the event before 
 tracking it. We will then append these parameters to your callback URL.
 & like this url:  http://www.adjust.com/callback?key=value&foo=bar
 **/
- (void)eventAjustCallbackParamter:(NSString *)differentToken;
/**
  Partner parameters
 You can also add parameters to be transmitted to network partners, for the integrations that have been activated in your adjust dashboard.
 This works similarly to the callback parameters mentioned above, but can be added by calling the addPartnerParameter method on your ADJEvent instance.
 ***/
- (void)setPartnerParameters:(NSString *)differentToken;

- (void)setAdjustCroPro:(NSString *)token cpn:(NSString *)cpn pid:(NSString *)pid;

#pragma mark--- Ajust----




@end

















