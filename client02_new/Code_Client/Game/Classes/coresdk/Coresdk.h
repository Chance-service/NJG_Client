#ifndef  _CORESDK_H_
#define  _CORESDK_H_

#include "cocos2d.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "Config.h"
#include "ConfigLoader.h"
#include "WebRequest.h"
#include "Result.h"
#include "APIUtil.h"
#include "Enum.h"
#else
#include "coresdk/Config.h"
#include "coresdk/ConfigLoader.h"
#include "WebRequest.h"
#include "coresdk/Result.h"
#include "coresdk/APIUtil.h"
#include "coresdk/Enum.h"
#endif

namespace coresdk {
	class Coresdk : public cocos2d::CCObject
	{
	public:
		typedef void(*OnInitializeCallback)(bool);
		typedef void(*OnLoginCallback)(ProfileResult);
		typedef void(*OnLogoutCallback)(LogoutResult);
		typedef void(*OnBindCallback)(ProfileResult);

	public:
		static std::string getLoginURL();
		static std::string getToken();
		static void initialize(std::string gameId, std::string applicationIdentifier, Platform platform, OnInitializeCallback callback);
		static Coresdk *getInstance();

	public:
		static void openLogin(OnLoginCallback callback);
		static void openLogout(OnLogoutCallback callback);
		static void openPayment();
		static void openAccountBindGame(std::string game_account, OnBindCallback callback);
		static void postAccountBindGame(std::string game_account, OnBindCallback callback);

	public:
		static std::string prefKeyToken;

	public:
		std::string gameId;
		std::string applicationIdentifier;
		std::string token;
		coresdk::Config config;
		APIUtil *apiUtil;
		std::string platform;

	private:
		ConfigLoader *loader;
	
	};
}

#endif // _CORESDK_H_

