#pragma once

#include <map>
#include "spine/spine-cocos2dx.h"
#include "spine/SkeletonData.h"
using namespace spine;
using namespace std;

namespace spine {

class SkeletonDataCache
{
public:
	static SkeletonDataCache* getInstance();

	void loadSkeletonFile(const string& skeletonDataFile, const string& atlasFile, float scale);
	spSkeletonData* getSkeletonDataByFileStr(const string& skeletonDataFile);
	void removeByFileStr(const string& skeletonDataFile);
	void purgeData();
	~SkeletonDataCache();
	SkeletonDataCache();
private:
	static SkeletonDataCache* s_Instance;

	typedef std::map<std::string, spSkeletonData*> CacheDataStrMap;
	CacheDataStrMap	m_CacheDataMap;
 };
}
