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
		GameApp�����{�W�h�ۤv���M�z
		CCDirector::end()�uĲ�o�F�����h���Τ������M�z
	*/
	virtual void applicationWillGoToExit();
	//--end

public:
	//��s
	virtual void  update(float deltaTime);

	//�q���M�z�Ȧs
	virtual void  notifyPurgeCached();

	//��������
	virtual void  notifyRecycleTex();

	//�q�����s�L��
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
	//android �M�����z�Ȧs�}�� 0�� 1�}
	bool m_IsOpenPurgeCacheAndroid;
	//IOS �M�����z�Ȧs�}�� 0�� 1�}
	bool m_IsOpenPurgeCacheIOS;
};

void registerRecycleTex(const std::string& texName);

extern AppDelegate* g_AppDelegate;

#endif // _APP_DELEGATE_H_

