//
//  MessageBase.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/2/25.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Tracker.h"
#import "DBHelper.h"
#import "HttpHelper.h"
#import "AnalyticsBuilder.h"


@interface MessageBase : NSThread

@property Tracker *tracker;
@property DBHelper *dbHelper;
@property HttpHelper *httpHelper;

- (NSMutableDictionary*) toJSON;
- (void) run ;
- (id) init:(Tracker *) tracker;
- (void) retry ;
@end

