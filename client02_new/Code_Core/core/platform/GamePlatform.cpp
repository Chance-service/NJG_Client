
#include "stdafx.h"

#include "GamePlatform.h"
#include <cstdio>
#include "rc4.h"
#ifdef _WINDOWS
#include <direct.h>
#include "zlib/zlib.h"
#else
#include<sys/types.h>
#include<sys/stat.h>
#include<sys/statfs.h>
//#include<fcntl.h>
//#include <unistd.h>
#include "zlib.h"
#ifdef ANDROID

//
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include "jni.h"
#include "unistd.h"
#include <android/log.h>
//
#define  LOG_TAG    "libOS.cpp"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)

#endif

#endif
#include "GameMaths.h"

#include <string>
#include "cocos2d.h"
#include "AES.h"

FILE *getFIlE(const std::string& fileInPath, const char* mode)
{
	FILE* fp = fopen(fileInPath.c_str(), mode); //
	int directoryDepth = 50;

	int pathstart = 0;
	int totalLength = fileInPath.length();
	while(!fp && --directoryDepth>0 && pathstart!=std::string::npos && pathstart<totalLength)
	{
		int pathend = fileInPath.find_first_of("\\/",pathstart);
		pathstart = pathend+1;
		if(pathend!=std::string::npos)
		{
			std::string subFilename = fileInPath.substr(0,pathend);
#ifdef _WINDOWS
			mkdir(subFilename.c_str());
#else
			mkdir(subFilename.c_str(), S_IRWXU);
#endif
		}
		fp = fopen(fileInPath.c_str(), mode); 
	}

	return fp;
}

void saveFileInPath( const std::string& fileInPath, const char* mode, const unsigned char* data, unsigned long size, bool encrypt )
{
	FILE* fp = fopen(fileInPath.c_str(), "wb"); //
	int directoryDepth = 50;

	int pathstart = 0;
	int totalLength = fileInPath.length();
	while(!fp && --directoryDepth>0 && pathstart!=std::string::npos && pathstart<totalLength)
	{
		int pathend = fileInPath.find_first_of("\\/",pathstart);
		pathstart = pathend+1;
		if(pathend!=std::string::npos)
		{
			std::string subFilename = fileInPath.substr(0,pathend);
#ifdef _WINDOWS
			mkdir(subFilename.c_str());
#else
			mkdir(subFilename.c_str(), S_IRWXU);
#endif
		}
		fp = fopen(fileInPath.c_str(), mode); 
	}
	if (encrypt)
	{
		unsigned char head[2];
		head[0] = 0xef;
		head[1] = 0xfe;

		fwrite(head, 1, 2, fp);
	}
	size_t return_size = fwrite(data, 1,size, fp);  
	fclose(fp);
}

unsigned char* getFileData( const char* pszFileName, const char* pszMode, unsigned long * pSize ,unsigned short* crc,bool isShowBox)
{
	unsigned char* buffer = cocos2d::CCFileUtils::sharedFileUtils()->getFileData(pszFileName,pszMode,pSize,isShowBox,crc);
	return buffer;
}

std::string getFileDataForLua(const char* pszFileName)
{
	unsigned long pSize = 0;
	unsigned char* buffer = getFileData(pszFileName, "rb", &pSize);
	char* newData = new char[pSize + 1];
	memcpy(newData, buffer, pSize);
	newData[pSize] = 0;
	std::string dataStr(newData);
	delete[] newData;
	return dataStr;
}

void game_rmdir(const char* path)
{
#ifdef _WINDOWS
    std::string removepath(path);
	if(removepath.find_last_of("\\/")+1 == removepath.length())
		removepath = removepath.substr(0,removepath.find_last_of("\\/"));
	SHFILEOPSTRUCTA FileOp;
	FileOp.fFlags = FOF_NOCONFIRMATION;
	FileOp.hNameMappings = NULL;
	FileOp.hwnd = NULL;
	FileOp.lpszProgressTitle = NULL;
	FileOp.pFrom = removepath.c_str();
	FileOp.pTo = NULL;
	FileOp.wFunc = FO_DELETE;
	SHFileOperationA(&FileOp);
#else
    int err = rmdir(path);
#endif
    
}

long long game_getFreeSpace()
{
#ifdef _WINDOWS
    return -1;
#else
    long long freespace = 0;
	struct statfs disk_statfs;
	long long totalspace = 0;
	float freeSpacePercent = 0 ;
	if( statfs(getAppExternalStoragePath(), &disk_statfs) >= 0 )
	{
		freespace = (((long long)disk_statfs.f_bsize  * (long long)disk_statfs.f_bfree));///(long long)1024	//Kb
		totalspace = (((long long)disk_statfs.f_bsize * (long long)disk_statfs.f_blocks) );///(long long)1024
	}
	//freeSpacePercent = ((float)freespace/(float)totalspace)*100 ;
	return freespace;//bytes
#endif
}

