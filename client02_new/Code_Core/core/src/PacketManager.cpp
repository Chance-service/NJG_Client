
#include "stdafx.h"

#include "PacketManager.h"
#include "PacketBase.h"
#include "GameMaths.h"
#include "cocos2d.h"
#include "ThreadSocket.h"
#include "json/json.h"
#include <google/protobuf/message.h>
//#include "LoginPacket.h"

#include "AsyncSocket.h"

#ifndef _UTILITY_USE_

//#include "MessageBoxPage.h"
#include "script_support/CCScriptSupport.h"
#include "support/zip_support/unzip.h"
#include "support/zip_support/ZipUtils.h"
#include "CCLuaEngine.h"

#include "GamePlatform.h"
#include "Language.h"
//#include "waitingManager.h"

#else


unsigned char* getFileData(const char* pszFileName, const char* pszMode, unsigned long* pSize,bool isShowBox=true)
{
	unsigned char* pBuffer = NULL;

	*pSize = 0;
	do 
	{
		// read the file from hardware
		FILE *fp = fopen(pszFileName, pszMode);
		CC_BREAK_IF(!fp);

		fseek(fp,0,SEEK_END);
		*pSize = ftell(fp);
		fseek(fp,0,SEEK_SET);
		pBuffer = new unsigned char[*pSize];
		*pSize = fread(pBuffer,sizeof(unsigned char), *pSize,fp);
		fclose(fp);
	} while (0);
	if (! pBuffer)
	{
		std::string msg = "Get data from file(";
		msg.append(pszFileName).append(") failed!");

		CCLOG(msg.c_str());
		if(isShowBox)
		{
			if(isShowBox&&msg.find(".msg")==std::string::npos&&msg!=".ccbi")
			{
				if(msg.find(".")!=std::string::npos)
				{
					CCMessageBox(msg.c_str(),"File Not Found");
				}
				if(msg.find(".png")!=std::string::npos||msg.find(".PNG")!=std::string::npos)
				{
					do
					{
						// read the file from hardware
						std::string fullPath = fullPathForFilename("mainScene/empty.png");//todo:draw a pic
						FILE *fp = fopen(fullPath.c_str(), pszMode);
						CC_BREAK_IF(!fp);

						fseek(fp,0,SEEK_END);
						*pSize = ftell(fp);
						fseek(fp,0,SEEK_SET);
						pBuffer = new unsigned char[*pSize];
						*pSize = fread(pBuffer,sizeof(unsigned char), *pSize,fp);
						fclose(fp);
					} while (0);
				}
			}
		}
	}
	return pBuffer;
}

#endif

USING_NS_CC;

AsyncSocket mySocket;
//static char left_buf[PacketManager::DEFAULT_BUFFER_LENGTH] = {0};

PacketManager::PacketManager(void):m_sStream(DEFAULT_BUFFER_LENGTH), m_sOctets(DEFAULT_COMPRESS_BUFFER_LENGTH)
{
	//mNeedReConnect = false;
	mIsCompress = true;
	m_pStream[0] = malloc(sizeof(z_stream));
	m_pStream[1] = malloc(sizeof(z_stream));
	memset(m_pStream[0], 0, sizeof(z_stream));
	memset(m_pStream[1], 0, sizeof(z_stream));
	left_len = 0;
	int iRet  = 1;

	//压缩组件
	iRet = deflateInit((z_stream*)m_pStream[0], Z_DEFAULT_COMPRESSION);
	assert(iRet == Z_OK);

	//解压组件
	iRet = inflateInit((z_stream*)m_pStream[1]);
	assert(iRet == Z_OK);

	left_buf = (char*)malloc(DEFAULT_BUFFER_LENGTH);

	// 
	// memset(left_buf, 0, sizeof(DEFAULT_BUFFER_LENGTH)); //what?
	memset(left_buf, 0, DEFAULT_BUFFER_LENGTH);
	// the end
}


