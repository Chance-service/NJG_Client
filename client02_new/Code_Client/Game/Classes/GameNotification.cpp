#include "GameNotification.h"
#include "lib91.h"
#include <time.h>
#include "GamePrecedure.h"
#include "libOS.h"
#include "DataTableManager.h"
#include "TimeCalculator.h"
#include "Language.h"

const int ONE_DAY_LONG = 24*60*60;

GameNotification::GameNotification(void)
{
}


GameNotification::~GameNotification(void)
{
}

void GameNotification::addNotification()
{
	libOS::getInstance()->addNotification(Language::Get()->getString("@Notification24hours"),ONE_DAY_LONG,false);  
	//power recovered
//	long timeleft = 0;
//	if(TimeCalculator::Get()->getTimeLeft("allPowerRecoverTime",timeleft))
//	{
//		libOS::getInstance()->clearNotification();
//
//		if(VaribleManager::Get()->getSetting("NotificationEatPowerStats")=="1")
//		{
//			//eat chicken and add power
//
//#if defined(ANDROID)
//			/*
//				�ȮɥH�F�K�ɰ� local
//			*/
//			addDailyNotification(12,0,0,Language::Get()->getString("@NotificationEatChicken"));
//			addDailyNotification(18,0,0,Language::Get()->getString("@NotificationEatChicken"));
//#else
//			addDailyNotification(AMSTART_TIME,0,0,Language::Get()->getString("@NotificationEatChicken"));
//			addDailyNotification(PMSTART_TIME,0,0,Language::Get()->getString("@NotificationEatChicken"));
//#endif
//		}
//		
//		if(VaribleManager::Get()->getSetting("NotificationWorldBossStats")=="1")
//		{
//			//world boss
//			int hour = StringConverter::parseInt(VaribleManager::Get()->getSetting("WorldBossOpenHour"));
//			int min = StringConverter::parseInt(VaribleManager::Get()->getSetting("WorldBossOpenMin"));
//#if !defined(ANDROID)
//			/*
//				Android�ȮɥH�F�K�ɰ� local�p��A���M�ڭ̰t���ɶ� �ݭn�����⦨���a�Ҧb�ɰϪ��ɶ�
//			*/
//			hour-=8;
//			if(hour<0)hour+=24;
//#endif
//			addDailyNotification(hour,min,0,Language::Get()->getString("@NotificationWorldBoss"));
//		}
//		
//		if(VaribleManager::Get()->getSetting("NotificationPowerRecoveyStats")=="1")
//		{
//			if(timeleft>0)
//			{
//				CCLOG("notification at %d seconds later: %s",timeleft,Language::Get()->getString("@NotificationPowerRecover").c_str());
//				libOS::getInstance()->addNotification(Language::Get()->getString("@NotificationPowerRecover"),timeleft,false);        
//			}
//		}
//	}
}


void GameNotification::addDailyNotification( int hour, int min, int second, const std::string& msg )
{
//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	/*
		NDK has no timegm function now
	*/
	//return;
//#else

	time_t tempt = time(0); 
	time_t t = tempt;
	if(GamePrecedure::Get()->getServerTime()>0 &&(GamePrecedure::Get()->getServerTime()-tempt>300 || GamePrecedure::Get()->getServerTime()-tempt<-300))
		t = GamePrecedure::Get()->getServerTime();
//#define ANDROID
#if defined(ANDROID)
	struct tm* tm = localtime(&t);
#else
	struct tm* tm=gmtime(&t);
#endif
	struct tm tt = *tm;
	tt.tm_hour = hour;
	tt.tm_min = min;
	tt.tm_sec = second;
#if defined(WIN32)
	time_t targettime = _mkgmtime(&tt);
#elif defined(ANDROID)
	time_t targettime = mktime(&tt);
#else
    time_t targettime = timegm(&tt);
#endif
	if(targettime<t)
		targettime+=ONE_DAY_LONG;
	if(targettime-t>ONE_DAY_LONG)
		targettime-=ONE_DAY_LONG;
//#undef ANDROID
	int timedelay = targettime - t;

	CCLOG("notification at %d seconds later(loop): %s",timedelay,msg.c_str());
	libOS::getInstance()->addNotification(msg,timedelay,true);

//#endif
}
