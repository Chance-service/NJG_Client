#pragma once

#include <string>

FILE *getFIlE(const std::string& fileInPath, const char* mode);

void saveFileInPath(const std::string& fileInPath, const char* mode, const unsigned char* data, unsigned long size, bool encrypt = false);

unsigned char* getFileData(const char* pszFileName, const char* pszMode, unsigned long * pSize, unsigned short* crc = 0,bool isShowBox=true);

std::string getFileDataForLua(const char* pszFileName);

void game_rmdir(const char* path);

long long game_getFreeSpace();