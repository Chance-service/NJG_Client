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

#ifndef __CCSCROLLVIEW_H__
#define __CCSCROLLVIEW_H__

#include "cocos2d.h"
#include "ExtensionMacros.h"
#include "CCBReader/CCBFileNew.h"
NS_CC_EXT_BEGIN

/**
 * @addtogroup GUI
 * @{
 */

typedef enum {
	kCCScrollViewDirectionNone = -1,
    kCCScrollViewDirectionHorizontal = 0,
    kCCScrollViewDirectionVertical,
    kCCScrollViewDirectionBoth
} CCScrollViewDirection;

class CCScrollView;

class CCScrollViewDelegate
{
public:
    virtual ~CCScrollViewDelegate() {}
    virtual void scrollViewDidScroll(CCScrollView* view) = 0;
	virtual void scrollViewDidDeaccelerateScrolling(CCScrollView* view, CCPoint initSpeed){};
	virtual void scrollViewDidDeaccelerateStop(CCScrollView* view, CCPoint initSpeed){};
    virtual void scrollViewDidZoom(CCScrollView* view) = 0;
	virtual void scrollViewDidScrollEnd(CCScrollView* view){};
};

class CCBFileCell: public CCNode
{
public:
	enum Locate_Type
	{
		LT_Top,
		LT_Mid,
		LT_Bottom,
	};

	CCBFileCell();
	~CCBFileCell();
	CREATE_FUNC(CCBFileCell);
	void preload();
	void load();
	void unLoad();
	void reLoad();
	bool isLoaded();

	void refreshContent();
	void refreshAndResizeContent();

	void locateTo(Locate_Type type, float offset = 0, float duration = 0);

	void setOwner(CCScrollView* owner){mOwner = owner;};
	CCScrollView* getOwner(){return mOwner;}

	void setCCBFile(const std::string& ccbfile);
	const std::string& getCCBFile();
	CCBFileNew* getCCBFileNode();

	void registerFunctionHandler(int nHandler);
	void unregisterFunctionHandler();

	void setCellTag(int tag){mCellTag = tag;}
	int getCellTag(){return mCellTag;}

	void setIsPreLoad(bool isPreLoad){mIsPreLoad = isPreLoad;}
	bool getIsPreLoad(){return mIsPreLoad;}

	void setDisSize(const CCSize& disSize){mDisSize = disSize;}
	const CCSize& getDisSize(){return mDisSize;}
private:
	std::string mCCBFileName;
	CCBFileNew* mCCBFile;
	int mScriptTableHandler;
	CCScrollView*  mOwner;
	int mCellTag;
	bool mIsPreLoad;//是否是提前加载好的，如果是，在第一次出现在可见区域之前都不unload
	CCSize mDisSize;
};

/**
 * ScrollView support for cocos2d for iphone.
 * It provides scroll view functionalities to cocos2d projects natively.
 */
class CCScrollView : public CCLayer
{
public:
    CCScrollView();
    virtual ~CCScrollView();

	friend class CCBFileCell;

    bool init();
    virtual void registerWithTouchDispatcher();

    /**
     * Returns an autoreleased scroll view object.
     *
     * @param size view size
     * @param container parent object
     * @return autoreleased scroll view object
     */
    static CCScrollView* create(CCSize size, CCNode* container = NULL);

    /**
     * Returns an autoreleased scroll view object.
     *
     * @param size view size
     * @param container parent object
     * @return autoreleased scroll view object
     */
    static CCScrollView* create();

    /**
     * Returns a scroll view object
     *
     * @param size view size
     * @param container parent object
     * @return scroll view object
     */
    bool initWithViewSize(CCSize size, CCNode* container = NULL);


    /**
     * Sets a new content offset. It ignores max/min offset. It just sets what's given. (just like UIKit's UIScrollView)
     *
     * @param offset new offset
     * @param If YES, the view scrolls to the new offset
     */
    void setContentOffset(CCPoint offset, bool animated = false);
    CCPoint getContentOffset();
    /**
     * Sets a new content offset. It ignores max/min offset. It just sets what's given. (just like UIKit's UIScrollView)
     * You can override the animation duration with this method.
     *
     * @param offset new offset
     * @param animation duration
     */
    void setContentOffsetInDuration(CCPoint offset, float dt); 

