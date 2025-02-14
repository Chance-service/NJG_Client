//
//  SPluginShare.h
//  SCore
//
//  Created by dev on 2017/9/26.
//  Copyright © 2017年 . All rights reserved.
//

#import "SPlugin.h"

@interface SPluginShare : SPlugin

- (void)doShareWithContents:(NSDictionary<NSString *, NSObject *> *)contents;
- (void)doShareWithContents:(NSDictionary<NSString *, NSObject *> *)contents toSocial:(NSUInteger)social;
- (void)doShareWithContents:(NSDictionary<NSString *, NSObject *> *)contents toSocials:(NSArray<NSNumber *> *)socials;

@end
