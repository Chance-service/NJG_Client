#include "PlayerControllerManager.h"


PlayerControllerManager::PlayerControllerManager()
{

}

PlayerControllerManager::~PlayerControllerManager()
{
	destoryAllPlayerControllers();
}

PlayerControllerManager* PlayerControllerManager::getInstance()
{
	return PlayerControllerManager::Get();
}

PlayerController* PlayerControllerManager::createPlayerControllerWithTag(unsigned int rTag)
{
	PlayerController* playerController = new PlayerController();
	playerController->setTag(rTag);

	playerController = _addPlayerControllerToMap(rTag, playerController);

	return playerController;
}

PlayerController* PlayerControllerManager::_addPlayerControllerToMap(unsigned int rTag, PlayerController* rPlayerController)
{
	PlayerControllersMap::iterator itr = mPlayerControllersMap.find(rTag);

	if (itr != mPlayerControllersMap.end())
	{
		PlayerController* controller = itr->second;

		if (controller)
		{
			controller->setTag(rTag);
			controller->setOfficerDelegate(NULL);
			controller->setReceptionDelegate(NULL);

			delete rPlayerController;
			return controller;
		}
	}

	mPlayerControllersMap.insert(std::make_pair(rTag, rPlayerController));

	return rPlayerController;
}

bool PlayerControllerManager::destoryPlayerControllerWithTag(unsigned int rTag)
{
	PlayerControllersMap::iterator itr = mPlayerControllersMap.find(rTag);
	if (itr != mPlayerControllersMap.end())
	{
		PlayerController* obj = itr->second;
		mPlayerControllersMap.erase(itr);

		if (obj)
		{
			delete obj;
		}
	}

	return true;
}

bool PlayerControllerManager::destoryAllPlayerControllers()
{
	PlayerControllersMap::iterator itr = mPlayerControllersMap.begin();

	for (; itr != mPlayerControllersMap.end(); ++itr)
	{
		PlayerController* obj = itr->second;

		if (obj)
		{
			delete obj;
			obj = NULL;
		}
	}

	PlayerControllersMap emptyMap;
	mPlayerControllersMap.swap(emptyMap);
	mPlayerControllersMap.clear();

	return true;
}

PlayerController* PlayerControllerManager::getPlayerControllerByTag(unsigned int rTag)
{
	PlayerControllersMap::iterator itr = mPlayerControllersMap.find(rTag);

	if (itr != mPlayerControllersMap.end())
	{
		PlayerController* obj = itr->second;

		if (obj)
		{
			return obj;
		}
	}

	return NULL;
}
