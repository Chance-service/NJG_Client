
#include "stdafx.h"

#include "PacketBase.h"
#include "GameMaths.h"
#include <string>
#include <google/protobuf/message.h>
#include "cocos2d.h"
#include "support/zip_support/unzip.h"
#include "support/zip_support/ZipUtils.h"
#include "PacketManager.h"

static unsigned short g_PacketIndex = 0;

PacketBase::PacketBase( ::google::protobuf::Message* _message, int opcode)
	:mProtoMessage(_message)
	,mOpcode(opcode)
{

}

PacketBase::~PacketBase( void )
{
	if(mProtoMessage)
		delete mProtoMessage;
}

#define BUFFER_INC_FACTOR (2)
int PacketBase::InflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int *outLength, unsigned int outLenghtHint)
{
	/* ret value */
	int err = Z_OK;

	int bufferSize = outLenghtHint;
	*out = new unsigned char[bufferSize];

	z_stream d_stream; /* decompression stream */
	d_stream.zalloc = (alloc_func)0;
	d_stream.zfree = (free_func)0;
	d_stream.opaque = (voidpf)0;

	d_stream.next_in = in;
	d_stream.avail_in = inLength;
	d_stream.next_out = *out;
	d_stream.avail_out = bufferSize;

	/* window size to hold 256k */
	if ((err = inflateInit2(&d_stream, 15 + 32)) != Z_OK)
		return err;

	for (;;)
	{
		err = inflate(&d_stream, Z_NO_FLUSH);

		if (err == Z_STREAM_END)
		{
			break;
		}

		switch (err)
		{
		case Z_NEED_DICT:
			err = Z_DATA_ERROR;
		case Z_DATA_ERROR:
		case Z_MEM_ERROR:
			inflateEnd(&d_stream);
			return err;
		}

		// not enough memory ?
		if (err != Z_STREAM_END)
		{
			//out buffer不能直接删除 得备份下前面解压的部分,拷贝到新的缓存里，然后继续解压
			unsigned char *tempbuffer = new unsigned char[bufferSize];
			memcpy(tempbuffer, *out, bufferSize);

			delete[] * out;

			*out = new unsigned char[bufferSize * BUFFER_INC_FACTOR];

			memcpy(*out, tempbuffer, bufferSize);
			delete[] tempbuffer;

			/* not enough memory, ouch */
			if (!*out)
			{
				CCLOG("cocos2d: ZipUtils: realloc failed");
				inflateEnd(&d_stream);
				return Z_MEM_ERROR;
			}

			d_stream.next_out = *out + bufferSize;
			d_stream.avail_out = bufferSize;
			bufferSize *= BUFFER_INC_FACTOR;
		}
	}

	*outLength = bufferSize - d_stream.avail_out;
	err = inflateEnd(&d_stream);
	return err;
}

int PacketBase::InflateMemoryWithHint(unsigned char *in, unsigned int inLength, unsigned char **out, unsigned int outLengthHint)
{
	unsigned int outLength = 0;
	int err = InflateMemoryWithHint(in, inLength, out, &outLength, outLengthHint);

	if (err != Z_OK || *out == NULL) {
		if (err == Z_MEM_ERROR)
		{
			CCLOG("cocos2d: ZipUtils: Out of memory while decompressing map data!");
		} else
			if (err == Z_VERSION_ERROR)
			{
				CCLOG("cocos2d: ZipUtils: Incompatible zlib version!");
			} else
				if (err == Z_DATA_ERROR)
				{
					CCLOG("cocos2d: ZipUtils: Incorrect zlib compressed data!");
				}
				else
				{
					CCLOG("cocos2d: ZipUtils: Unknown error while decompressing map data!");
				}

				delete[] *out;
				*out = NULL;
				outLength = 0;
	}

	return outLength;
}



