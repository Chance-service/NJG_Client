/****************************************************************************
Copyright (c) 2012 cocos2d-x.org
Copyright (c) 2010 Sangwoo Im

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/

#include "CCScrollView.h"
#include "CCLuaEngine.h"

NS_CC_EXT_BEGIN

#define SCROLL_DEACCEL_RATE  0.95f
#define SCROLL_DEACCEL_DIST  1.0f
#define BOUNCE_DURATION      0.15f
#define INSET_RATIO          0.2f
#define MOVE_INCH            7.0f/160.0f

static float convertDistanceFromPointToInch(float pointDis)
{
	float factor = (CCEGLView::sharedOpenGLView()->getScaleX() + CCEGLView::sharedOpenGLView()->getScaleY()) / 2;
	return pointDis * factor / CCDevice::getDPI();
}


CCScrollView::CCScrollView()
: m_fZoomScale(0.0f)
, m_fMinZoomScale(0.0f)
, m_fMaxZoomScale(0.0f)
, m_pDelegate(NULL)
, m_eDirection(kCCScrollViewDirectionBoth)
, m_bDragging(false)
, m_pContainer(NULL)
, m_bTouchMoved(false)
, m_bBounceable(false)
, m_bEdgePreserve(false)
, m_bClippingToBounds(false)
, m_fTouchLength(0.0f)
, m_pTouches(NULL)
, m_fMinScale(0.0f)
, m_fMaxScale(0.0f)
, m_fScrollDeaccelRate(SCROLL_DEACCEL_RATE)
, m_tDisplayArea(0, 0, 0, 0)
, mOriginalContentSize(CCSizeMake(0, 0))
{

}

CCScrollView::~CCScrollView()
{
	CC_SAFE_RELEASE(m_pTouches);
	this->unregisterScriptHandler(kScrollViewScroll);
	this->unregisterScriptHandler(kScrollViewZoom);
}

CCScrollView* CCScrollView::create(CCSize size, CCNode* container/* = NULL*/)
{
	CCScrollView* pRet = new CCScrollView();
	if (pRet && pRet->initWithViewSize(size, container))
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}

CCScrollView* CCScrollView::create()
{
	CCScrollView* pRet = new CCScrollView();
	if (pRet && pRet->init())
	{
		pRet->autorelease();
	}
	else
	{
		CC_SAFE_DELETE(pRet);
	}
	return pRet;
}


bool CCScrollView::initWithViewSize(CCSize size, CCNode *container/* = NULL*/)
{
	if (CCLayer::init())
	{
		m_pContainer = container;

		if (!this->m_pContainer)
		{
			m_pContainer = CCLayer::create();
			this->m_pContainer->ignoreAnchorPointForPosition(false);
			this->m_pContainer->setAnchorPoint(ccp(0.0f, 0.0f));
		}

		this->setViewSize(size);

		setTouchEnabled(true);
		m_pTouches = new CCArray();
		m_pDelegate = NULL;
		m_bBounceable = true;
		m_bClippingToBounds = true;
		//m_pContainer->setContentSize(CCSizeZero);
		m_eDirection = kCCScrollViewDirectionBoth;
		m_pContainer->setPosition(ccp(0.0f, 0.0f));
		m_fTouchLength = 0.0f;

		this->addChild(m_pContainer);
		m_fMinScale = m_fMaxScale = 1.0f;
		m_mapScriptHandler.clear();
		return true;
	}
	return false;
}

bool CCScrollView::init()
{
	return this->initWithViewSize(CCSizeMake(200, 200), NULL);
}

void CCScrollView::registerWithTouchDispatcher()
{
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, CCLayer::getTouchPriority(), true);
}

bool CCScrollView::isNodeVisible(CCNode* node)
{
	const CCPoint offset = this->getContentOffset();
	const CCSize  size = this->getViewSize();
	const float   scale = this->getZoomScale();

	CCRect viewRect;

	viewRect = CCRectMake(-offset.x / scale, -offset.y / scale, size.width / scale, size.height / scale);

	return viewRect.intersectsRect(node->boundingBox());
}

void CCScrollView::pause(CCObject* sender)
{
	m_pContainer->pauseSchedulerAndActions();

	CCObject* pObj = NULL;
	CCArray* pChildren = m_pContainer->getChildren();

	CCARRAY_FOREACH(pChildren, pObj)
	{
		CCNode* pChild = (CCNode*)pObj;
		pChild->pauseSchedulerAndActions();
	}
}

void CCScrollView::resume(CCObject* sender)
{
	CCObject* pObj = NULL;
	CCArray* pChildren = m_pContainer->getChildren();

	CCARRAY_FOREACH(pChildren, pObj)
	{
		CCNode* pChild = (CCNode*)pObj;
		pChild->resumeSchedulerAndActions();
	}

	m_pContainer->resumeSchedulerAndActions();
}

void CCScrollView::setTouchEnabled(bool e)
{
	CCLayer::setTouchEnabled(e);
	if (!e)
	{
		m_bDragging = false;
		m_bTouchMoved = false;
		m_pTouches->removeAllObjects();
	}
}

void CCScrollView::setContentOffset(CCPoint offset, bool animated/* = false*/)
{
	if (animated)
	{ //animate scrolling
		this->setContentOffsetInDuration(offset, BOUNCE_DURATION);
	}
	else
	{ //set the container position directly
		//if (!m_bBounceable)
		//if the bounceable is false or the edge protection is enable, the content in scrollview will not able to scroll outside the scroll's min or max container offset.
		if (!m_bBounceable || m_bEdgePreserve)
		{
			const CCPoint minOffset = this->minContainerOffset();
			const CCPoint maxOffset = this->maxContainerOffset();

			offset.x = MAX(minOffset.x, MIN(maxOffset.x, offset.x));
			offset.y = MAX(minOffset.y, MIN(maxOffset.y, offset.y));
		}

		/*if (!m_bBounceable)
		{

			float currentY = this->m_pContainer->getPositionY();
			if (currentY > 0)
			{
				offset.x = this->m_pContainer->getPositionX();
				offset.y = 0;
			}
			if (-currentY > this->m_pContainer->getContentSize().height - this->getViewSize().height)
			{
				offset.x = this->m_pContainer->getPositionX();
				offset.y = -m_pContainer->getContentSize().height + this->getViewSize().height;
			}
		}*/

		m_pContainer->setPosition(offset);

		if (m_pDelegate != NULL)
		{
			m_pDelegate->scrollViewDidScroll(this);
		}
		_scrollViewDidScroll();
	}
}

