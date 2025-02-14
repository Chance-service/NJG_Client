#include "LibPlatformForScript.h"
#include "CCLuaEngine.h"
USING_NS_CC;

#define RUN_SCRIPT_FUN(funname) \
	if(mScriptHandler) \
{ \
	CCLuaEngine::defaultEngine()->executeClassFunc(mScriptHandler,funname,this,"LibPlatformScriptListener"); \
}
std::string LibPlatformScriptListener::onReceiveCommonMessage(const std::string& tag, const std::string& msg)
{
	/*
	ÒW¢ï?ÒZ¾ììÙ
	*/
	PlatformMsgInfo info;
	info.mMsgFunname = tag;
	info.mMsgValue = msg;
	mAllPlatformMsg.push_back(info);
	return "";
}
LibPlatformScriptListener::LibPlatformScriptListener( int nHandler )
{
	mScriptHandler = nHandler;
	mLibPlatform = NULL;
	mState = false;
	mLog = "";

	mResultStr = "";
	libPlatformManager::getPlatform()->registerListener(this);
	CCLog("lua.......ListenerInit!!!!!!");

	m_pSchedulerLua = CCDirector::sharedDirector()->getScheduler();
	m_pSchedulerLua->scheduleSelector(schedule_selector(LibPlatformScriptListener::update),this,0.1f,false);
	
}

LibPlatformScriptListener::~LibPlatformScriptListener()
{
	libPlatformManager::getPlatform()->removeListener(this);
	if(m_pSchedulerLua)
	{
	//	m_pSchedulerLua->unscheduleUpdateForTarget(this);
		m_pSchedulerLua->unscheduleSelector(schedule_selector(LibPlatformScriptListener::update),this);
	}
}
void LibPlatformScriptListener::update( float dt )
{
	
	if (mAllPlatformMsg.size() > 0)
	{
		std::list<PlatformMsgInfo>::iterator it = mAllPlatformMsg.begin();
		while (it != mAllPlatformMsg.end())
		{
			//mCount = -1;
			//mResultStr = "";
			//mResult = false;
			//Json::Reader jreader;
			//Json::Value data;

			//bool ret = jreader.parse(it->mMsgValue.c_str(), data, false);
			//
			//if (!data["IntValue"].empty())
			//{
			//	mCount = data["IntValue"].asInt();
			//}
			//if (!data["StringValue"].empty())
			//{
			//	mResultStr = data["StringValue"].asString();
			//}
			//if (!data["BoolValue"].empty())
			//{
			//	mResult = data["BoolValue"].asBool();
			//}
			mResultStr = it->mMsgValue;
			RUN_SCRIPT_FUN(it->mMsgFunname.c_str());

			mAllPlatformMsg.erase(it++);
		}
	}
	
}
void LibPlatformScriptListener::onInit( libPlatform* pLibPlatform, bool success, const std::string& log )
{
	mLibPlatform = pLibPlatform;
	mState = success;
	mLog = log;
	RUN_SCRIPT_FUN("onInit");
}

void LibPlatformScriptListener::onUpdate( libPlatform* pLibPlatform, bool success, std::string log )
{
	mLibPlatform = pLibPlatform;
	mState = success;
	mLog = log;
	RUN_SCRIPT_FUN("onUpdate");
}

void LibPlatformScriptListener::onLogin( libPlatform* pLibPlatform, bool success, const std::string& log )
{
	mLibPlatform = pLibPlatform;
	mState = success;
	mLog = log;
	RUN_SCRIPT_FUN("onLogin");
}

void LibPlatformScriptListener::onPlatformLogout( libPlatform* pLibPlatform)
{
	mLibPlatform = pLibPlatform;
	RUN_SCRIPT_FUN("onPlatformLogout");
}

void LibPlatformScriptListener::onBuyinfoSent( libPlatform* pLibPlatform, bool success, const BUYINFO& buyInfo, const std::string& log )
{
	mLibPlatform = pLibPlatform;
	mState = success;
	mLog = log;
	mBuyInfo = buyInfo;
	RUN_SCRIPT_FUN("onBuyinfoSent");
}

void LibPlatformScriptListener::onRequestBindTryUserToOkUser( const char* tyrUin, const char* okUin )
{

}

void LibPlatformScriptListener::onTryUserRegistSuccess()
{
	RUN_SCRIPT_FUN("onTryUserRegistSuccess");
}

void LibPlatformScriptListener::onShareEngineMessage( bool result )
{
	mResult = result;
	RUN_SCRIPT_FUN("onShareEngineMessage");
}

void LibPlatformScriptListener::onMotionShake()
{
	RUN_SCRIPT_FUN("onMotionShake");
}



