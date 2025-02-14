#include "RecorderControllerManager.h"


RecorderControllerManager::RecorderControllerManager()
{

}

RecorderControllerManager::~RecorderControllerManager()
{
	destoryAllRecorderControllers();
}

RecorderControllerManager* RecorderControllerManager::getInstance()
{
	return RecorderControllerManager::Get();
}

RecorderController* RecorderControllerManager::createRecorderControllerWithTypeAndTag(RecorderType rType, unsigned int rTag)
{
	RecorderController* recorderController = new RecorderController();
	recorderController->setTag(rTag);
	recorderController->setType(rType);

	recorderController = _addRecorderControllerToMap(rTag, rType, recorderController);

	return recorderController;
}

RecorderController* RecorderControllerManager::_addRecorderControllerToMap(unsigned int rTag, RecorderType rType, RecorderController* rRecorderController)
{
	RecorderControllersMap::iterator itr = mRecorderControllersMap.find(rTag);

	if (itr != mRecorderControllersMap.end())
	{
		RecorderController* controller = itr->second;

		if (controller)
		{
			controller->setType(rType);
			controller->setTag(rTag);
			controller->setOfficerDelegate(NULL);
			controller->setReceptionDelegate(NULL);

			delete rRecorderController;
			return controller;
		}
	}

	mRecorderControllersMap.insert(std::make_pair(rTag, rRecorderController));

	return rRecorderController;
}

bool RecorderControllerManager::destoryRecorderControllerWithTag(unsigned int rTag)
{
	RecorderControllersMap::iterator itr = mRecorderControllersMap.find(rTag);
	if (itr != mRecorderControllersMap.end())
	{
		RecorderController* obj = itr->second;
		mRecorderControllersMap.erase(itr);

		if (obj)
		{
			delete obj;
		}
	}

	return true;
}

bool RecorderControllerManager::destoryAllRecorderControllers()
{
	RecorderControllersMap::iterator itr = mRecorderControllersMap.begin();

	for (; itr != mRecorderControllersMap.end(); ++itr)
	{
		RecorderController* obj = itr->second;

		if (obj)
		{
			delete obj;
			obj = NULL;
		}
	}

	RecorderControllersMap emptyMap;
	mRecorderControllersMap.swap(emptyMap);
	mRecorderControllersMap.clear();

	return true;
}

RecorderController* RecorderControllerManager::getRecorderControllerByTag(unsigned int rTag)
{
	RecorderControllersMap::iterator itr = mRecorderControllersMap.find(rTag);

	if (itr != mRecorderControllersMap.end())
	{
		RecorderController* obj = itr->second;

		if (obj)
		{
			return obj;
		}
	}

	return NULL;
}
