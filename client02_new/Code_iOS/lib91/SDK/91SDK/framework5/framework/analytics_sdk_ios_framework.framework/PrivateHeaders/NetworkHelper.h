//
//  MessageBase.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/2/25.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIApplication.h>


@interface NetworkHelper : NSObject

+ (NSString *) getNetworkType ;
+ (BOOL) useVPN ;

@end