PacketManager::~PacketManager(void)
{
	if (left_buf)
	{
		free(left_buf);
		left_buf = 0;
	}
	if (m_pStream[0])
	{
		free(m_pStream[0]);
		m_pStream[0] = 0;
	}

	if (m_pStream[1])
	{
		free(m_pStream[1]);
		m_pStream[1] = 0;
	}

	{
		PACKET_FACTORY_MAP::iterator iter = mFactories.begin();
		while (iter != mFactories.end())
		{
			PacketFactoryBase *pBase = iter->second;
			delete pBase; pBase = 0;
			++iter;
		}
		mFactories.clear();
	}
	{
	}
	{
		std::set<PacketManagerListener*>::iterator iter = mPacketSendListenerList.begin();
		while (iter != mPacketSendListenerList.end())
		{
			PacketManagerListener *pListenner = *iter;
			delete pListenner; pListenner = 0;
			++iter;
		}
		mPacketSendListenerList.clear();
	}

}

void PacketManager::init(const std::string& configFile)
{
	std::string ip = "127.0.0.1";
	int port = 9999;
	if(configFile!="")
	{

		Json::Reader jreader;
		Json::Value root;
		unsigned long filesize;
		unsigned short crc = 0;

#ifndef _UTILITY_USE_
		char* pBuffer = (char*)getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(configFile.c_str()).c_str(),"rt",&filesize,&crc,false);
#else
		char* pBuffer = (char*)getFileData((const char*)configFile.c_str(),"rt",&filesize,&crc,false);
#endif
		if(!pBuffer)
		{
			char msg[256];
			sprintf(msg,"Failed open net config file: %s !!",configFile.c_str());
			cocos2d::CCMessageBox(msg,Language::Get()->getString("@ShowMsgBoxTitle").c_str());
		}
		else
		{
			jreader.parse(pBuffer, filesize, root, false);
			CC_SAFE_DELETE_ARRAY(pBuffer);

			if(root["version"].asInt()<=1)
			{
				ip = root["ip"].asString();
				port = root["port"].asInt();
			}
		}
		CC_SAFE_DELETE_ARRAY(pBuffer);
	}
	ThreadSocket::Get()->disconnect();
	ThreadSocket::Get()->connect(ip.c_str(),port);
}

void PacketManager::init( const std::string& ip, int port )
{
	ThreadSocket::Get()->disconnect();
	ThreadSocket::Get()->connect(ip.c_str(),port);
}

void PacketManager::update( float dt )
{
	//_checkReceivePacket();
	ThreadSocket::Get()->update();
}

void PacketManager::disconnect()
{
	ThreadSocket::Get()->disconnect();
}

void PacketManager::sendPakcet( int opcode, ::google::protobuf::Message* msg, bool needWaiting/*=true*/, int targetOpcode/*=0*/)
{
	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator it;
	for(it = itSet.begin();it!=itSet.end();++it)
	{
		(*it)->onPreSend(opcode,msg,needWaiting);
	}
	std::string debugstr = msg->DebugString();
	std::string outStr;
	GameMaths::replaceStringWithCharacter(debugstr,'\n',' ',outStr);
	CCLOG("send packet! opcode:%d message:%s",opcode,outStr.c_str());
	PacketBase* pack = createPacket(opcode);
	int size;
	void* buffer = pack->PackPacket(size,msg);
	ThreadSocket::PacketData data;
	data.buffer=buffer;
	data.length = size;
	ThreadSocket::Get()->sendPacket(data,opcode);
	delete pack;

	for(it = itSet.begin();it!=itSet.end();++it)
	{
		(*it)->onPostSend(opcode,msg,needWaiting, targetOpcode);
	}
}

