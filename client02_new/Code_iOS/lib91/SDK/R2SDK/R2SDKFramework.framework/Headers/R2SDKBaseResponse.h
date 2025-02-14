//
//  R2BaseResponse.h
//  R2SDK
//
//  Created by luxing on 7/24/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "R2SDKResponse.h"

#define R2_RESPONSE_DEFAULT_CODE 20000

#define R2_RESPONSE_SUCCESS_CODE 0
#define R2_RESPONSE_SUCCESS_DESC @"success"

#define _R2_RESPONSE_CODE_ @"code"
#define _R2_RESPONSE_MSG_ @"message"
#define _R2_RESPONSE_DATA_ @"data"

@interface R2SDKBaseResponse : NSObject<R2SDKResponse>
@property int code;
@property NSString* message;
@property NSDictionary* data;

-(void)initWithData:(NSData*)serverData;
-(int)getResponseCode;
-(NSString*)getResponseMsg;
-(NSDictionary*)getResponseData;

@end
