
#include <string>

#include <jni.h>
#include "jni/JniHelper.h"
#include "comHuTuo.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "json/json.h"
#define  CLASS_NAME "com/nuclear/gjwow/LastLoginHelp"

using namespace cocos2d;

//�ͻ����������ͬ��������id
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

//ˢ����Ϸ��������Ϣ�������л��û������÷������б�
void comHuTuo::refreshServerInfo(const std::string& gameid, const std::string& puid, bool getSvr){
	Json::Value msg;
	msg["gameid"] = gameid;
	msg["puid"] = puid;
	msg["getSvr"] = getSvr;
	callPlatformSendMessageG2PJNI("refreshServerInfo", msg);
}
//����˺ŷ������ϼ�¼����Ϸ����������
int comHuTuo::getServerInfoCount(){
	return callPlatformSendMessageG2PJNI("getServerInfoCount", Json::Value(Json::objectValue)).asInt();
}
//����˳�����˺ŷ������ϵ�n����Ϸ�������ķ�����ID
int comHuTuo::getServerUserByIndex(int index){
	Json::Value msg;
	msg["index"] = index;
	return callPlatformSendMessageG2PJNI("getServerUserByIndex", msg).asInt();
}