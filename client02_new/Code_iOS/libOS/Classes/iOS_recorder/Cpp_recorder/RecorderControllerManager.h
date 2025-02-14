#pragma once
//#include "..\..\include\core\Singleton.h"
#include "RecorderController.h"
#include <map>
//#include "..\..\include\core\IteratorWrapper.h"
#include "Singleton.h"
#include "IteratorWrapper.h"


class RecorderControllerManager
	: public Singleton<RecorderControllerManager>
{
public:
	RecorderControllerManager();
	~RecorderControllerManager();

	typedef std::map<unsigned int, RecorderController*> RecorderControllersMap;
	typedef ConstMapIterator<RecorderControllersMap> RecorderControllersMapIterator;

	RecorderController* createRecorderControllerWithTypeAndTag(RecorderType rType, unsigned int rTag);
	bool destoryRecorderControllerWithTag(unsigned int rTag);
	bool destoryAllRecorderControllers();

	RecorderController* getRecorderControllerByTag(unsigned int rTag);
	RecorderControllersMapIterator getAllRecorderControllers()
	{
		return RecorderControllersMapIterator(mRecorderControllersMap.begin(), mRecorderControllersMap.end());
	}

	static RecorderControllerManager* getInstance();
	 
private:
	RecorderControllersMap mRecorderControllersMap;

	RecorderController* _addRecorderControllerToMap(unsigned int rTag, RecorderType rType, RecorderController* rRecorderController);
};