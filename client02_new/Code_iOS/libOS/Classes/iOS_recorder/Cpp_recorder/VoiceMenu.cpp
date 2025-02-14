#include "VoiceMenu.h"

USING_NS_CC;


VoiceMenu* VoiceMenu::createWithItem(CCMenuItem* item)
{
	return VoiceMenu::create(item, NULL);
}

VoiceMenu * VoiceMenu::create(CCMenuItem* item, ...)
{
	va_list args;
	va_start(args, item);
	VoiceMenu *pRet = new VoiceMenu();
	if (pRet && pRet->initWithItems(item, args))
	{
		pRet->autorelease();
		va_end(args);
		return pRet;
	}
	va_end(args);
	CC_SAFE_DELETE(pRet);
	return NULL;
}

bool VoiceMenu::initWithItems(CCMenuItem* item, va_list args)
{
	CCArray* pArray = NULL;
	if (item)
	{
		pArray = CCArray::create(item, NULL);
		CCMenuItem *i = va_arg(args, CCMenuItem*);
		while (i)
		{
			pArray->addObject(i);
			i = va_arg(args, CCMenuItem*);
		}
	}

	if (CCMenu::initWithArray(pArray))
	{
        this->initWithArray(pArray);

		//do something

		return true;
	}

	return false;
}

bool VoiceMenu::ccTouchBegan(CCTouch* touch, CCEvent* event)
{
	CC_UNUSED_PARAM(event);
	if (m_eState != kCCMenuStateWaiting || !m_bVisible || !m_bEnabled)
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
	CCPoint worldPos = convertToWorldSpace(convertTouchToNodeSpace(touch));

	if (m_bScrollViewChild)
	{
		if (!mTouchArea.containsPoint(worldPos))
			return false;
	}

	m_pSelectedItem = dynamic_cast<VoiceMenuItem*> (this->itemForTouch(touch));
	if (m_pSelectedItem)
	{
		m_eState = kCCMenuStateTrackingTouch;
		m_pSelectedItem->selected();
		if (m_bScrollViewChild)
		{
			m_tTouchPoint = convertToWorldSpace(convertTouchToNodeSpace(touch));
		}
		return true;
	}
	return false;
}

void VoiceMenu::ccTouchEnded(CCTouch *touch, CCEvent* event)
{
	CC_UNUSED_PARAM(touch);
	CC_UNUSED_PARAM(event);
	CCAssert(m_eState == kCCMenuStateTrackingTouch, "[Menu ccTouchEnded] -- invalid state");
	if (m_pSelectedItem)
	{
		if (m_bScrollViewChild)
		{
			CCPoint np = convertToWorldSpace(convertTouchToNodeSpace(touch));
			if (fabs(np.x - m_tTouchPoint.x) < 20.0f && fabs(np.y - m_tTouchPoint.y) < 20.0f)
			{
					//判断送开始是否点中按钮
					if (this->itemForTouch(touch))
					{
						m_pSelectedItem->unselected();
					}
					else
					{	//若结束时没在点击状态，则调用没点击函数
						m_pSelectedItem->unselected_cancelClick();
					}
				m_pSelectedItem->activate();

				scheduleTouchesLock();
			}
			else
			{
				//m_pSelectedItem->unselected_cancel();

				//unselected_cancle会调unselected(正常结束点击);
				//来电的话改为也是掉取消
				m_pSelectedItem->unselected_cancelClick();
			}
		}
		else
		{	//判断送开始是否点中按钮
			if (this->itemForTouch(touch))
			{
				m_pSelectedItem->unselected();
			}
			else
			{	//若结束时没在点击状态，则调用没点击函数
				m_pSelectedItem->unselected_cancelClick();
			}
			m_pSelectedItem->activate();

			scheduleTouchesLock();
		}
	}
	m_eState = kCCMenuStateWaiting;
}


void VoiceMenu::ccTouchCancelled(CCTouch *touch, CCEvent* event)
{
	CC_UNUSED_PARAM(touch);
	CC_UNUSED_PARAM(event);
	CCAssert(m_eState == kCCMenuStateTrackingTouch, "[Menu ccTouchCancelled] -- invalid state");
	if (m_pSelectedItem)
	{
		//m_pSelectedItem->unselected_cancel();

		//unselected_cancle会调unselected(正常结束点击);
		//来电的话改为也是掉取消
		m_pSelectedItem->unselected_cancelClick();
	}
	m_eState = kCCMenuStateWaiting;
}

