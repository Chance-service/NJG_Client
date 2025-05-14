#ifndef  _ECCHIGAMER_CONFIG_H_
#define  _ECCHIGAMER_CONFIG_H_

namespace ecchigamer
{
	namespace Config
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        static inline const char* EroR18_GAME_ID = "128";
		static inline const char* Erolabs_GAME_ID = "116";
#else
		const char* EroR18_GAME_ID = "128";
		const char* Erolabs_GAME_ID = "116";
#endif
	}
};

#endif // _ECCHIGAMER_CONFIG_H_

