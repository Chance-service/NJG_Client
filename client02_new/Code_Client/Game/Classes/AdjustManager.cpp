#include "AdjustManager.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "Adjust/Adjust2dx.h"
#endif
void AdjustManager::onTrackEvent(std::string eventName) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	auto adjustEvent = AdjustEvent2dx(eventName.c_str());
	Adjust2dx::trackEvent(adjustEvent);
#endif
}

void AdjustManager::onTrackRevenueEvent(std::string eventName, int num) {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	auto adjustEvent = AdjustEvent2dx(eventName.c_str());

	adjustEvent.setRevenue(num, "CNY");
	//adjustEvent.setTransactionId("DUMMY_TRANSACTION_ID");

	Adjust2dx::trackEvent(adjustEvent);
#endif
}