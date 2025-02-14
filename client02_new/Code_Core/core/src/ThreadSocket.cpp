
#include "stdafx.h"

#include "ThreadSocket.h"
#include "PacketManager.h"
#include "cocos2d.h"

class SocketConnectTask : public SocketTask
{
public:
	std::string mIP;
	int mPort;
    
	virtual SOCKETTYPE getType(){return ST_CONNECT;}
	SocketConnectTask(const std::string & ipaddress, int port)
	{
		mIP = ipaddress;
		mPort = port;
	}

	virtual int run()
	{
		AsyncSocket& socket = ThreadSocket::Get()->lockSocket();
		do
		{
#ifdef WIN32
			WSADATA wsaData;   
			if (WSAStartup(MAKEWORD(2,1), &wsaData))
			{ 
				printf("Windows socket initialize error!\n"); 
				WSACleanup(); 
				ThreadSocket::Get()->setState(ThreadSocket::SS_CONNECT_FAILED);
				ThreadSocket::Get()->releaseSocket();
				return 0;
			}
#endif
			if(! socket.onCreate(mIP.c_str(), mPort))
			{
				printf("create SyncSocket error.\n");
				ThreadSocket::Get()->setState(ThreadSocket::SS_CONNECT_FAILED);
				socket.onClose();
				ThreadSocket::Get()->releaseSocket();
				return 0;
			}
			if(! socket.onConnect(mIP.c_str(), mPort))
			{
				printf("connect server error.\n");
				ThreadSocket::Get()->setState(ThreadSocket::SS_CONNECT_FAILED);
				socket.onClose();
				ThreadSocket::Get()->releaseSocket();
				return 0;
			}

		}while(0);

		ThreadSocket::Get()->SetConnectionOK(true);
		ThreadSocket::Get()->setState(ThreadSocket::SS_WAIT);
		ThreadSocket::Get()->releaseSocket();
		return 0;
	} 
};


class SocketSendTask : public SocketTask
{
private:
	ThreadSocket::PacketData mData;
public:
	int opcode;
	virtual SOCKETTYPE getType(){return ST_SEND;}
	SocketSendTask(ThreadSocket::PacketData data, int Opcode)
	{
		mData = data;
		opcode = Opcode;
	}
	virtual int run()
	{
		AsyncSocket& socket = ThreadSocket::Get()->lockSocket();
		do
		{
			if(mData.buffer == 0)
				break;
			if(mData.length<=0 )
			{
				delete[] (char*)mData.buffer;
				break;
			}
			bool sendOK = (socket.onSend(mData.buffer,mData.length) > 0);
			delete[] (char*) mData.buffer;
			if(sendOK)
			{
				ThreadSocket::Get()->setState(ThreadSocket::SS_WAIT);
				ThreadSocket::Get()->releaseSocket();
				return 0;
			}

		}while(0);

		if(ThreadSocket::Get()->getState() != ThreadSocket::SS_UNINITIALIZED && 
			ThreadSocket::Get()->getState() != ThreadSocket::SS_CONNECTING && 
			ThreadSocket::Get()->getState() != ThreadSocket::SS_CONNECT_FAILED)
			ThreadSocket::Get()->setState(ThreadSocket::SS_SEND_FAILED);
		ThreadSocket::Get()->releaseSocket();
		return 0;
	} 
};

class SocketReceiveTask : public SocketTask
{
private:
	ThreadSocket::PacketData mData;
public:
	virtual SOCKETTYPE getType(){return ST_RECEIVED;}
	SocketReceiveTask()
	{
		mData.buffer = new char[PacketManager::DEFAULT_BUFFER_LENGTH];
		mData.length = -1;
	}
	~SocketReceiveTask()
	{
		if(mData.buffer)
			delete [](char*)mData.buffer;
	}
	virtual int run()
	{
		AsyncSocket& socket = ThreadSocket::Get()->lockSocket();
		do
		{
			mData.length = socket.onReceive(mData.buffer,PacketManager::DEFAULT_BUFFER_LENGTH,0);
			if(mData.length > 0)
			{
				ThreadSocket::Get()->setState(ThreadSocket::SS_RECEIVE_DONE);
				ThreadSocket::Get()->releaseSocket();
				return 0;
			}
			else if (mData.length == 0 || mData.length == -1)//zhengxin 2014-08-20 -2是无可读数据
			{
				if(ThreadSocket::Get()->getState() != ThreadSocket::SS_UNINITIALIZED && 
					ThreadSocket::Get()->getState() != ThreadSocket::SS_CONNECTING && 
					ThreadSocket::Get()->getState() != ThreadSocket::SS_CONNECT_FAILED)
					ThreadSocket::Get()->setState(ThreadSocket::SS_RECEIVE_FAILED);
				ThreadSocket::Get()->releaseSocket();
				return 0;				
			}
		}while(0);

		ThreadSocket::Get()->setState(ThreadSocket::SS_WAIT);
		ThreadSocket::Get()->releaseSocket();
		return 0;
	} 

