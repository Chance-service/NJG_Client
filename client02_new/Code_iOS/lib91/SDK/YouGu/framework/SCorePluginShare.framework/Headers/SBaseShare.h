//
//  SBaseShare.h
//  SCorePluginShare
//
//  Created by htdev on 2018/1/25.
//  Copyright © 2018年 dev. All rights reserved.
//

#import <SCore/SCore.h>

@interface SBaseShare : NSObject

@property (nonatomic) NSInteger socialId;
@property (nonatomic, copy, readonly) NSDictionary *params;

@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareText;
@property (nonatomic, copy) NSString *shareDescription;

@property (nonatomic, copy) NSData *shareImageData;
@property (nonatomic, copy) NSString *shareImageURL;
@property (nonatomic, copy) NSString *shareImageLocalPath;

@property (nonatomic, copy) NSData *shareThumbImageData;
@property (nonatomic, copy) NSString *shareThumbImageURL;
@property (nonatomic, copy) NSString *shareThumbImageLocalPath;

@property (nonatomic, copy) NSString *shareLinkURL;
@property (nonatomic, copy) NSString *shareExtend;

@property (nonatomic) BOOL hasText, hasImage, hasThumbImage, hasLinkURL;

extern const int DEFAULT_THUMB_IMAGE_SIZE;

- (void)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;
- (void)application:(UIApplication *)application openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options;

- (BOOL)initWithParams:(NSDictionary *)params;
- (void)doShareWithContents:(NSDictionary<NSString *, NSObject *> *)contents toSocial:(NSUInteger)social;

- (BOOL)isValidContents;
- (void)doShareSuccess:(NSDictionary *)params;
- (void)doShareFailure:(SError *)error;
- (void)clean;

- (NSData *)compressImageData:(NSData *)data maxSizeOfKb:(int)maxSizeOfKb;
- (NSData *)getShareImageData;
- (NSData *)getShareImageData:(int)maxSizeOfKb;
- (NSData *)getShareThumbImageData;
- (NSData *)getShareThumbImageData:(int)maxSizeOfKb;

@end
