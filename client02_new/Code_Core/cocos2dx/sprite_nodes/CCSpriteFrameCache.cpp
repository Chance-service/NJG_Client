/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2009      Jason Booth
Copyright (c) 2009      Robert J Payne
Copyright (c) 2011      Zynga Inc.

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

#include "cocoa/CCNS.h"
#include "ccMacros.h"
#include "textures/CCTextureCache.h"
#include "CCSpriteFrameCache.h"
#include "CCSpriteFrame.h"
#include "CCSprite.h"
#include "support/TransformUtils.h"
#include "platform/CCFileUtils.h"
#include "cocoa/CCString.h"
#include "cocoa/CCArray.h"
#include "cocoa/CCDictionary.h"
#include "CCDirector.h"
#include "CCScheduler.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "../core/include/SeverConsts.h"
#endif
#include <vector>

using namespace std;

NS_CC_BEGIN

static CCSpriteFrameCache *pSharedSpriteFrameCache = NULL;

CCSpriteFrameCache* CCSpriteFrameCache::sharedSpriteFrameCache(void)
{
    if (! pSharedSpriteFrameCache)
    {
        pSharedSpriteFrameCache = new CCSpriteFrameCache();
        pSharedSpriteFrameCache->init();
    }

    return pSharedSpriteFrameCache;
}

void CCSpriteFrameCache::purgeSharedSpriteFrameCache(void)
{
    CC_SAFE_RELEASE_NULL(pSharedSpriteFrameCache);
}

void CCSpriteFrameCache::purgeSpriteFramesAndFileNames(void)
{
	m_pSpriteFramesAndFileNames.clear();
}

bool CCSpriteFrameCache::init(void)
{
    m_pSpriteFrames= new CCDictionary();
    m_pSpriteFramesAliases = new CCDictionary();
    m_pLoadedFileNames = new std::set<std::string>();
	m_pSpriteFramesAndFileNames.clear();
	CCDirector::sharedDirector()->getScheduler()->scheduleUpdateForTarget(this,0,false);
    return true;
}

CCSpriteFrameCache::~CCSpriteFrameCache(void)
{
	m_elementToRemove.clear();
    CC_SAFE_RELEASE(m_pSpriteFrames);
    CC_SAFE_RELEASE(m_pSpriteFramesAliases);
    CC_SAFE_DELETE(m_pLoadedFileNames);

	CCDirector::sharedDirector()->getScheduler()->unscheduleAllForTarget(this);
}

