
#ifndef __com4lovesSDK__com4loves__
#define __com4lovesSDK__com4loves__

#include <iostream>

#endif /* defined(__com4lovesSDK__com4loves__) */


class comHuTuo
{
public:
    //客户端向服务器同步服务器id
    static void updateServerInfo(int serverID, const std::string& playerName, int playerID, int lvl, int vipLvl, int coin1, int coin2, bool pushSvr);
    
    //刷新游戏服务器信息，用于切换用户后重置服务器列表
    static void refreshServerInfo(const std::string& gameid, const std::string& puid, bool getSvr);
    
    //获得账号服务器上记录的游戏服务器数量
    static int getServerInfoCount();
    //根据顺序获得账号服务器上第n个游戏服务器的服务器ID
    static int getServerUserByIndex(int index);
};
