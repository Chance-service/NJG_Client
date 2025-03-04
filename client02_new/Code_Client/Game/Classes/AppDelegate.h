#ifndef  _APP_DELEGATE_H_
#define  _APP_DELEGATE_H_

#include "cocos2d.h"

/**
@brief    The cocos2d Application.

The reason for implement as private inheritance is to hide some interface call by CCDirector.
*/
class  AppDelegate : private cocos2d::CCApplication, public cocos2d::CCObject
{
public:
    AppDelegate();
    virtual ~AppDelegate();

    /**
    @brief    Implement CCDirector and CCScene init code here.
    @return true    Initialize success, app continue.
    @return false   Initialize failed, app terminate.
    */
    virtual bool applicationDidFinishLaunching();

    /**
    @brief  The function be called when the application enter background
    @param  the pointer of the application
    */
    virtual void applicationDidEnterBackground();

    /**
    @brief  The function be called when the application enter foreground
    @param  the pointer of the application
    */
    virtual void applicationWillEnterForeground();

	/*
	*/
	virtual void purgeCachedData(void);

	//--begin xinzheng 2013-6-3
	/*
		GameApp具體實現上層自己的清理
		CCDirector::end()只觸發了引擎層面及內部的清理
	*/
	virtual void applicationWillGoToExit();
	//--end

public:
	//更新
	virtual void  update(float deltaTime);

	//通知清理暫存
	virtual void  notifyPurgeCached();

	//頁面切換
	virtual void  notifyRecycleTex();

	//通知內存過高
	virtual void  checkMemoryWarning(bool forceInst = false);

public:
	virtual void  registerRecycleTex(const std::string& texName);

	virtual void  clearRecycleTex();

	void setMaxCacheByteSizeLimit(unsigned int maxbytes);

protected:
	std::map<std::string, std::string> recycleTex;

protected:
	//purge cache data
	bool	needPurgeCache;
	//page changed purge recycle texture
	bool	needRecycleTex;
	//
	float	delayRecycleSeconds;
	//
	unsigned int max_cache_bytes;
	//android 清除紋理暫存開關 0關 1開
	bool m_IsOpenPurgeCacheAndroid;
	//IOS 清除紋理暫存開關 0關 1開
	bool m_IsOpenPurgeCacheIOS;
};

void registerRecycleTex(const std::string& texName);

extern AppDelegate* g_AppDelegate;

#endif // _APP_DELEGATE_H_

