﻿/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2011      Zynga Inc.
Copyright (c) Microsoft Open Technologies, Inc.

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

#include "CCTextureCache.h"
#include "CCTexture2D.h"
#include "ccMacros.h"
#include "CCDirector.h"
#include "platform/platform.h"
#include "platform/CCFileUtils.h"
#include "platform/CCThread.h"
#include "platform/CCImage.h"
#include "support/ccUtils.h"
#include "shaders/CCShaderCache.h"
#include "CCScheduler.h"
#include "cocoa/CCString.h"
#include <errno.h>
#include <stack>
#include <string>
#include <cctype>
#include <queue>
#include <list>

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT) && (CC_TARGET_PLATFORM != CC_PLATFORM_WP8)
#include <pthread.h>
#else
#include "CCPThreadWinRT.h"
#include <ppl.h>
#include <ppltasks.h>
using namespace concurrency;
#endif

#include "sprite_nodes/CCSpriteFrameCache.h"

#define kCCShader_PositionTextureColor_Palette "ShaderPositionTextureColor_Palette"

using namespace std;

NS_CC_BEGIN
unsigned int getPowsize(unsigned int size)
{
	unsigned int Powsize = 1;
	while(size !=1 )
	{
		size = ceil((float)size / 2.0);
		Powsize = Powsize * 2;
	}
	return Powsize;
}
typedef struct _AsyncStruct
{
    std::string            filename;
    CCObject    *target;
    SEL_CallFuncO        selector;
} AsyncStruct;

typedef struct _ImageInfo
{
    AsyncStruct *asyncStruct;
    CCImage        *image;
    CCImage::EImageFormat imageType;
} ImageInfo;

static pthread_t s_loadingThread;

static pthread_mutex_t		s_SleepMutex;
static pthread_cond_t		s_SleepCondition;

static pthread_mutex_t      s_asyncStructQueueMutex;
static pthread_mutex_t      s_ImageInfoMutex;

#ifdef EMSCRIPTEN
// Hack to get ASM.JS validation (no undefined symbols allowed).
#define pthread_cond_signal(_)
#endif // EMSCRIPTEN

static unsigned long s_nAsyncRefCount = 0;

static bool need_quit = false;

static std::queue<AsyncStruct*>* s_pAsyncStructQueue = NULL;

static std::queue<ImageInfo*>*   s_pImageQueue = NULL;

static float totalSize = 0;

static CCImage::EImageFormat computeImageFormatType(string& filename)
{
    CCImage::EImageFormat ret = CCImage::kFmtUnKnown;

    if ((std::string::npos != filename.find(".jpg")) || (std::string::npos != filename.find(".jpeg")))
    {
        ret = CCImage::kFmtJpg;
    }
    else if ((std::string::npos != filename.find(".png")) || (std::string::npos != filename.find(".PNG")))
    {
        ret = CCImage::kFmtPng;
    }
    else if ((std::string::npos != filename.find(".tiff")) || (std::string::npos != filename.find(".TIFF")))
    {
        ret = CCImage::kFmtTiff;
    }
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT) && (CC_TARGET_PLATFORM != CC_PLATFORM_WP8)
    else if ((std::string::npos != filename.find(".webp")) || (std::string::npos != filename.find(".WEBP")))
    {
        ret = CCImage::kFmtWebp;
    }
#endif
   
    return ret;
}

static void loadImageData(AsyncStruct *pAsyncStruct)
{
    const char *filename = pAsyncStruct->filename.c_str();

    // compute image type
    CCImage::EImageFormat imageType = computeImageFormatType(pAsyncStruct->filename);
    if (imageType == CCImage::kFmtUnKnown)
    {
        CCLOG("unsupported format %s",filename);
        delete pAsyncStruct;
        return;
    }
        
    // generate image            
    CCImage *pImage = new CCImage();
    if (pImage && !pImage->initWithImageFileThreadSafe(filename, imageType))
    {
        CC_SAFE_RELEASE(pImage);
        CCLOG("can not load %s", filename);
        return;
    }

    // generate image info
    ImageInfo *pImageInfo = new ImageInfo();
    pImageInfo->asyncStruct = pAsyncStruct;
    pImageInfo->image = pImage;
    pImageInfo->imageType = imageType;
    // put the image info into the queue
    pthread_mutex_lock(&s_ImageInfoMutex);
    s_pImageQueue->push(pImageInfo);
    pthread_mutex_unlock(&s_ImageInfoMutex);   
}

