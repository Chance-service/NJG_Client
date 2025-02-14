#pragma once
//#include "..\..\include\core\Singleton.h"
#include "PlayerController.h"
#include <map>
//#include "..\..\include\core\IteratorWrapper.h"
#include "Singleton.h"
#include "IteratorWrapper.h"


class PlayerControllerManager
	: public Singleton<PlayerControllerManager>
{
public:
	PlayerControllerManager();
	~PlayerControllerManager();

	typedef std::map<unsigned int, PlayerController*> PlayerControllersMap;
	typedef ConstMapIterator<PlayerControllersMap> PlayerControllersMapIterator;

	PlayerController* createPlayerControllerWithTag(unsigned int rTag);
	bool destoryPlayerControllerWithTag(unsigned int rTag);
	bool destoryAllPlayerControllers();

	PlayerController* getPlayerControllerByTag(unsigned int rTag);
	PlayerControllersMapIterator getAllPlayerControllers()
	{
		return PlayerControllersMapIterator(mPlayerControllersMap.begin(), mPlayerControllersMap.end());
	}

	static PlayerControllerManager* getInstance();

private:
	PlayerControllersMap mPlayerControllersMap;

	PlayerController* _addPlayerControllerToMap(unsigned int rTag, PlayerController* rPlayerController);
};