	ThreadSocket::PacketData getData(){return mData;}
};


ThreadSocket::ThreadSocket(void)
	:mState(SS_UNINITIALIZED)
	,mCurrentTask(0)
	,mForceShutDone(false)
	,mConnectionOk(false)
{
}


ThreadSocket::~ThreadSocket(void)
{
}

void ThreadSocket::update()
{
	if(getState() == SS_CONNECT_FAILED)
	{
		ThreadSocket::Get()->SetConnectionOK(false);

		std::string ip;
		int port = 0;
		if(mCurrentTask)
		{
			SocketConnectTask* conn = dynamic_cast<SocketConnectTask*>(mCurrentTask);
			if(conn)
			{
				ip = conn->mIP;
				port = conn->mPort;
			//}
				delete mCurrentTask;//mThread.shutdown();
				mCurrentTask = 0;
			}
			else
			{
				printf("SS_CONNECT_FAILED,mCurrentTask is not SocketConnectTask\n");
			}
		}
		else
		{
			printf("SS_CONNECT_FAILED,mCurrentTask is NULL\n");
		}
		setState(SS_UNINITIALIZED);
		//--begin zhengxin 2014-08-22
		//连接失败，清空task，让上层逻辑触发重新connect和send正确packet
		
		std::list<SocketTask*>::iterator it = mTaskList.begin();
		for(;it!=mTaskList.end();++it)
		{
			delete *it;
		}
		mTaskList.clear();
		
		//
		PacketManager::Get()->_boardcastConnectionFailed(ip,port);
	}

	if(getState() == SS_UNINITIALIZED)
	{
		if(mCurrentTask)
		{
			delete mCurrentTask;//mThread.shutdown();
			mCurrentTask = 0;
		}
		std::list<SocketTask*>::iterator it = mTaskList.begin();
		for(;it!=mTaskList.end();++it)
		{
			if((*it)->getType() == SocketTask::ST_CONNECT)
			{
				SocketConnectTask* conn = dynamic_cast<SocketConnectTask*>(*it);
				if(conn)
				{
					mCurrentTask = conn;
					setState(SS_CONNECTING);
					mTaskList.erase(it);
					mThread.execute(mCurrentTask);//mCurrentTask->run();
					//mCurrentTask->run();
					//mTaskList.erase(it);
					return;
				}
			}
		}
	}

	if(getState() == SS_SEND_FAILED)
	{
		int opcode = 0;
		if(mCurrentTask)
		{
			SocketSendTask* conn = dynamic_cast<SocketSendTask*>(mCurrentTask);
			if(conn)
			{
				opcode = conn->opcode;
			//}
				delete mCurrentTask;//mThread.shutdown();
				mCurrentTask = 0;
				//
				//setState(SS_WAIT);
				disconnect();
				PacketManager::Get()->_boardcastSendFailed(opcode);
			}
			else
			{
				printf("SS_SEND_FAILED,mCurrentTask is not SocketSendTask\n");
				setState(SS_WAIT);
			}
		}
		else
		{
			printf("SS_SEND_FAILED,mCurrentTask is NULL\n");
			setState(SS_WAIT);
		}
		//setState(SS_WAIT);
		//disconnect();
		//PacketManager::Get()->_boardcastSendFailed(opcode);
	}

	if(getState() == SS_RECEIVE_DONE)
	{
		if(mCurrentTask && mCurrentTask->getType() == SocketTask::ST_RECEIVED)//last task finished
		{

			SocketReceiveTask* reTask = dynamic_cast<SocketReceiveTask*>(mCurrentTask);
			if(reTask)
			{
				PacketManager::Get()->_onReceivedPacket(reTask->getData().buffer,reTask->getData().length);
			}
			setState(SS_WAIT);
			delete mCurrentTask;//mThread.shutdown();
			mCurrentTask = 0;
		}
	}

	if(getState() == SS_RECEIVE_FAILED)
	{
		if(mCurrentTask)
		{
			SocketReceiveTask* conn = dynamic_cast<SocketReceiveTask*>(mCurrentTask);
			if (conn)
			{
				delete mCurrentTask;//mThread.shutdown();
				mCurrentTask = 0;
				//
				//setState(SS_WAIT);
				disconnect();
				PacketManager::Get()->_boardcastReceiveFailed();
			}
			else
			{
				printf("SS_RECEIVE_FAILED,mCurrentTask is not SocketReceiveTask\n");
				setState(SS_WAIT);
			}
		}
		else
		{
			printf("SS_RECEIVE_FAILED,mCurrentTask is NULL\n");
			setState(SS_WAIT);
		}
		//setState(SS_WAIT);
		//disconnect();
		//PacketManager::Get()->_boardcastReceiveFailed();
	}

	if(getState() == SS_WAIT)
	{
		/*
			找setState为SS_WAIT的有4处：
			1、connect ok
			2、send ok
			3、empty receive
			4、receive done
			all need to be deleted
		*/
		if(mCurrentTask/* && mCurrentTask->getType() != SocketTask::ST_CONNECT*/)//last task finished
		{
			delete mCurrentTask;//mThread.shutdown();
			mCurrentTask = 0;
		}

		//should after delete current task
		if(mForceShutDone)
		{
			AsyncSocket& socket = lockSocket();
			socket.onClose();
#ifdef WIN32
			WSACleanup();
#endif
			releaseSocket();
			setState(SS_UNINITIALIZED);
			mForceShutDone = false;
		}

		if(mTaskList.empty())
		{
			//static bool check = true;
			//if(check)
			{
				SocketReceiveTask* reTask = new SocketReceiveTask;
				mTaskList.push_back(reTask);

			}
		}
		else
		{
			mCurrentTask = mTaskList.front();
			mTaskList.pop_front();

			///* why skip connect?
			if (mCurrentTask)
			{
				while (/*!mTaskList.empty() && */ mCurrentTask && mCurrentTask->getType() == SocketTask::ST_CONNECT)
				{
					//assert(false);
					printf("SS_WAIT invalid connect task\n");
					//
					delete mCurrentTask;
					mCurrentTask = 0;
					//
					if (!mTaskList.empty())
					{
						mCurrentTask = mTaskList.front();
						mTaskList.pop_front();
					}
				}
			}
			//*/

			if (mCurrentTask)
			{
				if (mCurrentTask->getType() == SocketTask::ST_SEND)
					setState(SS_SENDING);
				if (mCurrentTask->getType() == SocketTask::ST_RECEIVED)
					setState(SS_RECEIVING);
				if (mCurrentTask->getType() == SocketTask::ST_CONNECT)
					setState(SS_CONNECTING);

				mThread.execute(mCurrentTask);
			}
		}
	}
}