void PacketManager::sendPakcet( int opcode, char* buff, int length, bool needWaiting )
{
	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator it;
	for(it = itSet.begin();it!=itSet.end();++it)
	{
		(*it)->onPreSend(opcode,buff,length,needWaiting);
	}

	ThreadSocket::PacketData data;
	if(length == 0)length = strlen(buff);
	std::string str(buff,length);
	void*buffGen = PacketBase::PackPacket(opcode,data.length,str);
	data.buffer = new char[data.length+1];
	memcpy(data.buffer,buffGen,data.length);
	((char*)data.buffer)[data.length]=0;
	CCLOG("send packet! opcode:%d message is in lua",opcode);
	ThreadSocket::Get()->sendPacket(data,opcode);
	delete (char*)buffGen;

	for(it = itSet.begin();it!=itSet.end();++it)
	{
		(*it)->onPostSend(opcode,buff,length,needWaiting);
	}
}

//采用 AP Hash算法
unsigned int  PacketManager::CalcCrc(const unsigned char* pData, unsigned int iSize, unsigned int* pCrc)
{
	unsigned int iCrc = 0;
	if (pCrc)
		iCrc = *pCrc;

	for (unsigned int i = 0; i < iSize; i++) 
	{
		iCrc ^= ((i & 1) == 0) ? ((iCrc << 7) ^ pData[i] ^ (iCrc >> 3)) : (~((iCrc << 11) ^ pData[i] ^ (iCrc >> 5)));
	}

	if (pCrc)
		*pCrc = iCrc;

	return iCrc;
}

void PacketManager::_onReceivedPacket( void* buffer, int len )
{
	//CCLOG("PacketManager::_onReceivedPacket| ReceivedPacket size:%d", len);
	//CCLog("*******start ____ PacketManager::_onReceivedPacket| ReceivedPacket size:%d", len);
	//step.1 先解压缩，再进行后续操作
	HawkOctets octet(buffer,len);
	if (mIsCompress)
	{
		PacketManager::Get()->Uncompress(octet);
	}
	

	
	//static char left_buf[PacketManager::DEFAULT_BUFFER_LENGTH];//move to static cpp
	//static int left_len = 0;

	if(len < 0)
		return;

	char _buff[PacketManager::DEFAULT_BUFFER_LENGTH];
	char* rec = _buff;
	int rec_len = 0;
	if(left_len != 0)
	{
		memcpy( rec, left_buf, left_len);
		rec_len += left_len;
		// 
		//memset(left_buf, 0, sizeof(left_buf));
		memset(left_buf, 0, DEFAULT_BUFFER_LENGTH);
		// the end
		left_len = 0;
	}
	memcpy( rec + rec_len, octet.Begin(), octet.Size());
	rec_len += octet.Size();

	do 
	{
		//if(rec[0] != 0x5d || rec[1] != 0x6b)
		//{
		//	CCLOG("PacketManager::_onReceivedPacket | rec[0] != 0x5d || rec[1] != 0xc3 , disconnect!");
		//	disconnect();
		//	return ;
		//}

		//new game's header is 
		//1 int type, int size, int reserve, int crc

		int size,opcode,reserve;
		unsigned int crc=0;
		//opcode
		memcpy(&opcode,rec,4);
		//size
		memcpy(&size,rec+4,4);
		//reserve
		memcpy(&reserve,rec+8,4);
		//crc
		memcpy(&crc,rec+12,4);

		size = ReverseAuto<int>(size);
		opcode = ReverseAuto<int>(opcode);
		reserve= ReverseAuto<int>(reserve);
		crc = ReverseAuto<unsigned int>(crc);
		int packSize = size + PacketHead;

		//CCLOG("PacketManager::_onReceivedPacket opcode:%d size:%d,rec_len:%d,",opcode,packSize,rec_len);
		//CCLog("PacketManager::_onReceivedPacket opcode:%d size:%d,rec_len:%d,", opcode, packSize, rec_len);
		if(packSize>DEFAULT_BUFFER_LENGTH || rec_len>DEFAULT_BUFFER_LENGTH || packSize<PacketHead)
		{
			//CCLOG("packSize>DEFAULT_BUFFER_LENGTH || rec_len>DEFAULT_BUFFER_LENGTH || packSize<PacketHead || packSize:%d,rec_len:%d,",packSize,rec_len);
			//CCLog("packSize>DEFAULT_BUFFER_LENGTH || rec_len>DEFAULT_BUFFER_LENGTH || packSize<PacketHead || packSize:%d,rec_len:%d,", packSize, rec_len);
			return;
		}
		
		if(rec_len < packSize)
		{
			//CCLOG("ReceivedPacket len:%d < packSize:%d opcode:%d", rec_len, packSize, opcode);
			//CCLog("ReceivedPacket len:%d < packSize:%d opcode:%d", rec_len, packSize, opcode);
			memcpy(left_buf+left_len, rec, rec_len);
			left_len += rec_len;
			break;
		}
		else
		{
			//CCLOG("Do ReceivedPacket packSize:%d opcode:%d", packSize, opcode);
			//CCLog("Do ReceivedPacket packSize:%d opcode:%d", packSize, opcode);
			//step.1 校验Crc码
			unsigned int packCrc = CalcCrc((unsigned char*)(rec+PacketHead),size,NULL);
			//如果不正确，提示并return
			if (packCrc != crc)
			{
				CCLOG("@PacketManager::_onReceivedPacket -- crc is not correspont to the recieved one, return");


				return;
			}

			//step.2 判断是否需要解压缩
			PacketBase* pack = createPacket(opcode);
			//压缩已经做过了。
			int cCompress = reserve;
			if(pack)
			{
				if(pack->UnpackPacket(rec + PacketHead,size,cCompress))
					_boardcastPacketToHandler(pack->getOpcode(), pack->getMessage(), pack->getInfoString());
				else
				{
					char out[128];
					sprintf(out,"Network error!\nFailed to create packet! \nopcode:%d",opcode);
					CCMessageBox(out,"error");
				}
			}
			else
			{
				_boardcastPacketToHandler(opcode, NULL, PacketBase::UnpackPacket(opcode, rec + PacketHead, size,cCompress));
			}
			if(pack)
				delete pack;

			rec += packSize;
			rec_len -= packSize;
		}

	} while (rec_len > 0);

	//CCLog("packet complete****** %d", len);
}

