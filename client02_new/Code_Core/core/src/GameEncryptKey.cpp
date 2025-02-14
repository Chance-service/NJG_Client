
#include "stdafx.h"

#include <cstdio>
#include "rc4.h"
#include "GameEncryptKey.h"
#ifdef _WINDOWS
#include <direct.h>
#include "zlib/zlib.h"
#else
#include<sys/types.h>
#include<sys/stat.h>
//#include<sys/statfs.h>
#include "zlib.h"
#endif

#include <string>
#include "cocos2d.h"
#include "AES.h"


bool decBuffer(unsigned long inSize , unsigned char* inBuffer, unsigned long& outSize, unsigned char*& outBuffer)
{

	unsigned char* decbuffer = new unsigned char[inBuffer[0]*blocksize];
	outSize = inBuffer[0]*blocksize;
	if(decbuffer)
	{
		int keyflag=0;
		int keylength = strlen((char *) gamekey);
		for(int i=0;i<inSize;++i)
		{
			*(inBuffer+i)=(*(inBuffer+i)^gamekey[keyflag]);
			keyflag = (keyflag+1)%keylength;
		}
		int ret = uncompress(decbuffer,&outSize,inBuffer+1,inSize-1);
		outBuffer = new unsigned char[outSize];
		//cocos2d::CCLog("decBuffer ret : %d", ret);
		//cocos2d::CCLog("decBuffer inSize : %ld", inSize);
		//cocos2d::CCLog("decBuffer outSize : %ld", outSize);
		//cocos2d::CCLog("decBuffer inBuffer : %s", inBuffer);
		//cocos2d::CCLog("decBuffer outBuffer : %s", outBuffer);
		if(ret == Z_OK && outBuffer!=0)
		{
			memcpy(outBuffer,decbuffer,outSize);
			delete[] decbuffer;
			return true;
		}

		delete[] decbuffer;
	}
	return false;
}


bool encBuffer(unsigned long inSize , unsigned char* inBuffer, unsigned long& outSize, unsigned char*& outBuffer)
{
	outBuffer = new unsigned char[inSize+1];
	outSize = inSize;
	int ret = compress(outBuffer+1,&outSize,inBuffer,inSize);

	if(ret == Z_OK && outBuffer!=0)
	{
		int keyflag=0;
		int keylength = strlen((char *)(gamekey));
		for(int i=0;i<inSize;++i)
		{
			*(outBuffer+i)=(*(outBuffer+i)^gamekey[keyflag]);
			keyflag = (keyflag+1)%keylength;
		}
		outBuffer[0]=inSize/blocksize + 1;//record number of blocks on the first byte
		outSize++;
		return true;
	}
	return false;
}

unsigned char* rc4DocumentBuffer(unsigned long inSize,unsigned char* inBuffer,unsigned long* outSize)
{
	unsigned long inBufferSize = inSize;
	unsigned char* outBuffer = NULL;
	AVRC4 rc4_key;
	av_rc4_init(&rc4_key,gamekey,strlen((char*)gamekey)*8);

	outBuffer = new unsigned char[DATA_BUFFER_SIZE];

	unsigned char* decOut = new unsigned char[inBufferSize - MARK_SIZE];
	av_rc4_crypt(&rc4_key,decOut,inBuffer + MARK_SIZE,inBufferSize - MARK_SIZE);
	unsigned long dataBufferSize = DATA_BUFFER_SIZE;
	int ret = uncompress(outBuffer,&dataBufferSize,decOut,inBufferSize - MARK_SIZE);
	if (Z_OK == ret)
	{
		*outSize = dataBufferSize;
		delete[] inBuffer;
		delete[] decOut;
		return outBuffer;
	}
	else
	{
		delete[] inBuffer;
		delete[] decOut;
		delete[] outBuffer;
		return NULL;
	}
}

unsigned char*  rc4TextureBuffer(unsigned long inSize,unsigned char* inBuffer,unsigned long* outSize)
{
	unsigned char* outBuffer = 0;
	unsigned long inBufferSize = inSize;
	AVRC4 rc4_key;
	memset(&rc4_key,0,sizeof(AVRC4));
	av_rc4_init(&rc4_key,gamekey,strlen((char*)gamekey)*8);

	outBuffer = new unsigned char[inBufferSize - MARK_SIZE];

	int encodeBufferSize = 0;
	int encodeSize = 0x80;
	((inBufferSize - MARK_SIZE) > encodeSize) ? encodeBufferSize = encodeSize : encodeBufferSize = inBufferSize - MARK_SIZE;
	av_rc4_crypt(&rc4_key,outBuffer,inBuffer + MARK_SIZE,encodeBufferSize);
	if (encodeBufferSize < inBufferSize - MARK_SIZE)
	{
		memcpy(outBuffer + encodeSize,inBuffer + encodeSize + MARK_SIZE,inBufferSize - encodeSize - MARK_SIZE);
	}
	*outSize = inBufferSize - MARK_SIZE;
	delete[] inBuffer;
	return outBuffer;
}

/************************************************************************/
/* ����                                                                 */
/************************************************************************/
unsigned char* getEncodeBuffer( unsigned long* inSize,unsigned char* buffer,const char * fileName,const char* pszMode)
{
	std::string fileNameStr=fileName;
	unsigned long outBufferSize = 0;
	unsigned char* outBuffer = 0;
	if(fileNameStr.find(".el")!=std::string::npos)
	{//lua���ܷ�ʽ���е���Ϊrc4,�����ϼ����㷨����ʱ������
		decBuffer(*inSize,buffer,outBufferSize,outBuffer);
		delete []buffer;
		*inSize = outBufferSize;
		return outBuffer;
	}
	else
	{
		if(buffer && buffer[0]==0xef && buffer[1]==0xfe)
		{//�����Ǽ����ļ�
			if(strcmp(pszMode,"rb")!=0 )
			{//���ǲ��Ƕ������ļ���ȡ�ķ�ʽ 
				delete[] buffer;
				buffer = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(fileName,"rb",inSize,false);//getFileData���ٴε���getEncodeBuffer����Ҫreturn
				return buffer;
			}
			
			if(buffer[2] == 0x80)
			{
				buffer = rc4TextureBuffer(*inSize,buffer,inSize);			
				return buffer;
			}
			else if(buffer[2]==0xff)
			{
				buffer = rc4DocumentBuffer(*inSize,buffer,inSize);
				return buffer;
			}
			else
			{
				if(decBuffer(*inSize-2,buffer+2,outBufferSize,outBuffer))
				{
					delete []buffer;
					*inSize = outBufferSize;
					return outBuffer;
				}
			}

			delete []buffer;
			buffer = NULL;
			return buffer;
		}
	}
	return buffer;
}


