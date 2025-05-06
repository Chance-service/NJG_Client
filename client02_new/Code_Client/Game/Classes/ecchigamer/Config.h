#ifndef  _ECCHIGAMER_CONFIG_H_
#define  _ECCHIGAMER_CONFIG_H_

namespace ecchigamer
{
	namespace Config
    {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        static inline const char* GAME_ID = "128";
#else
		const char* GAME_ID = "128";
#endif
	}
};

#endif // _ECCHIGAMER_CONFIG_H_

