//
//  HuTuoUser.m
//  comHuTuoSDK
//
//  Created by ljc on 13-10-4.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import "HuTuoUser.h"
#import "SDKEncrypt.h"

@implementation HuTuoUser

- (void) initWithJsonString:(NSString *) json
{
    
}
- (NSDictionary*) proxyForJson {
    
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                          self.name,@"name",
                          self.huTuoId,@"youaiId",
                          [NSNumber numberWithInteger:self.userType] ,@"userType",
                          nil==self.password?@"":[[SDKEncrypt sharedInstance] base64Encrypt:[NSString stringWithString:self.password]],@"password",
                          nil];
    return dict;
}
@end