static void* loadImage(void* data)
{
    AsyncStruct *pAsyncStruct = NULL;

    while (true)
    {
        // create autorelease pool for iOS
        CCThread thread;
        thread.createAutoreleasePool();

        std::queue<AsyncStruct*> *pQueue = s_pAsyncStructQueue;
        pthread_mutex_lock(&s_asyncStructQueueMutex);// get async struct from queue
        if (pQueue->empty())
        {
            pthread_mutex_unlock(&s_asyncStructQueueMutex);
            if (need_quit) {
                break;
            }
            else {
            	pthread_cond_wait(&s_SleepCondition, &s_SleepMutex);
                continue;
            }
        }
        else
        {
            pAsyncStruct = pQueue->front();
            pQueue->pop();
            pthread_mutex_unlock(&s_asyncStructQueueMutex);
        }        

        const char *filename = pAsyncStruct->filename.c_str();

        // compute image type
        CCImage::EImageFormat imageType = computeImageFormatType(pAsyncStruct->filename);
        if (imageType == CCImage::kFmtUnKnown)
        {
            CCLOG("unsupported format %s",filename);
            delete pAsyncStruct;
            
            continue;
        }
        
        // generate image            
        CCImage *pImage = new CCImage();
        if (pImage && !pImage->initWithImageFileThreadSafe(filename, imageType))
        {
            CC_SAFE_RELEASE(pImage);
            CCLOG("can not load %s", filename);
			pImage = 0;
        }

        // generate image info
        ImageInfo *pImageInfo = new ImageInfo();
        pImageInfo->asyncStruct = pAsyncStruct;
        pImageInfo->image = pImage;
        pImageInfo->imageType = imageType;

        // put the image info into the queue
        pthread_mutex_lock(&s_ImageInfoMutex);
        s_pImageQueue->push(pImageInfo);
        pthread_mutex_unlock(&s_ImageInfoMutex);    
    }
    
    if( s_pAsyncStructQueue != NULL )
    {
        delete s_pAsyncStructQueue;
        s_pAsyncStructQueue = NULL;
        delete s_pImageQueue;
        s_pImageQueue = NULL;

        pthread_mutex_destroy(&s_asyncStructQueueMutex);
        pthread_mutex_destroy(&s_ImageInfoMutex);
        pthread_mutex_destroy(&s_SleepMutex);
        pthread_cond_destroy(&s_SleepCondition);
    }
    
    return 0;
}

// implementation CCTextureCache

// TextureCache - Alloc, Init & Dealloc
static CCTextureCache *g_sharedTextureCache = NULL;

CCTextureCache * CCTextureCache::sharedTextureCache()
{
    if (!g_sharedTextureCache)
    {
        g_sharedTextureCache = new CCTextureCache();
    }
    return g_sharedTextureCache;
}

CCTextureCache::CCTextureCache()
{
    CCAssert(g_sharedTextureCache == NULL, "Attempted to allocate a second instance of a singleton.");
    
    m_pTextures = new CCDictionary();

	if (CCFileUtils::sharedFileUtils()->isFileExist("shader/png_handle.plist")){
		m_pPNG8Files = CCDictionary::createWithContentsOfFileThreadSafe("shader/png_handle.plist");
		m_pPNG8Files->retain();
	}else{
		m_pPNG8Files = CCDictionary::create();
		m_pPNG8Files->retain();
	}

	infoDirty = false;
	enablePalette = false;
	info_totalBytes = 0;
	info_max_totalBytes = 0;
	max_cache_bytes = MAX_CACHETEXTURE_BYTESIZE;

	CCDirector::sharedDirector()->getScheduler()->scheduleUpdateForTarget(this,0,false);
}

CCTextureCache::~CCTextureCache()
{
    CCLOGINFO("cocos2d: deallocing CCTextureCache.");
    need_quit = true;
	m_elementToRemove.clear();

    pthread_cond_signal(&s_SleepCondition);
    CC_SAFE_RELEASE(m_pTextures);
	CC_SAFE_RELEASE(m_pPNG8Files);
	CCDirector::sharedDirector()->getScheduler()->unscheduleAllForTarget(this);
}

void CCTextureCache::purgeSharedTextureCache()
{
    CC_SAFE_RELEASE_NULL(g_sharedTextureCache);
}

const char* CCTextureCache::description()
{
    return CCString::createWithFormat("<CCTextureCache | Number of textures = %u>", m_pTextures->count())->getCString();
}

bool CCTextureCache::isPaletteTextureEnable() const
{
	return enablePalette;
}

bool CCTextureCache::initPaletteGLProgram(const GLchar* vShaderByteArray, const GLchar* fShaderByteArray)
{
	CCGLProgram* pGLProgram = CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor_Palette);
	if (!pGLProgram && vShaderByteArray && fShaderByteArray)
	{
		pGLProgram = new CCGLProgram();
		if (!pGLProgram->initWithVertexShaderByteArray(vShaderByteArray, fShaderByteArray))
		{
			CC_SAFE_RELEASE_NULL(pGLProgram);
			return false;
		}

		pGLProgram->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
		pGLProgram->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
		pGLProgram->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);

		if (!pGLProgram->link())
		{
			CC_SAFE_RELEASE_NULL(pGLProgram);
			return false;
		}

		pGLProgram->updateUniforms();

		CCShaderCache::sharedShaderCache()->addProgram(pGLProgram, kCCShader_PositionTextureColor_Palette);
		CC_SAFE_RELEASE_NULL(pGLProgram);

		enablePalette = true;
		CCImage::setImgPaletteEnable(enablePalette);
	}

	return pGLProgram != 0;
}

CCGLProgram* CCTextureCache::getPaletteGLProgram()
{
	return CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor_Palette);
}

CCDictionary* CCTextureCache::snapshotTextures()
{ 
    CCDictionary* pRet = new CCDictionary();
    CCDictElement* pElement = NULL;
    CCDICT_FOREACH(m_pTextures, pElement)
    {
        pRet->setObject(pElement->getObject(), pElement->getStrKey());
    }
    pRet->autorelease();
    return pRet;
}