void CCScrollView::setContentOffsetInDuration(CCPoint offset, float dt)
{
	CCFiniteTimeAction *scroll, *expire, *scrollEnd;

	scroll = CCMoveTo::create(dt, offset);
	expire = CCCallFuncN::create(this, callfuncN_selector(CCScrollView::stoppedAnimatedScroll));
	scrollEnd = CCCallFuncN::create(this, callfuncN_selector(CCScrollView::stoppedAnimatedScrollEnd));
	m_pContainer->runAction(CCSequence::create(scroll, expire, scrollEnd, NULL));
	this->schedule(schedule_selector(CCScrollView::performedAnimatedScroll));
}

CCPoint CCScrollView::getContentOffset()
{
	return m_pContainer->getPosition();
}

void CCScrollView::setZoomScale(float s)
{
	if (m_pContainer->getScale() != s)
	{
		CCPoint oldCenter, newCenter;
		CCPoint center;

		if (m_fTouchLength == 0.0f)
		{
			center = ccp(m_tViewSize.width*0.5f, m_tViewSize.height*0.5f);
			center = this->convertToWorldSpace(center);
		}
		else
		{
			center = m_tTouchPoint;
		}

		oldCenter = m_pContainer->convertToNodeSpace(center);
		m_pContainer->setScale(MAX(m_fMinScale, MIN(m_fMaxScale, s)));
		newCenter = m_pContainer->convertToWorldSpace(oldCenter);

		const CCPoint offset = ccpSub(center, newCenter);
		if (m_pDelegate != NULL)
		{
			m_pDelegate->scrollViewDidZoom(this);
		}
		this->setContentOffset(ccpAdd(m_pContainer->getPosition(), offset));
	}
}

float CCScrollView::getZoomScale()
{
	return m_pContainer->getScale();
}

void CCScrollView::setZoomScale(float s, bool animated)
{
	if (animated)
	{
		this->setZoomScaleInDuration(s, BOUNCE_DURATION);
	}
	else
	{
		this->setZoomScale(s);
	}
}

void CCScrollView::setZoomScaleInDuration(float s, float dt)
{
	if (dt > 0)
	{
		if (m_pContainer->getScale() != s)
		{
			CCActionTween *scaleAction;
			scaleAction = CCActionTween::create(dt, "zoomScale", m_pContainer->getScale(), s);
			this->runAction(scaleAction);
		}
	}
	else
	{
		this->setZoomScale(s);
	}
}

void CCScrollView::setViewSize(CCSize size)
{
	m_tViewSize = size;
	CCLayer::setContentSize(size);

	_caculateDisplayArea(getViewRect());
}

CCNode * CCScrollView::getContainer()
{
	return this->m_pContainer;
}


void CCScrollView::_caculateDisplayArea(const CCRect& rect)
{
	if (this->getParent())
	{
		// 		CCPoint screenPos = this->getParent()->convertToWorldSpace(this->getPosition());
		// 		float sx = this->getScaleX();
		// 		float sy = this->getScaleY();
		// 		CCNode* par = this;
		// 		while(par->getParent()){par=par->getParent();sx*=par->getScaleX();sy*=par->getScaleY();}
		// 		CCRect rect(screenPos.x, screenPos.y, m_tViewSize.width*sx, m_tViewSize.height*sy);
		if (!m_tDisplayArea.equals(rect))
		{
			m_tDisplayArea = rect;
			_setChildMenu(m_pContainer);
		}
	}
}

void CCScrollView::_setChildMenu(CCNode* par)
{
	if (par && par->getChildren())
	{
		CCObject* child;
		CCARRAY_FOREACH(par->getChildren(), child)
		{
			::cocos2d::CCMenu* pNode = dynamic_cast<CCMenu*>(child);
			if (pNode)
			{
				if (!pNode->getScrollViewChild())
				{
					pNode->setScrollViewChild(true);
					if (pNode->isTouchEnabled())
					{
						pNode->setTouchEnabled(false);
						pNode->setTouchEnabled(true);
					}
				}

				pNode->setTouchArea(m_tDisplayArea);

				//pNode->registerWithTouchDispatcher();
			}
			::cocos2d::CCNode* pNode2 = dynamic_cast<CCNode*>(child);
			if (pNode2)
			{
				_setChildMenu(pNode2);
			}
		}
	}

}


void CCScrollView::setContainer(CCNode * pContainer)
{
	// Make sure that 'm_pContainer' has a non-NULL value since there are
	// lots of logic that use 'm_pContainer'.
	if (NULL == pContainer)
		return;

	this->removeAllChildrenWithCleanup(true);
	this->m_pContainer = pContainer;

	this->m_pContainer->ignoreAnchorPointForPosition(false);
	this->m_pContainer->setAnchorPoint(ccp(0.0f, 0.0f));


	this->setViewSize(this->m_tViewSize);
	_setChildMenu(pContainer);

	this->addChild(this->m_pContainer);
	mOriginalContentSize = pContainer->getContentSize();
	this->setContentSize(mOriginalContentSize);
	if (this->getDirection() == kCCScrollViewDirectionVertical)
		this->setContentOffset(::ccp(0, maxContainerOffset().y));
}

void CCScrollView::resetContainer()
{
	m_pContainer->setPosition(ccp(0.0f, 0.0f));
	this->setContentSize(mOriginalContentSize);
	if (this->getDirection() == kCCScrollViewDirectionVertical)
		this->setContentOffset(::ccp(0, maxContainerOffset().y));
}

