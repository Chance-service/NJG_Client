//
//  AppDelegate.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/2/24.
//

#import <UIKit/UIKit.h>
#import "Analytics.h"

@interface Tracker : NSObject


@property Analytics *analytics;
@property DBHelper *dbHelper;

- (void) appStart;
- (void) livenessCheck;


- (BOOL) login:(NSString *)userId and:(NSString *)platformUserId;
- (BOOL) logout;
- (BOOL) charge:(NSString *)orderId and:(NSString *)currencyCode and:(NSNumber *)amount and:(NSString *)product;

- (id)init:(Analytics *) analytics;




@end
