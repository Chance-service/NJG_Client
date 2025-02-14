
#pragma once

#include <string>
#include "cocos2d.h"

USING_NS_CC;

#define  BLUR_TAG  100021

class BlurSprite : public CCSprite
{
protected:
    virtual char* getShaderFile();
	virtual char* getVertShaderFile();
    virtual void initUniforms();
    virtual void setUniforms();
    
public:
    ~BlurSprite();
    bool initWithTexture(CCTexture2D* texture, const CCRect& rect);
    void draw();
    void initProgram();    
	void setDir(CCPoint dir);
private:
	GLuint		radius;				//¼Ò½k¥b®|
	GLuint      dir;				//¼Ò½k¤è¦V

	CCPoint		mDir;
};


namespace BlurSpriteMgr
{
	CCSprite* createBlurSprite(CCNode* parent,CCSize recSize);
}