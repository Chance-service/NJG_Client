/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.3
 * 
 * Copyright (c) 2013-2015, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to use, install, execute and perform the Spine
 * Runtimes Software (the "Software") and derivative works solely for personal
 * or internal use. Without the written permission of Esoteric Software (see
 * Section 2 of the Spine Software License Agreement), you may not (a) modify,
 * translate, adapt or otherwise create derivative works, improvements of the
 * Software or develop new applications using the Software or (b) remove,
 * delete, alter or obscure any trademarks or any copyright, trademark, patent
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

#include <spine/SkeletonAnimation.h>
#include <spine/spine-cocos2dx.h>
#include <spine/extension.h>
#include <algorithm>
#include "CCLuaEngine.h"

USING_NS_CC;
using std::min;
using std::max;
using std::vector;

namespace spine {

void animationCallback (spAnimationState* state, int trackIndex, spEventType type, spEvent* event, int loopCount) {
	((SkeletonAnimation*)state->rendererObject)->onAnimationStateEvent(trackIndex, type, event, loopCount);
}

void trackEntryCallback (spAnimationState* state, int trackIndex, spEventType type, spEvent* event, int loopCount) {
	((SkeletonAnimation*)state->rendererObject)->onTrackEntryEvent(trackIndex, type, event, loopCount);
}

typedef struct _TrackEntryListeners
{
	_TrackEntryListeners()
	{
		startListener = NULL;
		endListener = NULL;
		completeListener = NULL;
		eventListener = NULL;
	}

	StartListener startListener;
	EndListener endListener;
	CompleteListener completeListener;
	EventListener eventListener;
} _TrackEntryListeners;

static _TrackEntryListeners* getListeners (spTrackEntry* entry) {
	if (!entry->rendererObject) {
		entry->rendererObject = NEW(spine::_TrackEntryListeners);
		entry->listener = trackEntryCallback;
	}
	return (_TrackEntryListeners*)entry->rendererObject;
}

void disposeTrackEntry (spTrackEntry* entry) {
	if (entry->rendererObject) FREE(entry->rendererObject);
	_spTrackEntry_dispose(entry);
}

SkeletonAnimation* SkeletonAnimation::createWithData (spSkeletonData* skeletonData) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonData);
	node->autorelease();
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const char* skeletonDataFile, spAtlas* atlas, float scale) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonDataFile, atlas, scale);
	node->autorelease();
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const char* skeletonDataFile, const char* atlasFile, float scale) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonDataFile, atlasFile, scale);
	node->autorelease();
	return node;
}

void SkeletonAnimation::initialize () {
	ownsAnimationStateData = true;
	state = spAnimationState_create(spAnimationStateData_create(skeleton->data));
	state->rendererObject = this;
	state->listener = animationCallback;

	_spAnimationState* stateInternal = (_spAnimationState*)state;
	stateInternal->disposeTrackEntry = disposeTrackEntry;

	startListener = NULL;
	endListener = NULL;
	completeListener = NULL;
	eventListener = NULL;
}

SkeletonAnimation::SkeletonAnimation (spSkeletonData *skeletonData)
		: SkeletonRenderer(skeletonData) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const char* skeletonDataFile, spAtlas* atlas, float scale)
		: SkeletonRenderer(skeletonDataFile, atlas, scale) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const char* skeletonDataFile, const char* atlasFile, float scale)
		: SkeletonRenderer(skeletonDataFile, atlasFile, scale) {
	initialize();
}

SkeletonAnimation::~SkeletonAnimation () {
	if (ownsAnimationStateData) spAnimationStateData_dispose(state->data);
	spAnimationState_dispose(state);
}

void SkeletonAnimation::update (float deltaTime) {
	super::update(deltaTime);

	deltaTime *= timeScale;
	spAnimationState_update(state, deltaTime);
	spAnimationState_apply(state, skeleton);
	spSkeleton_updateWorldTransform(skeleton);
}

void SkeletonAnimation::setAnimationStateData (spAnimationStateData* stateData) {
	CCAssert(stateData, "stateData cannot be null.");

	if (ownsAnimationStateData) spAnimationStateData_dispose(state->data);
	spAnimationState_dispose(state);

	ownsAnimationStateData = false;
	state = spAnimationState_create(stateData);
	state->rendererObject = this;
	state->listener = animationCallback;
}

void SkeletonAnimation::setMix (const char* fromAnimation, const char* toAnimation, float duration) {
	spAnimationStateData_setMixByName(state->data, fromAnimation, toAnimation, duration);
}

