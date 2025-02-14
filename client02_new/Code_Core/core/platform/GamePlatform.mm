#include "GamePlatform.h"
#include <cstdio>
#include <sys/stat.h>
#include <string>
#include "cocos2d.h"
#include "AES.h"
#include "GameMaths.h"
#include <algorithm>
#include "zlib.h"

#define DIR_MODE 0777


FILE *getFIlE(const std::string& fileInPath, const char* mode)
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
            mkdir(subFilename.c_str(),DIR_MODE);
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
			mkdir(subFilename.c_str(),DIR_MODE);
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
	fwrite(data, 1,size, fp);  
	fclose(fp);
}

unsigned char* getFileData( const char* pszFileName, const char* pszMode, unsigned long * pSize ,unsigned short* crc, bool isShowBox)
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
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* nPath = [NSString stringWithUTF8String:path];
    [fileManager removeItemAtPath:nPath error:nil];
}

long long game_getFreeSpace()
{
    
    long long totalSpace = -1;
    long long totalFreeSpace = -1;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes longLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes longLongValue];
    }
    
    return totalFreeSpace;
}
