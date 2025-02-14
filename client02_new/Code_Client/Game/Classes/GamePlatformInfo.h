#pragma once
#include "lib91.h"
#include "libAndroid.h"
#include "libEfun.h"

#ifdef PROJECT_R2
#include "libR2.h"
#endif

#ifdef PROJECT_R2_AR
#include "libR2Ar.h"
#endif

#ifdef PROJECT_GNETOPSPECIAL_JP
#include "libGNetop.h"
#endif

#ifdef PROJECT_GNETOPNORMAL_JP
#include "libGNetop.h"
#endif

#ifdef PROJECT_GNETOPBACKUP_JP
#include "libGNetop.h"
#endif

#ifdef PROJECT_GNETOPRETAINED_JP
#include "libGNetop.h"
#endif

#ifdef PROJECT_GNETOP_JP
#include "libGNetop.h"
#endif

#ifdef PROJECT_GNETOPSBANK_JP
#include "libGNetopSBank.h"
#endif

#ifdef PROJECT_ENTERMATE
#include "libEntermate.h"
#endif

#ifdef PROJECT_RYUK_JP
#include "libRyuk.h"
#endif

#ifdef PROJECT_RYUK_NEW_JP
#include "libRyukNew.h"
#endif

#ifdef PROJECT_GUAJI_YOUGU
#include "libYouGu.h"
#endif

#ifdef PROJECT_GUAJI_YOUGU_YIJIE
#include "libYouGuYiJie.h"
#endif

#ifdef PROJECT_GUAJI_LONGXIAO
#include "libLongXiao.h"
#endif

#ifdef PROJECT_GUAJI_DEMO
#include "libDemo.h"
#endif

#include "libPP.h"
#include "libAG.h"
#include "libTB.h"
#include "libITools.h"
#include "lib91Debug.h"
#include "lib91Quasi.h"
#include "libAppStore.h"
#include "libYouai.h"
#include "libKY.h"
#include "libCmge.h"
#include "lib37wanwan.h"
#include "libUC.h"
#include "lib49app.h"
#include "libAs.h"
#include "libDownJoy.h"
#include "libUHaima.h"
#include "libXY.h"

class GamePlatformInfo
{
	static GamePlatformInfo *m_sInstance;
	std::string platFormName;
	std::string platVersionName;
    SDK_CONFIG_STU config;
public:
	
	void init(bool isRegPlat=false);
	void registerPlatform();
	std::string getPlatFormName() { return platFormName;};
	std::string getPlatVersionName() { return platVersionName;}
	static GamePlatformInfo* getInstance();
    SDK_CONFIG_STU getPlatFromconfig() { return config;}
};
