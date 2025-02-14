//
//  SModule.h
//
//  Created by dev on 2017/8/31.
//  Copyright © 2017年 dev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SModule : NSObject

#define S_DEPRECATED(_version, _message) __attribute__((deprecated(#_version"版本之后接口已不可用，"#_message)))

typedef void (^SOnCallback)(NSUInteger action, NSDictionary *result);

@property (readonly) NSInteger tag;

- (instancetype)initWithTag:(NSInteger)tag;

/**
 *  @brief 设置回调
 *  @param callback 回调block
 */
- (void)setCallback:(SOnCallback)callback;

@end
