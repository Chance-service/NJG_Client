#include "GamePlatformInfo.h"
#include "libPlatform.h"
#include "platform/CCPlatformConfig.h"
#include "libOS.h"

GamePlatformInfo * GamePlatformInfo::m_sInstance = 0;

GamePlatformInfo* GamePlatformInfo::getInstance()
{
	if(!m_sInstance)
	{
		m_sInstance = new GamePlatformInfo;
		m_sInstance->init();
	}
	return m_sInstance;
}

void GamePlatformInfo::init(bool isRegPlat)
{
    std::string libOSKeychain = "2WLZ3CD2G8.jp.co.school.battle.keychainshare";//xiao dong zhengshu
    config.com4lovesconfig.appid = "gjwow";
    config.com4lovesconfig.sdkappid = "21";
    config.com4lovesconfig.sdkappkey = "gjwow_ios";
#ifdef PROJECT_EXPERIENCE_IOS
		if(isRegPlat) AUTO_REGISTER_PLATFORM(lib91);
		platVersionName="version_experience_ios.cfg";
		platFormName="lib91";
#else
    
#ifdef PROJECT91
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(lib91);
        platVersionName="version_ios_all.cfg";
        platFormName="lib91";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_91";
        
        
        config.platformconfig.appid = "115606";//115601
        config.platformconfig.appkey = "85da6ab16bde4088798ea977f9bf4c227446a88f145ec157";//45a22c2a03c74e685106b5c567bf2370447c3f2c347e9c7c
        config.platformconfig.uidPrefix = "91_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "91";
        config.platformconfig.moneyName = "91;
    }
#endif
#ifdef PROJECTEFUN_EN
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libEfun);
        platVersionName="version_ios_efun_en.cfg";
        platFormName="libEfun";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_efun_en";
        
        config.platformconfig.appid = "34";//115601
        config.platformconfig.appkey = "ios_efun_en";//45a22c2a03c74e685106b5c567bf2370447c3f2c347e9c7c
        config.platformconfig.uidPrefix = "efun_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "efun";
        config.platformconfig.moneyName = "";
    }
#endif
#ifdef PROJECTEFUN_TW
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libEfun);
        platVersionName="version_ios_efun_tw.cfg";
        platFormName="libEfun";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_efun_tw";
        
        config.platformconfig.appid = "34";//115601
        config.platformconfig.appkey = "9CF88F381804FC4B2622AE76409E8D68";//45a22c2a03c74e685106b5c567bf2370447c3f2c347e9c7c
        config.platformconfig.uidPrefix = "efuntw_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "efun";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_R2
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libR2);
        platVersionName="version_ios_r2_en.cfg";
        platFormName="libR2";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_r2_en";
        
        config.platformconfig.appid = "959454720";
        config.platformconfig.appkey = "ios_r2";
        config.platformconfig.uidPrefix = "r2_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "r2";
        config.platformconfig.moneyName = "";
    }