    void setZoomScale(float s);
    /**
     * Sets a new scale and does that for a predefined duration.
     *
     * @param s a new scale vale
     * @param animated if YES, scaling is animated
     */
    void setZoomScale(float s, bool animated);

    float getZoomScale();

	void setScrollDeaccelRate(float rate){m_fScrollDeaccelRate = rate;}
	float getScrollDeaccelRate(){return m_fScrollDeaccelRate;}
    /**
     * Sets a new scale for container in a given duration.
     *
     * @param s a new scale value
     * @param animation duration
     */
    void setZoomScaleInDuration(float s, float dt);
    /**
     * Returns the current container's minimum offset. You may want this while you animate scrolling by yourself
     */
    CCPoint minContainerOffset();
    /**
     * Returns the current container's maximum offset. You may want this while you animate scrolling by yourself
     */
    CCPoint maxContainerOffset(); 
    /**
     * Determines if a given node's bounding box is in visible bounds
     *
     * @return YES if it is in visible bounds
     */
    bool isNodeVisible(CCNode * node);
    /**
     * Provided to make scroll view compatible with SWLayer's pause method
     */
    void pause(CCObject* sender);
    /**
     * Provided to make scroll view compatible with SWLayer's resume method
     */
    void resume(CCObject* sender);


    bool isDragging() {return m_bDragging;}
    bool isTouchMoved() { return m_bTouchMoved; }
    bool isBounceable() { return m_bBounceable; }
    void setBounceable(bool bBounceable) { m_bBounceable = bBounceable; }

	// add by zhenhui 2014/7/26 to determine whether scrollview can scroll outside the edge and at the same time preserve the Bounceable property.
	bool isEdgePreserve() { return m_bEdgePreserve; }
	void setEdgePreserve(bool bEdgePreserve) { m_bEdgePreserve = bEdgePreserve; }

    /**
     * size to clip. CCNode boundingBox uses contentSize directly.
     * It's semantically different what it actually means to common scroll views.
     * Hence, this scroll view will use a separate size property.
     */
    CCSize getViewSize() { return m_tViewSize; } 
    void setViewSize(CCSize size);

    CCNode * getContainer();
    void setContainer(CCNode * pContainer);
	void resetContainer();
    /**
     * direction allowed to scroll. CCScrollViewDirectionBoth by default.
     */
    CCScrollViewDirection getDirection() { return m_eDirection; }
    virtual void setDirection(CCScrollViewDirection eDirection) { m_eDirection = eDirection; }

    CCScrollViewDelegate* getDelegate() { return m_pDelegate; }
    void setDelegate(CCScrollViewDelegate* pDelegate) { m_pDelegate = pDelegate; }

    /** override functions */
    // optional
    virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);

    virtual void setContentSize(const CCSize & size);
    virtual const CCSize& getContentSize() const;

	void updateInset();
    /**
     * Determines whether it clips its children or not.
     */
    bool isClippingToBounds() { return m_bClippingToBounds; }
    void setClippingToBounds(bool bClippingToBounds) { m_bClippingToBounds = bClippingToBounds; }
    /**
     *  @js NA
     */
    virtual void visit();
    virtual void addChild(CCNode * child, int zOrder, int tag);
    virtual void addChild(CCNode * child, int zOrder);
    virtual void addChild(CCNode * child);
    void setTouchEnabled(bool e);

	void orderCCBFileCells();
	void forceRecaculateChildren();
	virtual void addCell(CCBFileCell * cell, int index=-1);
	virtual void addCellFront(CCBFileCell * cell);
	virtual void addCellBack(CCBFileCell * cell,bool needPreLoad = false);
	virtual void removeCell(CCBFileCell * cell);
	virtual void removeAllCell();
	void refreshAllCell();
	void reLoadAllCell();
	void locateToByIndex(int index, CCBFileCell::Locate_Type localType = CCBFileCell::LT_Top,
		float offset = 0, float duration = 0);
	void resetCellPosition(CCBFileCell* cell,float offset);

	void _setChildMenu(CCNode* child);

	CCPoint getScrollDistanceInit(){return m_tScrollDistance_init;};
	CCPoint getScrollDistance(){return m_tScrollDistance;};

	virtual void setVisible(bool visible);