void CCScrollView::relocateContainer(bool animated)
{
	CCPoint oldPoint, min, max;
	float newX, newY;

	min = this->minContainerOffset();
	max = this->maxContainerOffset();

	oldPoint = m_pContainer->getPosition();

	newX = oldPoint.x;
	newY = oldPoint.y;
	//     if (m_eDirection == kCCScrollViewDirectionBoth || m_eDirection == kCCScrollViewDirectionHorizontal)
	//     {
	// 		if(m_tViewSize.width<=m_pContainer->getContentSize().width*m_pContainer->getScaleX())
	// 		{
	// 			newX     = MAX(newX, min.x);
	// 			newX     = MIN(newX, max.x);
	// 		}
	// 		else
	// 		{
	// 			newX = min.x;
	// 		}
	//     }
	// 
	//     if (m_eDirection == kCCScrollViewDirectionBoth || m_eDirection == kCCScrollViewDirectionVertical)
	//     {
	// 		if(m_tViewSize.height<=m_pContainer->getContentSize().height*m_pContainer->getScaleY())
	// 		{
	// 			newY     = MIN(newY, max.y);
	// 			newY     = MAX(newY, min.y);
	// 		}
	// 		else
	// 		{
	// 			newY = max.y;
	// 		}
	//     }
	if (m_eDirection == kCCScrollViewDirectionBoth || m_eDirection == kCCScrollViewDirectionHorizontal)
	{
		newX = MAX(newX, min.x);
		newX = MIN(newX, max.x);
	}

	if (m_eDirection == kCCScrollViewDirectionBoth || m_eDirection == kCCScrollViewDirectionVertical)
	{
		newY = MIN(newY, max.y);
		newY = MAX(newY, min.y);
	}
	if (newY != oldPoint.y || newX != oldPoint.x)
	{
		this->setContentOffset(ccp(newX, newY), animated);
	}
}

CCPoint CCScrollView::maxContainerOffset()
{
	float x = m_tViewSize.width - m_pContainer->getContentSize().width*m_pContainer->getScaleX();
	float y = m_tViewSize.height - m_pContainer->getContentSize().height*m_pContainer->getScaleY();
	x = x>0 ? x : 0;
	y = y>0 ? y : 0;
	return ccp(x, y);
}

CCPoint CCScrollView::minContainerOffset()
{
	float x = m_tViewSize.width - m_pContainer->getContentSize().width*m_pContainer->getScaleX();
	float y = m_tViewSize.height - m_pContainer->getContentSize().height*m_pContainer->getScaleY();
	// 	x=x<0?x:0;
	// 	y=y<0?y:0;
	return ccp(x, y);
}

void CCScrollView::deaccelerateScrolling(float dt)
{
	if (m_bDragging)
	{
		this->unschedule(schedule_selector(CCScrollView::deaccelerateScrolling));

		if (m_pDelegate != NULL)
		{
			m_pDelegate->scrollViewDidScrollEnd(this);
		}
		return;
	}

	float newX, newY;
	CCPoint maxInset, minInset;

	//m_pContainer->setPosition(ccpAdd(m_pContainer->getPosition(), m_tScrollDistance));
	CCPoint newPosition = ccpAdd(m_pContainer->getPosition(), m_tScrollDistance);
	this->setContentOffset(newPosition);
	newX = m_pContainer->getPosition().x;
	newY = m_pContainer->getPosition().y;
	m_tScrollDistance = ccpMult(m_tScrollDistance, m_fScrollDeaccelRate);

	if (m_bBounceable)
	{
		maxInset = m_fMaxInset;
		minInset = m_fMinInset;
	}
	else
	{
		maxInset = this->maxContainerOffset();
		minInset = this->minContainerOffset();
	}

	//check to see if offset lies within the inset bounds
	//     newX     = MIN(m_pContainer->getPosition().x, maxInset.x);
	//     newX     = MAX(newX, minInset.x);
	//     newY     = MIN(m_pContainer->getPosition().y, maxInset.y);
	//     newY     = MAX(newY, minInset.y);
	//     
	//     newX = m_pContainer->getPosition().x;
	//     newY = m_pContainer->getPosition().y;
	//     
	//     m_tScrollDistance     = ccpSub(m_tScrollDistance, ccp(newX - m_pContainer->getPosition().x, newY - m_pContainer->getPosition().y));
	//     m_tScrollDistance     = ccpMult(m_tScrollDistance, m_fScrollDeaccelRate);
	//     this->setContentOffset(ccp(newX,newY));

	if ((fabsf(m_tScrollDistance.x) <= SCROLL_DEACCEL_DIST &&
		fabsf(m_tScrollDistance.y) <= SCROLL_DEACCEL_DIST) ||
		newY > maxInset.y || newY < minInset.y ||
		newX > maxInset.x || newX < minInset.x ||
		newX == maxInset.x || newX == minInset.x ||
		newY == maxInset.y || newY == minInset.y)
	{
		this->unschedule(schedule_selector(CCScrollView::deaccelerateScrolling));
		this->relocateContainer(true);
		if (m_pDelegate != NULL)
		{
			m_pDelegate->scrollViewDidDeaccelerateStop(this, m_tScrollDistance_init);
			m_pDelegate->scrollViewDidScrollEnd(this);
		}
		fireEvent("scrollViewDidDeaccelerateStop", kScrollViewScrollEnd);
	}
}

void CCScrollView::stoppedAnimatedScroll(CCNode * node)
{
	this->unschedule(schedule_selector(CCScrollView::performedAnimatedScroll));
	// After the animation stopped, "scrollViewDidScroll" should be invoked, this could fix the bug of lack of tableview cells.
	if (m_pDelegate != NULL)
	{
		m_pDelegate->scrollViewDidScroll(this);
	}
	fireEvent("scrollViewDidScroll", kScrollViewScroll);
	_scrollViewDidScroll();
}

void CCScrollView::stoppedAnimatedScrollEnd(CCNode* node)
{
	if (m_pDelegate != NULL)
	{
		m_pDelegate->scrollViewDidScrollEnd(this);
	}
}

void CCScrollView::performedAnimatedScroll(float dt)
{
	if (m_bDragging)
	{
		this->unschedule(schedule_selector(CCScrollView::performedAnimatedScroll));
		return;
	}

	if (m_pDelegate != NULL)
	{
		m_pDelegate->scrollViewDidScroll(this);
	}
	fireEvent("scrollViewDidScroll", kScrollViewScroll);
	_scrollViewDidScroll();
}