void PacketManager::_checkReceivePacket()
{
//	char rec[DEFAULT_BUFFER_LENGTH];
//	int len = mySocket.onReceive(rec,DEFAULT_BUFFER_LENGTH);
//	_onReceivedPacket(rec,len);
}

PacketBase* PacketManager::createPacket( int opcode )
{
	PACKET_FACTORY_MAP::iterator it = mFactories.find(opcode);
	if(it==mFactories.end())
	{
		CCLOG("Can't find Packet Factory Name! opcode: %d", opcode);
		return 0;
	}
	return it->second->createPacket();
}

bool PacketManager::_registerPacketFactory( int opcode, const std::string& packetName, PacketFactoryBase* fac)
{
	CCAssert(mFactories.find(opcode)==mFactories.end(),"Packet Factory Name REDEFINED!!!");
	mFactories.insert(std::make_pair(opcode,fac));
	mNameToOpcode.insert(std::make_pair(packetName,opcode));
	return true;
}

bool PacketManager::registerPacketHandler( int opcode,PacketHandler* handler)
{
	if(handler == 0)
		return false;
	PACKET_HANDLER_MAP::iterator it = mHandlers.find(opcode);
	if(it == mHandlers.end())
	{
		std::set<PacketHandler*> sec;
		sec.insert(handler);
		mHandlers.insert(std::make_pair(opcode,sec));
	}
	else 
	{
		std::set<PacketHandler*>& handlerset = it->second;
		if(handlerset.find(handler)==handlerset.end())
			handlerset.insert(handler);
	}
	return true;
}


