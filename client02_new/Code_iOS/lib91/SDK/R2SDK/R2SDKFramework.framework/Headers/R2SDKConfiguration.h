//
//  R2SDKConfig.h
//  R2SDK
//
//  Created by luxing on 7/24/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//

#import <Foundation/Foundation.h>

#define R2_SDK_VERSION_CODE @"v3.0.1"

@interface R2SDKConfiguration : NSObject
+(NSString*)getKey;
+(NSString*)getServerSideEncryptKey;
+(NSString*)getRegisterRequestUrl;
+(NSString*)getLoginRequestUrl;
+(NSString*)getOldLoginRequestUrl;
+(NSString*)getBindR2AccountRequestUrl;
+(NSString*)getBindThirdPartyAccountRequestUrl;
+(NSString*)getSingleQueryRequestUrl;
+(NSString*)getBatchQueryRequestUrl;
+(NSString*)getActivationRequestUrl;

@end