const CCSize& CCScrollView::getContentSize() const
{
	return m_pContainer->getContentSize();
}

void CCScrollView::setContentSize(const CCSize & size)
{
	if (this->getContainer() != NULL)
	{
		this->getContainer()->setContentSize(size);
		this->updateInset();
	}
}

void CCScrollView::updateInset()
{
	if (this->getContainer() != NULL)
	{
		m_fMaxInset = this->maxContainerOffset();
		m_fMaxInset = ccp(m_fMaxInset.x + m_tViewSize.width * INSET_RATIO,
			m_fMaxInset.y + m_tViewSize.height * INSET_RATIO);
		m_fMinInset = this->minContainerOffset();
		m_fMinInset = ccp(m_fMinInset.x - m_tViewSize.width * INSET_RATIO,
			m_fMinInset.y - m_tViewSize.height * INSET_RATIO);
	}
}

/**
* make sure all children go to the container
*/
void CCScrollView::addChild(CCNode * child, int zOrder, int tag)
{
	child->ignoreAnchorPointForPosition(false);
	child->setAnchorPoint(ccp(0.0f, 0.0f));
	if (m_pContainer != child) {
		m_pContainer->addChild(child, zOrder, tag);
		_setChildMenu(child);
	}
	else {
		CCLayer::addChild(child, zOrder, tag);
	}
}

void CCScrollView::addChild(CCNode * child, int zOrder)
{
	this->addChild(child, zOrder, child->getTag());
}

void CCScrollView::addChild(CCNode * child)
{
	this->addChild(child, child->getZOrder(), child->getTag());
}

/**
* clip this view so that outside of the visible bounds can be hidden.
*/
void CCScrollView::beforeDraw()
{
	if (m_bClippingToBounds)
	{
		m_bScissorRestored = false;
		CCRect frame = getViewRect();
		_caculateDisplayArea(frame);
		if (CCEGLView::sharedOpenGLView()->isScissorEnabled()) {
			m_bScissorRestored = true;
			m_tParentScissorRect = CCEGLView::sharedOpenGLView()->getScissorRect();
			//set the intersection of m_tParentScissorRect and frame as the new scissor rect
			if (frame.intersectsRect(m_tParentScissorRect)) {
				this->getContainer()->setVisible(true);
				float x = MAX(frame.origin.x, m_tParentScissorRect.origin.x);
				float y = MAX(frame.origin.y, m_tParentScissorRect.origin.y);
				float xx = MIN(frame.origin.x + frame.size.width, m_tParentScissorRect.origin.x + m_tParentScissorRect.size.width);
				float yy = MIN(frame.origin.y + frame.size.height, m_tParentScissorRect.origin.y + m_tParentScissorRect.size.height);

				CCEGLView::sharedOpenGLView()->setScissorInPoints(x, y, xx - x, yy - y);
			}
			//scrollview nest display bug
			else
			{
				this->getContainer()->setVisible(false);
			}
		}
		else {
			glEnable(GL_SCISSOR_TEST);
			CCEGLView::sharedOpenGLView()->setScissorInPoints(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
		}
	}
}

/**
* retract what's done in beforeDraw so that there's no side effect to
* other nodes.
*/
void CCScrollView::afterDraw()
{
	if (m_bClippingToBounds)
	{
		if (m_bScissorRestored) {//restore the parent's scissor rect
			CCEGLView::sharedOpenGLView()->setScissorInPoints(m_tParentScissorRect.origin.x, m_tParentScissorRect.origin.y, m_tParentScissorRect.size.width, m_tParentScissorRect.size.height);
		}
		else {
			glDisable(GL_SCISSOR_TEST);
		}
	}
}

void CCScrollView::visit()
{
	// quick return if not visible
	if (!isVisible())
	{
		return;
	}

	kmGLPushMatrix();

	if (m_pGrid && m_pGrid->isActive())
	{
		m_pGrid->beforeDraw();
		this->transformAncestors();
	}

	this->transform();
	this->beforeDraw();

	if (m_pChildren)
	{
		ccArray *arrayData = m_pChildren->data;
		unsigned int i = 0;

		// draw children zOrder < 0
		for (; i < arrayData->num; i++)
		{
			CCNode *child = (CCNode*)arrayData->arr[i];
			if (child->getZOrder() < 0)
			{
				visitChild(child);
			}
			else
			{
				break;
			}
		}

		// this draw
		this->draw();

		// draw children zOrder >= 0
		for (; i < arrayData->num; i++)
		{
			CCNode* child = (CCNode*)arrayData->arr[i];
			visitChild(child);
		}

	}
	else
	{
		this->draw();
	}

	this->afterDraw();
	if (m_pGrid && m_pGrid->isActive())
	{
		m_pGrid->afterDraw(this);
	}

	kmGLPopMatrix();
}

void CCScrollView::visitChild(CCNode* childNode)
{
	CC_RETURN_IF(!childNode)

	if (childNode == m_pContainer && m_pContainer->getChildrenCount() > 1)
	{
		// quick return if not visible
		if (!m_pContainer->isVisible())
		{
			return;
		}

		kmGLPushMatrix();

		CCGridBase* pGrid = m_pContainer->getGrid();
		if (pGrid && pGrid->isActive())
		{
			pGrid->beforeDraw();
		}

		m_pContainer->transform();

		if (m_pContainer->getChildrenCount())
		{
			m_pContainer->sortAllChildren();
			ccArray *arrayData = m_pContainer->getChildren()->data;
			unsigned int i = 0;

			// draw children zOrder < 0
			for (; i < arrayData->num; i++)
			{
				CCNode *child = (CCNode*)arrayData->arr[i];
				if (child && child->getZOrder() < 0 && isNodeVisible(childNode))
				{
					child->visit();
				}
				else
				{
					break;
				}
			}

			// this draw
			m_pContainer->draw();

			// draw children zOrder >= 0
			for (; i < arrayData->num; i++)
			{
				CCNode* child = (CCNode*)arrayData->arr[i];
				if (child && isNodeVisible(child))
				{
					child->visit();
				}
			}

		}
		else
		{
			m_pContainer->draw();
		}

		m_pContainer->setOrderOfArrival(0);
		if (pGrid && pGrid->isActive())
		{
			pGrid->afterDraw(m_pContainer);
		}

		kmGLPopMatrix();
	}
	else
	{
		childNode->visit();
	}
}

bool CCScrollView::ccTouchBegan(CCTouch* touch, CCEvent* event)
{
	if (!this->isVisible())
	{
		return false;
	}

	CCRect frame = getViewRect();

	//dispatcher does not know about clipping. reject touches outside visible bounds.
	if (m_pTouches->count() > 2 ||
		m_bTouchMoved ||
		!frame.containsPoint(m_pContainer->convertToWorldSpace(m_pContainer->convertTouchToNodeSpace(touch))))
	{
		return false;
	}
	for (CCNode *c = this->m_pParent; c != NULL; c = c->getParent())
	{
		if (c->isVisible() == false)
		{
			return false;
		}
	}
	if (!m_pTouches->containsObject(touch))
	{
		m_pTouches->addObject(touch);
	}

	if (m_pTouches->count() == 1)
	{ // scrolling
		m_tTouchPoint = this->convertTouchToNodeSpace(touch);
		m_bTouchMoved = false;
		m_bDragging = true; //dragging started
		m_tScrollDistance = ccp(0.0f, 0.0f);
		m_tScrollDistance_init = ccp(0.0f, 0.0f);
		m_fTouchLength = 0.0f;
	}
	else if (m_pTouches->count() == 2)
	{
		m_tTouchPoint = ccpMidpoint(this->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0)),
			this->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(1)));
		m_fTouchLength = ccpDistance(m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0)),
			m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(1)));
		m_bDragging = false;
	}
	return true;
}

