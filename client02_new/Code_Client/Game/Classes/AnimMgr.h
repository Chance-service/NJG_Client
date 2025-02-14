#pragma once
#include "cocos2d.h"


#include "Singleton.h"
#include <string>
#include "CCBContainer.h"
#include "GameMaths.h"

USING_NS_CC;
USING_NS_CC_EXT;

/*
*UI常用動畫管理器
*/

#define ANIM_MOVE_TIME 0.25
#define ANIM_MOVE_UNIT 0.1
#define ANIM_DELAY_TIME 0.03
#define ANIM_SCALE_TIME 0.3

#define SCROLL_MOVE_IN_TAG 100232

class AnimMgr
	:public Singleton<AnimMgr>
{
public:
	AnimMgr();
	~AnimMgr();

	//閃爍效果，漸隱出現，漸隱消失
	void fadeInAndOut(CCNode* node,float time);	

	//scrollview 的content依次快速出現
	void scrollViewMoveIn(CCScrollView* scrollView);
	void nodeMoveIn(CCNode* node,bool order = false);

	//彈出框，縮放漸現
	void scaleToShow(CCNode* node,float start,float end,CCCallFuncND* func);
	//彈出框，縮放消失
	void scaleToHide(CCNode* node,float start,CCCallFuncND* func);

	//for lua
	static AnimMgr* getInstance();
};


namespace InverseColorEffect
{
	CCSprite* generateInverseColorSpriteByNode(CCNode* node,CCPoint  anchorPoin);
}