#endif
    
    
#ifdef PROJECT_R2_AR
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libR2Ar);
        platVersionName="version_ios_r2_ar.cfg";
        platFormName="libR2Ar";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_r2_ar";
        
        config.platformconfig.appid = "959454720";
        config.platformconfig.appkey = "ios_r2";
        config.platformconfig.uidPrefix = "r2_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "r2";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_RYUK_NEW_JP
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libRyukNew);
        platVersionName="version_ios_sg.cfg";
        platFormName="libRyukNew";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_hutuo";
        //config.com4lovesconfig.platformid = "sanguo_ios_ks";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_sg";
        config.platformconfig.uidPrefix = "sg_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "sgios";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GUAJI_YOUGU
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libYouGu);
        platVersionName="version_ios_sg.cfg";
        platFormName="libYouGu";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "yougu_channel_ios";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_sg";
        config.platformconfig.uidPrefix = "sg_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "sgios";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GUAJI_YOUGU_YIJIE
    {
        if (isRegPlat) AUTO_REGISTER_PLATFORM(libYouGuYiJie);
        platVersionName="version_ios_sg.cfg";
        platFormName="libYouGuYiJie";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "youguYiJie_channel_ios";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_sg";
        config.platformconfig.uidPrefix = "sg_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "sgios";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GUAJI_LONGXIAO
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libLongXiao);
        platVersionName="version_ios_sg.cfg";
        platFormName="libLongXiao";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "longxiao_channel_ios";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_sg";
        config.platformconfig.uidPrefix = "";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "longxiao_channel_ios";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GUAJI_DEMO
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libDemo);
        platVersionName="version_ios_sg.cfg";
        platFormName="libDemo";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "Demo_channel_ios";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_sg";
        config.platformconfig.uidPrefix = "sg_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "sgios";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_RYUK_JP
    
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libRyukNew);
        platVersionName="version_ios_ryuk_jp.cfg";
        platFormName="libRyuk";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_ryuk_ss";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_ryuk";
        config.platformconfig.uidPrefix = "ryuk_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "ryuk";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GNETOP_JP
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libGNetop);
        platVersionName="version_ios_gnetop_jp.cfg";
        platFormName="libGNetop";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_gnetop_jp";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_gnetop";
        config.platformconfig.uidPrefix = "gnetop_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "gnetop";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GNETOPNORMAL_JP
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libGNetop);
        platVersionName="version_ios_gnetop_jp.cfg";
        platFormName="libGNetop";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_gnetop_jp";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_gnetop";
        config.platformconfig.uidPrefix = "gnetop_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "gnetop";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GNETOPSPECIAL_JP
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libGNetop);
        platVersionName="version_ios_gnetop_jp.cfg";
        platFormName="libGNetop";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_gnetop_jp";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_gnetop";
        config.platformconfig.uidPrefix = "gnetop_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "gnetop";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GNETOPBACKUP_JP
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libGNetop);
        platVersionName="version_ios_gnetop_jp.cfg";
        platFormName="libGNetop";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_gnetop_jp";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_gnetop";
        config.platformconfig.uidPrefix = "gnetop_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "gnetop";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GNETOPRETAINED_JP
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libGNetop);
        platVersionName="version_ios_gnetop_jp.cfg";
        platFormName="libGNetop";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_gnetop_jp";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_gnetop";
        config.platformconfig.uidPrefix = "gnetop_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "gnetop";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_GNETOPSBANK_JP
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libGNetop);
        platVersionName="version_ios_gnetop_jp.cfg";
        platFormName="libGNetop";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_gnetop_jp";
        
        config.platformconfig.appid = "973410592";
        config.platformconfig.appkey = "ios_gnetop";
        config.platformconfig.uidPrefix = "gnetop_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "gnetop";
        config.platformconfig.moneyName = "";
    }
#endif
    
#ifdef PROJECT_ENTERMATE
    {
        if(isRegPlat) AUTO_REGISTER_PLATFORM(libEntermate);
        platVersionName="version_ios_entermate_kr.cfg";
        platFormName="libEntermate";
        
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_entermate_kr";
        
        config.platformconfig.appid = "93207793276619858";
        config.platformconfig.appkey = "ios_entermate";
        config.platformconfig.uidPrefix = "entermate_";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "entermate";
        config.platformconfig.moneyName = "";
    }
#endif 
    
#ifdef PROJECTCMGE
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libCmge);
		platVersionName="version_ios_all.cfg";
		platFormName="libCmge";
	}
#endif
    
#ifdef PROJECTUC
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libUC);
		platVersionName="version_ios_all.cfg";
		platFormName="libUC";
	}
#endif
    
#ifdef PROJECTPP
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libPP);
		platVersionName="version_ios_all.cfg";
		platFormName="libPP";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_pp";
        
        
        config.platformconfig.appid = "4293";//115601
        config.platformconfig.appkey = "f55b314daff2e50c0e168fd548e62b00";//45a22c2a03c74e685106b5c567bf2370447c3f2c347e9c7c
        config.platformconfig.uidPrefix = "PPUSR_";
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "PP";
        config.platformconfig.moneyName = "PP;
	}
