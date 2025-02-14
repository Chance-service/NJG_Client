#pragma once

#include "cocos2d.h"

class AdjustManager {
public:
	static void onTrackEvent(std::string eventName);
	
	static void onTrackRevenueEvent(std::string eventName, int num);
};
