//
//  InAppPurchaseManager.h
//  com4lovesSDK
//
//  Created by fish on 13-8-22.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#define kInAppPurchaseManagerProductsFetchedNotification @"kInAppPurchaseManagerProductsFetchedNotification"
#define kInAppPurchaseManagerTransactionFailedNotification @"kInAppPurchaseManagerTransactionFailedNotification"
#define kInAppPurchaseManagerTransactionSucceededNotification @"kInAppPurchaseManagerTransactionSucceededNotification"


@interface InAppPurchaseManager : NSObject<SKProductsRequestDelegate,SKPaymentTransactionObserver>

+ (InAppPurchaseManager *)sharedInstance;

// public methods
- (void)loadStore;
- (BOOL)canMakePurchases;
- (void)purchaseProduct: (NSString*) productID price:(float) price;

- (NSData*) getRecept;
- (NSString*) getLastProductID;
- (float) getLastProductPrice;
- (void)completeTransaction:(SKPaymentTransaction *)transaction;
@end
