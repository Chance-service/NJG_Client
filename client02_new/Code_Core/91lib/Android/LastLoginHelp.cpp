
#include <string>

#include <jni.h>
#include "jni/JniHelper.h"
#include "comHuTuo.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "json/json.h"
#define  CLASS_NAME "com/nuclear/gjwow/LastLoginHelp"

using namespace cocos2d;

//客户端向服务器同步服务器id
void comHuTuo::updateServerInfo(int serverID, const std::string& playerName, int playerID, int lvl, int vipLvl, int coin1, int coin2, bool pushSvr){
	Json::Value msg;
	msg["serverID"] = serverID;
	msg["playerName"] = playerName;
	msg["playerID"] = playerID;
	msg["lvl"] = lvl;
	msg["vipLvl"] = vipLvl;
	msg["coin1"] = coin1;
	msg["coin2"] = coin2;
	msg["pushSvr"] = pushSvr;
	callPlatformSendMessageG2PJNI("updateServerInfo", msg);
}

//刷新游戏服务器信息，用于切换用户后重置服务器列表
void comHuTuo::refreshServerInfo(const std::string& gameid, const std::string& puid, bool getSvr){
	Json::Value msg;
	msg["gameid"] = gameid;
	msg["puid"] = puid;
	msg["getSvr"] = getSvr;
	callPlatformSendMessageG2PJNI("refreshServerInfo", msg);
}
//获得账号服务器上记录的游戏服务器数量
int comHuTuo::getServerInfoCount(){
	return callPlatformSendMessageG2PJNI("getServerInfoCount", Json::Value(Json::objectValue)).asInt();
}
//根据顺序获得账号服务器上第n个游戏服务器的服务器ID
int comHuTuo::getServerUserByIndex(int index){
	Json::Value msg;
	msg["index"] = index;
	return callPlatformSendMessageG2PJNI("getServerUserByIndex", msg).asInt();
}