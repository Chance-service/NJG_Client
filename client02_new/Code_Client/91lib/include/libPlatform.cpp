#include "libPlatform.h"
#include "libOS.h"
#include <assert.h>
#include <string>

#if !defined(WIN32) && !defined(ANDROID)
#include <sys/sysctl.h>
#include <mach/mach.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
#endif

libPlatformManager * libPlatformManager::m_sInstance = 0;

libPlatformManager* libPlatformManager::getInstance()
{
//    libOS::getInstance()->setShareWeChatCallBackDisabled();
	if(!m_sInstance)m_sInstance = new libPlatformManager;
	return m_sInstance;
}


void libPlatformManager::setPlatform( std::string name )
{
	assert(mPlatforms.find(name)!=mPlatforms.end());
	m_sPlatform = mPlatforms.find(name)->second;	
}

bool libPlatformManager::registerPlatform( std::string name, libPlatform* platform )
{
	assert(mPlatforms.find(name)==mPlatforms.end());
	
	mPlatforms.insert(std::make_pair(name,platform));
	return true;
}

void libPlatform::updateApp(std::string& storeURL)
{
    
}

void libPlatform::logout()
{

}

void libPlatform::switchUsers()
{

}

void libPlatform::buyGoods( BUYINFO& )
{

}

void libPlatform::openBBS()
{

}

void libPlatform::userFeedBack()
{

}

void libPlatform::gamePause()
{

}


const std::string libPlatform::getPlatformInfo()
{
    return libOS::getInstance()->getPlatformInfo() + libOS::getInstance()->getConnector() + getClientChannel();
}

const std::string& libPlatform::sessionID()
{
	static std::string ret = "";
	return ret;
}

const std::string& libPlatform::nickName()
{
	static std::string ret = "";
	return ret;
}

bool libPlatform::getIsTryUser()
{
	return false;
}

void libPlatform::callPlatformBindUser()
{

}

void libPlatform::notifyGameSvrBindTryUserToOkUserResult( int result )
{

}

void libPlatform::notifyEnterGame()
{

}

const float libPlatform::getPlatformChangeRate()
{
	return 1.0f;
}

void libPlatform::setToolBarVisible( bool isShow )
{

}
void libPlatform::onShareEngineMessage(bool _result)
{
	 libOS::getInstance()->boardcastMessageShareEngine(_result, "");
}
void libPlatform::onPlayMovieEnd()
{
	 libOS::getInstance()->boardcastMessageOnPlayEnd();
}
void libPlatform::onMotionShake()
{
	libOS::getInstance()->boardcastMotionShakeMessage();
}
// void libPlatform::createRole(const std::string &serverID)
// {
// 	libOS::getInstance()->createRole(serverID);
// }

void libPlatform::onFBShareBack(bool success)
{
	libOS::getInstance()->boardcastMessageonFBShareBack(success);
}
void libPlatform::final()
{

}

void libPlatform::OnKrGetInviteCount()
{

}

void libPlatform::OnKrgetInviteLists()
{

}

void libPlatform::OnKrgetFriendLists()
{

}

void libPlatform::OnKrsendInvite( const std::string& strUserId, const std::string& strServerId )
{

}

void libPlatform::OnKrgetGiftLists()
{

}

void libPlatform::OnKrReceiveGift( const std::string& strGiftId, const std::string& strServerId )
{

}

void libPlatform::OnKrGetGiftCount()
{

}

void libPlatform::OnKrSendGift( const std::string& strUserName, const std::string& strServerId )
{

}

void libPlatform::OnKrGiftBlock( bool bVisible )
{

}

void libPlatform::OnKrGetKakaoId()
{

}

void libPlatform::OnKrLoginGames()
{

}

void libPlatform::setLanguageName( const std::string& lang )
{

}

void libPlatform::setPlatformName(int platform)
{

}

const unsigned int libPlatform::getPlatformId()
{
	return 0;
}

void libPlatform::setPayR18(int mid, int serverid, const std::string& url)
{

}

void libPlatform::OnKrIsShowFucForIOS()
{

}

void libPlatform::setH365Check(const bool swit)
{

}