void CCSpriteFrameCache::addSpriteFramesWithDictionary(CCDictionary* dictionary, CCTexture2D *pobTexture)
{
    /*
    Supported Zwoptex Formats:

    ZWTCoordinatesFormatOptionXMLLegacy = 0, // Flash Version
    ZWTCoordinatesFormatOptionXML1_0 = 1, // Desktop Version 0.0 - 0.4b
    ZWTCoordinatesFormatOptionXML1_1 = 2, // Desktop Version 1.0.0 - 1.0.1
    ZWTCoordinatesFormatOptionXML1_2 = 3, // Desktop Version 1.0.2+
    */

    CCDictionary *metadataDict = (CCDictionary*)dictionary->objectForKey("metadata");
    CCDictionary *framesDict = (CCDictionary*)dictionary->objectForKey("frames");
    int format = 0;

    // get the format
    if(metadataDict != NULL) 
    {
        format = metadataDict->valueForKey("format")->intValue();
    }

    // check the format
    CCAssert(format >=0 && format <= 3, "format is not supported for CCSpriteFrameCache addSpriteFramesWithDictionary:textureFilename:");

    CCDictElement* pElement = NULL;
    CCDICT_FOREACH(framesDict, pElement)
    {
        CCDictionary* frameDict = (CCDictionary*)pElement->getObject();
        std::string spriteFrameName = pElement->getStrKey();
        CCSpriteFrame* spriteFrame = (CCSpriteFrame*)m_pSpriteFrames->objectForKey(spriteFrameName);
        if (spriteFrame)
        {
            continue;
        }
        
        if(format == 0) 
        {
            float x = frameDict->valueForKey("x")->floatValue();
            float y = frameDict->valueForKey("y")->floatValue();
            float w = frameDict->valueForKey("width")->floatValue();
            float h = frameDict->valueForKey("height")->floatValue();
            float ox = frameDict->valueForKey("offsetX")->floatValue();
            float oy = frameDict->valueForKey("offsetY")->floatValue();
            int ow = frameDict->valueForKey("originalWidth")->intValue();
            int oh = frameDict->valueForKey("originalHeight")->intValue();
            // check ow/oh
            if(!ow || !oh)
            {
                CCLOGWARN("cocos2d: WARNING: originalWidth/Height not found on the CCSpriteFrame. AnchorPoint won't work as expected. Regenrate the .plist");
            }
            // abs ow/oh
            ow = abs(ow);
            oh = abs(oh);
            // create frame
            spriteFrame = new CCSpriteFrame();
            spriteFrame->initWithTexture(pobTexture, 
                                        CCRectMake(x, y, w, h), 
                                        false,
                                        CCPointMake(ox, oy),
                                        CCSizeMake((float)ow, (float)oh)
                                        );
        } 
        else if(format == 1 || format == 2) 
        {
            CCRect frame = CCRectFromString(frameDict->valueForKey("frame")->getCString());
            bool rotated = false;

            // rotation
            if (format == 2)
            {
                rotated = frameDict->valueForKey("rotated")->boolValue();
            }

            CCPoint offset = CCPointFromString(frameDict->valueForKey("offset")->getCString());
            CCSize sourceSize = CCSizeFromString(frameDict->valueForKey("sourceSize")->getCString());

            // create frame
            spriteFrame = new CCSpriteFrame();
            spriteFrame->initWithTexture(pobTexture, 
                frame,
                rotated,
                offset,
                sourceSize
                );
        } 
        else if (format == 3)
        {
            // get values
            CCSize spriteSize = CCSizeFromString(frameDict->valueForKey("spriteSize")->getCString());
            CCPoint spriteOffset = CCPointFromString(frameDict->valueForKey("spriteOffset")->getCString());
            CCSize spriteSourceSize = CCSizeFromString(frameDict->valueForKey("spriteSourceSize")->getCString());
            CCRect textureRect = CCRectFromString(frameDict->valueForKey("textureRect")->getCString());
            bool textureRotated = frameDict->valueForKey("textureRotated")->boolValue();

            // get aliases
            CCArray* aliases = (CCArray*) (frameDict->objectForKey("aliases"));
            CCString * frameKey = new CCString(spriteFrameName);

            CCObject* pObj = NULL;
            CCARRAY_FOREACH(aliases, pObj)
            {
                std::string oneAlias = ((CCString*)pObj)->getCString();
                if (m_pSpriteFramesAliases->objectForKey(oneAlias.c_str()))
                {
                    CCLOGWARN("cocos2d: WARNING: an alias with name %s already exists", oneAlias.c_str());
                }

                m_pSpriteFramesAliases->setObject(frameKey, oneAlias.c_str());
            }
            frameKey->release();
            // create frame
            spriteFrame = new CCSpriteFrame();
            spriteFrame->initWithTexture(pobTexture,
                            CCRectMake(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height),
                            textureRotated,
                            spriteOffset,
                            spriteSourceSize);
        }

        // add sprite frame
        m_pSpriteFrames->setObject(spriteFrame, spriteFrameName);
        spriteFrame->release();
#if COCOS2D_DEBUG > 0
		spriteFrame->setSpriteFrameName(spriteFrameName.c_str());
		spriteFrame->setSourceInfo(pobTexture->sourceInfo());
#endif
    }
}

void CCSpriteFrameCache::addSpriteFramesWithFile(const char *pszPlist, CCTexture2D *pobTexture)
{
    std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(pszPlist);
    CCDictionary *dict = CCDictionary::createWithContentsOfFileThreadSafe(fullPath.c_str());
    
    CCLOG("addSpriteFramesWithFile:%s", pszPlist);

#if COCOS2D_DEBUG > 0
	{
		char tmp[256] = {0};
		strcpy(tmp, pobTexture->sourceInfo());
		if (tmp[strlen(tmp)-1] == ']')
		{
			CCAssert(false, "what's wrong"); 
		}
		strcat(tmp,"[");
		strcat(tmp,pszPlist);
		strcat(tmp,"]");
		pobTexture->setSourceInfo(tmp);
	}
#endif

    addSpriteFramesWithDictionary(dict, pobTexture);

    dict->release();
}

void CCSpriteFrameCache::addSpriteFramesWithFile(const char* plist, const char* textureFileName)
{
    CCAssert(textureFileName, "texture name should not be null");
    CCTexture2D *texture = CCTextureCache::sharedTextureCache()->addImage(textureFileName);

    if (texture)
    {
        addSpriteFramesWithFile(plist, texture);
    }
    else
    {
        CCLOG("cocos2d: CCSpriteFrameCache: couldn't load texture file. File not found %s", textureFileName);
    }
}