void CCTextureCache::addImageAsync(const char *path, CCObject *target, SEL_CallFuncO selector)
{
#ifdef EMSCRIPTEN
    CCLOGWARN("Cannot load image %s asynchronously in Emscripten builds.", path);
    return;
#endif // EMSCRIPTEN

    CCAssert(path != NULL, "TextureCache: fileimage MUST not be NULL");    

    CCTexture2D *texture = NULL;

    // optimization

    std::string pathKey = path;

    pathKey = CCFileUtils::sharedFileUtils()->fullPathForFilename(pathKey.c_str());

    texture = (CCTexture2D*)m_pTextures->objectForKey(pathKey.c_str());

    std::string fullpath = pathKey;


    if (texture != NULL)
    {
        if (target && selector)
        {
            (target->*selector)(texture);
        }
        
        return;
    }


    // lazy init
    if (s_pAsyncStructQueue == NULL)
    {             
        s_pAsyncStructQueue = new queue<AsyncStruct*>();
        s_pImageQueue = new queue<ImageInfo*>();        
        
        pthread_mutex_init(&s_asyncStructQueueMutex, NULL);
        pthread_mutex_init(&s_ImageInfoMutex, NULL);
        pthread_mutex_init(&s_SleepMutex, NULL);
        pthread_cond_init(&s_SleepCondition, NULL);
#if (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT) && (CC_TARGET_PLATFORM != CC_PLATFORM_WP8)
        pthread_create(&s_loadingThread, NULL, loadImage, NULL);
#endif
        need_quit = false;
    }

    if (0 == s_nAsyncRefCount)
    {
        CCDirector::sharedDirector()->getScheduler()->scheduleSelector(schedule_selector(CCTextureCache::addImageAsyncCallBack), this, 0, false);
    }

    ++s_nAsyncRefCount;

    if (target)
    {
        target->retain();
    }

    // generate async struct
    AsyncStruct *data = new AsyncStruct();
    data->filename = fullpath.c_str();
    data->target = target;
    data->selector = selector;

#if (CC_TARGET_PLATFORM != CC_PLATFORM_WINRT) && (CC_TARGET_PLATFORM != CC_PLATFORM_WP8)
    // add async struct into queue
    pthread_mutex_lock(&s_asyncStructQueueMutex);
    s_pAsyncStructQueue->push(data);
    pthread_mutex_unlock(&s_asyncStructQueueMutex);

    pthread_cond_signal(&s_SleepCondition);
#else
    // WinRT uses an Async Task to load the image since the ThreadPool has a limited number of threads
    //std::replace( data->filename.begin(), data->filename.end(), '/', '\\'); 
    create_task([this, data] {
        loadImageData(data);
    });
#endif
}

void CCTextureCache::addImageAsyncCallBack(float dt)
{
    // the image is generated in loading thread
    std::queue<ImageInfo*> *imagesQueue = s_pImageQueue;

    pthread_mutex_lock(&s_ImageInfoMutex);
    if (imagesQueue->empty())
    {
        pthread_mutex_unlock(&s_ImageInfoMutex);
    }
    else
    {
        ImageInfo *pImageInfo = imagesQueue->front();
        imagesQueue->pop();
        pthread_mutex_unlock(&s_ImageInfoMutex);

        AsyncStruct *pAsyncStruct = pImageInfo->asyncStruct;
        CCImage *pImage = pImageInfo->image;

        CCObject *target = pAsyncStruct->target;
        SEL_CallFuncO selector = pAsyncStruct->selector;
        const char* filename = pAsyncStruct->filename.c_str();

		CCTexture2D *texture = 0;

		if(pImage)
		{

        // generate texture in render thread
        texture = new CCTexture2D();

#if 0 //TODO: (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        texture->initWithImage(pImage, kCCResolutioniPhone);
#else
        texture->initWithImage(pImage);
#endif

#if CC_ENABLE_CACHE_TEXTURE_DATA
       // cache the texture file name
       VolatileTexture::addImageTexture(texture, filename, pImageInfo->imageType);
#endif

        // cache the texture
        m_pTextures->setObject(texture, filename);infoDirty = true;
		texture->retain();
        texture->autorelease();
		}

        if (target && selector)
        {
            (target->*selector)(texture);
            target->release();
        }        

		if(texture)
			texture->release();
		if(pImage)
			pImage->release();
        delete pAsyncStruct;
        delete pImageInfo;

        --s_nAsyncRefCount;
        if (0 == s_nAsyncRefCount)
        {
            CCDirector::sharedDirector()->getScheduler()->unscheduleSelector(schedule_selector(CCTextureCache::addImageAsyncCallBack), this);
        }
    }
}

//纹理检查的开关
#if COCOS2D_DEBUG > 0
#define TEXTURE_CHECKING
#endif