void CCScrollView::ccTouchMoved(CCTouch* touch, CCEvent* event)
{
	if (!this->isVisible())
	{
		return;
	}

	if (m_pTouches->containsObject(touch))
	{
		if (m_pTouches->count() == 1 && m_bDragging)
		{ // scrolling
			CCPoint moveDistance, newPoint, maxInset, minInset;
			CCRect  frame;
			float newX, newY;

			frame = getViewRect();

			newPoint = this->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0));
			moveDistance = ccpSub(newPoint, m_tTouchPoint);

			float dis = 0.0f;
			if (m_eDirection == kCCScrollViewDirectionVertical)
			{
				dis = moveDistance.y;
			}
			else if (m_eDirection == kCCScrollViewDirectionHorizontal)
			{
				dis = moveDistance.x;
			}
			else
			{
				dis = sqrtf(moveDistance.x*moveDistance.x + moveDistance.y*moveDistance.y);
			}

			if (!m_bTouchMoved && fabs(convertDistanceFromPointToInch(dis)) < MOVE_INCH)
			{
				//CCLOG("Invalid movement, distance = [%f, %f], disInch = %f", moveDistance.x, moveDistance.y);
				return;
			}

			if (!m_bTouchMoved)
			{
				moveDistance = CCPointZero;
			}

			m_tTouchPoint = newPoint;
			m_bTouchMoved = true;

			if (frame.containsPoint(this->convertToWorldSpace(newPoint)))
			{
				switch (m_eDirection)
				{
				case kCCScrollViewDirectionVertical:
					moveDistance = ccp(0.0f, moveDistance.y);
					break;
				case kCCScrollViewDirectionHorizontal:
					moveDistance = ccp(moveDistance.x, 0.0f);
					break;
				default:
					break;
				}

				maxInset = m_fMaxInset;
				minInset = m_fMinInset;

				newX = m_pContainer->getPosition().x + moveDistance.x;
				newY = m_pContainer->getPosition().y + moveDistance.y;

				m_tScrollDistance = moveDistance;
				m_tScrollDistance_init = m_tScrollDistance;
				this->setContentOffset(ccp(newX, newY));
			}
		}
		else if (m_pTouches->count() == 2 && !m_bDragging)
		{
			const float len = ccpDistance(m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(0)),
				m_pContainer->convertTouchToNodeSpace((CCTouch*)m_pTouches->objectAtIndex(1)));
			this->setZoomScale(this->getZoomScale()*len / m_fTouchLength);
		}
	}
}

void CCScrollView::ccTouchEnded(CCTouch* touch, CCEvent* event)
{
	if (!this->isVisible())
	{
		return;
	}
	if (m_pTouches->containsObject(touch))
	{
		if (m_pTouches->count() == 1 && m_bTouchMoved)
		{
			this->schedule(schedule_selector(CCScrollView::deaccelerateScrolling));
			if (m_pDelegate != NULL)
			{
				m_pDelegate->scrollViewDidDeaccelerateScrolling(this, m_tScrollDistance_init);
			}
		}
		m_pTouches->removeObject(touch);
	}

	if (m_pTouches->count() == 0)
	{
		m_bDragging = false;
		m_bTouchMoved = false;
	}
}

void CCScrollView::ccTouchCancelled(CCTouch* touch, CCEvent* event)
{
	if (!this->isVisible())
	{
		return;
	}
	m_pTouches->removeObject(touch);
	if (m_pTouches->count() == 0)
	{
		m_bDragging = false;
		m_bTouchMoved = false;
	}
}

CCRect CCScrollView::getViewRect()
{
	CCPoint screenPos = this->convertToWorldSpace(CCPointZero);

	float scaleX = this->getScaleX();
	float scaleY = this->getScaleY();

	for (CCNode *p = m_pParent; p != NULL; p = p->getParent()) {
		scaleX *= p->getScaleX();
		scaleY *= p->getScaleY();
	}

	// Support negative scaling. Not doing so causes intersectsRect calls
	// (eg: to check if the touch was within the bounds) to return false.
	// Note, CCNode::getScale will assert if X and Y scales are different.
	if (scaleX<0.f) {
		screenPos.x += m_tViewSize.width*scaleX;
		scaleX = -scaleX;
	}
	if (scaleY<0.f) {
		screenPos.y += m_tViewSize.height*scaleY;
		scaleY = -scaleY;
	}

	return CCRectMake(screenPos.x, screenPos.y, m_tViewSize.width*scaleX, m_tViewSize.height*scaleY);
}