void CCSpriteFrameCache::addSpriteFramesWithFile(const char *pszPlist)
{
    CCAssert(pszPlist, "plist filename should not be NULL");
	/*
		removeUnusedSpriteFrames and other places which not call m_pLoadedFileNames->clear(); will cause this assert
	*/
	//CCAssert(m_pLoadedFileNames->find(pszPlist) == m_pLoadedFileNames->end(), "has loaded the same plist file");

    //if (m_pLoadedFileNames->find(pszPlist) == m_pLoadedFileNames->end())
    //{
        std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(pszPlist);
        CCDictionary *dict = CCDictionary::createWithContentsOfFileThreadSafe(fullPath.c_str());

        string texturePath("");

        CCDictionary* metadataDict = (CCDictionary*)dict->objectForKey("metadata");
        if (metadataDict)
        {
            // try to read  texture file name from meta data
            texturePath = metadataDict->valueForKey("textureFileName")->getCString();
        }

        if (! texturePath.empty())
        {
            // build texture path relative to plist file
            texturePath = CCFileUtils::sharedFileUtils()->fullPathFromRelativeFile(texturePath.c_str(), pszPlist);
        }
        else
        {
            // build texture path by replacing file extension
            texturePath = pszPlist;

            // remove .xxx
            size_t startPos = texturePath.find_last_of("."); 
            texturePath = texturePath.erase(startPos);

            // append .png
            texturePath = texturePath.append(".png");

#if COCOS2D_DEBUG > 0
            CCLOG("cocos2d: CCSpriteFrameCache: Trying to use file %s as texture", texturePath.c_str());
#endif
        }

        CCTexture2D *pTexture = CCTextureCache::sharedTextureCache()->addImage(texturePath.c_str());

        if (pTexture)
        {
#if COCOS2D_DEBUG > 0
			{
				char tmp[256] = {0};
				strcpy(tmp, pTexture->sourceInfo());
				if (tmp[strlen(tmp)-1] == ']')
				{
					//CCAssert(false, "what's wrong"); 
				}
				else
				{
					strcat(tmp,"[");
					strcat(tmp,pszPlist);
					strcat(tmp,"]");
					pTexture->setSourceInfo(tmp);
				}
			}
#endif
			//
			addSpriteFramesWithDictionary(dict, pTexture);
			m_pLoadedFileNames->insert(pszPlist);
        }
        else
        {
            CCLOG("cocos2d: CCSpriteFrameCache: Couldn't load texture");
        }

        dict->release();
    }

void CCSpriteFrameCache::addSpriteFramesNameWithFile( const char *pszPlist )
{
	std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(pszPlist);
	CCDictionary *dictionary = CCDictionary::createWithContentsOfFileThreadSafe(fullPath.c_str());
	if (!dictionary)
	{
		return;
	}
	dictionary->autorelease();
	CCDictionary *framesDict = (CCDictionary*)dictionary->objectForKey("frames");
	if(!framesDict)
	{
		CCLOG("cocos2d: addSpriteFramesNameWithFile: can not find spriteFrameName: '%s'!", pszPlist);
		return;
	}
	CCDictElement* pElement = NULL;
	CCDICT_FOREACH(framesDict, pElement)
	{
		std::string spriteFrameName = pElement->getStrKey();

#if !defined(COCOS2D_DEBUG) || COCOS2D_DEBUG == 0
#else
		if(m_pSpriteFramesAndFileNames.find(spriteFrameName) != m_pSpriteFramesAndFileNames.end())
		{
			CCLOG("cocos2d: addSpriteFramesNameWithFile: spriteFrameName '%s' already loaded!", spriteFrameName.c_str());
		}
#endif // COCOS2D_DEBUG
		
		m_pSpriteFramesAndFileNames[spriteFrameName]=pszPlist;
	}
}

void CCSpriteFrameCache::addSpriteFrame(CCSpriteFrame *pobFrame, const char *pszFrameName)
{
	CCAssert(false, "CCSpriteFrameCache::addSpriteFrame not use");
    m_pSpriteFrames->setObject(pobFrame, pszFrameName);
}

void CCSpriteFrameCache::removeSpriteFrames(void)
{
    m_pSpriteFrames->removeAllObjects();
    m_pSpriteFramesAliases->removeAllObjects();
    m_pLoadedFileNames->clear();
}