void ThreadSocket::connect( const std::string& ip ,int port )
{
	mIp = ip;
	mPort = port;
	mForceShutDone = false;
	SocketConnectTask* task = new SocketConnectTask(ip,port);
	mTaskList.push_back(task);

	CCLOG("connect start!");

	fprintf(stderr,"ThreadSocket::disconnect\n");
}

void ThreadSocket::reconnect()
{
	
	if (mTaskList.size() && (*mTaskList.begin())->getType() == SocketTask::ST_CONNECT)
		return;
	if (mCurrentTask && mCurrentTask->getType() == SocketTask::ST_CONNECT)
		return;
	disconnect();

	mForceShutDone = false;
	SocketConnectTask* task = new SocketConnectTask(mIp,mPort);
	mTaskList.push_back(task);

	CCLOG("Reconnect start!");

	fprintf(stderr,"ThreadSocket::disconnect\n");
}

void ThreadSocket::sendPacket( PacketData data, int opcode )
{
	if (getState() == SS_UNINITIALIZED || 
		getState() == SS_CONNECTING || 
		getState() == SS_CONNECT_FAILED)
	{
		std::list<SocketTask*>::iterator it = mTaskList.begin();
		for(;it!=mTaskList.end();++it)
		{
			SocketSendTask* send = dynamic_cast<SocketSendTask*>(*it);
			if(send && send->opcode == opcode)
			{
				return;
			}
		}
	}
	//
	SocketSendTask* task = new SocketSendTask(data, opcode);
	mTaskList.push_back(task);

	/*SocketReceiveTask* reTask = new SocketReceiveTask;
	mTaskList.push_back(reTask);*/
}

void ThreadSocket::disconnect()
{
	mConnectionOk = false;

	if (getState() == SS_UNINITIALIZED)
		return;

	AsyncSocket& socket = lockSocket();

	if(mCurrentTask)
	{
		// can not delete , been post to task'thread , task leak 
		//delete mCurrentTask;
		mCurrentTask = 0;
	}

	mTaskList.clear();

	socket.onClose();

#ifdef WIN32
	WSACleanup();
#endif
	
	setState(SS_UNINITIALIZED);

	CCLOG("Disconnected!");

	fprintf(stderr,"ThreadSocket::disconnect\n");
	//mForceShutDone = true;

	releaseSocket();

}
