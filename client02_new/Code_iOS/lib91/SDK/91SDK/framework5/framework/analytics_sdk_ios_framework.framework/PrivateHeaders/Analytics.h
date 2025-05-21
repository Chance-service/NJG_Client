//
//  Header.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/3/8.
//

#import <UIKit/UIKit.h>
#import "DBHelper.h"


@interface Analytics : NSObject

@property NSUUID *IDFV;
//IDFV 對應 androidId
@property NSUUID *uuId;
@property NSUUID *sessionId;

@property NSString *network;
@property BOOL useVPN;

@property NSString *userId;
@property NSString *platformUserId;
@property NSString *bundleId;
//bundleId 對應 packageName
@property NSString *version;
//version 對應 versionName
@property NSString *build;
//build 對應 versionCode

@property double widthPixels;
@property double heightPixels;
@property double widthPoint;
@property double heightPoint;
@property double scale;
@property double nativeScale;
@property NSString *deviceModel;
@property NSString *deviceBrand;
@property NSString *language;
@property NSString *country;
@property NSString *osVersion;

@property DBHelper *dbHelper;

- (void) genSessionId;
- (void) clearSessionId;
- (void) setUser:(NSString *) userId and:(NSString *) platformUserId;
@end
