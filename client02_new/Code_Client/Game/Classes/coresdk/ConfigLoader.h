#ifndef  _CORESDK_CONFIG_LOADER_H_
#define  _CORESDK_CONFIG_LOADER_H_

#include "cocos2d.h"
#include "Config.h"

namespace coresdk {
	class ConfigLoader : public cocos2d::CCObject
	{
	public:
		typedef void(*OnInitializeCallback)(bool, coresdk::Config);	// isSuccess, Config

	public:
		static std::string configFilename;

	public:
		void initialize(OnInitializeCallback callback);

	public:
		ConfigLoader();

	public:
		void parseDomainJson(std::string json);
		void updateConfig();
		void findLoginDomain();
	};
}

#endif // _CORESDK_CONFIG_LOADER_H_