void CCScrollView::registerScriptHandler(int nFunID, int nScriptEventType)
{
	this->unregisterScriptHandler(nScriptEventType);
	m_mapScriptHandler[nScriptEventType] = nFunID;
}
void CCScrollView::unregisterScriptHandler(int nScriptEventType)
{
	std::map<int, int>::iterator iter = m_mapScriptHandler.find(nScriptEventType);

	if (m_mapScriptHandler.end() != iter)
	{
		CCScriptEngineManager::sharedManager()->getScriptEngine()->removeScriptHandler(nScriptEventType);
		m_mapScriptHandler.erase(iter);
	}
}
int  CCScrollView::getScriptHandler(int nScriptEventType)
{
	std::map<int, int>::iterator iter = m_mapScriptHandler.find(nScriptEventType);

	if (m_mapScriptHandler.end() != iter)
		return iter->second;

	return 0;
}
void CCScrollView::fireEvent(const char* eventName, int nScriptEventType)
{
	int scriptTableHandler = getScriptHandler(nScriptEventType);
	if (scriptTableHandler != 0)
	{
		CCLuaEngine::defaultEngine()->executeClassFunc(scriptTableHandler, eventName, this, "CCScrollView");
	}
}
#ifndef max
#define max(a,b)            (((a) > (b)) ? (a) : (b))
#endif
#ifndef min
#define min(a,b)            (((a) < (b)) ? (a) : (b))
#endif
void CCScrollView::orderCCBFileCells()
{
	if (mChildrenCells.empty()) return;

	float width = .0f;
	float height = .0f;
	float cellwidth = .0f;
	float cellheight = .0f;
	float cellwidthAnchorOffset = .0f;
	float cellheightAnchorOffset = .0f;
	float tempLen = .0f;
	if (m_eDirection == kCCScrollViewDirectionVertical)
	{
		CellSet::iterator itr = mChildrenCells.begin();
		for (; itr != mChildrenCells.end(); ++itr)
		{
			cellheight = (*itr)->getContentSize().height;
			cellwidth = (*itr)->getContentSize().width;
			cellwidthAnchorOffset = cellwidth * (*itr)->getAnchorPoint().x;
			cellheightAnchorOffset = cellheight * ((*itr)->getAnchorPoint().y - 1);
			if (width + cellwidth <= m_tViewSize.width)
				tempLen = max(tempLen, cellheight);
			else
			{
				width = .0f;
				height -= tempLen;
				tempLen = cellheight;
			}
			(*itr)->setPosition(CCPointMake(width + cellwidthAnchorOffset, height + cellheightAnchorOffset));
			width += cellwidth;
		}
		height -= tempLen;
		//std::for_each(mChildrenCells.begin(), mChildrenCells.end(), [height](CCBFileCell* cell){cell->setPositionY(cell->getPositionY() - height); });
		itr = mChildrenCells.begin();
		for (; itr != mChildrenCells.end(); ++itr)
		{
			(*itr)->setPositionY((*itr)->getPositionY() - height);
		}
		this->setContentSize(CCSizeMake(m_tViewSize.width, -height));
		this->setContentOffset(CCPointMake(0, this->getViewSize().height - this->getContentSize().height * this->getScaleY()));
	}
	else if (m_eDirection == kCCScrollViewDirectionHorizontal)
	{
		CellSet::iterator itr = mChildrenCells.begin();
		for (; itr != mChildrenCells.end(); ++itr)
		{
			cellheight = (*itr)->getContentSize().height;
			cellwidth = (*itr)->getContentSize().width;
			cellwidthAnchorOffset = cellwidth * (*itr)->getAnchorPoint().x;
			cellheightAnchorOffset = cellheight * (*itr)->getAnchorPoint().y;
			if (height >= cellheight)
			{
				tempLen = max(tempLen, cellwidth);
				height -= cellheight;
			}
			else
			{
				height = m_tViewSize.height - cellheight;
				width += tempLen;
				tempLen = cellwidth;
			}
			(*itr)->setPosition(CCPointMake(width + cellwidthAnchorOffset, height + cellheightAnchorOffset));
		}
		this->setContentSize(CCSizeMake(width + tempLen, m_tViewSize.height));
		this->setContentOffset(CCPointMake(0, 0));
	}
	this->forceRecaculateChildren();
}

void CCScrollView::forceRecaculateChildren()
{
	if (m_pContainer)
		_setChildMenu(m_pContainer);
}

void CCScrollView::addCell(CCBFileCell * cell, int index/* = -1*/)
{
	if (index == 0)
		addCellFront(cell);
	else if (index < 0 || index >= mChildrenCells.size())
		addCellBack(cell);
	else
	{
		CellSet::iterator itr = mChildrenCells.begin();
		while (index > 0 && itr != mChildrenCells.end())
		{
			--index;
			++itr;
		}
		mChildrenCells.insert(itr, cell);
		cell->retain();
		cell->setOwner(this);
	}
}

void CCScrollView::addCellFront(CCBFileCell * cell)
{
	if (m_pContainer)
		mChildrenCells.push_front(cell);
	cell->retain();
	cell->setOwner(this);
}

void CCScrollView::addCellBack(CCBFileCell * cell, bool needPreLoad/* = false*/)
{

	cell->retain();
	cell->setOwner(this);
	if (needPreLoad)
	{
		cell->setIsPreLoad(true);
		cell->preload();
		cell->load();
		CCSize disSize = cell->getDisSize();
		float height = cell->getContentSize().height;
		float width = cell->getContentSize().width;
		CellSet::iterator itr = mChildrenCells.begin();
		for (; itr != mChildrenCells.end(); ++itr)
		{
			if ((*itr))
			{
				if (m_eDirection == kCCScrollViewDirectionVertical)
				{
					(*itr)->setPositionY((*itr)->getPositionY() + height);
				}
				else if (m_eDirection == kCCScrollViewDirectionHorizontal)
				{
					(*itr)->setPositionX((*itr)->getPositionX() + width);
				}
			}
		}
		if (m_eDirection == kCCScrollViewDirectionVertical)
		{
			m_pContainer->setPositionY(m_pContainer->getPositionY() - height * this->getScaleY());
		}
		else if (m_eDirection == kCCScrollViewDirectionHorizontal)
		{
			m_pContainer->setPositionY(m_pContainer->getPositionX() - width * this->getScaleX());
		}
		m_pContainer->addChild(cell, cell->getZOrder(), cell->getTag());
	}
	mChildrenCells.push_back(cell);
}