CCTexture2D * CCTextureCache::addImage(const char * path)
{
    CCAssert(path != NULL, "TextureCache: fileimage MUST not be NULL");

    CCTexture2D * texture = NULL;
    CCImage* pImage = NULL;
    // Split up directory and filename
    // MUTEX:
    // Needed since addImageAsync calls this method from a different thread
    
    //pthread_mutex_lock(m_pDictLock);

#ifdef TEXTURE_CHECKING

	//test case.1 打印所有Imagesetfile plist的引用情况
	std::string s_pathName(path);
	std::size_t found = s_pathName.find("Imagesetfile");
	if (found!=std::string::npos){
		CCLog("@CCTextureCache::addImage-- new texture load, texture name is %s",path);
	}
	//test case.2 打印所有被加载的资源
	//CCLog("@CCTextureCache::addImage-- new texture load, texture name is %s",path);
#endif

    std::string pathKey = path;
	if(pathKey=="")
	{
		pathKey="empty.png";
		CCLOG("Error,CCTextureCache addImage path is ''");
	}
    pathKey = CCFileUtils::sharedFileUtils()->fullPathForFilename(pathKey.c_str());
    if (pathKey.size() == 0)
    {
		pathKey = CCFileUtils::sharedFileUtils()->fullPathForFilename("empty.png");
		if(pathKey.size()==0)
			return NULL;
    }
    texture = (CCTexture2D*)m_pTextures->objectForKey(pathKey.c_str());

    std::string fullpath = pathKey; // (CCFileUtils::sharedFileUtils()->fullPathFromRelativePath(path));
    if (! texture) 
    {
		//--begin xinzheng 2014-1-7
		if (info_totalBytes >= max_cache_bytes)
		{
			CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFramesPerFrame();
			CCTextureCache::sharedTextureCache()->removeUnusedTexturesPerFrame();
		}
		//--end
        std::string lowerCase(pathKey);
        for (unsigned int i = 0; i < lowerCase.length(); ++i)
        {
            lowerCase[i] = tolower(lowerCase[i]);
        }
        // all images are handled by UIImage except PVR extension that is handled by our own handler
        do 
        {
            if (std::string::npos != lowerCase.find(".pvr"))
            {
                texture = this->addPVRImage(fullpath.c_str());
            }
            else if (std::string::npos != lowerCase.find(".pkm"))
            {
                // ETC1 file format, only supportted on Android
                texture = this->addETCImage(fullpath.c_str());
            }
            else
            {
                CCImage::EImageFormat eImageFormat = CCImage::kFmtUnKnown;
                if (std::string::npos != lowerCase.find(".png"))
                {
                    eImageFormat = CCImage::kFmtPng;
                }
                else if (std::string::npos != lowerCase.find(".jpg") || std::string::npos != lowerCase.find(".jpeg"))
                {
                    eImageFormat = CCImage::kFmtJpg;
                }
                else if (std::string::npos != lowerCase.find(".tif") || std::string::npos != lowerCase.find(".tiff"))
                {
                    eImageFormat = CCImage::kFmtTiff;
                }
                else if (std::string::npos != lowerCase.find(".webp"))
                {
                    eImageFormat = CCImage::kFmtWebp;
                }
                
                pImage = new CCImage();
                CC_BREAK_IF(NULL == pImage);

                unsigned long nSize = 0;
                unsigned char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(fullpath.c_str(), "rb", &nSize);
                
				pImage->m_imgInPlist = imgInPalettePlist(path);

                bool bRet = pImage->initWithImageData((void*)pBuffer, nSize, eImageFormat);
                CC_SAFE_DELETE_ARRAY(pBuffer);
                CC_BREAK_IF(!bRet);

				//CCLOG("[TextureCache] Load: %s", fullpath.c_str());

                texture = new CCTexture2D();

                if( texture &&
                    texture->initWithImage(pImage) )
                {
#if CC_ENABLE_CACHE_TEXTURE_DATA
                    // cache the texture file name
                    VolatileTexture::addImageTexture(texture, fullpath.c_str(), eImageFormat);
#endif
                    m_pTextures->setObject(texture, pathKey.c_str());infoDirty = true;
                    texture->release();
					#if COCOS2D_DEBUG > 0
					//unsigned int bpp = texture->bitsPerPixelForFormat();
					//// Each texture takes up width * height * bytesPerPixel bytes.
					//unsigned int bytes = texture->getPixelsWide() * texture->getPixelsHigh() * bpp / 8;
					//unsigned int Powbytes = getPowsize(texture->getPixelsWide()) * getPowsize(texture->getPixelsHigh()) * bpp / 8;
					//totalSize = totalSize + Powbytes; 
					//    //CCLog("@CCTextureCache::addImage-- new texture load, texture name is %s", path);
					//	CCLOG("Load: texture load, texture name is: \"%s\" rc=%lu id=%lu %lu x %lu @ %ld bpp => %lu KB %lu KB totalSize %lu MB",
					//		path,
					//		(long)texture->retainCount(),
					//		(long)texture->getName(),
					//		(long)texture->getPixelsWide(),
					//		(long)texture->getPixelsHigh(),
					//		(long)bpp,
					//		(long)bytes / 1024,
					//		(long)Powbytes / 1024,
					//		(long)totalSize / 1024 / 1024);
						texture->setSourceInfo(pathKey.c_str());
					#endif
                }
                else
                {
                    CCLOG("cocos2d: Couldn't create texture for file:%s in CCTextureCache", path);
                }
            }
        } while (0);
    }

    CC_SAFE_RELEASE(pImage);

    //pthread_mutex_unlock(m_pDictLock);
    return texture;
}
bool CCTextureCache::imgInPalettePlist(const char* fileimage){
	if (m_pPNG8Files == NULL)
	{
		return false;
	}
	//
	static bool alltrue = false;
	if (alltrue)
		return true;
	//
	int filesize = m_pPNG8Files->count();
	if (filesize>0)
	{
		static bool needcheck = true;
		if (!alltrue && needcheck)
		{
			CCObject* object = m_pPNG8Files->objectForKey("alltrue");
			if (object ==NULL)
			{
				needcheck = false;
				alltrue = false;
			}
			else
			{
				CCString * pString =dynamic_cast<CCString*> (object);
				if (!pString)
				{
					alltrue = false;
				}
				else
				{
					if (pString->compare("true") == 0)
					{
						alltrue = true;
					}else{
						alltrue = false;
					}
				}
			}
		}
		//
		CCObject* object = m_pPNG8Files->objectForKey(fileimage);
		if (object ==NULL)
		{
			return false;
		}

		CCString * pString =dynamic_cast<CCString*> (object);
		if (!pString)
		{
			return false;
		}

		if (pString->compare("true") == 0)
		{
			return true;
		}else{
			return false;
		}
	}
	return false;
}
CCTexture2D * CCTextureCache::addPVRImage(const char* path)
{
    CCAssert(path != NULL, "TextureCache: fileimage MUST not be nil");

    CCTexture2D* texture = NULL;
    std::string key(path);
    
    if( (texture = (CCTexture2D*)m_pTextures->objectForKey(key.c_str())) ) 
    {
        return texture;
    }

    // Split up directory and filename
    std::string fullpath = CCFileUtils::sharedFileUtils()->fullPathForFilename(key.c_str());
    texture = new CCTexture2D();

    if(texture != NULL && texture->initWithPVRFile(fullpath.c_str()) )
    {
#if CC_ENABLE_CACHE_TEXTURE_DATA
        // cache the texture file name
        VolatileTexture::addImageTexture(texture, fullpath.c_str(), CCImage::kFmtRawData);
#endif
        m_pTextures->setObject(texture, key.c_str());infoDirty = true;
        texture->autorelease();
    }
    else
    {
        CCLOG("cocos2d: Couldn't add PVRImage:%s in CCTextureCache",key.c_str());
        CC_SAFE_DELETE(texture);
    }

    return texture;
}

