//
//  MessageBase.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/2/25.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>


@interface DBHelper : NSObject
- (BOOL) insert:(NSString *)tableName and:(NSString *)key and:(NSString *)value and:(NSNumber *)number;
- (NSMutableDictionary *) inquiry:(NSString *)tableName ;
- (BOOL) delete:(NSString *)tableName and:(NSString *)key ;
- (BOOL) update:(NSString *)tableName and:(NSString *)key and:(NSString *)value and:(NSNumber *)number ;
@end