void CCScrollView::removeCell(CCBFileCell * cell)
{
	mChildrenCells.remove(cell);
	if (cell)
	{
		m_pContainer->removeChild(cell, true);
		cell->unLoad();
		cell->release();
	}
	// 	CellSet::iterator itr = std::find(mChildrenCells.begin(), mChildrenCells.end(), cell);
	// 	if (itr != mChildrenCells.end())
	// 	{
	// 		(*itr)->unLoad();
	// 		m_pContainer->removeChild((*itr), true);
	// 		mChildrenCells.remove(cell);
	// 		(*itr)->release();
	// 	}
	orderCCBFileCells();
}

void CCScrollView::removeAllCell()
{
	CellSet::iterator itr = mChildrenCells.begin();
	for (; itr != mChildrenCells.end(); ++itr)
	{
		(*itr)->unLoad();
		(*itr)->release();
	}
	mChildrenCells.clear();
	m_pContainer->removeAllChildren();
	m_bDragging = false;
	m_bTouchMoved = false;
	m_pTouches->removeAllObjects();
}

void CCScrollView::refreshAllCell()
{
	CellSet::iterator itr = mChildrenCells.begin();
	for (; itr != mChildrenCells.end(); ++itr)
	{
		if ((*itr)->isLoaded())
		{
			(*itr)->refreshContent();
		}
	}
}

void CCScrollView::reLoadAllCell()
{
	CellSet::iterator itr = mChildrenCells.begin();
	for (; itr != mChildrenCells.end(); ++itr)
	{
		(*itr)->reLoad();
	}
}

void CCScrollView::locateToByIndex(int index, CCBFileCell::Locate_Type localType/* = CCBFileCell::Locate_Type::LT_TOP*/,
	float offset/* = 0*/, float duration/* = 0*/)
{
	int childrenSize = mChildrenCells.size();
	if (index < 0 || index > childrenSize)
	{
		return;
	}
	CCBFileCell* pCell;
	CellSet::iterator itr = mChildrenCells.begin();
	int i = 0;
	for (; itr != mChildrenCells.end(); ++itr)
	{
		if (i++ == index)
		{
			(*itr)->locateTo(localType, offset, duration);
			break;
		}
	}
}

void CCScrollView::resetCellPosition(CCBFileCell* cell, float offset)
{
	if (!cell)
	{
		return;
	}
	CellSet::iterator itr = mChildrenCells.begin();
	bool findCell = false;
	for (; itr != mChildrenCells.end(); ++itr)
	{
		if ((*itr) == cell)
		{
			findCell = true;
			continue;
		}
		if (findCell)
		{
			CCPoint oldPosition = (*itr)->getPosition();
			if (m_eDirection == kCCScrollViewDirectionVertical)
			{
				oldPosition.y += offset;
			}
			(*itr)->setPosition(oldPosition);
		}
	}
	CCSize oldSize = getContentSize();
	if (cell->getIsPreLoad())
	{
		if (m_eDirection == kCCScrollViewDirectionVertical)
		{
			oldSize.height += cell->getContentSize().height;
		}
		else if (m_eDirection == kCCScrollViewDirectionHorizontal)
		{
			oldSize.width += cell->getContentSize().width;
		}
	}
	else
	{
		if (m_eDirection == kCCScrollViewDirectionVertical)
		{
			oldSize.height += offset;
		}
		else if (m_eDirection == kCCScrollViewDirectionHorizontal)
		{
			oldSize.width += offset;
		}
	}
	setContentSize(oldSize);
	// 	CCSize oldOffsetSize = getContentOffset();
	// 	if (m_eDirection == kCCScrollViewDirectionVertical)
	// 	{
	// 		oldOffsetSize.height += offset;
	// 	}
	//	setContentOffset(oldOffsetSize);
}
void CCScrollView::setVisible(bool visible)
{
	CCNode::setVisible(visible);
	setTouchEnabled(visible);
}

void CCScrollView::_scrollViewDidScroll()
{
	CellSet loadSet;
	CellSet::iterator itr = mChildrenCells.begin();
	for (; itr != mChildrenCells.end(); ++itr)
	{
		CCBFileCell* pNode = (*itr);
		if (pNode)
		{
			if (this->isNodeVisible(pNode))
			{
				if (!pNode->getParent())
				{
					loadSet.push_back(pNode);
				}
				else if ((*itr)->getIsPreLoad())
				{
					(*itr)->setIsPreLoad(false);
				}
			}
			else
			{
				if (!(*itr)->getIsPreLoad())
				{
					pNode->unLoad();
					//pNode->setVisible(false);
					m_pContainer->removeChild(pNode, true);
				}
			}
		}
	}
	for (CellSet::iterator itr = loadSet.begin(); itr != loadSet.end(); itr++)
	{
		CCBFileCell* cell = (*itr);

		//cell->setVisible(true);
		//if(!cell->getParent())
		//{
		//cell->preload();
		cell->load();
		m_pContainer->addChild(cell, cell->getZOrder(), cell->getTag());
		//_setChildMenu(cell);
		//}
	}
}


CCBFileCell::CCBFileCell()
{
	mScriptTableHandler = 0;
	mCCBFile = 0;
	mCCBFileName = "";
	mCellTag = 0;
	mIsPreLoad = false;
	mDisSize = CCSizeMake(0, 0);
}

CCBFileCell::~CCBFileCell()
{
	unLoad();
	unregisterFunctionHandler();
}

void CCBFileCell::preload()
{
	if (mScriptTableHandler)
	{
		CCLuaEngine::defaultEngine()->executeClassFunc(mScriptTableHandler, "onPreLoad", this, "CCBFileCell");
	}
}