private:

	void _caculateDisplayArea(const CCRect& rect);
	
    /**
     * Relocates the container at the proper offset, in bounds of max/min offsets.
     *
     * @param animated If YES, relocation is animated
     */
    void relocateContainer(bool animated);
    /**
     * implements auto-scrolling behavior. change SCROLL_DEACCEL_RATE as needed to choose
     * deacceleration speed. it must be less than 1.0f.
     *
     * @param dt delta
     */
    void deaccelerateScrolling(float dt);
    /**
     * This method makes sure auto scrolling causes delegate to invoke its method
     */
    void performedAnimatedScroll(float dt);
    /**
     * Expire animated scroll delegate calls
     */
    void stoppedAnimatedScroll(CCNode* node);
	void stoppedAnimatedScrollEnd(CCNode* node);		//add by liu longfei scroll end
    /**
     * clip this view so that outside of the visible bounds can be hidden.
     */
    void beforeDraw();
    /**
     * retract what's done in beforeDraw so that there's no side effect to
     * other nodes.
     */
    void afterDraw();
    /**
     * Zoom handling
     */
    void handleZoom();

	void visitChild(CCNode* child);

	void _scrollViewDidScroll();
protected:
    CCRect getViewRect();
    
    /**
     * current zoom scale
     */
    float m_fZoomScale;
    /**
     * min zoom scale
     */
    float m_fMinZoomScale;
    /**
     * max zoom scale
     */
    float m_fMaxZoomScale;
    /**
     * scroll view delegate
     */
    CCScrollViewDelegate* m_pDelegate;

    CCScrollViewDirection m_eDirection;
    /**
     * If YES, the view is being dragged.
     */
    bool m_bDragging;

    /**
     * Content offset. Note that left-bottom point is the origin
     */
    CCPoint m_tContentOffset;

    /**
     * Container holds scroll view contents, Sets the scrollable container object of the scroll view
     */
    CCNode* m_pContainer;
    /**
     * Determiens whether user touch is moved after begin phase.
     */
    bool m_bTouchMoved;
    /**
     * max inset point to limit scrolling by touch
     */
    CCPoint m_fMaxInset;
    /**
     * min inset point to limit scrolling by touch
     */
    CCPoint m_fMinInset;
    /**
     * Determines whether the scroll view is allowed to bounce or not.
     */
    bool m_bBounceable;

	// add by zhenhui 2014/7/26 to determine whether scrollview can scroll outside the edge and at the same time preserve the Bounceable property.
	 bool m_bEdgePreserve;

    bool m_bClippingToBounds;

    /**
     * scroll speed
     */
    CCPoint m_tScrollDistance;
	CCPoint m_tScrollDistance_init;
    /**
     * Touch point
     */
    CCPoint m_tTouchPoint;
    /**
     * length between two fingers
     */
    float m_fTouchLength;
    /**
     * UITouch objects to detect multitouch
     */
    CCArray* m_pTouches;
    /**
     * size to clip. CCNode boundingBox uses contentSize directly.
     * It's semantically different what it actually means to common scroll views.
     * Hence, this scroll view will use a separate size property.
     */
    CCSize m_tViewSize;
    /**
     * max and min scale
     */
    float m_fMinScale, m_fMaxScale;
    /**
     * scissor rect for parent, just for restoring GL_SCISSOR_BOX
     */
    CCRect m_tParentScissorRect;
    bool m_bScissorRestored;
	
		
	float m_fScrollDeaccelRate;
	
	CCRect m_tDisplayArea;

	typedef std::list<CCBFileCell*> CellSet;
	CellSet mChildrenCells;

public:
    enum ScrollViewScriptEventType
    {
        kScrollViewScroll   = 0,
        kScrollViewZoom,
		kScrollViewScrollEnd,
    };
    void registerScriptHandler(int nFunID,int nScriptEventType);
    void unregisterScriptHandler(int nScriptEventType);
    int  getScriptHandler(int nScriptEventType);
private:
    std::map<int,int> m_mapScriptHandler;
	CCSize mOriginalContentSize;
	void fireEvent( const char* eventName,int nScriptEventType );
};

// end of GUI group
/// @}

NS_CC_EXT_END

#endif /* __CCSCROLLVIEW_H__ */
