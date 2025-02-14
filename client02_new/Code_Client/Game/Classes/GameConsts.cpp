
#include "stdafx.h"

#include "GameConsts.h"

GameConst* GameConst::getInstance()
{
	 return GameConst::Get(); 
}

long GameConst::getCurrTime()
{
	struct cc_timeval now;

	CCTime::gettimeofdayCocos2d(&now, NULL);

	return (now.tv_sec * 1000 + now.tv_usec / 1000);
}
