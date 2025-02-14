
#include "VoiceMenuItem.h"
#include "VoiceChatRecord.h"

USING_NS_CC;

void VoiceMenuItem::selected()
{
	CCMenuItemSprite::selected();

	START_RECORD_VOICE_CHAT();
}

void VoiceMenuItem::unselected()
{
	CCMenuItemSprite::unselected();

	if (mIsUnClick)
	{
		mIsUnClick = false;
		return;
	}

	STOP_RECORD_VOICE_CHAT()
}

void VoiceMenuItem::unselected_cancel()
{
	//VoiceMenu不会调用他
	CCMenuItemSprite::unselected_cancel();
	//CANCLE_RECORD_VOICE_CHAT()
	//STOP_RECORD_VOICE_CHAT()
}

void VoiceMenuItem::unselected_cancelClick()
{
	//取消选中状态
	if (m_pNormalImage)
	{
		m_pNormalImage->setVisible(true);

		if (m_pSelectedImage)
		{
			m_pSelectedImage->setVisible(false);
		}
		else
		{
			CCSprite *sprite = dynamic_cast<CCSprite*>(m_pNormalImage);
			if (sprite)
			{
				sprite->setColor(getOriColor());
			}
		}

		if (m_pDisabledImage)
		{
			m_pDisabledImage->setVisible(false);
		}
	}

	//清除选中状态
	mIsUnClick = true;
	unselected();

	CANCLE_RECORD_VOICE_CHAT()
	STOP_RECORD_VOICE_CHAT()
}

VoiceMenuItem* VoiceMenuItem::itemWithImages(const char *normalImage, const char *selectedImage)
{
	VoiceMenuItem *pRet = new VoiceMenuItem();
	if (pRet && pRet->initWithImages(normalImage, selectedImage))
	{
		pRet->autorelease();
		return pRet;
	}
	CC_SAFE_DELETE(pRet);
	return NULL;
}

bool VoiceMenuItem::initWithImages(const char *normalImage, const char *selectedImage)
{

	CCNode *normalSprite = NULL;
	CCNode *selectedSprite = NULL;
	CCNode *disabledSprite = NULL;

	if (normalImage)
	{
		normalSprite = CCSprite::create(normalImage);
	}

	if (selectedImage)
	{
		selectedSprite = CCSprite::create(selectedImage);
	}

	//CCAssert(normalSprite != NULL && selectedSprite != NULL, "image must be not NULL");

	if (CCMenuItemSprite::initWithNormalSprite(normalSprite,selectedSprite,NULL,NULL,NULL))
	{
		// do something ?

		return true;
	}
	return false;
}