#define DEFAULT_HINT_BUFFER_LENGTH 131070 //64k
bool PacketBase::UnpackPacket( void* buffer , int _length, int cCompress )
{
	if(!mProtoMessage)
		return false;
	try
	{

		char* pBuf = (char*)buffer;
		//unsigned char* pBuff = (unsigned char*)buffer;
		//encoding
		if (cCompress == 1)
		{
			unsigned int sizeHint = _length;
			unsigned char *deflated;
			int outLength = InflateMemoryWithHint((unsigned char*)(pBuf), (unsigned int)_length, &deflated, DEFAULT_HINT_BUFFER_LENGTH);
			if (deflated){
				mInfoString.assign((char*)deflated,outLength);
				CC_SAFE_DELETE_ARRAY(deflated);
			}else{
				CCLOG("zlib compress error");
			}
		}else{
			mInfoString.assign(pBuf,_length);
		}
		
		mProtoMessage->ParseFromString(mInfoString);
		std::string debugstr = mProtoMessage->DebugString();
		std::string outStr;
		GameMaths::replaceStringWithCharacter(debugstr,'\n',' ',outStr);

		size_t allLength = outStr.length();
		if(allLength>=cocos2d::kMaxLogLen + 1)
		{
			size_t stp = 0;
			CCLOG("received packet! opcode:%d message:",mOpcode);
			while (stp<allLength)
			{
				size_t length = (((allLength-stp)>cocos2d::kMaxLogLen)?cocos2d::kMaxLogLen:(allLength-stp));
				std::string out1 = outStr.substr(stp,cocos2d::kMaxLogLen);
				CCLOG(out1.c_str());
				stp+=cocos2d::kMaxLogLen;
			}
		}
		else
		{
			CCLOG("received packet! opcode:%d message:%s",mOpcode,outStr.c_str());
		}
		return true;
	}
	catch (...)
	{
		return false;
	}
	
}

std::string PacketBase::UnpackPacket(int opcode, void *buffer, int _length ,int cCompress)
{
	char* pBuf = (char*)buffer;
	unsigned char* pBuff = (unsigned char*)buffer;
	std::string str;
	if (cCompress == 1)
	{
		unsigned int sizeHint = _length;
		unsigned char *deflated;
		int outLength = InflateMemoryWithHint((unsigned char*)(pBuf), (unsigned int)_length, &deflated, DEFAULT_HINT_BUFFER_LENGTH);
		if (deflated)
		{
			str.assign((char*)deflated,outLength);
			CC_SAFE_DELETE_ARRAY(deflated);
		}else{
			CCLOG("zlib compress error");
		}
		

	}else{
		str.assign(pBuf,_length);
	}

	//std::string str(pBuf,_length);
	CCLOG("received packet! opcode:%d message:%s",opcode,str.c_str());
	return str;
}

void* PacketBase::PackPacket( int &_length, const ::google::protobuf::Message *msg )
{
	if(!msg)
		msg = mProtoMessage;

	if(!msg)
		return 0;

	std::string str;
	msg->SerializeToString(&str);
	
	return PackPacket(mOpcode,_length,str);
}

#define  DEFAULT_SEND_PACKET_SIZE 4096

void* PacketBase::PackPacket(int _opcode, int &_length,const std::string& str)
{
	unsigned char* pBuff = (unsigned char*)str.c_str();
	//encoding
	int xorMask = rand() % 91 + 9;
	for(int i=0;i<str.length();++i)
	{
		pBuff[i]=pBuff[i]^xorMask;
	}

	char* sendstr = new char[DEFAULT_SEND_PACKET_SIZE];//
	memset(sendstr,0,DEFAULT_SEND_PACKET_SIZE);

	//char head[2] = {0x5d,0x6b};

	int opcode = ReverseAuto<int>(_opcode);
	int length = 0;
	length = ReverseAuto<int>(str.length());
	//服务器解析时，只取后八位 int data = (reserve >> 0) & 0xFF;
	int rand16 = (++g_PacketIndex)<<16;
	int rand8 = (rand() %200 + 9 )<<8;
	int reserve = (rand16) | (rand8)| xorMask;

	reserve = ReverseAuto<int>(reserve);
	//int crc =0;
	unsigned int crc = PacketManager::Get()->CalcCrc((const unsigned char*)str.c_str(),str.length(),NULL);
	crc = ReverseAuto<unsigned int>(crc);
	size_t offset = 0;
	memcpy(sendstr+offset,&opcode,4);
	offset+=4;
	memcpy(sendstr+offset,&length,4);
	offset+=4;
	memcpy(sendstr+offset,&reserve,4);
	offset+=4;
	memcpy(sendstr+offset,&crc,4);
	offset+=4;
	memcpy(sendstr+offset,str.c_str(),str.length());
	offset+=str.length();
	_length = offset;

	if (PacketManager::Get()->getCompress())
	{
		HawkOctets octets(sendstr,_length);
		PacketManager::Get()->Compress(octets);
		_length = octets.Size();
		memset(sendstr,0,DEFAULT_SEND_PACKET_SIZE);
		memcpy(sendstr,octets.Begin(),octets.Size());
	}

	return sendstr;
}

int PacketBase::getOpcode()
{
	return mOpcode;
}

const ::google::protobuf::Message * PacketBase::getMessage()
{
	return mProtoMessage;
}

std::string PacketBase::getInfoString()
{
	return mInfoString;
}
