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
#ifndef __CC_FILEUTILS_WIN32_H__
#define __CC_FILEUTILS_WIN32_H__

#include "platform/CCFileUtils.h"
#include "platform/CCPlatformMacros.h"
#include "ccTypes.h"
#include "ccTypeInfo.h"
#include <string>
#include <vector>

NS_CC_BEGIN

/**
 * @addtogroup platform
 * @{
 */

//! @brief  Helper class to handle file operations
class CC_DLL CCFileUtilsWin32 : public CCFileUtils
{
    friend class CCFileUtils;
    CCFileUtilsWin32();
public:
    /* override funtions */
    bool init();
    virtual std::string getWritablePath();
    virtual bool isFileExist(const std::string& strFilePath);
    virtual bool isAbsolutePath(const std::string& strPath);
	virtual void addSearchPath(const char* path);
	virtual void insertSearchPath(const char* path, int index);
	virtual void removeSearchPath(const char *path);

	/* transfer utf8 to gbk */
	std::string utf8Togbk(const char *src);

	virtual std::string fullPathForFilename(const char* pszFileName);

	protected:
    /**
     *  Gets full path for filename, resolution directory and search path.
     *
     *  @param filename The file name.
     *  @param resolutionDirectory The resolution directory.
     *  @param searchPath The search path.
     *  @return The full path of the file. It will return an empty string if the full path of the file doesn't exist.
     */
    virtual std::string getPathForFilename(const std::string& filename, const std::string& resolutionDirectory, const std::string& searchPath);
};

// end of platform group
/// @}

NS_CC_END

#endif    // __CC_FILEUTILS_WIN32_H__

