#include "AssetsManagerEx.h"
#include "cocos2d.h"
#include "support/zip_support/unzip.h"
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
#include "sys/stat.h"
#include "sys/types.h"
#include "errno.h"
#endif
using namespace cocos2d;
using namespace std;
#define BUFFER_SIZE    8192
#define MAX_FILENAME   512

AssetsManagerEx::AssetsManagerEx()

{
    
}

AssetsManagerEx::~AssetsManagerEx()
{
   
}

bool AssetsManagerEx::uncompress(const std::string& file,const std::string& stroge)
{
    // Open the zip file
    string outFileName = file;
    unzFile zipfile = unzOpen(outFileName.c_str());
    if (! zipfile)
    {
        CCLOG("can not open downloaded zip file %s", outFileName.c_str());
        return false;
    }
    
    // Get info about the zip file
    unz_global_info global_info;
    if (unzGetGlobalInfo(zipfile, &global_info) != UNZ_OK)
    {
        CCLOG("can not read file global info of %s", outFileName.c_str());
        unzClose(zipfile);
        return false;
    }
    
    // Buffer to hold data read from the zip file
    char readBuffer[BUFFER_SIZE];
    
    CCLOG("start uncompressing");
    
    // Loop to extract all files.
    uLong i;
	uLong sum = global_info.number_entry;
    for (i = 0; i < global_info.number_entry; ++i)
    {
        // Get info about current file.
        unz_file_info fileInfo;
        char fileName[MAX_FILENAME];
        if (unzGetCurrentFileInfo(zipfile,
                                  &fileInfo,
                                  fileName,
                                  MAX_FILENAME,
                                  NULL,
                                  0,
                                  NULL,
                                  0) != UNZ_OK)
        {
            CCLOG("can not read file info");
            unzClose(zipfile);
            return false;
        }
        
        string fullPath = stroge + fileName;
        
        // Check if this entry is a directory or a file.
        const size_t filenameLength = strlen(fileName);
        if (fileName[filenameLength-1] == '/')
        {
            // Entry is a direcotry, so create it.
            // If the directory exists, it will failed scilently.
            if (!createDirectory(fullPath.c_str()))
            {
                CCLOG("can not create directory %s", fullPath.c_str());
                unzClose(zipfile);
                return false;
            }
        }
        else
        {
			std::string tmpFile = fileName;
			std::vector<std::string> tmpPathList;
			while (tmpFile.find_last_of('/') != -1)
			{
				tmpFile = tmpFile.substr(0,tmpFile.find_last_of('/'));
				tmpPathList.push_back(stroge+tmpFile);
			}
			for (int idx=tmpPathList.size()-1; idx >= 0; --idx)
			{
				if (!CCFileUtils::sharedFileUtils()->isDirectoryExist(tmpPathList[idx]))
				{
					if (!createDirectory(tmpPathList[idx].c_str()))
					{
						CCLOG("can not create directory %s", tmpPathList[idx].c_str());
						unzClose(zipfile);
						return false;
					}
				}
			}
            // Entry is a file, so extract it.
            
            // Open current file.
            if (unzOpenCurrentFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not open file %s", fileName);
                unzClose(zipfile);
                return false;
            }
            
            // Create a file to store current file.
            FILE *out = fopen(fullPath.c_str(), "wb");
            if (! out)
            {
                CCLOG("can not open destination file %s", fullPath.c_str());
                unzCloseCurrentFile(zipfile);
                unzClose(zipfile);
                return false;
            }
            
            // Write current file content to destinate file.
            int error = UNZ_OK;
            do
            {
                error = unzReadCurrentFile(zipfile, readBuffer, BUFFER_SIZE);
                if (error < 0)
                {
                    CCLOG("can not read zip file %s, error code is %d", fileName, error);
                    unzCloseCurrentFile(zipfile);
                    unzClose(zipfile);
                    return false;
                }
                
                if (error > 0)
                {
                    fwrite(readBuffer, error, 1, out);
                }
            } while(error > 0);
            
            fclose(out);
        }
        
        unzCloseCurrentFile(zipfile);
        
        // Goto next entry listed in the zip file.
        if ((i+1) < global_info.number_entry)
        {
            if (unzGoToNextFile(zipfile) != UNZ_OK)
            {
                CCLOG("can not read next file");
                unzClose(zipfile);
                return false;
            }
        }
    }
    unzClose(zipfile);
    CCLOG("end uncompressing");
    
    return true;
}

bool AssetsManagerEx::createDirectory(const char *path)
{
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WIN32)
	mode_t processMask = umask(0);
	int ret = mkdir(path, S_IRWXU | S_IRWXG | S_IRWXO);
	umask(processMask);
	if (ret != 0 && (errno != EEXIST))
	{
		return false;
	}

	return true;
#else
	BOOL ret = CreateDirectoryA(path, NULL);
	if (!ret && ERROR_ALREADY_EXISTS != GetLastError())
	{
		return false;
	}
	return true;
#endif
}

