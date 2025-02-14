
#include "SkeletonDataCache.h"
namespace spine {

SkeletonDataCache* SkeletonDataCache::s_Instance = NULL;

SkeletonDataCache::SkeletonDataCache()
{
	purgeData();
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
SkeletonDataCache::~SkeletonDataCache()
{
	purgeData();
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
void SkeletonDataCache::purgeData()
{
	for (map<std::string, spSkeletonData*>::iterator iter = m_CacheDataMap.begin(); iter != m_CacheDataMap.end(); ++iter)
		{
			if (iter->second != 0)
			{
				spSkeletonData_dispose(iter->second);
			}
		}
	m_CacheDataMap.clear();
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
SkeletonDataCache* SkeletonDataCache::getInstance()
{
	if (NULL == s_Instance)
		{
			s_Instance = new SkeletonDataCache();
		}
		return s_Instance;
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
void SkeletonDataCache::loadSkeletonFile(const string& skeletonDataFile, const string& atlasFile, float scale)
{
    map<std::string, spSkeletonData*>::iterator iter = m_CacheDataMap.find(skeletonDataFile);
	//if (iter != m_CacheDataMap.end())
	//{
	//	return;
	//}
	spAtlas* _atlas = spAtlas_createFromFile(atlasFile.c_str(), 0);
	//assert(_atlas, "Error reading atlas file.");
	std::string str_ext = skeletonDataFile.substr(skeletonDataFile.length() - 5, 5);
	if (str_ext.compare(".skel") == 0)
	{
		spSkeletonBinary* binary = spSkeletonBinary_create(_atlas);
		binary->scale = scale;
		spSkeletonData* skeletonData = spSkeletonBinary_readSkeletonDataFile(binary, skeletonDataFile.c_str());
		spSkeletonBinary_dispose(binary);
		//m_CacheDataMap[skeletonDataFile] = skeletonData;
	}
	else
	{
		spSkeletonJson* json = spSkeletonJson_create(_atlas);
		json->scale = scale;
		spSkeletonData* skeletonData = spSkeletonJson_readSkeletonDataFile(json, skeletonDataFile.c_str());
		CCAssert(skeletonData, json->error ? json->error : "Error reading skeleton data.");
		spSkeletonJson_dispose(json);
		//m_CacheDataMap[skeletonDataFile] = skeletonData;
	}
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
spSkeletonData* SkeletonDataCache::getSkeletonDataByFileStr(const string& skeletonDataFile)
{
	map<std::string, spSkeletonData*>::iterator iter = m_CacheDataMap.find(skeletonDataFile);
	if (iter != m_CacheDataMap.end())
		{
			return iter->second;
		}
		return NULL;
}

//--------------------------------------------------------------------------------
//--------------------------------------------------------------------------------
void SkeletonDataCache::removeByFileStr(const string& skeletonDataFile)
{
	spSkeletonData* data = getSkeletonDataByFileStr(skeletonDataFile);
		if (data)
		{
			spSkeletonData_dispose(data);
			m_CacheDataMap.erase(skeletonDataFile);
		}
 }

}
