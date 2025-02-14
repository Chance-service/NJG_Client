#pragma once

#include <string>
const unsigned char gamekey[] = "quantaninjagirl24";

const int blocksize = 1024*8;
const int DATA_BUFFER_SIZE = 1024*1024;
const int MARK_SIZE = 3;

bool encBuffer(unsigned long inSize , unsigned char* inBuffer, unsigned long& outSize, unsigned char*& outBuffer);

bool decBuffer(unsigned long inSize , unsigned char* inBuffer, unsigned long& outSize, unsigned char*& outBuffer);

unsigned char* rc4DocumentBuffer(unsigned long inSize,unsigned char* inBuffer,unsigned long* outSize);

unsigned char* rc4TextureBuffer(unsigned long inSize,unsigned char* inBuffer,unsigned long* outSize);

unsigned char* getEncodeBuffer( unsigned long* inSize,unsigned char* buffer,const char * fileName,const char* pszMode);