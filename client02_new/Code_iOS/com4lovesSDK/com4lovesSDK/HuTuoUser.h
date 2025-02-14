//
//  HuTuoUser.h
//  com4lovesSDK
//
//  Created by ljc on 13-10-4.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UserTypeTryUser 2

//interface buxing
@interface HuTuoUser : NSObject

@property (retain,nonatomic) NSString*  name;
@property (retain,nonatomic) NSString*  huTuoId;
@property (retain,nonatomic) NSString*  password;
@property (nonatomic) NSInteger  userType;

- (void) initWithJsonString:(NSString *) json;
- (NSDictionary*) proxyForJson;

@end
