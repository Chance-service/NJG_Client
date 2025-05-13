
#include "stdafx.h"

#include "LoginPacket.h"
#include "PacketManager.h"
#include "GamePackets.h"
#include "lib91.h"
#include "libOS.h"
//#include "ThreadSocket.h"
#include "Base64.h"
#include "md5.h"
#include "DataTableManager.h"
#include "StringConverter.h"
#include "waitingManager.h"
#include "GamePrecedure.h"
#include "SeverConsts.h"
#include "MessageBoxPage.h"
#include "LoadingFrame.h"

LoginPacket::LoginPacket( void )
	: mCanSend(true)
	, mWaitingTime(LoginPacketWaitingTime)
{

}

void LoginPacket::update( float dt )
{
	if(mCanSend)
	{
		return;
	}
	if(mWaitingTime <= 0 || !waitingManager::Get()->getWaiting())
	{
		mWaitingTime=0;
		mCanSend = true;
	}
	else
	{
		mWaitingTime -= dt;
	}
}

void LoginPacket::sendPacket()
{
	CCLOG("LoginPacket::sendPacket");
	if(mCanSend) 
	{
		_sendPacket();
		mWaitingTime = LoginPacketWaitingTime;
		mCanSend = false;
	}
}

void LoginPacket::forceSentPacket()
{
	CCLOG("LoginPacket::forceSentPacket");
	mEnable = true;
	_sendPacket();
}

void LoginPacket::_sendPacket()
{
    int a = 0;
    if (a == 0)
    {
        //return;
    }
	if(!mEnable)
		return;
	CCLOG("LoginPacket::_sendPacket->PacketManager::reconnect");
	//MSG_BOX_LAN("@ReconnectGameServer");
	PacketManager::Get()->reconnect();
	HPLogin loginPack;
	std::string uin = libPlatformManager::getPlatform()->loginUin();
#ifdef PROJECT91Quasi
		uin=GamePrecedure::Get()->getLoginUin();
#endif
	if(uin.empty()) uin="none";

	std::string platformInfo = libPlatformManager::getPlatform()->getPlatformInfo();
	std::string deviceID = libOS::getInstance()->getDeviceID();

	if(uin.empty()) uin="none";
	if(deviceID.empty()) deviceID="none";
	if(!platformInfo.empty())
		loginPack.set_platform(platformInfo);
	std::string aPwd = GamePrecedure::getInstance()->getDefaultPwd();
	if (SeverConsts::Get()->IsEroR18() || SeverConsts::Get()->IsErolabs())
	{
		loginPack.set_registed(false);
		loginPack.set_passwd(aPwd);
	}
	else
	{
		if (aPwd != "")
			loginPack.set_passwd(aPwd);
	}
    loginPack.set_isrelogin(true);
	loginPack.set_puid(uin);
	loginPack.set_deviceid(deviceID);
	loginPack.set_serverid(g_iSelectedSeverIDCopy);
	loginPack.set_version(SeverConsts::Get()->getServerVersion());

	PacketManager::Get()->sendPakcet(LOGIN_C,&loginPack);
}
