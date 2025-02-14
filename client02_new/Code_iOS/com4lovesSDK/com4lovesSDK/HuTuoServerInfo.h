//
//  HuTuoServerInfo.h
//  com4lovesSDK
//
//  Created by ljc on 13-11-26.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HuTuoServerInfo : NSObject

@property (nonatomic) int serverID;
@property (nonatomic, copy) NSString *playerName;
@property (nonatomic, copy) NSString *gameid;
@property (nonatomic, copy) NSString *puid;
@property (nonatomic) int playerID;
@property (nonatomic) int lvl;
@property (nonatomic) int vipLvl;
@property (nonatomic) int coin1;
@property (nonatomic) int coin2;

@end
