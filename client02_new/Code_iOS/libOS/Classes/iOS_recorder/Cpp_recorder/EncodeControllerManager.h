#pragma once
//#include "..\..\include\core\Singleton.h"
#include "EncodeController.h"
#include <map>
//#include "..\..\include\core\IteratorWrapper.h"
#include "Singleton.h"
#include "IteratorWrapper.h"


class EncodeControllerManager
	: public Singleton<EncodeControllerManager>
{
public:
	EncodeControllerManager();
	~EncodeControllerManager();

	typedef std::map<unsigned int, EncodeController*> EncodeControllersMap;
	typedef ConstMapIterator<EncodeControllersMap> EncodeControllersMapIterator;

	EncodeController* createEncodeControllerWithTag(unsigned int rTag);
	bool destoryEncodeControllerWithTag(unsigned int rTag);
	bool destoryAllEncodeControllers();

	EncodeController* getEncodeControllerByTag(unsigned int rTag);
	EncodeControllersMapIterator getAllEncodeControllers()
	{
		return EncodeControllersMapIterator(mEncodeControllersMap.begin(), mEncodeControllersMap.end());
	}

	static EncodeControllerManager* getInstance();

private:
	EncodeControllersMap mEncodeControllersMap;

	EncodeController* _addEncodeControllerToMap(unsigned int rTag, EncodeController* rEncodeController);
};