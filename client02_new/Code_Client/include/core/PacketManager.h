#pragma once
#ifndef __PacketHandler_H_
#define __PacketHandler_H_

namespace google{namespace protobuf{class Message;}}

#include "Singleton.h"
#include "cocos2d.h"

#include <map>
#include <set>
#include <string>

#include "HawkOctets.h"

using namespace Hawk;

class PacketBase;
class PacketFactoryBase;

class PacketHandler
{
public:
	enum Handler_Type
	{
		Default_Handler,
		Scripty_Handler,
		Double_Handler,
	};
	virtual void onReceivePacket(const int opcode, const ::google::protobuf::Message* packet){};
	virtual void onReceivePacket(const int opcode, const std::string& str){};
	virtual void onSendPacketFailed(const int opcode) = 0;
	virtual void onReceivePacketFailed() {};
	virtual void onConnectFailed(std::string ip, int port) = 0;
	virtual void onTimeout(const int opcode) = 0;
	virtual void onPacketError(const int opcode) = 0;
	virtual Handler_Type getHandleType(void) {return Default_Handler;};
};

class PacketManagerListener
{
public:
	virtual void onPreSend(int opcode, ::google::protobuf::Message*, bool needWaiting=true){}
	virtual void onPreSend(int opcode, char* buff, int length, bool needWaiting = true){}
	virtual void onPostSend(int opcode, ::google::protobuf::Message*, bool needWaiting=true, int targetOpcode = 0){}
	virtual void onPostSend(int opcode, char* buff, int length, bool needWaiting = true){}

	virtual void onBoardcastPacketToHandler( int id, const ::google::protobuf::Message* msg, const std::string& msgStr=0){}
	virtual void onBoardcastConnectionFailed(std::string ip, int port){}
	virtual void onBoardcastSendFailed(int opcode){}
	virtual void onBoardcastReceiveFailed(){}
	virtual void onBoardcastReceiveTimeout(int opcode){}
	virtual void onBoardcastPacketError(int opcode, const std::string &errmsg){}

};
class PacketScriptHandler : public cocos2d::CCObject, public PacketHandler 
{
public:
	PacketScriptHandler(int opcode, int nHandler);
	virtual ~PacketScriptHandler();
	virtual void onReceivePacket(const int opcode, const ::google::protobuf::Message* packet);;
	virtual void onReceivePacket(const int opcode, const std::string& str);;
	virtual void onSendPacketFailed(const int opcode);
	virtual void onConnectFailed(std::string ip, int port);
	virtual void onTimeout(const int opcode);
	virtual void onPacketError(const int opcode);
	virtual Handler_Type getHandleType(void) {return Scripty_Handler;};
	void registerFunctionHandler( int nHandler);
	void validateFunctionHandler();
	//for lua
	int getRecPacketBufferLength(){return mPktBuffer.length();}
	std::string  getRecPacketBuffer(){return mPktBuffer;}

private:

	int mRecOpcode;
	std::string mPktBuffer;

	int mScriptFunHandler;
};

class PacketManager : public Singleton<PacketManager>
{
public:
	PacketManager(void);
	~PacketManager(void);
	static PacketManager* getInstance();

	enum
	{
		DEFAULT_BUFFER_LENGTH = 131072,//128k
		DEFAULT_COMPRESS_BUFFER_LENGTH = 8096,
	};
	void init(const std::string& configFile);
	void init(const std::string& ip, int port);
	void update(float dt);
	void disconnect();
	void reconnect();

	bool registerPacketHandler(int opcode,PacketHandler*);
	bool registerPacketSendListener(PacketManagerListener*);
	void removePacketSendListener(PacketManagerListener*);

	int nameToOpcode(const std::string& name);
	void removePacketHandler(int opcode, PacketHandler* packethandler);
	void removePacketHandler(PacketHandler* packethandler);
	
	void sendPakcet(int opcode, ::google::protobuf::Message*, bool needWaiting=true, int targetOpcode = 0);
	void sendPakcet(int opcode, char* buff, int length, bool needWaiting = true);

	void _onReceivedPacket(void* buffer, int size);
	void _checkReceivePacket();
	bool _registerPacketFactory(int opcode, const std::string& packetName,  PacketFactoryBase*);
	bool _buildDefaultMessage(int opcode, ::google::protobuf::Message*);
	::google::protobuf::Message* _getDefaultMessage(int opcode);

	void _boardcastPacketToHandler( int id, const ::google::protobuf::Message* msg, const std::string& msgStr=0);
	void _boardcastConnectionFailed(std::string ip, int port);
	void _boardcastSendFailed(int opcode);
	void _boardcastReceiveFailed();
	void _boardcastReceiveTimeout(int opcode);
	void _boardcastPacketError(int opcode, const std::string &errmsg);

	//add by zhenhui for the calc crc 2014/8/3
	unsigned int  CalcCrc(const unsigned char* pData, unsigned int iSize, unsigned int* pCrc);

	//add by zhenhui for the stream uncompress 2014/8/23
	bool Compress(HawkOctets& xOctets);
	bool Uncompress(HawkOctets& xOctets);

	void setCompress(bool flag){mIsCompress = flag;};
	bool getCompress(){return mIsCompress;};
private:
	//if compress or not
	bool mIsCompress;
	friend class pressureTest;
	PacketBase* createPacket(int opcode);

	typedef std::map<int, PacketFactoryBase*> PACKET_FACTORY_MAP;
	PACKET_FACTORY_MAP mFactories;

	typedef std::map<int,std::set<PacketHandler*> > PACKET_HANDLER_MAP;
	PACKET_HANDLER_MAP mHandlers;


	typedef std::map<std::string, int> NAME_TO_OPCODE_MAP;
	NAME_TO_OPCODE_MAP mNameToOpcode;

	typedef std::map<int, ::google::protobuf::Message*> DEFAULT_MESSAGE_MAP;
	DEFAULT_MESSAGE_MAP mDefaultMessageMap;

	std::set<PacketManagerListener*> mPacketSendListenerList;
	//流对象指针
	void* m_pStream[2];;
	//当前操作总流数据存储
	HawkOctets m_sStream;
	//当前操作流数据存储
	HawkOctets m_sOctets;

	char* left_buf;
	int left_len;
};

#endif//__PacketHandler_H_