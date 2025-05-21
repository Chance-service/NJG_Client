//
//  MessageBase.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/2/25.
//

#import <UIKit/UIKit.h>

@interface HttpHelper : NSObject

- (NSString *) post:(NSString *) urlStr and:(NSDictionary *) dictionaray;
@property NSString *contentType;
@property NSString *accept;

@end

