//
//  R2LoginResponse.h
//  R2SDK
//
//  Created by luxing on 7/27/15.
//  Copyright (c) 2015 luxing. All rights reserved.
//

#import "R2SDKBaseResponse.h"


#define _R2_LOGIN_RESP_R2_UID_ @"muid"
#define _R2_LOGIN_RESP_TOKEN_ @"token"
#define _R2_LOGIN_RESP_GC_UID_ @"gcid"
#define _R2_LOGIN_RESP_FB_UID_ @"fbid"
#define _R2_LOGIN_RESP_R2_ @"r2"
#define _R2_LOGIN_RESP_USERNAME_ @"username"

#define _R2_LOGIN_RESP_DATA_FOR_TOKEN_ @"token"
#define _R2_LOGIN_RESP_DATA_FOR_TUID_ @"openid"



@interface R2LoginResponse : R2SDKBaseResponse

@property NSString* r2Uid;
@property NSString* token;
@property NSString* gameCenterUid;
@property NSString* facebookUid;
@property NSString* r2;
@property NSString* username;
@property NSDictionary* dataForToken;
@property NSDictionary* dataForThirdPartyAccount;

-(void)initWithData:(NSData*)serverData;

@end
