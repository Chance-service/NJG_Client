#pragma once
#include "cocos2d.h"

USING_NS_CC;

class VoiceMenuItem : public CCMenuItemSprite
{

public:
	VoiceMenuItem() : mIsUnClick(false){};
	virtual ~VoiceMenuItem(){};

	static VoiceMenuItem* itemWithImages(const char *normalImage, const char *selectedImage);
	bool initWithImages(const char *normalImage, const char *selectedImage);

	/** The item was selected (not activated), similar to "mouse-over" */
	virtual void selected();
	/** The item was unselected */
	virtual void unselected();
	virtual void unselected_cancel();
	
	//�Ƴ���ť��Χ����ȡ����������
	virtual void unselected_cancelClick();

private:
	//���ڱ���Ƿ��Ǵ�cancleCLick����unselected
	bool mIsUnClick;


};