CCTexture2D* CCTextureCache::addETCImage(const char* path)
{
    CCAssert(path != NULL, "TextureCache: fileimage MUST not be nil");
    
    CCTexture2D* texture = NULL;
    std::string key(path);
    
    if( (texture = (CCTexture2D*)m_pTextures->objectForKey(key.c_str())) )
    {
        return texture;
    }
    
    // Split up directory and filename
    std::string fullpath = CCFileUtils::sharedFileUtils()->fullPathForFilename(key.c_str());
    texture = new CCTexture2D();
    if(texture != NULL && texture->initWithETCFile(fullpath.c_str()))
    {
        m_pTextures->setObject(texture, key.c_str());
        texture->autorelease();
    }
    else
    {
        CCLOG("cocos2d: Couldn't add ETCImage:%s in CCTextureCache",key.c_str());
        CC_SAFE_DELETE(texture);
    }
    
    return texture;
}

CCTexture2D* CCTextureCache::addUIImage(CCImage *image, const char *key)
{
    CCAssert(image != NULL, "TextureCache: image MUST not be nil");

    CCTexture2D * texture = NULL;
    // textureForKey() use full path,so the key should be full path
    std::string forKey;
    if (key)
    {
        forKey = CCFileUtils::sharedFileUtils()->fullPathForFilename(key);
    }

    // Don't have to lock here, because addImageAsync() will not 
    // invoke opengl function in loading thread.

    do 
    {
        // If key is nil, then create a new texture each time
        if(key && (texture = (CCTexture2D *)m_pTextures->objectForKey(forKey.c_str())))
        {
            break;
        }

        // prevents overloading the autorelease pool
        texture = new CCTexture2D();
        texture->initWithImage(image);

        if(key && texture)
        {
            m_pTextures->setObject(texture, forKey.c_str());infoDirty = true;
            texture->autorelease();
#if COCOS2D_DEBUG > 0
			texture->setSourceInfo(forKey.c_str());
#endif
        }
        else
        {
            CCLOG("cocos2d: Couldn't add UIImage in CCTextureCache");
        }

    } while (0);

#if CC_ENABLE_CACHE_TEXTURE_DATA
    VolatileTexture::addCCImage(texture, image);
#endif
    
    return texture;
}

bool CCTextureCache::reloadTexture(const char* fileName)
{
    std::string fullpath = CCFileUtils::sharedFileUtils()->fullPathForFilename(fileName);
    if (fullpath.size() == 0)
    {
        return false;
    }
    
    CCTexture2D * texture = (CCTexture2D*) m_pTextures->objectForKey(fullpath);
    
    bool ret = false;
    if (! texture) {
        texture = this->addImage(fullpath.c_str());
        ret = (texture != NULL);
    }
    else
    {
        do {
            CCImage* image = new CCImage();
            CC_BREAK_IF(NULL == image);
            
            bool bRet = image->initWithImageFile(fullpath.c_str());
            CC_BREAK_IF(!bRet);
            
            ret = texture->initWithImage(image);
        } while (0);
    }
    
    return ret;
}

// TextureCache - Remove

void CCTextureCache::removeAllTextures()
{
    m_pTextures->removeAllObjects();infoDirty = true;
}