spTrackEntry* SkeletonAnimation::setAnimation (int trackIndex, const char* name, bool loop) {
	spAnimation* animation = spSkeletonData_findAnimation(skeleton->data, name);
	if (!animation) {
		CCLog("Spine: Animation not found: %s", name);
		return 0;
	}
	return spAnimationState_setAnimation(state, trackIndex, animation, loop);
}

spTrackEntry* SkeletonAnimation::addAnimation (int trackIndex, const char* name, bool loop, float delay) {
	spAnimation* animation = spSkeletonData_findAnimation(skeleton->data, name);
	if (!animation) {
		CCLog("Spine: Animation not found: %s", name);
		return 0;
	}
	return spAnimationState_addAnimation(state, trackIndex, animation, loop, delay);
}

spTrackEntry* SkeletonAnimation::getCurrent (int trackIndex) { 
	return spAnimationState_getCurrent(state, trackIndex);
}

void SkeletonAnimation::clearTracks () {
	spAnimationState_clearTracks(state);
}

void SkeletonAnimation::clearTrack (int trackIndex) {
	spAnimationState_clearTrack(state, trackIndex);
}

void SkeletonAnimation::onAnimationStateEvent (int trackIndex, spEventType type, spEvent* event, int loopCount) {
	std::map<std::string, int>::iterator it = mFuncHandlers.end();
	std::string tmp_string = "";
	switch (type) {
	case SP_ANIMATION_START:
		if (startListener) startListener(trackIndex);
		it = mFuncHandlers.find("START");
		tmp_string = "START";
		break;
	case SP_ANIMATION_END:
		if (endListener) endListener(trackIndex);
		it = mFuncHandlers.find("END");
		tmp_string = "END";
		break;
	case SP_ANIMATION_COMPLETE:
		if (completeListener) completeListener(trackIndex, loopCount);
		it = mFuncHandlers.find("COMPLETE");
		tmp_string = "COMPLETE";
		break;
	case SP_ANIMATION_EVENT:
		if (eventListener) eventListener(trackIndex, event);
		it = mFuncHandlers.find("SELF_EVENT");
		tmp_string = event->data->name;
		break;
	}
	if (it != mFuncHandlers.end())
	{
		CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
		stack->pushInt(trackIndex);
		stack->pushInt(this->getTag());
		stack->pushString(tmp_string.c_str(), tmp_string.size());
		stack->executeFunctionByHandler(it->second, 3);
	}
}

void SkeletonAnimation::onTrackEntryEvent (int trackIndex, spEventType type, spEvent* event, int loopCount) {
	spTrackEntry* entry = spAnimationState_getCurrent(state, trackIndex);
	if (!entry->rendererObject) return;
	_TrackEntryListeners* listeners = (_TrackEntryListeners*)entry->rendererObject;
	switch (type) {
	case SP_ANIMATION_START:
		if (listeners->startListener) listeners->startListener(trackIndex);
		break;
	case SP_ANIMATION_END:
		if (listeners->endListener) listeners->endListener(trackIndex);
		break;
	case SP_ANIMATION_COMPLETE:
		if (listeners->completeListener) listeners->completeListener(trackIndex, loopCount);
		break;
	case SP_ANIMATION_EVENT:
		if (listeners->eventListener) listeners->eventListener(trackIndex, event);
		break;
	}
}

void SkeletonAnimation::setStartListener (spTrackEntry* entry, StartListener listener) {
	getListeners(entry)->startListener = listener;
}

void SkeletonAnimation::setEndListener (spTrackEntry* entry, EndListener listener) {
	getListeners(entry)->endListener = listener;
}

void SkeletonAnimation::setCompleteListener (spTrackEntry* entry, CompleteListener listener) {
	getListeners(entry)->completeListener = listener;
}

void SkeletonAnimation::setEventListener (spTrackEntry* entry, spine::EventListener listener) {
	getListeners(entry)->eventListener = listener;
}

EventListener SkeletonAnimation::getEventListener(spTrackEntry* entry)
{
	return getListeners(entry)->eventListener;
}

void SkeletonAnimation::registerFunctionHandler(char* func, int nHandler)
{
	std::map<std::string, int>::iterator it = mFuncHandlers.find(func);
	if (it == mFuncHandlers.end())
		mFuncHandlers.insert(std::make_pair(func, nHandler));
	else
	{
		CCLog("replace %s handler from %d to %d", func, it->second, nHandler);
		it->second = nHandler;
	}
}

void SkeletonAnimation::unregisterFunctionHandler(char* func)
{
	std::map<std::string, int>::iterator it = mFuncHandlers.find(func);
	if (it != mFuncHandlers.end())
		mFuncHandlers.erase(it);
}

}