void PacketManager::_boardcastPacketToHandler( int id, const ::google::protobuf::Message* msg, const std::string& msgStr)
{
	if(msg == 0 && msgStr.empty())
		return ;
	
	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator itListener;
	for(itListener = itSet.begin();itListener!=itSet.end();++itListener)
	{
		(*itListener)->onBoardcastPacketToHandler(id,msg,msgStr);
	}

	PACKET_HANDLER_MAP::iterator it = mHandlers.find(id);
	if(it != mHandlers.end())
	{
		std::set<PacketHandler*> handlerset;
		handlerset.insert(it->second.begin(),it->second.end());

		std::set<PacketHandler*>& handlerset_ref = it->second;
		std::set<PacketHandler*>::iterator hanIt = handlerset.begin();
		for( ; hanIt!= handlerset.end(); ++hanIt)
		{
			if(handlerset_ref.find(*hanIt)!=handlerset_ref.end())
			{
				if( (*hanIt)->getHandleType() == PacketHandler::Default_Handler )
				{
					if(msg!=0)
						(*hanIt)->onReceivePacket(id,msg);
				}
				else if(!msgStr.empty() && (*hanIt)->getHandleType() == PacketHandler::Scripty_Handler)
					(*hanIt)->onReceivePacket(id,msgStr);
				else
					(*hanIt)->onReceivePacket(id,msg);
			}
		}
	}
}

void PacketManager::_boardcastConnectionFailed(std::string ip, int port)
{

	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator itListener;
	for(itListener = itSet.begin();itListener!=itSet.end();++itListener)
	{
		(*itListener)->onBoardcastConnectionFailed(ip,port);
	}

	PACKET_HANDLER_MAP::iterator it = mHandlers.begin();
	for(;it != mHandlers.end();++it)
	{
		std::set<PacketHandler*> handlerset;
		handlerset.insert(it->second.begin(),it->second.end());

		std::set<PacketHandler*>& handlerset_ref = it->second;
		std::set<PacketHandler*>::iterator hanIt = handlerset.begin();
		for( ; hanIt!= handlerset.end(); ++hanIt)
		{
			(*hanIt)->onConnectFailed(ip,port);
		}
	}
	CCLOG("ConnectionFailed! ip:%s port:%d",ip.c_str(),port);
}

void PacketManager::_boardcastSendFailed( int opcode)
{
	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator itListener;
	for(itListener = itSet.begin();itListener!=itSet.end();++itListener)
	{
		(*itListener)->onBoardcastSendFailed(opcode);
	}

	PACKET_HANDLER_MAP::iterator it = mHandlers.begin();
	for(;it != mHandlers.end();++it)
	{
		//此处onSendPacketFailed 是全量opcode通知, why it->first==opcode? dylan
		std::set<PacketHandler*> handlerset;
		handlerset.insert(it->second.begin(),it->second.end());

		std::set<PacketHandler*>& handlerset_ref = it->second;
		std::set<PacketHandler*>::iterator hanIt = handlerset.begin();
		for( ; hanIt!= handlerset.end(); ++hanIt)
		{
			(*hanIt)->onSendPacketFailed(opcode);
		}
	}
	CCLOG("PacketManager::_boardcastSendFailed | SendFailed! opcode:%d",opcode);
}

