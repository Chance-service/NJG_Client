#include "SpineContainer.h"
#include "CCLuaEngine.h"

USING_NS_CC;
#define TIMES_SPINE_LOOP -1

//SpineContainer* SpineContainer::spineContainer = nullptr;

SpineContainer* SpineContainer::create(const char* path, const char* name, float scale /* = 0.0f */)
{
	//path = "Spine/ganning";
	//name = "ganning";
	CCLog("SpineContainer::create");
	const char* filePath	= CCString::createWithFormat("%s/%s", path, name)->getCString();
	const char* configFile	= CCString::createWithFormat("%s.skel", filePath)->getCString(),
		* atlasFile		= CCString::createWithFormat("%s.atlas", filePath)->getCString();
	if (std::string(filePath).find("Spine") == std::string::npos) {
		configFile = CCString::createWithFormat("Spine/%s", configFile)->getCString();
	}
	//std::string writablePath = cocos2d::CCFileUtils::sharedFileUtils()->getWritablePath();
	//std::string fullPath1 = writablePath + configFile;
	//std::string fullPath2 = writablePath + "/assets/" + configFile;
	//std::string fullPath3 = writablePath + "/hotUpdate/" + configFile;
	//if (!cocos2d::CCFileUtils::sharedFileUtils()->isFileExist(fullPath1) &&
	//	!cocos2d::CCFileUtils::sharedFileUtils()->isFileExist(fullPath2) &&
	//	!cocos2d::CCFileUtils::sharedFileUtils()->isFileExist(fullPath3)) {
	//	configFile = CCString::createWithFormat("%s.json", filePath)->getCString();
	//	CCLOG("SpineContainer::begin load json file: %s", configFile);
	//}
	//else {
		CCLog("SpineContainer::begin load skel file: %s", configFile);
	//}
	//spineContainer = new SpineContainer(configFile, atlasFile, scale);
	//if ( !spineContainer )
	//{
	//	return NULL;
	//}
	//spineContainer->autorelease();
	//return spineContainer;

	SpineContainer *pSpineContainer = new SpineContainer(configFile, atlasFile, scale);
	CCLog("SpineContainer::end load file: %s", configFile);
	if (pSpineContainer && pSpineContainer->init())
	{
		pSpineContainer->autorelease();
		return pSpineContainer;
	}
	CC_SAFE_DELETE(pSpineContainer);
	return NULL;
}

void SpineContainer::runAnimation(int trackIndex,const char* name, int loopTimes,float delay)
{
	CC_RETURN_IF(/*loopTimes == 0 || */loopTimes < TIMES_SPINE_LOOP)
	//--loopTimes;

	AnimationTrackMap::iterator it = m_mapTrack.find(name);
	if ( it == m_mapTrack.end() )
	{
		m_mapTrack.insert(std::make_pair(name, SAnimationInfo(name, trackIndex, loopTimes)));
	}
	else
	{
		trackIndex = it->second.trackIndex;
		it->second.loopTimes = loopTimes;
	}

	spTrackEntry* aniEntry=NULL;
	if(delay!=0.0f)
	{
		aniEntry=addAnimation(trackIndex, name, loopTimes != 0,delay);
	}
	else
	{
		aniEntry=setAnimation(trackIndex, name, loopTimes != 0);
	}

	if ( aniEntry )
	{
		if ( m_pEventListener || m_iLuaListener )
		{
// 			this->setStartListener(aniEntry, std::bind(&SpineContainer::onReceiveStartEventListener, this, std::placeholders::_1));
// 			this->setEndListener(aniEntry, std::bind(&SpineContainer::onReceiveEndEventListener, this, std::placeholders::_1));
// 			this->setCompleteListener(aniEntry, std::bind(&SpineContainer::onReceiveCompleteEventListener, this, std::placeholders::_1, std::placeholders::_2));
// 			this->setEventListener(aniEntry, std::bind(&SpineContainer::onReceiveEventListener, this, std::placeholders::_1, std::placeholders::_2));
		}
	}
}


void SpineContainer::setListener(SpineEventListener* eventListener)
{
	m_pEventListener = eventListener;
}

void SpineContainer::registerLuaListener(int listener)
{
	m_iLuaListener = listener;
}

