#ifndef _LIBPLATFORMFORSCRIPT_H_
#define _LIBPLATFORMFORSCRIPT_H_
#include "libPlatform.h"
#include "cocos2d.h"

using namespace cocos2d;

struct PlatformMsgInfo{
	std::string mMsgValue;
	std::string mMsgTag;
	std::string mMsgFunname;
};
class LibPlatformScriptListener : public CCObject,public platformListener
{
public:
	LibPlatformScriptListener(int nHandler);
	virtual ~LibPlatformScriptListener();

	virtual std::string onReceiveCommonMessage(const std::string& tag, const std::string& msg);
	virtual void onInit(libPlatform*, bool success, const std::string& log);
	virtual void onUpdate(libPlatform*, bool success, std::string log);
	virtual void onLogin(libPlatform*, bool success, const std::string& log);
	virtual void onPlatformLogout(libPlatform*);
	virtual void onBuyinfoSent(libPlatform*, bool success, const BUYINFO&, const std::string& log);
	virtual void onRequestBindTryUserToOkUser(const char* tyrUin, const char* okUin);
	virtual void onTryUserRegistSuccess();
	virtual void onShareEngineMessage(bool result);
	virtual void onMotionShake();

	libPlatform* getLibPlatform(){return mLibPlatform;}
	bool getState(){return mState;}
	std::string getLog(){return mLog;}
	bool getResult(){return mResult;}
	BUYINFO getBuyInfo(){return mBuyInfo;}
	//int getCount(){return mCount;}
	std::string getResultStr(){return mResultStr;}
	void update( float dt );
	//std::string getMsgTag(){ return m_MsgTag; }
	//std::string getMsgValue(){ return m_MsgValue; }
private:
	cocos2d::CCScheduler* m_pSchedulerLua;
	libPlatform* mLibPlatform;
	bool mState;
	std::string mLog;
	int mScriptHandler;
	bool mResult;
	BUYINFO mBuyInfo;

	std::string mResultStr;

	std::list<PlatformMsgInfo> mAllPlatformMsg;
};

#endif