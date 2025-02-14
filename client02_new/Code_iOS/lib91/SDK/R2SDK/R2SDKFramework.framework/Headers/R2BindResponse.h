//
//  R2BindResponse.h
//  R2SDK
//
//  Created by luxing on 7/27/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//

#import "R2SDKBaseResponse.h"
#define _R2_BIND_RESP_DATA_FOR_R2_UID_ @"muid"
#define _R2_BIND_RESP_DATA_FOR_THIRD_PARTY_ACCOUNT_ @"openid"

@interface R2BindResponse : R2SDKBaseResponse

@property NSDictionary* dataForR2Uid;
@property NSDictionary* dataForThirdPartyAccount;

-(void)initWithData:(NSData*)responseData;


@end