void SpineContainer::unregisterLuaListener()
{
	m_iLuaListener = 0;
}



void SpineContainer::stopAllAnimations() 
{ 
	clearTracks();
}

void SpineContainer::stopAnimationByIndex(int trackIndex)
{
	clearTrack(trackIndex);
}


void SpineContainer::onAnimationStateEvent (int trackIndex, const char* animationName,spEventType type, spEvent* _event, int loopCount)
{
	CC_RETURN_IF(!m_pEventListener && !m_iLuaListener)

	std::string eventName("");
	switch ( type )
	{
	case SP_ANIMATION_COMPLETE:
		{
			SAnimationInfo* ctrlInfo = getAnimationInfo(trackIndex);
			if ( ctrlInfo->loopTimes > 0 )
			{
				runAnimation(trackIndex,ctrlInfo->aniName, ctrlInfo->loopTimes);
			}
			else if ( ctrlInfo->loopTimes == 0 )
			{
				if ( m_pEventListener )
				{
					m_pEventListener->onSpineAnimationComplete(trackIndex,loopCount);
				}
				eventName = "Complete";
			}
		}
		break;
	case SP_ANIMATION_START:
		if ( m_pEventListener )
		{
			m_pEventListener->onSpineAnimationStart(trackIndex);
		}
		eventName = "Start";
		break;
	case SP_ANIMATION_END:
		if ( m_pEventListener )
		{
			m_pEventListener->onSpineAnimationEnd(trackIndex);
		}
		eventName = "End";
		break;
	case SP_ANIMATION_EVENT:
		if ( m_pEventListener )
		{
			m_pEventListener->onSpineAnimationEvent(trackIndex, _event);
		}
		eventName = "Event";
		break;
	default:
		break;
	}

	if ( m_iLuaListener && !eventName.empty() )
	{
		CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
		stack->pushString(eventName.c_str(), eventName.size());
		stack->pushInt(trackIndex);
		stack->pushString(animationName, strlen(animationName));
		stack->pushInt(loopCount);
		stack->executeFunctionByHandler(m_iLuaListener, 4);
	}
}


void SpineContainer::onReceiveStartEventListener(int trackIndex)
{
	if ( m_pEventListener )
	{
		m_pEventListener->onSpineAnimationStart(trackIndex);
	}
}

void SpineContainer::onReceiveEndEventListener(int trackIndex)
{
	if ( m_pEventListener )
	{
		m_pEventListener->onSpineAnimationEnd(trackIndex);
	}
}

void SpineContainer::onReceiveCompleteEventListener(int trackIndex, int loopCount)
{
	if ( m_pEventListener )
	{
		m_pEventListener->onSpineAnimationComplete(trackIndex, loopCount);
	}
}

void SpineContainer::onReceiveEventListener(int trackIndex, spEvent* event)
{
	if ( m_pEventListener )
	{
		m_pEventListener->onSpineAnimationEvent(trackIndex, event);
	}
}

bool SpineContainer::isPlayingAnimation(const char* name, int trackIndex)
{
	spAnimation* animation = spSkeletonData_findAnimation(skeleton->data, name);
	if (!animation)
		return false;
	spTrackEntry* currentEntry = getCurrent(trackIndex);
	if (!currentEntry)
		return false;
	return currentEntry->animation == animation;
}

void SpineContainer::setAttachmentForLua(const char* slotName, const char* attachmentName)
{
	spSlotData* sp = spSkeletonData_findSlot(skeleton->data, slotName);
	//bool s = spSkeleton_setAttachment(skeleton, slotName, attachmentName);
	if (sp) {
		spSlotData_setAttachmentName(sp, attachmentName);
	}
	//return s;
}

void SpineContainer::setSlotColorForLua(const char* slotName, float red, float green, float blue)
{
	spSlotData* sp = spSkeletonData_findSlot(skeleton->data, slotName);
	//spSlot* sp2 = findSlot(slotName);
	if (sp) {
		sp->r = red;
		sp->g = green;
		sp->b = blue;
	}
	/*if (sp2) {
		sp2->r = red;
		sp2->g = green;
		sp2->b = blue;
	}*/
}

void SpineContainer::setTimeScale(float scale)
{
	timeScale = scale;
}