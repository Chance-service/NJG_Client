//
//  R2RegisterResponse.h
//  R2SDK
//
//  Created by luxing on 7/24/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//

#import "R2SDKBaseResponse.h"

#define _R2_REG_RESP_R2_UID_ @"muid"
#define _R2_REG_RESP_TOKEN_ @"token"
#define _R2_REG_RESP_R2_ @"r2"
#define _R2_REG_RESP_USERNAME_ @"username"


@interface R2RegisterResponse : R2SDKBaseResponse

@property NSString* r2Uid;
@property NSString* token;
@property NSString* r2;
@property NSString* username;

-(void)initWithData:(NSData*)serverData;

@end
