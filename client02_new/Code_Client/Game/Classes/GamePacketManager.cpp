#include "GamePacketManager.h"
#include "LoginPacket.h"
#include "MessageBoxPage.h"
#include "waitingManager.h"
#include "GameMessages.h"
#include "SeverConsts.h"
#include "ConfirmPage.h"

bool ret = PacketManager::Get()->registerPacketSendListener(GamePacketManager::Get());

void GamePacketManager::onPreSend( int opcode, ::google::protobuf::Message*, bool needWaiting/*=true*/ )
{
	if(mNeedReConnect)
	{
		mNeedReConnect = false;
		CCLOG("GamePacketManager::1onPreSend(%d)", opcode);
		if(opcode != LOGIN_C)
			LoginPacket::Get()->forceSentPacket();
	}
}

void GamePacketManager::onPreSend( int opcode, char* buff, int length, bool needWaiting /*= true*/ )
{
	if(mNeedReConnect)
	{
		mNeedReConnect = false;
		CCLOG("GamePacketManager::2onPreSend(%d)", opcode);
		if(opcode != LOGIN_C)
			LoginPacket::Get()->forceSentPacket();
	}
}

void GamePacketManager::onPostSend( int opcode, ::google::protobuf::Message*, bool needWaiting/*=true*/, int targetOpcode/*=0*/ )
{
	if (mShowRelogin)
	{
		return;
	}
	if(needWaiting)
		waitingManager::Get()->startWaiting(opcode,targetOpcode ? targetOpcode : opcode+1);
}

void GamePacketManager::onPostSend( int opcode, char* buff, int length, bool needWaiting /*= true*/ )
{
	if (mShowRelogin)
	{
		return;
	}
	if(needWaiting)
		waitingManager::Get()->startWaiting(opcode,opcode+1);
}

void GamePacketManager::onBoardcastPacketToHandler(int id, const ::google::protobuf::Message* msg, const std::string& msgStr/* =0 */)
{
	mReconnectTimes = 0;	

	if (mShowRelogin)
	{
		MsgMainFramePopPage msg;
		msg.pageName = "ConnectFailedPage";
		MessageManager::Get()->sendMessage(&msg);
		mShowRelogin = false;
	}		
}

void GamePacketManager::onBoardcastConnectionFailed(std::string ip, int port)
{
	++mReconnectTimes;
	bool b = libOS::getInstance()->getIsDebug();
	if (!b )
	{
		unsigned int max = StringConverter::parseUnsignedInt(VaribleManager::Get()->getSetting("ReconnectMaxTimes"));
		if (mReconnectTimes >= max && !mShowRelogin && (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32))
		{
			//MsgMainFramePushPage msg;
			//msg.pageName = "ConnectFailedPage";
			//MessageManager::Get()->sendMessage(&msg);	
			//
			waitingManager::Get()->endWaiting();
			mNeedReConnect = false;
			//mShowRelogin = true;
			//
			mReconnectTimes = 0;
			//
			//SeverConsts::Get()->Free();
			waitingManager::Get()->clearReasones();
			std::string title = Language::Get()->getString("@WarmlyTip");
			std::string message = Language::Get()->getString("@SendPacketFailed");
			//ShowConfirmPage3(message, title, ReEnterLoading, "@Determine", "@Cancel", false);
			ShowConfirmPage3(message, title, ReEnterGame, "@Determine", "@Cancel", false);
		}
	}	
	else
	{
		mNeedReConnect = true;
		waitingManager::Get()->endWaiting();
		waitingManager::Get()->clearReasones();
		MSG_BOX_LAN("@ConnectGameSvrFailed");
	}
}

void GamePacketManager::onBoardcastSendFailed( int opcode )
{
	if (mShowRelogin)
	{
		waitingManager::Get()->endWaiting();
		mNeedReConnect = false;
		return;
	}
	if(!GamePrecedure::Get()->getUserKickedByServer())
	{				
		if(opcode != 3)//心跳的opcode
		{
			if(libOS::getInstance()->getNetWork()==NotReachable)
			{
				MSG_BOX_LAN("@NoNetWork");
			}
			else
			{
				MSG_BOX_LAN("@SendPacketFailed");
				//PacketManager::Get()->reconnect();
				//zhengxin 2014-08-19
				mNeedReConnect = false;
				waitingManager::Get()->endWaiting();
				waitingManager::Get()->clearReasones();//手動觸發超時，結束菊花
				LoginPacket::Get()->setEnabled(true);//zhengxin 2014-08-19
				LoginPacket::Get()->sendPacket();
				//--end
			}
		}
		else
		{
			CCLOG("GamePacketManager::onBoardcastSendFailed(%d)->setNeedReConnect", opcode);
			setNeedReConnect();
			MSG_BOX_LAN("@NeedReconnectGameSvr");
		}
	}
	else
	{
		setNeedReConnect();
		MSG_BOX_LAN("@UserKickoutMsg");
	}
}

void GamePacketManager::onBoardcastReceiveFailed()
{
	if(libOS::getInstance()->getNetWork()==NotReachable)
	{
		MSG_BOX_LAN("@NoNetWork");
	}
	else
	{
		//MSG_BOX_LAN("@ReceivePacketFailed");
	}
	//--begin zhengxin at 2014-08-20
	if(!GamePrecedure::Get()->isInLoadingScene())
	{
		CCLOG("GamePacketManager::onBoardcastReceiveFailed! Not isInLoadingScene LoginPacket::Get()->sendPacket(); ");
		mNeedReConnect = false;
		waitingManager::Get()->endWaiting();
		waitingManager::Get()->clearReasones();//手動觸發超時，結束菊花
		LoginPacket::Get()->setEnabled(true);//zhengxin 2014-08-19
		LoginPacket::Get()->sendPacket();
	}
	else
	{
		CCLOG("GamePacketManager::onBoardcastReceiveFailed| isInLoadingScene showEnter");
		//PacketManager::Get()->disconnect();
		waitingManager::Get()->endWaiting();
		waitingManager::Get()->clearReasones();//手動觸發超時，結束菊花
	}
	//--end
}

void GamePacketManager::onBoardcastPacketError( int opcode, const std::string &errmsg)
{
	if (errmsg.size() != 0)
	{
		MSG_BOX_LAN(errmsg);
	}
	else
	{
		MSG_BOX_LAN("@PacketError");
	}
}

GamePacketManager::GamePacketManager()
{
	mNeedReConnect = false;
	mReconnectTimes = 0;
	mShowRelogin = false;
}

void GamePacketManager::onBoardcastReceiveTimeout( int opcode )
{
	CCLOG("GamePacketManager::onBoardcastReceiveTimeout! LoginPacket::Get()->sendPacket(); ");
	//LoginPacket::Get()->setEnabled(true);//zhengxin 2014-08-19
	//LoginPacket::Get()->sendPacket();
	char szTmp[32] = {0};
	sprintf(szTmp, "%d", opcode);
	std::string str = Language::Get()->getString("@ReceivedTimeout");
	CCLog("GamePacketManager::onBoardcastReceiveTimeout!opcode= %d", opcode);
	//str.append(szTmp);
	if (opcode != 217) {
		MSG_BOX(str);
	}
	//
	setNeedReConnect();//重連吧，會有能收到心跳包，但伺服器以為斷線的情況，其他包都超時，且不重新發包登錄恢復不了
	//MSG_BOX_LAN("@NeedReconnectGameSvr");
}
