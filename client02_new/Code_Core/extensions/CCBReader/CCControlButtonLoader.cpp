#include "CCControlButtonLoader.h"


NS_CC_EXT_BEGIN;

#define PROPERTY_ZOOMONTOUCHDOWN "zoomOnTouchDown"
#define PROPERTY_TITLE_NORMAL "title|1"
#define PROPERTY_TITLE_HIGHLIGHTED "title|2"
#define PROPERTY_TITLE_DISABLED "title|3"
#define PROPERTY_TITLECOLOR_NORMAL "titleColor|1"
#define PROPERTY_TITLECOLOR_HIGHLIGHTED "titleColor|2"
#define PROPERTY_TITLECOLOR_DISABLED "titleColor|3"
#define PROPERTY_TITLETTF_NORMAL "titleTTF|1"
#define PROPERTY_TITLETTF_HIGHLIGHTED "titleTTF|2"
#define PROPERTY_TITLETTF_DISABLED "titleTTF|3"
#define PROPERTY_TITLETTFSIZE_NORMAL "titleTTFSize|1"
#define PROPERTY_TITLETTFSIZE_HIGHLIGHTED "titleTTFSize|2"
#define PROPERTY_TITLETTFSIZE_DISABLED "titleTTFSize|3"
#define PROPERTY_LABELANCHORPOINT "labelAnchorPoint"
#define PROPERTY_PREFEREDSIZE "preferedSize" // TODO Should be "preferredSize". This is a typo in cocos2d-iphone, cocos2d-x and CocosBuilder!
#define PROPERTY_BACKGROUNDSPRITEFRAME_NORMAL "backgroundSpriteFrame|1"
#define PROPERTY_BACKGROUNDSPRITEFRAME_HIGHLIGHTED "backgroundSpriteFrame|2"
#define PROPERTY_BACKGROUNDSPRITEFRAME_DISABLED "backgroundSpriteFrame|3"
#define PROPERTY_BACKGROUNDSPRITE_ENABLEGRAY "grayEnabled"
#define PROPERTY_BACKGROUNDSPRITE_GRAYRATE "grayRate"

#define PROPERTY_TITLE_SHADOW_ENABLE "shadowEnabled"
#define PROPERTY_TITLE_SHADOW_COLOR "shadowColor"
#define PROPERTY_TITLE_SHADOW_OFFSET "shadowOffset"
#define PROPERTY_TITLE_SHADOW_OFFSET2 "shadowOffset2"
#define PROPERTY_TITLE_SHADOW_OFFSET3 "shadowOffset3"
#define PROPERTY_TITLE_SHADOW_OFFSET4 "shadowOffset4"
#define PROPERTY_TITLE_SHADOW_FOUR_DIR "fourDirEnabled"
#define PROPERTY_TITLE_FADE_ENABLE "fadeEnabled"
#define PROPERTY_TITLE_FADE_IMAGE "fadeImage"