void CCSpriteFrameCache::removeUnusedSpriteFrames(void)
{
	if (CCTextureCache::sharedTextureCache()->isBetterNeedToClearCache() == false)
	{
		return;//Cache策略，纹理内存降下来了就不频繁遍历了
	}
    bool bRemoved = false;
    CCDictElement* pElement = NULL;
    CCDICT_FOREACH(m_pSpriteFrames, pElement)
    {
        CCSpriteFrame* spriteFrame = (CCSpriteFrame*)pElement->getObject();
        if( spriteFrame->retainCount() == 1 ) 
        {
#if COCOS2D_DEBUG > 0
            //CCLOG("cocos2d: CCSpriteFrameCache: removing unused frame: %s", pElement->getStrKey());
#endif
            m_pSpriteFrames->removeObjectForElememt(pElement);			
            bRemoved = true;
        }

		// fixed crash by lct at 2014/03/13
		for (std::list<CCDictElement*>::iterator it_m = m_elementToRemove.begin(); it_m != m_elementToRemove.end(); it_m ++)
		{
			if (*it_m == pElement)
			{
				m_elementToRemove.erase(it_m);
				break;
			}
		}
		// end lct
    }

    // XXX. Since we don't know the .plist file that originated the frame, we must remove all .plist from the cache
    // zhengxin remove at 2013-12-14 for exactly check plist using status
	/*if( bRemoved )
    {
        m_pLoadedFileNames->clear();
    }*/
}

void CCSpriteFrameCache::removeUnusedSpriteFramesPerFrame()
{
	//if (CCTextureCache::sharedTextureCache()->isBetterNeedToClearCache() == false)
	//{
	//	return;//Cache策略，纹理内存降下来了就不频繁遍历了
	//}
	//
	if(!m_elementToRemove.empty())
	{
		return;
	}
	m_elementToRemove.clear();
	CCDictElement* pElement = NULL;
	CCDICT_FOREACH(m_pSpriteFrames, pElement)
	{
		CCSpriteFrame* spriteFrame = (CCSpriteFrame*)pElement->getObject();
		if( spriteFrame->retainCount() == 1 ) 
		{
			m_elementToRemove.push_back(pElement);
		}
	}
}

void CCSpriteFrameCache::update(float dt)
{
	for ( int i = 0; i < 2 && m_elementToRemove.size(); ++i )
	{
		std::list<CCDictElement*>::iterator iter = m_elementToRemove.begin();
		if ( (*iter) )
		{ 
			CCObject* obj = (*iter)->getObject();
			if ( obj && obj->retainCount() == 1 )
			{				
#if COCOS2D_DEBUG > 0
				//CCLOG("cocos2d: CCSpriteFrameCache: removing unused frame per frame: %s", (*iter)->getStrKey());
#endif	
				m_pSpriteFrames->removeObjectForElememt(*iter);
			}
		}
		m_elementToRemove.erase(iter);
	}
}

void CCSpriteFrameCache::removeSpriteFrameByName(const char *pszName)
{
    // explicit nil handling
    if( ! pszName )
    {
        return;
    }

    // Is this an alias ?
    CCString* key = (CCString*)m_pSpriteFramesAliases->objectForKey(pszName);

    if (key)
    {
        m_pSpriteFrames->removeObjectForKey(key->getCString());
        m_pSpriteFramesAliases->removeObjectForKey(key->getCString());
    }
    else
    {
        m_pSpriteFrames->removeObjectForKey(pszName);
    }

    // XXX. Since we don't know the .plist file that originated the frame, we must remove all .plist from the cache
    // zhengxin remove at 2013-12-14 for exactly check plist using status
	//m_pLoadedFileNames->clear();
}

void CCSpriteFrameCache::removeSpriteFramesFromFile(const char* plist)
{
    std::string fullPath = CCFileUtils::sharedFileUtils()->fullPathForFilename(plist);
    CCDictionary* dict = CCDictionary::createWithContentsOfFileThreadSafe(fullPath.c_str());

    removeSpriteFramesFromDictionary((CCDictionary*)dict);

    // remove it from the cache
    set<string>::iterator ret = m_pLoadedFileNames->find(plist);
    if (ret != m_pLoadedFileNames->end())
    {
        m_pLoadedFileNames->erase(ret);
    }

    dict->release();
}

void CCSpriteFrameCache::removeSpriteFramesFromDictionary(CCDictionary* dictionary)
{
    CCDictionary* framesDict = (CCDictionary*)dictionary->objectForKey("frames");
    CCArray* keysToRemove = CCArray::create();

    CCDictElement* pElement = NULL;
    CCDICT_FOREACH(framesDict, pElement)
    {
        if (m_pSpriteFrames->objectForKey(pElement->getStrKey()))
        {
            keysToRemove->addObject(CCString::create(pElement->getStrKey()));
        }
    }

    m_pSpriteFrames->removeObjectsForKeys(keysToRemove);
}