#endif
    
#ifdef PROJECTPPZB
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libPPZB);
		platVersionName="version_ios_pp.cfg";
		platFormName="libPPZB";
	}
#endif

#ifdef PROJECT37WANWAN
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(lib37wanwan);
		platVersionName="version_ios_all.cfg";
		platFormName="lib37wanwan";
	}
#endif
    
#ifdef PROJECT49APP
	{
        if(isRegPlat) AUTO_REGISTER_PLATFORM(lib49app);
        platVersionName="version_ios_all.cfg";
        platFormName="lib49app";
	}
#endif

#ifdef PROJECTAG
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libAG);
		platVersionName="version_ios_pp.cfg";
		platFormName="libAG";
	}
#endif

#ifdef PROJECTTB
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libTB);
		platVersionName="version_ios_all.cfg";
		platFormName="libTB";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_tb";
        
        config.platformconfig.appid = "140838";
        config.platformconfig.appkey = "GdTA4Naxm@JhWj7QGSqANCZx0zJWti7F";
        config.platformconfig.uidPrefix = "TBUSR_";
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "TB";
        config.platformconfig.moneyName = "TB";
	}
#endif

#ifdef PROJECTITools
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libITools);
		platVersionName="version_ios_all.cfg";
		platFormName="libITools";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_ito";
        
        config.platformconfig.appid = "438";
        config.platformconfig.appkey = "4981333892356B97E80EEDDC385071D8";
        config.platformconfig.uidPrefix = "ITOUSR_";
        config.platformconfig.bbsurl = "";
        
        config.platformconfig.clientChannel = "ITO";
        config.platformconfig.moneyName = "RMB";
	}
#endif

#ifdef PROJECT91Debug
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(lib91Debug);
		platVersionName="version_debug.cfg";
		platFormName="lib91Debug";
	}
#endif

#ifdef PROJECT91Quasi
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(lib91Quasi);
		platVersionName="version_ios_all.cfg";
		platFormName="lib91Quasi";
	}
#endif

#ifdef PROJECTAPPSTORE
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libAppStore);
		platVersionName="version_ios_all.cfg";
		platFormName="libAppStore";
        
        config.com4lovesconfig.appid = "gjwow";
        config.com4lovesconfig.sdkappid = "22";
        config.com4lovesconfig.sdkappkey = "gjwow_app";
        config.com4lovesconfig.channelid = "902";
        config.com4lovesconfig.platformid = "ios_appstore";
	}
#endif

#ifdef PROJECTAPPSTORETW
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libAppStore);
		platVersionName="version_ios_appstore_tw.cfg";
		platFormName="libAppStore";
	}
#endif



#ifdef PROJECTYOUAI
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libYouai);
        platVersionName="version_ios_all.cfg";
        platFormName="libYouai";
        
        config.com4lovesconfig.channelid = "0";
        config.com4lovesconfig.platformid = "ios_youai";
        
        config.platformconfig.appid = "qmwow.com4loves.com";
        config.platformconfig.appkey = "gjwowioseliqioqockqcnmwte";
        config.platformconfig.uidPrefix = "";
        
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "hutuo";
        config.platformconfig.moneyName = "RMB";
	}
#endif


#ifdef PROJECTKY
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libKY);
		platVersionName="version_ios_all.cfg";
		platFormName="libKY";
        
        config.com4lovesconfig.channelid = "901";
        config.com4lovesconfig.platformid = "ios_ky";

        
        config.platformconfig.appid = "2373fd9fcd8fd32d3f5cdd8824a4256e";
        config.platformconfig.appkey = "Z1b8QiK5HohimgBEAKd27rG4e6Q0qImp";
        config.platformconfig.uidPrefix = "KYUSR_";
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "KY";
        config.platformconfig.moneyName = "RMB";
        config.platformconfig.appScheme = "6129";
	}
#endif

#ifdef PROJECTDownJoy
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libDownJoy);
		platVersionName="version_ios_all.cfg";
		platFormName="libDownJoy";
	}
#endif