void CCControlButtonLoader::onHandlePropTypeCheck(CCNode * pNode, CCNode * pParent, const char * pPropertyName, bool pCheck, CCBReader * pCCBReader) {
	if (strcmp(pPropertyName, PROPERTY_ZOOMONTOUCHDOWN) == 0) {
		((CCControlButton *)pNode)->setZoomOnTouchDown(pCheck);
	} else if (strcmp(pPropertyName, PROPERTY_TITLE_SHADOW_ENABLE) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setTextShadowEnabled(pCheck);
			}
		}
	} else if (strcmp(pPropertyName, PROPERTY_TITLE_SHADOW_FOUR_DIR) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setTextShadowFourDirEnabled(pCheck);
			}
		}
	}
	else if (strcmp(pPropertyName, PROPERTY_TITLE_FADE_ENABLE) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setTextFadeEnabled(pCheck);
			}
		}
	}
	else if ( strcmp(pPropertyName, PROPERTY_BACKGROUNDSPRITE_ENABLEGRAY) == 0)
	{
		//((CCControlButton*)pNode)->enableGrayWhenSelected(pCheck);
    } else {
        CCControlLoader::onHandlePropTypeCheck(pNode, pParent, pPropertyName, pCheck, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypeString(CCNode * pNode, CCNode * pParent, const char * pPropertyName, const char * pString, CCBReader * pCCBReader) {
    if(strcmp(pPropertyName, PROPERTY_TITLE_NORMAL) == 0) {
        ((CCControlButton *)pNode)->setTitleForState(CCString::create(pString), CCControlStateNormal);
    } else if(strcmp(pPropertyName, PROPERTY_TITLE_HIGHLIGHTED) == 0) {
        ((CCControlButton *)pNode)->setTitleForState(CCString::create(pString), CCControlStateHighlighted);
    } else if(strcmp(pPropertyName, PROPERTY_TITLE_DISABLED) == 0) {
        ((CCControlButton *)pNode)->setTitleForState(CCString::create(pString), CCControlStateDisabled);
    } else {
        CCControlLoader::onHandlePropTypeString(pNode, pParent, pPropertyName, pString, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypeFontTTF(CCNode * pNode, CCNode * pParent, const char * pPropertyName, const char * pFontTTF, CCBReader * pCCBReader) {
    if(strcmp(pPropertyName, PROPERTY_TITLETTF_NORMAL) == 0) {
        ((CCControlButton *)pNode)->setTitleTTFForState(pFontTTF, CCControlStateNormal);
    } else if(strcmp(pPropertyName, PROPERTY_TITLETTF_HIGHLIGHTED) == 0) {
        ((CCControlButton *)pNode)->setTitleTTFForState(pFontTTF, CCControlStateHighlighted);
    } else if(strcmp(pPropertyName, PROPERTY_TITLETTF_DISABLED) == 0) {
        ((CCControlButton *)pNode)->setTitleTTFForState(pFontTTF, CCControlStateDisabled);
    } else {
        CCControlLoader::onHandlePropTypeFontTTF(pNode, pParent, pPropertyName, pFontTTF, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypeFloatScale(CCNode * pNode, CCNode * pParent, const char * pPropertyName, float pFloatScale, CCBReader * pCCBReader) {
    if(strcmp(pPropertyName, PROPERTY_TITLETTFSIZE_NORMAL) == 0) {
        ((CCControlButton *)pNode)->setTitleTTFSizeForState(pFloatScale, CCControlStateNormal);
    } else if(strcmp(pPropertyName, PROPERTY_TITLETTFSIZE_HIGHLIGHTED) == 0) {
        ((CCControlButton *)pNode)->setTitleTTFSizeForState(pFloatScale, CCControlStateHighlighted);
	}
	else if (strcmp(pPropertyName, PROPERTY_TITLETTFSIZE_DISABLED) == 0) {
		((CCControlButton *)pNode)->setTitleTTFSizeForState(pFloatScale, CCControlStateDisabled);
    } else {
        CCControlLoader::onHandlePropTypeFloatScale(pNode, pParent, pPropertyName, pFloatScale, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypeFloat(CCNode * pNode, CCNode * pParent, const char* pPropertyName, float pFloat, CCBReader * pCCBReader)
{
	if ( strcmp(pPropertyName, PROPERTY_BACKGROUNDSPRITE_GRAYRATE) == 0)
	{
		//((CCControlButton*)pNode)->setGrayRate(pFloat);
    } else {
        CCControlLoader::onHandlePropTypeFloatScale(pNode, pParent, pPropertyName, pFloat, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypePoint(CCNode * pNode, CCNode * pParent, const char * pPropertyName, CCPoint pPoint, CCBReader * pCCBReader) {
	if (strcmp(pPropertyName, PROPERTY_LABELANCHORPOINT) == 0) {
		((CCControlButton *)pNode)->setLabelAnchorPoint(pPoint);
	} else if (strcmp(pPropertyName, PROPERTY_TITLE_SHADOW_OFFSET) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setTexShadowOffset(pPoint.x, pPoint.y);
			}
		}
	} else if (strcmp(pPropertyName, PROPERTY_TITLE_SHADOW_OFFSET2) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setTexShadowOffset2(pPoint.x, pPoint.y);
			}
		}
	} else if (strcmp(pPropertyName, PROPERTY_TITLE_SHADOW_OFFSET3) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setTexShadowOffset3(pPoint.x, pPoint.y);
			}
		}
	} else if (strcmp(pPropertyName, PROPERTY_TITLE_SHADOW_OFFSET4) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setTexShadowOffset4(pPoint.x, pPoint.y);
			}
		}
    } else {
        CCControlLoader::onHandlePropTypePoint(pNode, pParent, pPropertyName, pPoint, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypeSize(CCNode * pNode, CCNode * pParent, const char * pPropertyName, CCSize pSize, CCBReader * pCCBReader) {
    if(strcmp(pPropertyName, PROPERTY_PREFEREDSIZE) == 0) {
        ((CCControlButton *)pNode)->setPreferredSize(pSize);
    } else {
        CCControlLoader::onHandlePropTypeSize(pNode, pParent, pPropertyName, pSize, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypeSpriteFrame(CCNode * pNode, CCNode * pParent, const char * pPropertyName, CCSpriteFrame * pCCSpriteFrame, CCBReader * pCCBReader) {
    if(strcmp(pPropertyName, PROPERTY_BACKGROUNDSPRITEFRAME_NORMAL) == 0) {
        if(pCCSpriteFrame != NULL) {
            ((CCControlButton *)pNode)->setBackgroundSpriteFrameForState(pCCSpriteFrame, CCControlStateNormal);
        }
    } else if(strcmp(pPropertyName, PROPERTY_BACKGROUNDSPRITEFRAME_HIGHLIGHTED) == 0) {
        if(pCCSpriteFrame != NULL) {
            ((CCControlButton *)pNode)->setBackgroundSpriteFrameForState(pCCSpriteFrame, CCControlStateHighlighted);
        }
    } else if(strcmp(pPropertyName, PROPERTY_BACKGROUNDSPRITEFRAME_DISABLED) == 0) {
        if(pCCSpriteFrame != NULL) {
            ((CCControlButton *)pNode)->setBackgroundSpriteFrameForState(pCCSpriteFrame, CCControlStateDisabled);
        }
    } else if(strcmp(pPropertyName, PROPERTY_TITLE_FADE_IMAGE) == 0) {
		CC_RETURN_IF(!pCCSpriteFrame);
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for (int i = 0; i < 3; ++i)
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ttf->setFadeTexture(pCCSpriteFrame->getTexture());
			}
		}
    } else {
        CCControlLoader::onHandlePropTypeSpriteFrame(pNode, pParent, pPropertyName, pCCSpriteFrame, pCCBReader);
    }
}

void CCControlButtonLoader::onHandlePropTypeColor3(CCNode * pNode, CCNode * pParent, const char * pPropertyName, ccColor3B pCCColor3B, CCBReader * pCCBReader) {
    if(strcmp(pPropertyName, PROPERTY_TITLECOLOR_NORMAL) == 0) {
        ((CCControlButton *)pNode)->setTitleColorForState(pCCColor3B, CCControlStateNormal);
    } else if(strcmp(pPropertyName, PROPERTY_TITLECOLOR_HIGHLIGHTED) == 0) {
        ((CCControlButton *)pNode)->setTitleColorForState(pCCColor3B, CCControlStateHighlighted);
    } else if(strcmp(pPropertyName, PROPERTY_TITLECOLOR_DISABLED) == 0) {
        ((CCControlButton *)pNode)->setTitleColorForState(pCCColor3B, CCControlStateDisabled);
    } else if(strcmp(pPropertyName, PROPERTY_TITLE_SHADOW_COLOR) == 0) {
		CCControlState states[3] = { CCControlStateNormal, CCControlStateHighlighted, CCControlStateDisabled };
		for ( int i = 0; i < 3; ++i )
		{
			CCNode* label = ((CCControlButton*)pNode)->getTitleLabelForState(states[i]);
			CCLabelTTF* ttf = dynamic_cast<CCLabelTTF*>(label);
			if (ttf)
			{
				ccColor4F c = ccc4FFromccc3B(pCCColor3B);
				ttf->setTextShadowColor(c.r, c.g, c.b, c.a);
			}
		}
    } else {
        CCControlLoader::onHandlePropTypeColor3(pNode, pParent, pPropertyName, pCCColor3B, pCCBReader);
    }
}

NS_CC_EXT_END;