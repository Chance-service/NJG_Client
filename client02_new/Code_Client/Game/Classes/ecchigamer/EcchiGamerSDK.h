#ifndef  _ECCHI_GAMER_SDK_H_
#define  _ECCHI_GAMER_SDK_H_

#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "Config.h"
#include "cocos2d.h"
#include "Coresdk.h"
#include "util.h"
#include "Enum.h"
#else
#include "ecchigamer/Config.h"
#include "cocos2d.h"
#include "coresdk/Coresdk.h"
#include "coresdk/util.h"
#include "coresdk/Enum.h"
#endif
#include "SeverConsts.h"

namespace ecchigamer {
	namespace EcchiGamerSDK {
		std::string getLoginURL() {
			return coresdk::Coresdk::getLoginURL();
		}

		std::string getToken() {
			return coresdk::Coresdk::getToken();
		}

		void initialize(coresdk::Platform platform, coresdk::Coresdk::OnInitializeCallback callback) {
			coresdk::Coresdk::prefKeyToken = "ecchigamer.token";
			
			std::string applicationIdentifier = coresdk::util::get_package_name();

			std::string GAME_ID = "";
			
			if (SeverConsts::Get()->IsEroR18()){
				GAME_ID = ecchigamer::Config::EroR18_GAME_ID;
				coresdk::ConfigLoader::configFilename = "ecchigamer_domain_v1.txt";
			}
			else {
				GAME_ID = ecchigamer::Config::Erolabs_GAME_ID;
				coresdk::ConfigLoader::configFilename = "erolabs_domain_v1.txt";
			}


			coresdk::Coresdk::initialize(
				GAME_ID,
				applicationIdentifier, 
				platform, 
				callback);
		}

		void openLogin(coresdk::Coresdk::OnLoginCallback callback) {
			coresdk::Coresdk::openLogin(callback);
		}

		void openLogout(coresdk::Coresdk::OnLogoutCallback callback) {
			coresdk::Coresdk::openLogout(callback);
		}

		void openPayment() {
			coresdk::Coresdk::openPayment();
		}

		void openAccountBindGame(std::string game_account, coresdk::Coresdk::OnBindCallback callback) {
			coresdk::Coresdk::openAccountBindGame(game_account, callback);
		}

		void postAccountBindGame(std::string game_account, coresdk::Coresdk::OnBindCallback callback) {
			coresdk::Coresdk::postAccountBindGame(game_account, callback);
		}
	}
}

#endif // _ECCHI_GAMER_SDK_H_

