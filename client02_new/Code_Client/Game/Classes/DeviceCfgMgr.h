#pragma once
#include "cocos2d.h"
#include "Singleton.h"

USING_NS_CC;

/*
*�w��]�w�޲z���A�Ω󵹤@�ǯS�Ĵ��ѵw��Ѽ�
*/

enum DeviceBlurType
{
	DeviceBlurType_Low = 1,				//�C
	DeviceBlurType_Middle = 2,			//��
	DeviceBlurType_High = 3,			//��
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