void PacketManager::_boardcastReceiveFailed()
{

	//memset(left_buf, 0, sizeof(left_buf));
	memset(left_buf, 0, DEFAULT_BUFFER_LENGTH);
	// the end

	left_len = 0;
	memset(m_pStream[0], 0, sizeof(z_stream));
	memset(m_pStream[1], 0, sizeof(z_stream));

	int iRet  = 1;

	//压缩组件
	iRet = deflateInit((z_stream*)m_pStream[0], Z_DEFAULT_COMPRESSION);
	assert(iRet == Z_OK);

	//解压组件
	iRet = inflateInit((z_stream*)m_pStream[1]);
	assert(iRet == Z_OK);

	//
	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator itListener;
	for(itListener = itSet.begin();itListener!=itSet.end();++itListener)
	{
		(*itListener)->onBoardcastReceiveFailed();
	}

	PACKET_HANDLER_MAP::iterator it = mHandlers.begin();
	for(;it != mHandlers.end();++it)
	{
		std::set<PacketHandler*> handlerset;
		handlerset.insert(it->second.begin(),it->second.end());

		std::set<PacketHandler*>& handlerset_ref = it->second;
		std::set<PacketHandler*>::iterator hanIt = handlerset.begin();
		for( ; hanIt!= handlerset.end(); ++hanIt)
		{
			(*hanIt)->onReceivePacketFailed();
		}
	}
	CCLOG("PacketManager::_boardcastReceiveFailed() ReceiveFailed!");
}

void PacketManager::_boardcastReceiveTimeout( int opcode)
{
	memset(left_buf, 0, DEFAULT_BUFFER_LENGTH);
	// the end

	left_len = 0;
	memset(m_pStream[0], 0, sizeof(z_stream));
	memset(m_pStream[1], 0, sizeof(z_stream));

	int iRet = 1;

	//压缩组件
	iRet = deflateInit((z_stream*)m_pStream[0], Z_DEFAULT_COMPRESSION);
	assert(iRet == Z_OK);

	//解压组件
	iRet = inflateInit((z_stream*)m_pStream[1]);
	assert(iRet == Z_OK);

	CCLOG("PacketManager::_boardcastReceiveTimeout | ReceiveTimeout! opcode:%d",opcode);

	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator itListener;
	for(itListener = itSet.begin();itListener!=itSet.end();++itListener)
	{
		(*itListener)->onBoardcastReceiveTimeout(opcode);
	}

	PACKET_HANDLER_MAP::iterator it = mHandlers.begin();
	for(;it != mHandlers.end();++it)
	{
		std::set<PacketHandler*> handlerset;
		handlerset.insert(it->second.begin(),it->second.end());

		std::set<PacketHandler*>& handlerset_ref = it->second;
		std::set<PacketHandler*>::iterator hanIt = handlerset.begin();
		for( ; hanIt!= handlerset.end(); ++hanIt)
		{
			(*hanIt)->onTimeout(opcode);
		}
	}
}

void PacketManager::_boardcastPacketError( int opcode,const std::string &errmsg)
{

	std::set<PacketManagerListener*> itSet;
	itSet.insert(mPacketSendListenerList.begin(),mPacketSendListenerList.end());
	std::set<PacketManagerListener*>::iterator itListener;
	for(itListener = itSet.begin();itListener!=itSet.end();++itListener)
	{
		(*itListener)->onBoardcastPacketError(opcode,errmsg);
	}

	PACKET_HANDLER_MAP::iterator it = mHandlers.begin();
	for(;it != mHandlers.end();++it)
	{
		std::set<PacketHandler*> handlerset;
		handlerset.insert(it->second.begin(),it->second.end());

		std::set<PacketHandler*>& handlerset_ref = it->second;
		std::set<PacketHandler*>::iterator hanIt = handlerset.begin();
		for( ; hanIt!= handlerset.end(); ++hanIt)
		{
			(*hanIt)->onPacketError(opcode);
		}
	}

// #ifndef _UTILITY_USE_
// 
//	MSG_BOX_LAN("@ReceivedTimeout");
// #endif
}

void PacketManager::removePacketHandler(int opcode, PacketHandler* messagehandler)
{
	if(messagehandler == 0)
		return;

	PACKET_HANDLER_MAP::iterator it = mHandlers.find(opcode);
	if(it != mHandlers.end()){
		std::set<PacketHandler*>& handlerset = it->second;
		if(handlerset.find(messagehandler) != handlerset.end())
			handlerset.erase(messagehandler);
	}
}

