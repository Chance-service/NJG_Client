
#pragma once

#include <string>
#include "cocos2d.h"
//#include "shaders/CCGLProgram.h"
USING_NS_CC;

class GraySprite : public CCSprite
{
protected:
    virtual char* getShaderFile();
    virtual void initUniforms();
    virtual void setUniforms();
    
public:
	GraySprite();
    ~GraySprite();
    bool initWithTexture(CCTexture2D* texture, const CCRect& rect);
    void draw();
    void initProgram();   
	static void AddColorGray(CCSprite * spr);
	static void RemoveColorGray(CCSprite * spr);

	static void AddColorGrayToNode(CCNode * node);
	static void RemoveColorGrayToNode(CCNode * node);

private:
    GLuint      grayColor;
};


namespace GraySpriteMgr
{
	GraySprite* createGrayMask(CCNode* parent,CCSize recSize);
}