void CCTextureCache::removeUnusedTextures()
{
    /*
    CCDictElement* pElement = NULL;
    CCDICT_FOREACH(m_pTextures, pElement)
    {
        CCLOG("cocos2d: CCTextureCache: texture: %s", pElement->getStrKey());
        CCTexture2D *value = (CCTexture2D*)pElement->getObject();
        if (value->retainCount() == 1)
        {
            CCLOG("cocos2d: CCTextureCache: removing unused texture: %s", pElement->getStrKey());
            m_pTextures->removeObjectForElememt(pElement);
        }
    }
     */
    
    /** Inter engineer zhuoshi sun finds that this way will get better performance
     */    
    if (m_pTextures->count())
    {   
        // find elements to be removed
        CCDictElement* pElement = NULL;
        list<CCDictElement*> elementToRemove;
        CCDICT_FOREACH(m_pTextures, pElement)
        {
            //CCLOG("cocos2d: CCTextureCache: texture: %s", pElement->getStrKey());
            CCTexture2D *value = (CCTexture2D*)pElement->getObject();
            if (value->retainCount() == 1)
            {
                elementToRemove.push_back(pElement);
            }
        }
        
        // remove elements
        for (list<CCDictElement*>::iterator iter = elementToRemove.begin(); iter != elementToRemove.end(); ++iter)
        {
            //CCLOG("cocos2d: CCTextureCache: removing unused texture: %s", (*iter)->getStrKey());
            m_pTextures->removeObjectForElememt(*iter);infoDirty = true;

			// fixed crash by lct at 2014/03/04
			for (std::list<CCDictElement*>::iterator it_m = m_elementToRemove.begin(); it_m != m_elementToRemove.end(); it_m ++)
			{
				if (*it_m == *iter)
				{
					m_elementToRemove.erase(it_m);
					break;
				}
			}
			// end lct
        }
    }
}
void CCTextureCache::removeUnusedTexturesPerFrame()
{
	//if (isBetterNeedToClearCache() == false)
	//{
	//	return;//Cache策略，纹理内存降下来了就不频繁遍历了
	//}
	if (!m_elementToRemove.empty())
		return;
	//this->removeUnusedTextures();
	//return;//有崩溃
	m_elementToRemove.clear();
	if (m_pTextures->count())
	{
		CCDictElement* pElement = NULL;
		CCDICT_FOREACH(m_pTextures, pElement)
		{
			//CCLOG("cocos2d: CCTextureCache: texture: %s", pElement->getStrKey());
			CCTexture2D *value = (CCTexture2D*)pElement->getObject();
			if (value->retainCount() == 1)
			{
				CCLog(">>>>>>>>>>CCTextureCache::removeUnusedTexturesPerFrame()");
				CCLog(pElement->getStrKey());
				m_elementToRemove.push_back(pElement);
			}
		}
	}
}

void CCTextureCache::update(float dt)
{
	//return;//有崩溃
	for ( int i = 0; i < 2 && m_elementToRemove.size(); ++i )
	{
		std::list<CCDictElement*>::iterator iter = m_elementToRemove.begin();
		CCDictElement* pEle = *iter;
		m_elementToRemove.erase(iter);
		if (pEle)
		{
			if (pEle->getObject())
			{
				if (pEle->getObject()->retainCount() == 1)
				{
					CCLOG("cocos2d: CCTextureCache: removing unused texture per frame: %s", pEle->getStrKey());
					m_pTextures->removeObjectForElememt(pEle);
					infoDirty = true;
				}
			}
		}
	}
}
void CCTextureCache::removeTexture(CCTexture2D* texture)
{
    if( ! texture )
    {
        return;
    }

    CCArray* keys = m_pTextures->allKeysForObject(texture);
    m_pTextures->removeObjectsForKeys(keys);
	infoDirty = true;

#ifdef _DEBUG
	if (keys && keys->count() > 0)
	{
		CCObject* pObj = NULL;
		CCARRAY_FOREACH(keys, pObj)
		{
			CCString* pStr = (CCString*)pObj;
			CCLOG("[TextureCache] Remove: %s, RefCount: %d", pStr->getCString(), texture->retainCount());
		}		
	}	
#endif
}

void CCTextureCache::removeTextureForKey(const char *textureKeyName)
{
    if (textureKeyName == NULL)
    {
        return;
    }

    string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(textureKeyName);
    m_pTextures->removeObjectForKey(fullPath);infoDirty = true;
}

CCTexture2D* CCTextureCache::textureForKey(const char* key)
{
    return (CCTexture2D*)m_pTextures->objectForKey(CCFileUtils::sharedFileUtils()->fullPathForFilename(key));
}

void CCTextureCache::reloadAllTextures()
{
#if CC_ENABLE_CACHE_TEXTURE_DATA
    VolatileTexture::reloadAllTextures();
#endif
}

