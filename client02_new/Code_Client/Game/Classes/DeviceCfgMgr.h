#pragma once
#include "cocos2d.h"
#include "Singleton.h"

USING_NS_CC;

/*
*硬體設定管理器，用於給一些特效提供硬體參數
*/

enum DeviceBlurType
{
	DeviceBlurType_Low = 1,				//低
	DeviceBlurType_Middle = 2,			//中
	DeviceBlurType_High = 3,			//高
};

class DeviceCfgMgr
	:public Singleton<DeviceCfgMgr>
{
public:
	DeviceCfgMgr();
	~DeviceCfgMgr();

	int getDeviceBlurType();

	//for lua
	static DeviceCfgMgr* getInstance();
};