void PacketManager::removePacketHandler(PacketHandler* messagehandler)
{
	if(messagehandler == 0)
		return;

	PACKET_HANDLER_MAP::iterator it = mHandlers.begin();
	for(;it!=mHandlers.end();++it)
	{
		std::set<PacketHandler*>& handlerset = it->second;
		if(handlerset.find(messagehandler)!= handlerset.end())
		{
			handlerset.erase(messagehandler);
		}
	}
}

int PacketManager::nameToOpcode( const std::string& name )
{
	int ret = -1;
	NAME_TO_OPCODE_MAP::iterator it = mNameToOpcode.find(name);
	if(it!=mNameToOpcode.end())
		ret = it->second;
	return ret;
}

bool PacketManager::_buildDefaultMessage( int opcode, ::google::protobuf::Message* msg)
{
	mDefaultMessageMap.insert(std::make_pair(opcode,msg));
	return true;
}

::google::protobuf::Message* PacketManager::_getDefaultMessage( int opcode )
{
	DEFAULT_MESSAGE_MAP::iterator it = mDefaultMessageMap.find(opcode);
	if(it!=mDefaultMessageMap.end())
	{
		return it->second;
	}
	return 0;
}

PacketManager* PacketManager::getInstance()
{
	return PacketManager::Get();
}

bool PacketManager::registerPacketSendListener( PacketManagerListener* listener)
{
	if(mPacketSendListenerList.find(listener) == mPacketSendListenerList.end())
		mPacketSendListenerList.insert(listener);
	return true;
}

void PacketManager::removePacketSendListener( PacketManagerListener* listener)
{
	if(mPacketSendListenerList.find(listener)!=mPacketSendListenerList.end())
		mPacketSendListenerList.erase(listener);
}


void PacketManager::reconnect()
{
	ThreadSocket::Get()->reconnect();
}

bool PacketManager::Compress(HawkOctets& xOctets)
{
	m_sOctets.Clear();		
	m_sStream.Clear();

	z_stream* p = (z_stream*)m_pStream[0];
	p->next_in  = (Bytef*)xOctets.Begin();  
	p->avail_in = xOctets.Size();

	while (p->avail_in > 0)
	{
		p->next_out  = (Bytef*)m_sOctets.Begin();  
		p->avail_out = m_sOctets.Capacity();  

		if (deflate(p, Z_SYNC_FLUSH) != Z_OK)
			return false;

		int iSize = m_sOctets.Capacity() - p->avail_out;
		m_sOctets.Resize(iSize);

		if (p->avail_in == 0)
		{
			if (!m_sStream.Size())
			{
				xOctets.Replace(m_sOctets.Begin(), m_sOctets.Size());
			}
			else
			{
				xOctets.Replace(m_sStream.Begin(), m_sStream.Size());
				xOctets.Append(m_sOctets.Begin(),  m_sOctets.Size());
			}
			return true;
		}
		else
		{
			m_sStream.Insert(m_sStream.End(),m_sOctets.Begin(),m_sOctets.Size());
		}
	}
	return false;
}


bool PacketManager::Uncompress(HawkOctets& xOctets)
{
	m_sOctets.Clear();		
	m_sStream.Clear();

	z_stream* p = (z_stream*)m_pStream[1];
	p->next_in  = (Bytef*)xOctets.Begin();  
	p->avail_in = xOctets.Size(); 				

	while (p->avail_in > 0)
	{
		p->next_out  = (Bytef*)m_sOctets.Begin();  
		p->avail_out = m_sOctets.Capacity();  

		if (inflate(p, Z_SYNC_FLUSH) != Z_OK)
			return false;

		int iSize = m_sOctets.Capacity() - p->avail_out;
		m_sOctets.Resize(iSize);

		if (p->avail_in == 0)
		{
			if (!m_sStream.Size())
			{
				xOctets.Replace(m_sOctets.Begin(), m_sOctets.Size());
			}
			else
			{
				xOctets.Replace(m_sStream.Begin(), m_sStream.Size());
				xOctets.Append(m_sOctets.Begin(),  m_sOctets.Size());
			}
			return true;
		}
		else
		{
			m_sStream.Insert(m_sStream.End(),m_sOctets.Begin(),m_sOctets.Size());
		}
	}
	return false;
	
}


