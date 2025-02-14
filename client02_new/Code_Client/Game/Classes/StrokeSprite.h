#ifndef __StrokeSprite__StrokeSprite__
#define __StrokeSprite__StrokeSprite__

#include <string>
#include "cocos2d.h"

USING_NS_CC;

#define S_STROKE_COLOR  ccc3(255,100,0)
#define A_STROKE_COLOR  ccc3(255,137,245)
#define B_STROKE_COLOR  ccc3(33,184,255)
#define C_STROKE_COLOR  ccc3(199,255,112)
#define D_STROKE_COLOR  ccc3(208,208,208)

#define STROKE_SIZE 8
#define INNER_FRAME_SIZE 84
#define STROKE_TAG 1000

class ColorSprite : public CCSprite
{
protected:
    virtual char* getShaderFile();
    virtual void initUniforms();
    virtual void setUniforms();
    
public:
    ColorSprite(ccColor3B color, GLubyte opacity);
    ~ColorSprite();
    bool initWithTexture(CCTexture2D* texture, const CCRect& rect);
    void draw();
    void initProgram();
    inline void setColorAndOpacity(ccColor3B color,int opacity){m_color = color;m_opacity = opacity;}
private:
    
    //GL Tags
    GLuint      strokeColor;
    ccColor3B   m_color;
    GLubyte     m_opacity;
};

class StrokeChartlet : public CCSprite
{
protected:
    virtual char* getShaderFile();
    virtual void initUniforms();
    virtual void setUniforms();
    
public:
    StrokeChartlet(ccColor3B color);
    ~StrokeChartlet();
    bool initWithTexture(CCTexture2D* texture, const CCRect& rect);
    void draw();
    void initProgram();
    inline void setColorAndOpacity(ccColor3B color,int opacity){m_color = color;m_opacity = opacity;}
private:
    
    //GL Tags
    GLuint      strokeColor;
    ccColor3B   m_color;
    GLubyte     m_opacity;
};

namespace StrokeSprite
{
    /*
     *@desc:¡Î£∂œr??≥∫
     *@param:sprite ÓÓ£·∑ÂÀ¡?ÀC¶c’⁄??…ª,quality ?Àµ§t?…÷”G¡Ì?›µÌi£∑?ÀC?ë˚?ÛO”G¡Ì?     */
    CCSprite* createStroke(CCSprite* sprite, int quality);
    /*
     *@desc:ÀC?ëcÓÿ??ÀC?     *@param:sprite ÓÓ£·∑ÂÀ¡?ÀC¶c’⁄??…ª,qulity ?Àµ§t Æ˛???Àµ§t??≥∫›ﬁﬁN?Æ˛??
     */
    CCSprite* createInnerStroke(CCSprite* sprite,int quality);
}

#endif /* defined(__StrokeSprite__StrokeSprite__) */
