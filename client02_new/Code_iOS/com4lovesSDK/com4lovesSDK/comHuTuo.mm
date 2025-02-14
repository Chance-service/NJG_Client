//
//  com4loves.cpp
//  com4lovesSDK
//
//  Created by fish on 13-8-31.
//  Copyright (c) 2013年 com4loves. All rights reserved.
//

#include "comHuTuo.h"
#import "comHuTuoSDK.h"
#import "HuTuoServerInfo.h"


void comHuTuo::updateServerInfo(int serverID, const std::string& playerName, int playerID, int lvl, int vipLvl, int coin1, int coin2, bool pushSvr)
{
    NSString* name = [NSString stringWithUTF8String:playerName.c_str()];
   [comHuTuoSDK updateServerInfo:serverID  playerName:name playerID:playerID lvl:lvl vipLvl:vipLvl coin1:coin1 coin2:coin2 pushSer:pushSvr];
   [comHuTuoSDK getServerInfo].serverID = serverID;
    [comHuTuoSDK getServerInfo].playerName = name;
    [comHuTuoSDK getServerInfo].playerID  = playerID;
    [comHuTuoSDK getServerInfo].lvl = lvl;
    [comHuTuoSDK getServerInfo].vipLvl = vipLvl;
    [comHuTuoSDK getServerInfo].coin1 = coin1;
    [comHuTuoSDK getServerInfo].coin2 = coin2;
}
void comHuTuo::refreshServerInfo(const std::string& gameid,const std::string& puid, bool getSvr)
{
    NSString* gameID = [NSString stringWithUTF8String:gameid.c_str()];
    NSString* PUID = [NSString stringWithUTF8String:puid.c_str()];
    [comHuTuoSDK getServerInfo].gameid = gameID;
    [comHuTuoSDK getServerInfo].puid = PUID;
    [comHuTuoSDK refreshServerInfo:gameID puid:PUID pushSer:getSvr];
}
int comHuTuo::getServerInfoCount()
{
    return [comHuTuoSDK getServerInfoCount];
}
int comHuTuo::getServerUserByIndex(int index)
{
    return [comHuTuoSDK getServerUserByIndex:index];
}