void VoiceMenu::ccTouchMoved(CCTouch* touch, CCEvent* event)
{
	CC_UNUSED_PARAM(event);
	CCAssert(m_eState == kCCMenuStateTrackingTouch, "[Menu ccTouchMoved] -- invalid state");
	CCMenuItem *currentItem = this->itemForTouch(touch);
	if (currentItem != m_pSelectedItem)
	{
		if (m_pSelectedItem)
		{
			//m_pSelectedItem->unselected_cancel();

			//unselected_cancle会调unselected(正常结束点击);
			//来电的话改为也是掉取消
			m_pSelectedItem->unselected_cancelClick();
		}
		m_pSelectedItem = dynamic_cast<VoiceMenuItem*> (currentItem);
		if (m_pSelectedItem)
		{
			m_pSelectedItem->selected();
		}
	}
}

void VoiceMenu::registerWithTouchDispatcher()
{
	CCDirector* pDirector = CCDirector::sharedDirector();

	//比普通menu高1
	pDirector->getTouchDispatcher()->addTargetedDelegate(this, kCCMenuHandlerPriority - 1, !m_bScrollViewChild);
	//pDirector->getTouchDispatcher()->addTargetedDelegate(this, this->getTouchPriority(), true);
}


bool VoiceMenu::initWithArray(CCArray* pArrayOfItems)
{
	if (CCLayer::init())
	{
		setTouchPriority(kCCMenuHandlerPriority);
		setTouchMode(kCCTouchesOneByOne);
		setTouchEnabled(true);

		m_bEnabled = true;
		// menu in the center of the screen
		CCSize s = CCDirector::sharedDirector()->getWinSize();

		this->ignoreAnchorPointForPosition(true);
		setAnchorPoint(ccp(0.5f, 0.5f));
		this->setContentSize(s);

		setPosition(ccp(s.width / 2, s.height / 2));

		if (pArrayOfItems != NULL)
		{
			int z = 0;
			CCObject* pObj = NULL;
			CCARRAY_FOREACH(pArrayOfItems, pObj)
			{
				CCMenuItem* item = (CCMenuItem*)pObj;
				this->addChild(item, z);
				z++;
			}
		}

		//    [self alignItemsVertically];
		m_pSelectedItem = NULL;
		m_eState = kCCMenuStateWaiting;

		// enable cascade color and opacity on menus
		setCascadeColorEnabled(true);
		setCascadeOpacityEnabled(true);

		return true;
	}
	return false;
}


void VoiceMenu::onExit()
{
	if (m_eState == kCCMenuStateTrackingTouch)
	{
		if (m_pSelectedItem)
		{
			m_pSelectedItem->unselected();
			m_pSelectedItem = NULL;
		}

		m_eState = kCCMenuStateWaiting;
	}

	CCLayer::onExit();
}

void VoiceMenu::removeChild(CCNode* child, bool cleanup)
{
	CCMenuItem *pMenuItem = dynamic_cast<CCMenuItem*>(child);
	CCAssert(pMenuItem != NULL, "Menu only supports MenuItem objects as children");

	if (m_pSelectedItem == pMenuItem)
	{
		m_pSelectedItem = NULL;
	}

	CCNode::removeChild(child, cleanup);
}

void VoiceMenu::setScrollViewChild(bool child)
{
	m_bScrollViewChild = child;
}

CCMenuItem* VoiceMenu::itemForTouch(CCTouch *touch)
{
	CCPoint touchLocation = touch->getLocation();

	if (m_pChildren && m_pChildren->count() > 0)
	{
		CCObject* pObject = NULL;
		CCARRAY_FOREACH_REVERSE(m_pChildren, pObject)
		{
			CCMenuItem* pChild = dynamic_cast<CCMenuItem*>(pObject);
			if (pChild && pChild->isVisible() && pChild->isEnabled())
			{
				//CCPoint local = pChild->convertToNodeSpace(touchLocation);
				CCPoint local = pChild->convertTouchToNodeSpace(touch);
				CCRect r = pChild->rect();
				r.origin = CCPointZero;

				if (r.containsPoint(local))
				{
					return pChild;
				}
			}
		}
	}

	return NULL;
}