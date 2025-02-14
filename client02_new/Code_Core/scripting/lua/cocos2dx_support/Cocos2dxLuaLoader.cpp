/****************************************************************************
Copyright (c) 2011 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#include "Cocos2dxLuaLoader.h"
#include <string>
#include <algorithm>
#include "zlib.h"
#include <iostream>
#include <sstream>
#include <iomanip>
#include "../../extensions/crypto/CCCrypto.h"

using namespace cocos2d::extension;
using namespace cocos2d;
using namespace std;
extern "C"
{
	void splitstring(const std::string& sourceStr, std::vector<std::string>& v, const std::string& c)
	{
		std::string::size_type pos1, pos2;
		pos2 = sourceStr.find(c);
		pos1 = 0;
		while (std::string::npos != pos2)
		{
			v.push_back(sourceStr.substr(pos1, pos2 - pos1));

			pos1 = pos2 + c.size();
			pos2 = sourceStr.find(c, pos1);
		}
		if (pos1 != sourceStr.length())
			v.push_back(sourceStr.substr(pos1));
	}

    int cocos2dx_lua_loader(lua_State *L)
    {
        std::string filename(luaL_checkstring(L, 1));
        size_t pos = filename.rfind(".lua");
        if (pos != std::string::npos)
        {
            filename = filename.substr(0, pos);
        }
        
        pos = filename.find_first_of(".");
        while (pos != std::string::npos)
        {
            filename.replace(pos, 1, "/");
            pos = filename.find_first_of(".");
        }

		
		
		#ifdef LUA_NAME_MD5   //lua 文件名做混淆
			std::string source = filename;

			int fileExtIndex = filename.find_last_of('.');
			int fileNameIndex = filename.find_last_of('/');
			string shortName = filename.substr(fileNameIndex + 1, fileExtIndex - fileNameIndex - 1);

			std::vector<std::string> splitArray;
			bool isNeedCry = true;
			splitstring("pb string table", splitArray, " ");

			for (int i = 0; i < splitArray.size(); i++)
			{

				if (shortName == splitArray[i])
				{
					CCLog("sssssssssssssssssssssss Cocos2dxLuaLoader:cocos2dx_lua_loader fileNam%s", filename.c_str());
					isNeedCry = false;
					break;
				}
			}

			if (isNeedCry)
			{
				string saltName = shortName + "hanchao";

				unsigned char buffer[CCCrypto::MD5_BUFFER_LENGTH];

				CCCrypto::MD5((void*)saltName.c_str(), strlen(saltName.c_str()), buffer);

				std::ostringstream oss;
				oss << std::hex;
				oss << std::setfill('0');
				for (int i = 0; i < CCCrypto::MD5_BUFFER_LENGTH; i++)
				{
					unsigned char c = buffer[i];
					oss << std::setw(2) << (unsigned int)c;
				}

				string cryStrName = oss.str();

				if (filename.rfind("/") != std::string::npos)
				{
					cryStrName = filename.substr(0, filename.rfind("/") + 1) + cryStrName;
				}
				filename = cryStrName;
				CCLog("Cocos2dxLuaLoader:cocos2dx_lua_loader fileNam%s cryFileName %s", filename.c_str(), cryStrName.c_str());
			}

		#endif
		
		std::string encryptFilename = filename + ".el";
		bool isDebug=false;
		bool isWin32=false;

#ifdef DEBUG 
		isDebug=true;
#endif	
#if  (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS) || (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
		isWin32=true;
#endif	

		std::string usingname = filename + ".lua";
		if(isWin32||isDebug)
		{//»Áπ˚ «win32ªÚ’ﬂdebug∞Ê±æ£¨”≈œ»≤È’“Œ¥º”√‹Œƒº˛

			bool haveLuaFile=CCFileUtils::sharedFileUtils()->isFileExist(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(usingname.c_str()).c_str());
			if(haveLuaFile)
			{
				filename.append(".lua");
			}
			else
			{
				filename.append(".el");
			}
		}
		else
		{
			filename.append(".el");
		}

		struct cc_timeval beginLoad;
		CCTime::gettimeofdayCocos2d(&beginLoad,NULL);
		clock_t beginClock,endclock;
		beginClock = clock();

		unsigned long codeBufferSize = 0;
		unsigned char* codeBuffer = CCFileUtils::sharedFileUtils()->getFileData(cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(filename.c_str()).c_str(), 
			"rb", &codeBufferSize,!isWin32);
		if (codeBuffer)
		{
			if (luaL_loadbuffer(L, (char*)codeBuffer, codeBufferSize, usingname.c_str()) != 0)
			{
				luaL_error(L, "Cocos2dxLuaLoader:cocos2dx_lua_loader | error loading module %s from file %s :\n\t%s",
					lua_tostring(L, 1), filename.c_str(), lua_tostring(L, -1));
			}
			delete[] codeBuffer;
		}
		else
		{
			CCLog("Cocos2dxLuaLoader:cocos2dx_lua_loader | can not get lua file data of %s", filename.c_str());
		}

		struct cc_timeval endLoad;
		CCTime::gettimeofdayCocos2d(&endLoad,NULL);
		float deletaTime = (endLoad.tv_sec - beginLoad.tv_sec) + (endLoad.tv_usec - beginLoad.tv_usec) / 1000000.0f;
		endclock = clock();
		if(isDebug)
		{
			CCLog("Cocos2dxLuaLoader:cocos2dx_lua_loader | load lua filename:%s cost: %f second,%d", filename.c_str(), deletaTime, endclock - beginClock);
		}
		return 1;
    }
}
