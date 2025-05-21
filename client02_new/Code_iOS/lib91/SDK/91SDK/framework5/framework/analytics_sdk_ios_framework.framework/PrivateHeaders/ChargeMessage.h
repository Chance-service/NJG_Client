//
//  MessageBase.h
//  analytics-sdk-ios
//
//  Created by gary_lai on 2022/2/25.
//

#import <UIKit/UIKit.h>
#import "MessageBase.h"

@interface ChargeMessage : MessageBase


@property NSString *orderId;
@property NSString *currencyCode;
@property NSNumber *amount;
@property NSString *product;
- (void) setParams:(NSString *)orderId and:(NSString *)currencyCode and:(NSNumber *)amount and:(NSString *)product;

@end