#ifdef PROJECTUHAIMA
    if(isRegPlat) AUTO_REGISTER_PLATFORM(libUHaima);
    platVersionName="version_ios_all.cfg";
    platFormName="libUHaima";
    
    config.com4lovesconfig.channelid = "1130";
    config.com4lovesconfig.platformid = "ios_haima";
    
    config.platformconfig.appid = "3000910897";
    config.platformconfig.appkey = "NjBGNDVEMDUyMzUxM0VDMjIxMDU4OTNFMDY3MDBDMDMyOUM5QzAwRk9UTXpOekl5TVRVek9UZzRNRE01TVRBek55c3hOelExTnprek9USXpNemMwT1RNNE1EWXpOak00TVRVeE1EQTVOemN6TURZME5qa3dNVGM9";
    config.platformconfig.uidPrefix = "HAIMAUSR_";
    config.platformconfig.bbsurl = "";
    config.platformconfig.clientChannel = "haima";
    config.platformconfig.moneyName = "RMB";
#endif
    
#ifdef PROJECTXY
    {
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libXY);
		platVersionName="version_ios_all.cfg";
		platFormName="libXY";
        
        config.com4lovesconfig.channelid = "1123";//xy:1123,xy1:1193,xy2:1194
        config.com4lovesconfig.platformid = "ios_xy";
        
        config.platformconfig.appid = "100001449";//xy:100001449;xy3:100002405
        config.platformconfig.appkey = "0nbgXBRKtwatWw7lAYBIVdkXCgYhhOS2";//xy:0nbgXBRKtwatWw7lAYBIVdkXCgYhhOS2;xy3:mb4osQ39PXncw43xq3s1QnxtH99Z6nDi
        config.platformconfig.uidPrefix = "XYUSR_";
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "xy";
        config.platformconfig.moneyName = "RMB";
	}
#endif
    
    
#ifdef PROJECT44755
    {
		if(isRegPlat) AUTO_REGISTER_PLATFORM(lib44755);
		platVersionName="version_ios_all.cfg";
		platFormName="lib44755";
	}
#endif

#ifdef PROJECTAPPSTOREDEBUG
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libAppStore);
		platVersionName="version_ios_appstore_debug.cfg";
		platFormName="libAppStore";
	}
#endif
    
#ifdef PROJECTAS
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libAs);
		platVersionName="version_ios_all.cfg";
		platFormName="libAs";
        
        config.com4lovesconfig.channelid = "123";
        config.com4lovesconfig.platformid = "ios_as";
        
        config.platformconfig.appid = "225";
        config.platformconfig.appkey = "b3e68abf68574c739556163fca085f21";
        config.platformconfig.uidPrefix = "ASUSR_";
        config.platformconfig.bbsurl = "";
        config.platformconfig.clientChannel = "as";
        config.platformconfig.moneyName = "RMB";
	}
#endif

#ifdef WIN32
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(lib91);
		platVersionName="version_win32.cfg";
		platFormName="lib91";
	}
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	{
		if(isRegPlat) AUTO_REGISTER_PLATFORM(libAndroid);
		platVersionName="version_android.cfg";
		platFormName="libAndroid";
	}
#endif
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    {
        libOS::getInstance()->setKeyChainUDIDGroup(libOSKeychain);
        GAME_CONFIG_STU gameConfig;
        gameConfig.gameid = config.com4lovesconfig.sdkappid;
        gameConfig.channel  = "android_BC";
        gameConfig.mtaEnable = false;
        gameConfig.flurryEnable = true;
        gameConfig.mta_key = "IPI6IR1NR34Q";
        libOS::getInstance()->initGameConfig(gameConfig);
        if(isRegPlat) AUTO_REGISTER_PLATFORM(lib91);
        platVersionName="version_ios.cfg";
        platFormName="lib91";
    }
#endif
    libOS::getInstance()->setConnector("#");

	if(isRegPlat)
	{
		libPlatformManager::getInstance()->setPlatform(platFormName);
	}
}

void GamePlatformInfo::registerPlatform()
{
	init(true);
}