void CCTextureCache::dumpCachedTextureInfo()
{
    unsigned int count = 0;
    unsigned int totalBytes = 0;
	unsigned int totalPowBytes = 0;

    CCDictElement* pElement = NULL;
    CCDICT_FOREACH(m_pTextures, pElement)
    {
        CCTexture2D* tex = (CCTexture2D*)pElement->getObject();
        unsigned int bpp = tex->bitsPerPixelForFormat();
        // Each texture takes up width * height * bytesPerPixel bytes.
        unsigned int bytes = tex->getPixelsWide() * tex->getPixelsHigh() * bpp / 8;
        totalBytes += bytes;
		unsigned int Powbytes = getPowsize(tex->getPixelsWide()) * getPowsize(tex->getPixelsHigh()) * bpp / 8;
		totalPowBytes += Powbytes;
        count++;
        CCLOG("cocos2d: \"%s\" rc=%lu id=%lu %lu x %lu @ %ld bpp => %lu KB %lu KB totalSize %lu MB",
               pElement->getStrKey(),
               (long)tex->retainCount(),
               (long)tex->getName(),
               (long)tex->getPixelsWide(),
               (long)tex->getPixelsHigh(),
               (long)bpp,
               (long)bytes / 1024,
			   (long)Powbytes / 1024 / 1024);
		//
		CCArray* pSpriteFrames = CCSpriteFrameCache::sharedSpriteFrameCache()->getSpriteFramesFromTexture(tex);
		{
			CCObject* pObj = NULL;
			CCARRAY_FOREACH(pSpriteFrames, pObj)
			{
				CCSpriteFrame* pFrame = (CCSpriteFrame*)pObj;
#if COCOS2D_DEBUG > 0
				pFrame->loginfo();
#endif
			}
		}
    }

    CCLOG("cocos2d: CCTextureCache dumpDebugInfo: %ld textures, for %lu KB (%.2f MB) PowSize = %.2f MB", (long)count, (long)totalBytes / 1024, totalBytes / (1024.0f*1024.0f), totalPowBytes / (1024.0f*1024.0f));
}

unsigned int CCTextureCache::getTextrueTotalBytes()
{
	if(infoDirty)
	{
		infoDirty = false;
		info_totalBytes = 0;
		CCDictElement* pElement = NULL;
		CCDICT_FOREACH(m_pTextures, pElement)
		{
			CCTexture2D* tex = (CCTexture2D*)pElement->getObject();
			unsigned int bpp = tex->bitsPerPixelForFormat();
			//unsigned int bytes = tex->getPixelsWide() * tex->getPixelsHigh() * bpp / 8;
			unsigned int bytes = getPowsize(tex->getPixelsWide()) * getPowsize(tex->getPixelsHigh()) * bpp / 8;
			info_totalBytes += bytes;
			info_max_totalBytes = info_max_totalBytes > info_totalBytes? info_max_totalBytes : info_totalBytes;
		}
	}
	return info_totalBytes/* / (1024.0f*1024.0f)*/;
}

unsigned int CCTextureCache::getMaxTextrueTotalBytes()
{
	return info_max_totalBytes;
}

void CCTextureCache::setMaxCacheByteSizeLimit( unsigned int maxbytes )
{
	max_cache_bytes = maxbytes;
}

bool CCTextureCache::checkUpdateRemove( CCTexture2D* pTex )
{
	if (m_elementToRemove.size())
	{
		std::list<CCDictElement*>::iterator iter = m_elementToRemove.begin();
		for (; iter != m_elementToRemove.end(); ++iter)
		{
			if ((*iter)->getObject() == pTex)
			{
				m_elementToRemove.erase(iter);
				return true;
			}
		}
	}
	return false;
}

unsigned int CCTextureCache::getMaxCacheByteSizeLimit()
{
	return max_cache_bytes;
}

bool CCTextureCache::isBetterNeedToClearCache()
{
	getTextrueTotalBytes();
	if (info_totalBytes > (max_cache_bytes-10*1024*1024))
	{
		return true;
	}
	return false;
}




#if CC_ENABLE_CACHE_TEXTURE_DATA

std::list<VolatileTexture*> VolatileTexture::textures;
bool VolatileTexture::isReloading = false;

VolatileTexture::VolatileTexture(CCTexture2D *t)
: texture(t)
, m_eCashedImageType(kInvalid)
, m_pTextureData(NULL)
, m_PixelFormat(kTexture2DPixelFormat_RGBA8888)
, m_strFileName("")
, m_FmtImage(CCImage::kFmtPng)
, m_alignment(kCCTextAlignmentCenter)
, m_vAlignment(kCCVerticalTextAlignmentCenter)
, m_strFontName("")
, m_strText("")
, uiImage(NULL)
, m_fFontSize(0.0f)
{
    m_size = CCSizeMake(0, 0);
    m_texParams.minFilter = GL_LINEAR;
    m_texParams.magFilter = GL_LINEAR;
    m_texParams.wrapS = GL_CLAMP_TO_EDGE;
    m_texParams.wrapT = GL_CLAMP_TO_EDGE;
    textures.push_back(this);
}

VolatileTexture::~VolatileTexture()
{
    textures.remove(this);
    CC_SAFE_RELEASE(uiImage);
}

void VolatileTexture::addImageTexture(CCTexture2D *tt, const char* imageFileName, CCImage::EImageFormat format)
{
    if (isReloading)
    {
        return;
    }

    VolatileTexture *vt = findVolotileTexture(tt);

    vt->m_eCashedImageType = kImageFile;
    vt->m_strFileName = imageFileName;
    vt->m_FmtImage    = format;
    vt->m_PixelFormat = tt->getPixelFormat();
}

void VolatileTexture::addCCImage(CCTexture2D *tt, CCImage *image)
{
    VolatileTexture *vt = findVolotileTexture(tt);
    image->retain();
    vt->uiImage = image;
    vt->m_eCashedImageType = kImage;
}