#ifndef _UTILITY_USE_
#define RUN_SCRIPT_FUN(funname) \
	if(mScriptFunHandler) \
{ \
	cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine(); \
	validateFunctionHandler();\
	pEngine->executeEvent(mScriptFunHandler,funname,this,"PacketScriptHandler"); \
}
#else
#define RUN_SCRIPT_FUN(funname) 
#endif
PacketScriptHandler::PacketScriptHandler( int opcode, int nHandler ) : mRecOpcode(opcode)
	, mScriptFunHandler(nHandler)
{
	PacketManager::Get()->registerPacketHandler(mRecOpcode,this);
}

PacketScriptHandler::~PacketScriptHandler()
{
	PacketManager::Get()->removePacketHandler(mRecOpcode,this);

	if (mScriptFunHandler)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(mScriptFunHandler);
		mScriptFunHandler = 0;
	}
}

void PacketScriptHandler::validateFunctionHandler()
{
	cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
	bool validateFlag = pEngine->checkHandlerValidate(mScriptFunHandler); 
	if (validateFlag == false)
	{
#ifdef _DEBUG
		char msg[256];
		sprintf(msg,"@PacketScriptHandler::load ,script function handler %d not fount, recieved opcode is %d, register again",mScriptFunHandler,mRecOpcode);
		cocos2d::CCMessageBox(msg,Language::Get()->getString("@ShowMsgBoxTitle").c_str());
#endif
		CCLOG("@PacketScriptHandler::load ,script function handler %d not fount, recieved opcode is %d, register again",mScriptFunHandler,mRecOpcode);
		//If handler is not validate, require the PackageLogicForLua and register the handler again.
		pEngine->executeString("require \"PackageLogicForLua\"");
		std::string funname = "validateAndRegisterAllHandler";
		CCScriptEngineManager::sharedManager()->getScriptEngine()->executeGlobalFunctionByName(funname.c_str(),NULL,"PacketScriptHandler");
	}
}


void PacketScriptHandler::registerFunctionHandler( int nHandler)
{
	cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
	bool validateFlag = pEngine->checkHandlerValidate(mScriptFunHandler); 
	//If handler is validate, don't register again, if not, remove old one and assign a new one. 
	if (validateFlag == true)
	{
		return;
	}
	if (mScriptFunHandler)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(mScriptFunHandler);
		mScriptFunHandler = 0;
	}
	mScriptFunHandler = nHandler;
}

void PacketScriptHandler::onReceivePacket( const int opcode, const ::google::protobuf::Message* packet )
{
	std::string str;
	packet->SerializeToString(&str);

	mPktBuffer = str;
	mRecOpcode = opcode;

	RUN_SCRIPT_FUN("luaReceivePacket");
}

void PacketScriptHandler::onReceivePacket( const int opcode, const std::string& str )
{
	mPktBuffer = str;
	mRecOpcode = opcode;

	RUN_SCRIPT_FUN("luaReceivePacket");
}

void PacketScriptHandler::onSendPacketFailed( const int opcode )
{
	RUN_SCRIPT_FUN("luaSendPacketFailed");
}

void PacketScriptHandler::onConnectFailed( std::string ip, int port )
{
	RUN_SCRIPT_FUN("luaConnectFailed");
}

void PacketScriptHandler::onTimeout( const int opcode )
{
	RUN_SCRIPT_FUN("luaTimeout");
}

void PacketScriptHandler::onPacketError( const int opcode )
{
	RUN_SCRIPT_FUN("luaPacketError");
}


