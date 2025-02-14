#include "DecodeControllerManager.h"


DecodeControllerManager::DecodeControllerManager()
{

}

DecodeControllerManager::~DecodeControllerManager()
{
	destoryAllDecodeControllers();
}

DecodeControllerManager* DecodeControllerManager::getInstance()
{
	return DecodeControllerManager::Get();
}

DecodeController* DecodeControllerManager::createDecodeControllerWithTag(unsigned int rTag)
{
	DecodeController* decodeController = new DecodeController();
	decodeController->setTag(rTag);

	decodeController = _addDecodeControllerToMap(rTag, decodeController);

	return decodeController;
}

DecodeController* DecodeControllerManager::_addDecodeControllerToMap(unsigned int rTag, DecodeController* rDecodeController)
{
	DecodeControllersMap::iterator itr = mDecodeControllersMap.find(rTag);

	if (itr != mDecodeControllersMap.end())
	{
		DecodeController* controller = itr->second;

		if (controller)
		{
			controller->setTag(rTag);
			controller->setOfficerDelegate(NULL);
			controller->setReceptionDelegate(NULL);
	
			delete rDecodeController;
			return controller;
		}
	}

	mDecodeControllersMap.insert(std::make_pair(rTag, rDecodeController));
	return rDecodeController;
}

bool DecodeControllerManager::destoryDecodeControllerWithTag(unsigned int rTag)
{
	DecodeControllersMap::iterator itr = mDecodeControllersMap.find(rTag);
	if (itr != mDecodeControllersMap.end())
	{
		DecodeController* obj = itr->second;
		mDecodeControllersMap.erase(itr);

		if (obj)
		{
			delete obj;
		}
	}

	return true;
}

bool DecodeControllerManager::destoryAllDecodeControllers()
{
	DecodeControllersMap::iterator itr = mDecodeControllersMap.begin();

	for (; itr != mDecodeControllersMap.end(); ++itr)
	{
		DecodeController* obj = itr->second;

		if (obj)
		{
			delete obj;
			obj = NULL;
		}
	}

	DecodeControllersMap emptyMap;
	mDecodeControllersMap.swap(emptyMap);
	mDecodeControllersMap.clear();

	return true;
}

DecodeController* DecodeControllerManager::getDecodeControllerByTag(unsigned int rTag)
{
	DecodeControllersMap::iterator itr = mDecodeControllersMap.find(rTag);

	if (itr != mDecodeControllersMap.end())
	{
		DecodeController* obj = itr->second;

		if (obj)
		{
			return obj;
		}
	}

	return NULL;
}
