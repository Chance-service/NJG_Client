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

#ifndef SPINE_SKELETONANIMATION_H_
#define SPINE_SKELETONANIMATION_H_

#include <spine/spine.h>
#include <spine/SkeletonRenderer.h>
#include "cocos2d.h"

namespace spine {

typedef void(*StartListener)(int trackIndex);
typedef void(*EndListener)(int trackIndex);
typedef void(*CompleteListener)(int trackIndex, int loopCount);
typedef void(*EventListener)(int trackIndex, spEvent* event);

/** Draws an animated skeleton, providing an AnimationState for applying one or more animations and queuing animations to be
  * played later. */
class SkeletonAnimation: public SkeletonRenderer {
public:
	spAnimationState* state;

	static SkeletonAnimation* createWithData (spSkeletonData* skeletonData);
	static SkeletonAnimation* createWithFile (const char* skeletonDataFile, spAtlas* atlas, float scale = 0);
	static SkeletonAnimation* createWithFile (const char* skeletonDataFile, const char* atlasFile, float scale = 0);

	SkeletonAnimation (spSkeletonData* skeletonData);
	SkeletonAnimation (const char* skeletonDataFile, spAtlas* atlas, float scale = 0);
	SkeletonAnimation (const char* skeletonDataFile, const char* atlasFile, float scale = 0);

	virtual ~SkeletonAnimation ();

	virtual void update (float deltaTime);

	void setAnimationStateData (spAnimationStateData* stateData);
	void setMix (const char* fromAnimation, const char* toAnimation, float duration);

	spTrackEntry* setAnimation (int trackIndex, const char* name, bool loop);
	spTrackEntry* addAnimation (int trackIndex, const char* name, bool loop, float delay = 0);
	spTrackEntry* getCurrent (int trackIndex = 0);
	void clearTracks ();
	void clearTrack (int trackIndex = 0);

	StartListener startListener;
	EndListener endListener;
	CompleteListener completeListener;
	EventListener eventListener;
	void setStartListener (spTrackEntry* entry, StartListener listener);
	void setEndListener (spTrackEntry* entry, EndListener listener);
	void setCompleteListener (spTrackEntry* entry, CompleteListener listener);
	void setEventListener (spTrackEntry* entry, EventListener listener);

	EventListener getEventListener(spTrackEntry* entry);

	virtual void onAnimationStateEvent (int trackIndex, spEventType type, spEvent* event, int loopCount);
	virtual void onTrackEntryEvent (int trackIndex, spEventType type, spEvent* event, int loopCount);

	void registerFunctionHandler(char* func, int nHandler);
	void unregisterFunctionHandler(char* func);

protected:
	SkeletonAnimation ();

private:
	typedef SkeletonRenderer super;
	bool ownsAnimationStateData;
	std::map<std::string, int> mFuncHandlers;

	void initialize ();
};

}

#endif /* SPINE_SKELETONANIMATION_H_ */
