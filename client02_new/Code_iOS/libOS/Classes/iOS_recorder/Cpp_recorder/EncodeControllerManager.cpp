#include "EncodeControllerManager.h"


EncodeControllerManager::EncodeControllerManager()
{

}

EncodeControllerManager::~EncodeControllerManager()
{
	destoryAllEncodeControllers();
}

EncodeControllerManager* EncodeControllerManager::getInstance()
{
	return EncodeControllerManager::Get();
}

EncodeController* EncodeControllerManager::createEncodeControllerWithTag(unsigned int rTag)
{
	EncodeController* encodeController = new EncodeController();
	encodeController->setTag(rTag);

	encodeController = _addEncodeControllerToMap(rTag, encodeController);

	return encodeController;
}

EncodeController* EncodeControllerManager::_addEncodeControllerToMap(unsigned int rTag, EncodeController* rEncodeController)
{
	EncodeControllersMap::iterator itr = mEncodeControllersMap.find(rTag);

	if (itr != mEncodeControllersMap.end())
	{
		EncodeController* controller = itr->second;

		if (controller)
		{
			controller->setTag(rTag);
			controller->setOfficerDelegate(NULL);
			controller->setReceptionDelegate(NULL);

			delete rEncodeController;
			return controller;
		}
	}

	mEncodeControllersMap.insert(std::make_pair(rTag, rEncodeController));

	return rEncodeController;
}

bool EncodeControllerManager::destoryEncodeControllerWithTag(unsigned int rTag)
{
	EncodeControllersMap::iterator itr = mEncodeControllersMap.find(rTag);
	if (itr != mEncodeControllersMap.end())
	{
		EncodeController* obj = itr->second;
		mEncodeControllersMap.erase(itr);

		if (obj)
		{
			delete obj;
		}
	}

	return true;
}

bool EncodeControllerManager::destoryAllEncodeControllers()
{
	EncodeControllersMap::iterator itr = mEncodeControllersMap.begin();

	for (; itr != mEncodeControllersMap.end(); ++itr)
	{
		EncodeController* obj = itr->second;

		if (obj)
		{
			delete obj;
			obj = NULL;
		}
	}

	EncodeControllersMap emptyMap;
	mEncodeControllersMap.swap(emptyMap);
	mEncodeControllersMap.clear();

	return true;
}

EncodeController* EncodeControllerManager::getEncodeControllerByTag(unsigned int rTag)
{
	EncodeControllersMap::iterator itr = mEncodeControllersMap.find(rTag);

	if (itr != mEncodeControllersMap.end())
	{
		EncodeController* obj = itr->second;

		if (obj)
		{
			return obj;
		}
	}

	return NULL;
}
