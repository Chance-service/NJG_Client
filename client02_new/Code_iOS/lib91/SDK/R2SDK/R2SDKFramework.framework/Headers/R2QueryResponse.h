//
//  R2QueryResponse.h
//  R2SDK
//
//  Created by luxing on 7/27/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//

#import "R2SDKBaseResponse.h"

#define _R2_QUERY_RESP_R2_UID_ @"muid"
#define _R2_QUERY_RESP_GC_UID_ @"gcid"
#define _R2_QUERY_RESP_FB_UID_ @"fbid"
#define _R2_QUERY_RESP_R2_ @"r2"
#define _R2_QUERY_RESP_USERNAME_ @"username"

@interface R2QueryResponse : R2SDKBaseResponse
@property NSString* r2Uid;
@property NSString* gameCenterUid;
@property NSString* facebookUid;
@property NSString* r2;
@property NSString* username;
@property NSDictionary* ids;


-(void)initWithData:(NSData*)responseData;

@end
