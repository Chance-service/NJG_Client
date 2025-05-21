//
//  AppDelegate.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/2/24.
//

#import <UIKit/UIKit.h>
#import "Tracker.h"

@interface AnalyticsBuilder : NSObject


+ (NSString *)apiUrl;
+ (NSString *)appKey;
+ (Tracker *)build:(NSString *)appKey;

+ (BOOL) advertiserIDCollection;

+ (void) setAdvertiserIDCollectionEnabled :(BOOL)result ; 

@end
