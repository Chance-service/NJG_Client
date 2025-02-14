//
//  SYSDKShare.h
//
//  Created by dev on 2017/9/25.
//  Copyright © 2017年 . All rights reserved.
//

#import "SModule.h"
#import "SPluginShareDef.h"

@interface SYSDKShare : SModule

+ (instancetype)getInstance;

/**
 *  @brief 分享(未指定社交平台)
 *  @param contents 内容
 */
- (void)doShareWithContents:(NSDictionary<NSString *, NSObject *> *)contents;

/**
 *  @brief 分享(指定单个社交平台)
 *  @param contents 内容
 *  @param social 平台
 */
- (void)doShareWithContents:(NSDictionary<NSString *, NSObject *> *)contents toSocial:(SShareToSocial)social;

/**
 *  @brief 分享(指定多个社交平台)
 *  @param contents 内容
 *  @param socials 平台
 */
- (void)doShareWithContents:(NSDictionary<NSString *, NSObject *> *)contents toSocials:(NSArray<NSNumber *> *)socials;

@end
