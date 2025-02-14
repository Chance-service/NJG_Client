#pragma once



#include "cocos2d.h"
#include "cocos-ext.h"
#include <spine/spine-cocos2dx.h>
#include <string>
#include <map>
using namespace spine;
USING_NS_CC;
USING_NS_CC_EXT;

class SpineEventListener
{
public:
	virtual void onSpineAnimationStart(int trackIndex){};
	virtual void onSpineAnimationEnd(int trackIndex){};
	virtual void onSpineAnimationComplete(int trackIndex, int loopCount){};
	virtual void onSpineAnimationEvent(int trackIndex, spEvent* event) {};
};

class SpineContainer: public SkeletonAnimation
{
public:
	SpineContainer(const char* skeletonDataFile, const char* atlasFile, float scale = 1.0f)
		: SkeletonAnimation(skeletonDataFile, atlasFile, scale)
		,m_pEventListener(NULL)
		, m_iLuaListener(0)
	{
		m_mapTrack.clear();
	};
	~SpineContainer()
	{
		m_mapTrack.clear();
	};

	static SpineContainer* create(const char* path, const char* name, float scale = 1.0f);
	void runAnimation(int trackIndex,const char* name, int loopTimes=1,float delay=0);

	void setListener(SpineEventListener* eventListener);
	void registerLuaListener(int listener);
	void unregisterLuaListener();

	void stopAllAnimations();

	void stopAnimationByIndex(int trackIndex);

	bool isPlayingAnimation(const char* name, int trackIndex);

	void setAttachmentForLua(const char* slotName, const char* attachmentName);

	void setSlotColorForLua(const char* slotName, float red, float green, float blue);

	void setTimeScale(float scale);

protected:
	struct SAnimationInfo
	{
		const char*			aniName;
		unsigned int	trackIndex;
		int				loopTimes;

		SAnimationInfo(const char* name, unsigned int index, int times)
			: aniName(name)
			, trackIndex(index)
			, loopTimes(times)
		{};
	};

	void onReceiveStartEventListener(int trackIndex);
	void onReceiveEndEventListener(int trackIndex);
	void onReceiveCompleteEventListener(int trackIndex, int loopCount);
	void onReceiveEventListener(int trackIndex, spEvent* event);

	typedef std::map<const char*, SAnimationInfo> AnimationTrackMap;
	void onAnimationStateEvent (int trackIndex, const char* animationName,spEventType type, spEvent* event, int loopCount);
	SAnimationInfo* getAnimationInfo(unsigned int trackIndex)
	{
		AnimationTrackMap::iterator it = m_mapTrack.begin(), itEnd = m_mapTrack.end();
		while ( it != itEnd )
		{
			if ( it->second.trackIndex == trackIndex )
			{
				return &(it->second);
			}
			++it;
		}
		return NULL;
	};
	SpineEventListener* m_pEventListener;
	int m_iLuaListener;

	AnimationTrackMap	m_mapTrack; 
private:
	//static SpineContainer* spineContainer;
};

