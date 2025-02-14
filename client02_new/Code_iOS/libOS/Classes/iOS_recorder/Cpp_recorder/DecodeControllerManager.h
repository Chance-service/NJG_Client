#pragma once
//#include "..\..\include\core\Singleton.h"
#include "DecodeController.h"
#include <map>
//#include "..\..\include\core\IteratorWrapper.h"
#include "Singleton.h"
#include "IteratorWrapper.h"


class DecodeControllerManager
	: public Singleton<DecodeControllerManager>
{
public:
	DecodeControllerManager();
	~DecodeControllerManager();

	typedef std::map<unsigned int, DecodeController*> DecodeControllersMap;
	typedef ConstMapIterator<DecodeControllersMap> DecodeControllersMapIterator;

	DecodeController* createDecodeControllerWithTag(unsigned int rTag);
	bool destoryDecodeControllerWithTag(unsigned int rTag);
	bool destoryAllDecodeControllers();

	DecodeController* getDecodeControllerByTag(unsigned int rTag);
	DecodeControllersMapIterator getAllDecodeControllers()
	{
		return DecodeControllersMapIterator(mDecodeControllersMap.begin(), mDecodeControllersMap.end());
	}

	static DecodeControllerManager* getInstance();

private:
	DecodeControllersMap mDecodeControllersMap;

	DecodeController* _addDecodeControllerToMap(unsigned int rTag, DecodeController* rDecodeController);
};