/****************************************************************************
Copyright (c) 2010 cocos2d-x.org

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

#include "platform/CCCommon.h"
#include "platform/CCFileUtils.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include <android/log.h>
#include <stdio.h>
#include <jni.h>

NS_CC_BEGIN

#define MAX_LEN         (cocos2d::kMaxLogLen + 1)
class AutoReleaseLog
{
	FILE *g_fpLog;
	static AutoReleaseLog sLog;
	std::string strErrLog;
public:

	AutoReleaseLog()
	{
		g_fpLog = NULL;
	}
	~AutoReleaseLog()
	{
		if (g_fpLog)
		{
			fprintf(g_fpLog,"Game closed!\n\n");
			fclose(g_fpLog);
		}
	}
	void Log(char* log)
	{
		if (g_fpLog== NULL)
			return;

		time_t t = time(0); 
		char tmp[64]; 
		strftime( tmp, sizeof(tmp), "%Y/%m/%d %X",localtime(&t) ); 
		fprintf(g_fpLog,"%s\t\t",tmp);
		fprintf(g_fpLog,"%s\n",log);
		fflush(g_fpLog);

		freopen(strErrLog.c_str(), "a+", stderr);

	}
	static AutoReleaseLog& getInstance(){return sLog;}
	void openLog()
	{
		std::string filepath = CCFileUtils::sharedFileUtils()->getWritablePath() + "/game.log";
		__android_log_print(ANDROID_LOG_DEBUG, "cocos2d-x debug info",  filepath.c_str());
		g_fpLog = fopen(filepath.c_str(), "w");
		fprintf(g_fpLog,"Game started!\n");
		filepath.append(".err.log");
		strErrLog = filepath;
		freopen(filepath.c_str(), "w", stderr);
	}
};

AutoReleaseLog AutoReleaseLog::sLog;

void CCLog(const char * pszFormat, ...)
{
	std::string logstr(pszFormat);

	char buf[MAX_LEN] = {0};

    va_list args;
    va_start(args, pszFormat);        
    vsnprintf(buf, MAX_LEN, pszFormat, args);
    va_end(args);

    __android_log_print(ANDROID_LOG_DEBUG, "cocos2d-x debug info",  buf);
	//
	if (logstr == "cocos2d-x app delegate")
	{
		AutoReleaseLog::getInstance().openLog();
	}
	
	AutoReleaseLog::getInstance().Log(buf);
}

void TheDialogOkCallback(int tag, void* ctx)
{
	
}

void CCMessageBox(const char * pszMsg, const char * pszTitle)
{
    showDialogJNI(pszMsg, pszTitle, TheDialogOkCallback, NULL, -1);
}

void CCLuaLog(const char * pszFormat)
{
    __android_log_print(ANDROID_LOG_DEBUG, "cocos2d-x lua_debug info", pszFormat);
	
	char buf[MAX_LEN] = {0};
	sprintf(buf, "%s", pszFormat);
	AutoReleaseLog::getInstance().Log(buf);
}

NS_CC_END