void CCSpriteFrameCache::removeSpriteFramesFromTexture(CCTexture2D* texture)
{
    CCArray* keysToRemove = CCArray::create();

    CCDictElement* pElement = NULL;
    CCDICT_FOREACH(m_pSpriteFrames, pElement)
    {
        string key = pElement->getStrKey();
        CCSpriteFrame* frame = (CCSpriteFrame*)m_pSpriteFrames->objectForKey(key.c_str());
        if (frame && (frame->getTexture() == texture))
        {
            keysToRemove->addObject(CCString::create(pElement->getStrKey()));
        }
    }

    m_pSpriteFrames->removeObjectsForKeys(keysToRemove);
}

CCArray* CCSpriteFrameCache::getSpriteFramesFromTexture(CCTexture2D* texture)
{
	CCArray* keysToRet = CCArray::create();

	CCDictElement* pElement = NULL;
	CCDICT_FOREACH(m_pSpriteFrames, pElement)
	{
		string key = pElement->getStrKey();
		CCSpriteFrame* frame = (CCSpriteFrame*)m_pSpriteFrames->objectForKey(key.c_str());
		if (frame && (frame->getTexture() == texture))
		{
			keysToRet->addObject(frame);
		}
	}

	return keysToRet;
}


CCSpriteFrame* CCSpriteFrameCache::spriteFrameByName(const char *pszName)
{
	std::string path(pszName);
	std::string::size_type pos = path.find_last_of("/");
	if(pos != std::string::npos)
		path = path.substr(pos+1);

	pszName = path.c_str();
	string name = "Icon_Hcoin";
	int findPos = path.find(name);
	if (findPos != std::string::npos){
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		if (SeverConsts::Get()->IsH365()) {
			pszName = "Icon_Hcoin.png";
		}
		else if (SeverConsts::Get()->IsEroR18()) {
			pszName = "Icon_Hcoin_r18.png";
		}
		else if (SeverConsts::Get()->IsKUSO()) {
			pszName = "Icon_Hcoin_kuso.png";
		}
		else if (SeverConsts::Get()->IsErolabs()) {
			pszName = "Icon_Hcoin_erolabs.png";
		}
		else if (SeverConsts::Get()->IsOP()) {
			pszName = "Icon_Hcoin_op.png";
		}
		else if (SeverConsts::Get()->IsAPLUS()) {
			pszName = "Icon_Hcoin_aplus.png";
		}
#endif
	}	
    CCSpriteFrame* frame = (CCSpriteFrame*)m_pSpriteFrames->objectForKey(pszName);
	
#ifdef TEXTURE_CHECKING
	std::map<std::string, std::string>::iterator itr = m_pSpriteFramesAndFileNames.find(pszName);
	if(itr != m_pSpriteFramesAndFileNames.end())
	{
		std::string plistFileName = itr->second;
		std::size_t found = plistFileName.find("mainScene");
		if (found==std::string::npos){
			CCLog("@CCSpriteFrameCache::spriteFrameByName-- sprite frame name is %s, plist name is %s",pszName,itr->second.c_str());
		}
	}
#endif
	
    if (!frame)
    {
        // try alias dictionary
        CCString *key = (CCString*)m_pSpriteFramesAliases->objectForKey(pszName);  
        if (key)
        {
            frame = (CCSpriteFrame*)m_pSpriteFrames->objectForKey(key->getCString());
//             if (! frame)
//             {
//                 CCLOG("cocos2d: CCSpriteFrameCache: Frame '%s' not found", pszName);
//             }
        }
    }

	if(!frame)
	{
		std::map<std::string, std::string>::iterator itr = m_pSpriteFramesAndFileNames.find(pszName);
		if(itr != m_pSpriteFramesAndFileNames.end())
		{
			addSpriteFramesWithFile(itr->second.c_str());
			frame = (CCSpriteFrame*)m_pSpriteFrames->objectForKey(pszName);
			if (!frame)
			{
				// try alias dictionary
				CCString *key = (CCString*)m_pSpriteFramesAliases->objectForKey(pszName);  
				if (key)
				{
					frame = (CCSpriteFrame*)m_pSpriteFrames->objectForKey(key->getCString());
					if (! frame)
					{
						CCLOG("cocos2d: CCSpriteFrameCache: Frame '%s' not found", pszName);
					}
				}
			}
		}
	}


    return frame;
}

NS_CC_END