VolatileTexture* VolatileTexture::findVolotileTexture(CCTexture2D *tt)
{
    VolatileTexture *vt = 0;
    std::list<VolatileTexture *>::iterator i = textures.begin();
    while (i != textures.end())
    {
        VolatileTexture *v = *i++;
        if (v->texture == tt) 
        {
            vt = v;
            break;
        }
    }
    
    if (! vt)
    {
        vt = new VolatileTexture(tt);
    }
    
    return vt;
}

void VolatileTexture::addDataTexture(CCTexture2D *tt, void* data, CCTexture2DPixelFormat pixelFormat, const CCSize& contentSize)
{
    if (isReloading)
    {
        return;
    }

    VolatileTexture *vt = findVolotileTexture(tt);

    vt->m_eCashedImageType = kImageData;
    vt->m_pTextureData = data;
    vt->m_PixelFormat = pixelFormat;
    vt->m_TextureSize = contentSize;
}

void VolatileTexture::addStringTexture(CCTexture2D *tt, const char* text, const CCSize& dimensions, CCTextAlignment alignment, 
                                       CCVerticalTextAlignment vAlignment, const char *fontName, float fontSize)
{
    if (isReloading)
    {
        return;
    }

    VolatileTexture *vt = findVolotileTexture(tt);

    vt->m_eCashedImageType = kString;
    vt->m_size        = dimensions;
    vt->m_strFontName = fontName;
    vt->m_alignment   = alignment;
    vt->m_vAlignment  = vAlignment;
    vt->m_fFontSize   = fontSize;
    vt->m_strText     = text;
}

void VolatileTexture::setTexParameters(CCTexture2D *t, ccTexParams *texParams) 
{
    VolatileTexture *vt = findVolotileTexture(t);

    if (texParams->minFilter != GL_NONE)
        vt->m_texParams.minFilter = texParams->minFilter;
    if (texParams->magFilter != GL_NONE)
        vt->m_texParams.magFilter = texParams->magFilter;
    if (texParams->wrapS != GL_NONE)
        vt->m_texParams.wrapS = texParams->wrapS;
    if (texParams->wrapT != GL_NONE)
        vt->m_texParams.wrapT = texParams->wrapT;
}

void VolatileTexture::removeTexture(CCTexture2D *t) 
{

    std::list<VolatileTexture *>::iterator i = textures.begin();
    while (i != textures.end())
    {
        VolatileTexture *vt = *i++;
        if (vt->texture == t) 
        {
            delete vt;
            break;
        }
    }
}

void VolatileTexture::reloadAllTextures()
{
    isReloading = true;

    CCLOG("reload all texture");
    std::list<VolatileTexture *>::iterator iter = textures.begin();

    while (iter != textures.end())
    {
        VolatileTexture *vt = *iter++;

        switch (vt->m_eCashedImageType)
        {
        case kImageFile:
            {
                std::string lowerCase(vt->m_strFileName.c_str());
                for (unsigned int i = 0; i < lowerCase.length(); ++i)
                {
                    lowerCase[i] = tolower(lowerCase[i]);
                }

                if (std::string::npos != lowerCase.find(".pvr")) 
                {
                    CCTexture2DPixelFormat oldPixelFormat = CCTexture2D::defaultAlphaPixelFormat();
                    CCTexture2D::setDefaultAlphaPixelFormat(vt->m_PixelFormat);

                    vt->texture->initWithPVRFile(vt->m_strFileName.c_str());
                    CCTexture2D::setDefaultAlphaPixelFormat(oldPixelFormat);
                } 
                else 
                {
                    CCImage* pImage = new CCImage();
                    unsigned long nSize = 0;
                    unsigned char* pBuffer = CCFileUtils::sharedFileUtils()->getFileData(vt->m_strFileName.c_str(), "rb", &nSize);

                    if (pImage && pImage->initWithImageData((void*)pBuffer, nSize, vt->m_FmtImage))
                    {
                        CCTexture2DPixelFormat oldPixelFormat = CCTexture2D::defaultAlphaPixelFormat();
                        CCTexture2D::setDefaultAlphaPixelFormat(vt->m_PixelFormat);
                        vt->texture->initWithImage(pImage);
                        CCTexture2D::setDefaultAlphaPixelFormat(oldPixelFormat);
                    }

                    CC_SAFE_DELETE_ARRAY(pBuffer);
                    CC_SAFE_RELEASE(pImage);
                }
            }
            break;
        case kImageData:
            {
                vt->texture->initWithData(vt->m_pTextureData, 
                                          vt->m_PixelFormat, 
                                          vt->m_TextureSize.width, 
                                          vt->m_TextureSize.height, 
                                          vt->m_TextureSize);
            }
            break;
        case kString:
            {
                vt->texture->initWithString(vt->m_strText.c_str(),
                                            vt->m_strFontName.c_str(),
                                            vt->m_fFontSize,
                                            vt->m_size,
                                            vt->m_alignment,
                                            vt->m_vAlignment
                                            );
            }
            break;
        case kImage:
            {
                vt->texture->initWithImage(vt->uiImage);
            }
            break;
        default:
            break;
        }
        vt->texture->setTexParameters(&vt->m_texParams);
    }

    isReloading = false;
}

#endif // CC_ENABLE_CACHE_TEXTURE_DATA

NS_CC_END