void CCBFileCell::load()
{
	// 	if(mScriptTableHandler)
	// 	{ 
	// 		CCLuaEngine::defaultEngine()->executeClassFunc(mScriptTableHandler,"onPreLoad",this,"CCBFileCell");
	// 	}

	if (mCCBFile || mCCBFileName.empty())
		return;
	mCCBFile = CCBFileNew::CreateInPool(mCCBFileName);
	//mCCBFile->setListener(this);
	mCCBFile->mScriptTableHandler = mScriptTableHandler;
	mCCBFile->retain();
	addChild(mCCBFile);
	mOwner->_setChildMenu(this);
	mCCBFile->setCCScrollViewChild(mOwner);
	mCCBFile->setCCBTag(mCellTag);
	//refreshContent();
	refreshAndResizeContent();
}

void CCBFileCell::unLoad()
{
	if (mCCBFile)
	{
		if (mScriptTableHandler)
		{
			//CCLuaEngine::defaultEngine()->executeClassFunc(mScriptTableHandler, "onUnLoad", this, "CCBFileCell");
		}

		if (mCCBFile->mScriptTableHandler == mScriptTableHandler)
			mCCBFile->mScriptTableHandler = 0;
		removeChild(mCCBFile, true);
		mCCBFile->release();
		mCCBFile = 0;
	}
}

void CCBFileCell::reLoad()
{
	bool isload = isLoaded();
	if (isload)
		unLoad();

	preload();

	if (isload)
		load();
}

bool CCBFileCell::isLoaded()
{
	return mCCBFile != 0;
}

void CCBFileCell::registerFunctionHandler(int nHandler)
{
	unregisterFunctionHandler();
	mScriptTableHandler = nHandler;
}

void CCBFileCell::unregisterFunctionHandler(void)
{
	if (mScriptTableHandler)
	{
		CCLuaEngine::defaultEngine()->removeScriptTableHandler(mScriptTableHandler);
		mScriptTableHandler = 0;
	}
}

void CCBFileCell::refreshContent()
{
	if (mScriptTableHandler)
	{
		CCLuaEngine::defaultEngine()->executeClassFunc(mScriptTableHandler, "onRefreshContent", this, "CCBFileCell");
	}
}

void CCBFileCell::refreshAndResizeContent()
{
	CCSize oldSize = getContentSize();
	refreshContent();
	CCSize newSize = getContentSize();
	if (oldSize.width == newSize.width && oldSize.height == newSize.height)
	{
		return;
	}
	float disX = newSize.width - oldSize.width;
	float disY = newSize.height - oldSize.height;
	CCScrollViewDirection dir = mOwner->getDirection();
	if (kCCScrollViewDirectionVertical == dir)
	{
		mOwner->resetCellPosition(this, disY);
	}
	else if (kCCScrollViewDirectionHorizontal == dir)
	{
		mOwner->resetCellPosition(this, disX);
	}

	setDisSize(CCSizeMake(disX, disY));
}

void CCBFileCell::setCCBFile(const std::string& ccbfile)
{
	if (ccbfile.empty() || mCCBFileName == ccbfile)
		return;

	mCCBFileName = ccbfile;
	CCBFileNew* ccbfile_node = CCBFileNew::CreateInPool(mCCBFileName);
	CCSize oldSize = getContentSize();
	CCSize newSize = ccbfile_node->getContentSize();
	setContentSize(ccbfile_node->getContentSize());

	if (mCCBFile)
	{
		unLoad();
		load();
	}

	// 	mCCBFileName = ccbfile;
	// 	CCBFile* ccbfile_node = CCBFile::CreateInPool(mCCBFileName);
	// 	setContentSize(ccbfile_node->getContentSize());
}

const std::string& CCBFileCell::getCCBFile()
{
	return mCCBFileName;
}

CCBFileNew* CCBFileCell::getCCBFileNode()
{
	return mCCBFile;
}

void CCBFileCell::locateTo(Locate_Type type, float offset/* = 0*/, float duration/* = 0*/)
{
	if (mOwner)
	{
		CCPoint contentOffset;
		float* _offset;
		float viewSize;
		float cellSize;
		float cellPosition;

		CCScrollViewDirection dir = mOwner->getDirection();
		if (kCCScrollViewDirectionHorizontal == dir)
		{
			viewSize = mOwner->getViewSize().width;
			cellSize = getContentSize().width;
			cellPosition = getPositionX();
			_offset = &contentOffset.x;
		}
		else if (kCCScrollViewDirectionVertical == dir)
		{
			viewSize = mOwner->getViewSize().height;
			cellSize = getContentSize().height;
			cellPosition = getPositionY();
			_offset = &contentOffset.y;
		}
		else if (kCCScrollViewDirectionBoth == dir)
		{
			return;
		}
		else
		{
			return;
		}

		float locateOffset;
		float cellOffset;
		if (type == LT_Top)
		{
			locateOffset = viewSize;
			cellOffset = cellPosition + cellSize;
		}
		else if (type == LT_Mid)
		{
			locateOffset = viewSize / 2;
			cellOffset = cellPosition + cellSize / 2;
		}
		else if (type == LT_Bottom)
		{
			locateOffset = 0;
			cellOffset = cellPosition;
		}
		else
		{
			return;
		}

		*_offset = locateOffset - cellOffset * mOwner->getScaleY() + offset;

		if (duration == 0)
		{
			mOwner->setContentOffset(contentOffset, false);
			mOwner->relocateContainer(false);
		}
		else
		{
			mOwner->_scrollViewDidScroll();

			CCPoint min, max;
			float newX, newY;

			min = mOwner->minContainerOffset();
			max = mOwner->maxContainerOffset();

			newX = contentOffset.x;
			newY = contentOffset.y;
			if (dir == kCCScrollViewDirectionBoth || dir == kCCScrollViewDirectionHorizontal)
			{
				newX = MAX(newX, min.x);
				newX = MIN(newX, max.x);
			}

			if (dir == kCCScrollViewDirectionBoth || dir == kCCScrollViewDirectionVertical)
			{
				newY = MIN(newY, max.y);
				newY = MAX(newY, min.y);
			}
			mOwner->setContentOffsetInDuration(ccp(newX, newY), duration);
		}
	}
}

NS_CC_EXT_END
