/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada
Copyright (c) 2011      Zynga Inc.

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

Use any of these editors to generate BMFonts:
http://glyphdesigner.71squared.com/ (Commercial, Mac OS X)
http://www.n4te.com/hiero/hiero.jnlp (Free, Java)
http://slick.cokeandcode.com/demos/hiero.jnlp (Free, Java)
http://www.angelcode.com/products/bmfont/ (Free, Windows only)

****************************************************************************/
#include "CCLabelBMFont.h"
#include "cocoa/CCString.h"
#include "platform/platform.h"
#include "cocoa/CCDictionary.h"
#include "CCConfiguration.h"
#include "draw_nodes/CCDrawingPrimitives.h"
#include "sprite_nodes/CCSprite.h"
#include "support/CCPointExtension.h"
#include "platform/CCFileUtils.h"
#include "CCDirector.h"
#include "textures/CCTextureCache.h"
#include "support/ccUTF8.h"
#include "support/ccArabic.h"

//因项目中配置表以空格分隔列,而海外版本语言词组中常包含空格,故将空格配置为"~",定义此宏以标明要还原为空格
//#define REPLACE_SPECIAL_CHAR_FOR_MULTILAN

#include "shaders/shaderhelper/CCTextShadowSH.h"
#include "shaders/shaderhelper/CCTextFadeSH.h"
#include "shaders/shaderhelper/CCTextBorderSH.h"
#include "shaders/CCGLProgram.h"
#include "shaders/CCShaderCache.h"

using namespace std;

NS_CC_BEGIN

#define SHADER_BMFONT_TEXT_SHADOW	kCCShader_Text_Shadow
#define SHADER_BMFONT_TEXT_FADE	kCCShader_Text_Bmfont_fade
#define SHADER_BMFONT_TEXT_BORDER	kCCShader_Text_Border



// The return value needs to be deleted by CC_SAFE_DELETE_ARRAY.
static unsigned short* copyUTF16StringN(unsigned short* str)
{
    int length = str ? cc_wcslen(str) : 0;
    unsigned short* ret = new unsigned short[length+1];
    for (int i = 0; i < length; ++i) {
        ret[i] = str[i];
    }
    ret[length] = 0;
    return ret;
}

//
//FNTConfig Cache - free functions
//
static CCDictionary* s_pConfigurations = NULL;
std::map<std::string, std::string> s_pTexturePic;

CCBMFontConfiguration* FNTConfigLoadFile( const char *fntFile)
{
    CCBMFontConfiguration* pRet = NULL;

    if( s_pConfigurations == NULL )
    {
        s_pConfigurations = new CCDictionary();
    }

    pRet = (CCBMFontConfiguration*)s_pConfigurations->objectForKey(fntFile);
    if( pRet == NULL )
    {
        pRet = CCBMFontConfiguration::create(fntFile);
        if (pRet)
        {
            s_pConfigurations->setObject(pRet, fntFile);
        }        
    }

    return pRet;
}

void FNTConfigRemoveCache( void )
{
    if (s_pConfigurations)
    {
		CCDictElement * pElement = NULL;
		CCDICT_FOREACH(s_pConfigurations, pElement)
		{
			if (pElement != NULL)
			{
				const char * key = pElement->getStrKey();
				std::map<std::string, std::string>::const_iterator it = s_pTexturePic.find(key);
				std::string TextureName = "";
				if (it != s_pTexturePic.end()){
					TextureName = it->second;
				}
				if (TextureName != "")
				{
					CCTextureCache::sharedTextureCache()->removeTextureForKey(TextureName.c_str());
				}
			}
		}
        s_pConfigurations->removeAllObjects();
        CC_SAFE_RELEASE_NULL(s_pConfigurations);
    }
}

//
//BitmapFontConfiguration
//

CCBMFontConfiguration * CCBMFontConfiguration::create(const char *FNTfile)
{
    CCBMFontConfiguration * pRet = new CCBMFontConfiguration();
    if (pRet->initWithFNTfile(FNTfile))
    {
        pRet->autorelease();
        return pRet;
    }
    CC_SAFE_DELETE(pRet);
    return NULL;
}

bool CCBMFontConfiguration::initWithFNTfile(const char *FNTfile)
{
    m_pKerningDictionary = NULL;
    m_pFontDefDictionary = NULL;
    
    m_pCharacterSet = this->parseConfigFile(FNTfile);
    
    if (! m_pCharacterSet)
    {
        return false;
    }

    return true;
}

std::set<unsigned int>* CCBMFontConfiguration::getCharacterSet() const
{
    return m_pCharacterSet;
}

CCBMFontConfiguration::CCBMFontConfiguration()
: m_pFontDefDictionary(NULL)
, m_nCommonHeight(0)
, m_pKerningDictionary(NULL)
, m_pCharacterSet(NULL)
{

}

CCBMFontConfiguration::~CCBMFontConfiguration()
{
    CCLOGINFO( "cocos2d: deallocing CCBMFontConfiguration" );
    this->purgeFontDefDictionary();
    this->purgeKerningDictionary();
    m_sAtlasName.clear();
    CC_SAFE_DELETE(m_pCharacterSet);
}

const char* CCBMFontConfiguration::description(void)
{
    return CCString::createWithFormat(
        "<CCBMFontConfiguration = " CC_FORMAT_PRINTF_SIZE_T " | Glphys:%d Kernings:%d | Image = %s>",
        (size_t)this,
        HASH_COUNT(m_pFontDefDictionary),
        HASH_COUNT(m_pKerningDictionary),
        m_sAtlasName.c_str()
    )->getCString();
}

void CCBMFontConfiguration::purgeKerningDictionary()
{
    tCCKerningHashElement *current;
    while(m_pKerningDictionary) 
    {
        current = m_pKerningDictionary; 
        HASH_DEL(m_pKerningDictionary,current);
        free(current);
    }
}

void CCBMFontConfiguration::purgeFontDefDictionary()
{    
    tCCFontDefHashElement *current, *tmp;

    HASH_ITER(hh, m_pFontDefDictionary, current, tmp) {
        HASH_DEL(m_pFontDefDictionary, current);
        free(current);
    }
}

std::set<unsigned int>* CCBMFontConfiguration::parseConfigFile(const char *controlFile)
{    
    std::string fullpath = CCFileUtils::sharedFileUtils()->fullPathForFilename(controlFile);
    CCString *contents = CCString::createWithContentsOfFile(fullpath.c_str());
	if (contents == NULL) contents = CCString::createWithContentsOfFile("Lang/Font-HT-TabPage.fnt");
    CCAssert(contents, "CCBMFontConfiguration::parseConfigFile | Open file error.");
    
    set<unsigned int> *validCharsString = new set<unsigned int>();

    if (!contents)
    {
        CCLOG("cocos2d: Error parsing FNTfile %s", controlFile);
        return NULL;
    }

    // parse spacing / padding
    std::string line;
    std::string strLeft = contents->getCString();
    while (strLeft.length() > 0)
    {
        int pos = strLeft.find('\n');

        if (pos != (int)std::string::npos)
        {
            // the data is more than a line.get one line
            line = strLeft.substr(0, pos);
            strLeft = strLeft.substr(pos + 1);
        }
        else
        {
            // get the left data
            line = strLeft;
            strLeft.erase();
        }

        if(line.substr(0,strlen("info face")) == "info face") 
        {
            // XXX: info parsing is incomplete
            // Not needed for the Hiero editors, but needed for the AngelCode editor
            //            [self parseInfoArguments:line];
            this->parseInfoArguments(line);
        }
        // Check to see if the start of the line is something we are interested in
        else if(line.substr(0,strlen("common lineHeight")) == "common lineHeight")
        {
            this->parseCommonArguments(line);
        }
        else if(line.substr(0,strlen("page id")) == "page id")
        {
            this->parseImageFileName(line, controlFile);
        }
        else if(line.substr(0,strlen("chars c")) == "chars c")
        {
            // Ignore this line
        }
        else if(line.substr(0,strlen("char")) == "char")
        {
            // Parse the current line and create a new CharDef
            tCCFontDefHashElement* element = (tCCFontDefHashElement*)malloc( sizeof(*element) );
            this->parseCharacterDefinition(line, &element->fontDef);

            element->key = element->fontDef.charID;
            HASH_ADD_INT(m_pFontDefDictionary, key, element);
            
            validCharsString->insert(element->fontDef.charID);
        }
//        else if(line.substr(0,strlen("kernings count")) == "kernings count")
//        {
//            this->parseKerningCapacity(line);
//        }
        else if(line.substr(0,strlen("kerning first")) == "kerning first")
        {
            this->parseKerningEntry(line);
        }
    }
    
    return validCharsString;
}

void CCBMFontConfiguration::parseImageFileName(std::string line, const char *fntFile)
{
    //////////////////////////////////////////////////////////////////////////
    // line to parse:
    // page id=0 file="bitmapFontTest.png"
    //////////////////////////////////////////////////////////////////////////

    // page ID. Sanity check
    int index = line.find('=')+1;
    int index2 = line.find(' ', index);
    std::string value = line.substr(index, index2-index);
    CCAssert(atoi(value.c_str()) == 0, "LabelBMFont file could not be found");
    // file 
    index = line.find('"')+1;
    index2 = line.find('"', index);
    value = line.substr(index, index2-index);

    m_sAtlasName = CCFileUtils::sharedFileUtils()->fullPathFromRelativeFile(value.c_str(), fntFile);
	s_pTexturePic.insert(std::make_pair(fntFile, m_sAtlasName));

}

void CCBMFontConfiguration::parseInfoArguments(std::string line)
{
    //////////////////////////////////////////////////////////////////////////
    // possible lines to parse:
    // info face="Script" size=32 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=1,4,3,2 spacing=0,0 outline=0
    // info face="Cracked" size=36 bold=0 italic=0 charset="" unicode=0 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=1,1
    //////////////////////////////////////////////////////////////////////////

    // padding
    int index = line.find("padding=");
    int index2 = line.find(' ', index);
    std::string value = line.substr(index, index2-index);
    sscanf(value.c_str(), "padding=%d,%d,%d,%d", &m_tPadding.top, &m_tPadding.right, &m_tPadding.bottom, &m_tPadding.left);
    CCLOG("cocos2d: padding: %d,%d,%d,%d", m_tPadding.left, m_tPadding.top, m_tPadding.right, m_tPadding.bottom);
}

void CCBMFontConfiguration::parseCommonArguments(std::string line)
{
    //////////////////////////////////////////////////////////////////////////
    // line to parse:
    // common lineHeight=104 base=26 scaleW=1024 scaleH=512 pages=1 packed=0
    //////////////////////////////////////////////////////////////////////////

    // Height
    int index = line.find("lineHeight=");
    int index2 = line.find(' ', index);
    std::string value = line.substr(index, index2-index);
    sscanf(value.c_str(), "lineHeight=%d", &m_nCommonHeight);
    // scaleW. sanity check
    index = line.find("scaleW=") + strlen("scaleW=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    CCAssert(atoi(value.c_str()) <= CCConfiguration::sharedConfiguration()->getMaxTextureSize(), "CCLabelBMFont: page can't be larger than supported");
    // scaleH. sanity check
    index = line.find("scaleH=") + strlen("scaleH=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    CCAssert(atoi(value.c_str()) <= CCConfiguration::sharedConfiguration()->getMaxTextureSize(), "CCLabelBMFont: page can't be larger than supported");
    // pages. sanity check
    index = line.find("pages=") + strlen("pages=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    CCAssert(atoi(value.c_str()) == 1, "CCBitfontAtlas: only supports 1 page");

    // packed (ignore) What does this mean ??
}

void CCBMFontConfiguration::parseCharacterDefinition(std::string line, ccBMFontDef *characterDefinition)
{    
    //////////////////////////////////////////////////////////////////////////
    // line to parse:
    // char id=32   x=0     y=0     width=0     height=0     xoffset=0     yoffset=44    xadvance=14     page=0  chnl=0 
    //////////////////////////////////////////////////////////////////////////

    // Character ID
    int index = line.find("id=");
    int index2 = line.find(' ', index);
    std::string value = line.substr(index, index2-index);
    sscanf(value.c_str(), "id=%u", &characterDefinition->charID);

    // Character x
    index = line.find("x=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "x=%f", &characterDefinition->rect.origin.x);
    // Character y
    index = line.find("y=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "y=%f", &characterDefinition->rect.origin.y);
    // Character width
    index = line.find("width=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "width=%f", &characterDefinition->rect.size.width);
    // Character height
    index = line.find("height=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "height=%f", &characterDefinition->rect.size.height);
    // Character xoffset
    index = line.find("xoffset=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "xoffset=%hd", &characterDefinition->xOffset);
    // Character yoffset
    index = line.find("yoffset=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "yoffset=%hd", &characterDefinition->yOffset);
    // Character xadvance
    index = line.find("xadvance=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "xadvance=%hd", &characterDefinition->xAdvance);
}

void CCBMFontConfiguration::parseKerningEntry(std::string line)
{        
    //////////////////////////////////////////////////////////////////////////
    // line to parse:
    // kerning first=121  second=44  amount=-7
    //////////////////////////////////////////////////////////////////////////

    // first
    int first;
    int index = line.find("first=");
    int index2 = line.find(' ', index);
    std::string value = line.substr(index, index2-index);
    sscanf(value.c_str(), "first=%d", &first);

    // second
    int second;
    index = line.find("second=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "second=%d", &second);

    // amount
    int amount;
    index = line.find("amount=");
    index2 = line.find(' ', index);
    value = line.substr(index, index2-index);
    sscanf(value.c_str(), "amount=%d", &amount);

    tCCKerningHashElement *element = (tCCKerningHashElement *)calloc( sizeof( *element ), 1 );
    element->amount = amount;
    element->key = (first<<16) | (second&0xffff);
    HASH_ADD_INT(m_pKerningDictionary,key, element);
}
//
//CCLabelBMFont
//

//LabelBMFont - Purge Cache
void CCLabelBMFont::purgeCachedData()
{
    FNTConfigRemoveCache();
}

CCLabelBMFont * CCLabelBMFont::create()
{
    CCLabelBMFont * pRet = new CCLabelBMFont();
    if (pRet && pRet->init())
    {
        pRet->autorelease();
        return pRet;
    }
    CC_SAFE_DELETE(pRet);
    return NULL;
}

CCLabelBMFont * CCLabelBMFont::create(const char *str, const char *fntFile, float width, CCTextAlignment alignment)
{
    return CCLabelBMFont::create(str, fntFile, width, alignment, CCPointZero);
}

CCLabelBMFont * CCLabelBMFont::create(const char *str, const char *fntFile, float width)
{
    return CCLabelBMFont::create(str, fntFile, width, kCCTextAlignmentLeft, CCPointZero);
}

CCLabelBMFont * CCLabelBMFont::create(const char *str, const char *fntFile)
{
    return CCLabelBMFont::create(str, fntFile, kCCLabelAutomaticWidth, kCCTextAlignmentLeft, CCPointZero);
}

//LabelBMFont - Creation & Init
CCLabelBMFont *CCLabelBMFont::create(const char *str, const char *fntFile, float width/* = kCCLabelAutomaticWidth*/, CCTextAlignment alignment/* = kCCTextAlignmentLeft*/, CCPoint imageOffset/* = CCPointZero*/)
{
    CCLabelBMFont *pRet = new CCLabelBMFont();
    if(pRet && pRet->initWithString(str, fntFile, width, alignment, imageOffset))
    {
        pRet->autorelease();
        return pRet;
    }
    CC_SAFE_DELETE(pRet);
    return NULL;
}

bool CCLabelBMFont::init()
{
    return initWithString(NULL, NULL, kCCLabelAutomaticWidth, kCCTextAlignmentLeft, CCPointZero);
}

bool CCLabelBMFont::initWithString(const char *theString, const char *fntFile, float width/* = kCCLabelAutomaticWidth*/, CCTextAlignment alignment/* = kCCTextAlignmentLeft*/, CCPoint imageOffset/* = CCPointZero*/)
{
    CCAssert(!m_pConfiguration, "re-init is no longer supported");
    CCAssert( (theString && fntFile) || (theString==NULL && fntFile==NULL), "Invalid params for CCLabelBMFont");
    
    CCTexture2D *texture = NULL;
    
    if (fntFile)
    {
        CCBMFontConfiguration *newConf = FNTConfigLoadFile(fntFile);
        if (!newConf)
        {
            CCLOG("cocos2d: WARNING. CCLabelBMFont: Impossible to create font. Please check file: '%s'", fntFile);
            release();
            return false;
        }
        
        newConf->retain();
        CC_SAFE_RELEASE(m_pConfiguration);
        m_pConfiguration = newConf;
        
        m_sFntFile = fntFile;
        
        texture = CCTextureCache::sharedTextureCache()->addImage(m_pConfiguration->getAtlasName());
    }
    else 
    {
        texture = new CCTexture2D();
        texture->autorelease();
    }

    if (theString == NULL)
    {
        theString = "";
    }

    if (CCSpriteBatchNode::initWithTexture(texture, strlen(theString)))
    {
        m_fWidth = width;
        m_pAlignment = alignment;
        
        m_cDisplayedOpacity = m_cRealOpacity = 255;
		m_tDisplayedColor = m_tRealColor = ccWHITE;
        m_bCascadeOpacityEnabled = true;
        m_bCascadeColorEnabled = true;
        
        m_obContentSize = CCSizeZero;
        
        m_bIsOpacityModifyRGB = m_pobTextureAtlas->getTexture()->hasPremultipliedAlpha();
        m_obAnchorPoint = ccp(0.5f, 0.5f);
        
        m_tImageOffset = imageOffset;
        
        m_pReusedChar = new CCSprite();
        m_pReusedChar->initWithTexture(m_pobTextureAtlas->getTexture(), CCRectMake(0, 0, 0, 0), false);
        m_pReusedChar->setBatchNode(this);
        
        this->setString(theString, true);
        
        return true;
    }
    return false;
}

CCLabelBMFont::CCLabelBMFont()
: m_sString(NULL)
, m_sInitialString(NULL)
, m_pAlignment(kCCTextAlignmentCenter)
, m_fWidth(-1.0f)
, m_pConfiguration(NULL)
, m_bLineBreakWithoutSpaces(false)
, m_tImageOffset(CCPointZero)
, m_pReusedChar(NULL)
, m_cDisplayedOpacity(255)
, m_cRealOpacity(255)
, m_tDisplayedColor(ccWHITE)
, m_tRealColor(ccWHITE)
, m_bCascadeColorEnabled(true)
, m_bCascadeOpacityEnabled(true)
, m_bIsOpacityModifyRGB(false)
, m_fadeTexture(NULL)
,m_iTexCoordCapa(0)
,m_textShadowFourDirEnabled(false)
,m_fShadowOffsetX(1.0)
,m_fShadowOffsetY(1.0)
,m_fShadowOffsetX2(1.0)
,m_fShadowOffsetY2(1.0)
,m_fShadowOffsetX3(1.0)
,m_fShadowOffsetY3(1.0)
,m_fShadowOffsetX4(1.0)
,m_fShadowOffsetY4(1.0)
{
	m_textShadowEnabled=false;
	m_textFadeEnabled=false;
	m_textBorderEnabled=false;
	m_textFadeImageURL="";
	m_shadowColor = ccc4f(1.0,1.0,1.0,1.0);
	m_borderColor = ccc4f(1.0,1.0,1.0,1.0);
	//m_iTexCoordCapa = DEFAULT_STRING_LEN;
	//m_pTex1 = (ccTex2F *)malloc( DEFAULT_STRING_LEN * sizeof(ccTex2F) * 4 );
	//m_pTex2 = (ccTex2F *)malloc( DEFAULT_STRING_LEN * sizeof(ccTex2F) * 4);

}

CCLabelBMFont::~CCLabelBMFont()
{
	 //CC_SAFE_FREE(m_pTex1);
	 //CC_SAFE_FREE(m_pTex2);
    CC_SAFE_RELEASE(m_pReusedChar);
    CC_SAFE_DELETE_ARRAY(m_sString);
    CC_SAFE_DELETE_ARRAY(m_sInitialString);
    CC_SAFE_RELEASE(m_pConfiguration);
	CC_SAFE_RELEASE(m_fadeTexture);
}

// LabelBMFont - Atlas generation
int CCLabelBMFont::kerningAmountForFirst(unsigned short first, unsigned short second)
{
    int ret = 0;
    unsigned int key = (first<<16) | (second & 0xffff);

    if( m_pConfiguration->m_pKerningDictionary ) {
        tCCKerningHashElement *element = NULL;
        HASH_FIND_INT(m_pConfiguration->m_pKerningDictionary, &key, element);        
        if(element)
            ret = element->amount;
    }
    return ret;
}

void CCLabelBMFont::createFontChars()
{
    int nextFontPositionX = 0;
    int nextFontPositionY = 0;
    unsigned short prev = -1;
    int kerningAmount = 0;

    CCSize tmpSize = CCSizeZero;

    int longestLine = 0;
    unsigned int totalHeight = 0;

    unsigned int quantityOfLines = 1;
    unsigned int stringLen = m_sString ? cc_wcslen(m_sString) : 0;
    if (stringLen == 0)
    {
        this->setContentSize(CC_SIZE_PIXELS_TO_POINTS(tmpSize));
        return;
    }

    set<unsigned int> *charSet = m_pConfiguration->getCharacterSet();

	//首先判断文字里是不是有阿语字符，有的话采用倒序渲染
	bool isRevRender = false;
    for (unsigned int i = 0; i < stringLen - 1; ++i)
    {
        unsigned short c = m_sString[i];
        if (c == '\n')
        {
            quantityOfLines++;
        }
		if (check_char_is_arabic(c)) isRevRender = true;
    }

    totalHeight = m_pConfiguration->m_nCommonHeight * quantityOfLines;
    nextFontPositionY = 0-(m_pConfiguration->m_nCommonHeight - m_pConfiguration->m_nCommonHeight * quantityOfLines);
    
    CCRect rect;
    ccBMFontDef fontDef;


	//这里string length多长就申请多少内存
	if(stringLen>m_pobTextureAtlas->getCapacity()){
		m_pobTextureAtlas->resizeCapacity(stringLen);
	}
	m_iTexCoordCapa = stringLen;

	/*if (stringLen>m_iTexCoordCapa)
	{
	m_pTex1 = (ccTex2F *)realloc( m_pTex1,stringLen*2 * sizeof(ccTex2F) * 4);
	if (!m_pTex1)
	{
	free(m_pTex1);
	CCLOG("memory not enough");
	}
	m_pTex2 = (ccTex2F *)realloc( m_pTex2,stringLen*2 * sizeof(ccTex2F) * 4);
	if (!m_pTex2)
	{
	free(m_pTex2);
	CCLOG("memory not enough");
	}
	} 


	memset( m_pTex1, 0, stringLen * sizeof(ccTex2F) *4 );
	memset( m_pTex2, 0, stringLen * sizeof(ccTex2F) *4 );*/

	vector<unsigned short> tempWord;
	unsigned int tempIndex = 0;
	for (unsigned int i = 0; i < stringLen; i++)
	{
		unsigned short c = m_sString[i];
		if (!get_is_text_render_left_2_right())
		{
			if (isRevRender)
			{
				c = m_sString[stringLen - 1 - i];
				//在阿拉伯语中的英文和数字，需要取到这个单词，然后不再倒序。。
				//如果本字符是单词的首个字符，进行判断
				bool isLastCharSpace = false;
				if (stringLen - 1 - i + 1 >= 0)
				{
					isLastCharSpace = isspace_unicode(m_sString[stringLen - 1 - i + 1]);

					if (m_sString[stringLen - 1 - i + 1] == '\n')
					{
						isLastCharSpace = true;
					}
				}

				if (!isspace_unicode(c) && !check_char_is_arabic(c) && (i == 0 || isLastCharSpace))
				{
					tempWord.clear();
					tempIndex = 0;
					unsigned int tempI = i;
					unsigned short tempC = c;
					while (tempI < stringLen)
					{
						//如果碰到了阿语或者空格的时候，就要截断了
						if (check_char_is_arabic(tempC) || isspace_unicode(tempC))
						{
							break;
						}
						tempWord.push_back(tempC);
						tempI++;
						if (tempI == stringLen) {
                            break;
                        }
						tempC = m_sString[stringLen - 1 - tempI];						
					}
				}

				size_t tempSize = tempWord.size();
				if (tempSize > 0)
				{
					if (tempIndex < tempSize)
					{
						c = tempWord[tempSize - 1 - tempIndex];
						tempIndex++;
					}
					else
					{
						tempIndex = 0;
						tempWord.clear();
					}
				}
			}
		}
		
		if (c == '\n')
		{
			nextFontPositionX = 0;
			nextFontPositionY -= m_pConfiguration->m_nCommonHeight;
			continue;
		}

		if (charSet->find(c) == charSet->end())
		{
			//CCLOGWARN("cocos2d::CCLabelBMFont: Attempted to use character not defined in this bitmap: %d", c);
			continue;
		}

		kerningAmount = this->kerningAmountForFirst(prev, c);

		tCCFontDefHashElement *element = NULL;

		// unichar is a short, and an int is needed on HASH_FIND_INT
		unsigned int key = c;
		HASH_FIND_INT(m_pConfiguration->m_pFontDefDictionary, &key, element);
		if (!element)
		{
			CCLOGWARN("cocos2d::CCLabelBMFont: characer not found %d", c);
			continue;
		}

		fontDef = element->fontDef;

		rect = fontDef.rect;
		rect = CC_RECT_PIXELS_TO_POINTS(rect);

		rect.origin.x += m_tImageOffset.x;
		rect.origin.y += m_tImageOffset.y;

		CCSprite *fontChar;

		bool hasSprite = true;
		fontChar = (CCSprite*)(this->getChildByTag(i));
		if (fontChar)
		{
			// Reusing previous Sprite
			fontChar->setVisible(true);
		}
		else
		{
			// New Sprite ? Set correct color, opacity, etc...
			if (0)
			{
				/* WIP: Doesn't support many features yet.
				But this code is super fast. It doesn't create any sprite.
				Ideal for big labels.
				*/
				fontChar = m_pReusedChar;
				fontChar->setBatchNode(NULL);
				hasSprite = false;
			}
			else
			{
				fontChar = new CCSprite();
				fontChar->initWithTexture(m_pobTextureAtlas->getTexture(), rect);
				addChild(fontChar, i, i);
				fontChar->release();
			}

			// Apply label properties
			fontChar->setOpacityModifyRGB(m_bIsOpacityModifyRGB);

			// Color MUST be set before opacity, since opacity might change color if OpacityModifyRGB is on
			fontChar->updateDisplayedColor(m_tDisplayedColor);
			fontChar->updateDisplayedOpacity(m_cDisplayedOpacity);
		}

		// updating previous sprite
		fontChar->setTextureRect(rect, false, rect.size);

		//genAndInsertTextureCoords(rect,i);

		// See issue 1343. cast( signed short + unsigned integer ) == unsigned integer (sign is lost!)
		int yOffset = m_pConfiguration->m_nCommonHeight - fontDef.yOffset;
		/*CCPoint fontPos = ccp((float)nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width*0.5f + kerningAmount,
			(float)nextFontPositionY + yOffset - rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR());*/

		CCPoint fontPos = ccp((float)nextFontPositionX + fontDef.xOffset + fontDef.rect.size.width*0.5f + kerningAmount,
			(float)nextFontPositionY + yOffset - rect.size.height*0.5f * CC_CONTENT_SCALE_FACTOR());

		fontChar->setPosition(CC_POINT_PIXELS_TO_POINTS(fontPos));

		// update kerning
		nextFontPositionX += fontDef.xAdvance + kerningAmount;
		prev = c;

		if (longestLine < nextFontPositionX)
		{
			longestLine = nextFontPositionX;
		}

		if (!hasSprite)
		{
			updateQuadFromSprite(fontChar, i);
		}
	}

	// If the last character processed has an xAdvance which is less that the width of the characters image, then we need
	// to adjust the width of the string to take this into account, or the character will overlap the end of the bounding
	// box
	if (fontDef.xAdvance < fontDef.rect.size.width)
	{
		tmpSize.width = longestLine + fontDef.rect.size.width - fontDef.xAdvance;
	}
	else
	{
		tmpSize.width = longestLine;
	}
	tmpSize.height = totalHeight;

	this->setContentSize(CC_SIZE_PIXELS_TO_POINTS(tmpSize));
}

//LabelBMFont - CCLabelProtocol protocol
void CCLabelBMFont::setString(const char *newString)
{
    this->setString(newString, true);
}




void CCLabelBMFont::setString(const char *newString, bool needUpdateLabel)
{
	//setAlignment(kCCTextAlignmentRight);
	/*
	 * begin special dealing
	 * 因项目中配置表以空格分隔列,而海外版本语言词组中常包含空格,故将空格配置为"~",此处还原
	 */
#ifdef REPLACE_SPECIAL_CHAR_FOR_MULTILAN
	std::string realString = newString;

	int pos = realString.find_first_of("~");
	while (pos != std::string::npos)
	{
		realString.replace(pos, 1, " ");
		pos = realString.find_first_of("~");
	}
	newString = realString.data();
#endif
	//end special dealing

	if (get_is_text_render_left_2_right())
	{
		if (newString == NULL) {
			newString = "";
		}
		if (needUpdateLabel) {
			m_sInitialStringUTF8 = newString;
		}
		unsigned short* utf16String = cc_utf8_to_utf16(newString);
		setString(utf16String, needUpdateLabel);

		CC_SAFE_DELETE_ARRAY(utf16String);
		return;
	}
	else
	{
		string strTemp = newString;	
		unsigned short* utf16str = cc_utf8_to_utf16(strTemp.data());
		size_t utf16size = cc_wcslen(utf16str);

		if (utf16size == 0)
		{
			CC_SAFE_DELETE_ARRAY(utf16str);
		}
		//try to change arabic chars
		vector<unsigned short> temp_string;
		temp_string.reserve(utf16size);

		for (int i = 0; i < utf16size; i++)
		{
			unsigned short selfC = 0x0, rightC = 0x0, leftC = 0x0, leftC2 = 0x0;
			selfC = utf16str[i];

			rightC = i + 1 >= utf16size ? 0x0 : utf16str[i + 1];
			leftC = i - 1 < 0 ? 0x0 : utf16str[i - 1];
			leftC2 = i - 2 < 0 ? 0x0 : utf16str[i - 2];

			//先进行普通变形
			unsigned short normal_change = get_arabic_char_normal_change(selfC, rightC, leftC);

			//采用新的规则，不需要替换符号了
			//normal_change = get_arabic_sign_replace_change(normal_change);

			//判断是否需要特殊变形
			unsigned short spec_change = get_arabic_char_spec_change(selfC, rightC, leftC);
			if (spec_change != 0x0)
			{
				temp_string.push_back(spec_change);
				//跳过下一个字符，因为已经合并了
				i++;
				continue;
			}
			temp_string.push_back(normal_change);
		}


		CC_SAFE_DELETE_ARRAY(utf16str);


		std::map<unsigned short, int> temp_char_list;
		int temp_char_index = 0;
		//遍历一次，判断如果有需要变形的标点，进行变形
		for (int i = 0; i < temp_string.size(); ++i)
		{
			unsigned short tempIChar = temp_string[i];
			if (i == 0 || isspace_unicode(tempIChar))
			{
				temp_char_list.clear();
				if (isspace_unicode(tempIChar))
				{
					temp_char_index = i + 1;
				}
				else
				{
					temp_char_index = i;
				}
				if (temp_char_index >= temp_string.size())
				{
					continue;
				}
				bool tempIndexCharIsArabic = false;
				unsigned short tempIndexChar = temp_string[temp_char_index];
				std::map<unsigned short, unsigned short> tempSignPairs;
				while (temp_char_index < temp_string.size())
				{
					tempIndexChar = temp_string[temp_char_index];

					if (!tempIndexCharIsArabic && check_char_is_arabic(tempIndexChar))
					{
						tempIndexCharIsArabic = true;
					}

					if (isspace_unicode(tempIndexChar))
					{
						break;
					}
					temp_char_list.insert(std::make_pair(tempIndexChar, temp_char_index));

					unsigned short sign_pair_char = get_arabic_sign_replace_change(tempIndexChar);
					if (sign_pair_char != tempIndexChar)
					{
						tempSignPairs.insert(std::make_pair(tempIndexChar, tempIndexChar));
						if (tempSignPairs.find(sign_pair_char) != tempSignPairs.end())
						{
							tempSignPairs[sign_pair_char] = tempIndexChar;

							if (tempSignPairs.find(tempIndexChar) != tempSignPairs.end())
							{
								tempSignPairs[tempIndexChar] = sign_pair_char;
							}
						}
					}

					temp_char_index++;
				}

				for (std::map<unsigned short, int>::iterator itr = temp_char_list.begin(); itr != temp_char_list.end(); itr++)
				{
					unsigned short word_temp_char = itr->first;
					if (tempSignPairs.find(word_temp_char) != tempSignPairs.end())
					{
						if (tempSignPairs[word_temp_char] == word_temp_char)
						{
							temp_string[itr->second] = get_arabic_sign_replace_change(word_temp_char);
						}
						else
						{
							if (tempIndexCharIsArabic)
							{
								temp_string[itr->second] = get_arabic_sign_replace_change(word_temp_char);
							}
						}
					}
				}
				tempSignPairs.clear();
				temp_char_list.clear();
				temp_char_index = 0;
			}
		}

		int new_str_size = temp_string.size() + 1;
		unsigned short* str_new = new unsigned short[new_str_size];

		////倒序
		//for (int i = 0; i < new_str_size - 1; ++i)
		//{
		//	str_new[new_str_size - 2 - i] = temp_string[i];
		//}

		//这里不做倒序，在渲染的时候倒序
		for (int i = 0; i < new_str_size - 1; ++i)
		{
			str_new[i] = temp_string[i];
		}

		str_new[new_str_size - 1] = '\0';

		if (newString == NULL) {
			newString = "";
		}
		if (needUpdateLabel) {
			m_sInitialStringUTF8 = newString;
		}

		setString(str_new, needUpdateLabel);
		CC_SAFE_DELETE_ARRAY(str_new);
		temp_string.clear();
	}
 }

void CCLabelBMFont::setString(unsigned short *newString, bool needUpdateLabel)
{
    if (!needUpdateLabel)
    {
        unsigned short* tmp = m_sString;
        m_sString = copyUTF16StringN(newString);
        CC_SAFE_DELETE_ARRAY(tmp);
    }
    else
    {
        unsigned short* tmp = m_sInitialString;
        m_sInitialString = copyUTF16StringN(newString);
        CC_SAFE_DELETE_ARRAY(tmp);
    }
    
    if (m_pChildren && m_pChildren->count() != 0)
    {
        CCObject* child;
        CCARRAY_FOREACH(m_pChildren, child)
        {
            CCNode* pNode = (CCNode*) child;
            if (pNode)
            {
                pNode->setVisible(false);
            }
        }
    }
    this->createFontChars();
    
    if (needUpdateLabel) {
        updateLabel();
    }
}

const char* CCLabelBMFont::getString(void)
{
    return m_sInitialStringUTF8.c_str();
}

void CCLabelBMFont::setCString(const char *label)
{
    setString(label);
}

//LabelBMFont - CCRGBAProtocol protocol
const ccColor3B& CCLabelBMFont::getColor()
{
    return m_tRealColor;
}

const ccColor3B& CCLabelBMFont::getDisplayedColor()
{
    return m_tDisplayedColor;
}

void CCLabelBMFont::setColor(const ccColor3B& color)
{
	m_tDisplayedColor = m_tRealColor = color;
	
	if( m_bCascadeColorEnabled ) {
		ccColor3B parentColor = ccWHITE;
        CCRGBAProtocol* pParent = dynamic_cast<CCRGBAProtocol*>(m_pParent);
        if (pParent && pParent->isCascadeColorEnabled())
        {
            parentColor = pParent->getDisplayedColor();
        }
        this->updateDisplayedColor(parentColor);
	}
}

GLubyte CCLabelBMFont::getOpacity(void)
{
    return m_cRealOpacity;
}

GLubyte CCLabelBMFont::getDisplayedOpacity(void)
{
    return m_cDisplayedOpacity;
}

/** Override synthesized setOpacity to recurse items */
void CCLabelBMFont::setOpacity(GLubyte opacity)
{
	m_cDisplayedOpacity = m_cRealOpacity = opacity;
    
	if( m_bCascadeOpacityEnabled ) {
		GLubyte parentOpacity = 255;
        CCRGBAProtocol* pParent = dynamic_cast<CCRGBAProtocol*>(m_pParent);
        if (pParent && pParent->isCascadeOpacityEnabled())
        {
            parentOpacity = pParent->getDisplayedOpacity();
        }
        this->updateDisplayedOpacity(parentOpacity);
	}
}

void CCLabelBMFont::setOpacityModifyRGB(bool var)
{
    m_bIsOpacityModifyRGB = var;
    if (m_pChildren && m_pChildren->count() != 0)
    {
        CCObject* child;
        CCARRAY_FOREACH(m_pChildren, child)
        {
            CCNode* pNode = (CCNode*) child;
            if (pNode)
            {
                CCRGBAProtocol *pRGBAProtocol = dynamic_cast<CCRGBAProtocol*>(pNode);
                if (pRGBAProtocol)
                {
                    pRGBAProtocol->setOpacityModifyRGB(m_bIsOpacityModifyRGB);
                }
            }
        }
    }
}
bool CCLabelBMFont::isOpacityModifyRGB()
{
    return m_bIsOpacityModifyRGB;
}

void CCLabelBMFont::updateDisplayedOpacity(GLubyte parentOpacity)
{
	m_cDisplayedOpacity = m_cRealOpacity * parentOpacity/255.0;
    
	CCObject* pObj;
	CCARRAY_FOREACH(m_pChildren, pObj)
    {
        CCSprite *item = (CCSprite*)pObj;
		item->updateDisplayedOpacity(m_cDisplayedOpacity);
	}
}

void CCLabelBMFont::updateDisplayedColor(const ccColor3B& parentColor)
{
	m_tDisplayedColor.r = m_tRealColor.r * parentColor.r/255.0;
	m_tDisplayedColor.g = m_tRealColor.g * parentColor.g/255.0;
	m_tDisplayedColor.b = m_tRealColor.b * parentColor.b/255.0;
    
    CCObject* pObj;
	CCARRAY_FOREACH(m_pChildren, pObj)
    {
        CCSprite *item = (CCSprite*)pObj;
		item->updateDisplayedColor(m_tDisplayedColor);
	}
}

bool CCLabelBMFont::isCascadeColorEnabled()
{
    return false;
}

void CCLabelBMFont::setCascadeColorEnabled(bool cascadeColorEnabled)
{
    m_bCascadeColorEnabled = cascadeColorEnabled;
}

bool CCLabelBMFont::isCascadeOpacityEnabled()
{
    return false;
}

void CCLabelBMFont::setCascadeOpacityEnabled(bool cascadeOpacityEnabled)
{
    m_bCascadeOpacityEnabled = cascadeOpacityEnabled;
}

// LabelBMFont - AnchorPoint
void CCLabelBMFont::setAnchorPoint(const CCPoint& point)
{
    if( ! point.equals(m_obAnchorPoint))
    {
        CCSpriteBatchNode::setAnchorPoint(point);
        updateLabel();
    }
}

// LabelBMFont - Alignment
void CCLabelBMFont::updateLabel()
{
    this->setString(m_sInitialString, false);

    if (m_fWidth > 0)
    {
        // Step 1: Make multiline
        vector<unsigned short> str_whole = cc_utf16_vec_from_utf16_str(m_sString);
        unsigned long stringLength = str_whole.size();
        vector<unsigned short> multiline_string;
        multiline_string.reserve( stringLength );
        vector<unsigned short> last_word;
        last_word.reserve( stringLength );

        unsigned int line = 1, i = 0;
        bool start_line = false, start_word = false;
        float startOfLine = -1, startOfWord = -1;
        int skip = 0;

        CCArray* children = getChildren();
        for (unsigned int j = 0; j < children->count(); j++)
        {
            CCSprite* characterSprite;
            unsigned int justSkipped = 0;
            
            while (!(characterSprite = (CCSprite*)this->getChildByTag(j + skip + justSkipped)))
            {
                justSkipped++;
            }
            
            skip += justSkipped;
            
            if (!characterSprite->isVisible())
                continue;

            if (i >= stringLength)
                break;

            unsigned short character = str_whole[i];

            if (!start_word)
            {
                startOfWord = getLetterPosXLeft( characterSprite );
                start_word = true;
            }
            if (!start_line)
            {
                startOfLine = startOfWord;
                start_line = true;
            }

            // Newline.
            if (character == '\n')
            {
                cc_utf8_trim_ws(&last_word);

                last_word.push_back('\n');
                multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
                last_word.clear();
                start_word = false;
                start_line = false;
                startOfWord = -1;
                startOfLine = -1;
                i+=justSkipped;
                line++;

                if (i >= stringLength)
                    break;

                character = str_whole[i];

                if (!startOfWord)
                {
                    startOfWord = getLetterPosXLeft( characterSprite );
                    start_word = true;
                }
                if (!startOfLine)
                {
                    startOfLine  = startOfWord;
                    start_line = true;
                }
            }

            // Whitespace.
            if (isspace_unicode(character))
            {
                last_word.push_back(character);
                multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
                last_word.clear();
                start_word = false;
                startOfWord = -1;
                i++;
                continue;
            }

            // Out of bounds.
            if ( getLetterPosXRight( characterSprite ) - startOfLine > m_fWidth )
            {
                if (!m_bLineBreakWithoutSpaces)
                {
                    last_word.push_back(character);

                    int found = cc_utf8_find_last_not_char(multiline_string, ' ');
                    if (found != -1)
                        cc_utf8_trim_ws(&multiline_string);
                    else
                        multiline_string.clear();

                    if (multiline_string.size() > 0)
                        multiline_string.push_back('\n');

                    line++;
                    start_line = false;
                    startOfLine = -1;
                    i++;
                }
                else
                {
                    cc_utf8_trim_ws(&last_word);

                    last_word.push_back('\n');
                    multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());
                    last_word.clear();
                    start_word = false;
                    start_line = false;
                    startOfWord = -1;
                    startOfLine = -1;
                    line++;

                    if (i >= stringLength)
                        break;

                    if (!startOfWord)
                    {
                        startOfWord = getLetterPosXLeft( characterSprite );
                        start_word = true;
                    }
                    if (!startOfLine)
                    {
                        startOfLine  = startOfWord;
                        start_line = true;
                    }

                    j--;
                }

                continue;
            }
            else
            {
                // Character is normal.
                last_word.push_back(character);
                i++;
                continue;
            }
        }

        multiline_string.insert(multiline_string.end(), last_word.begin(), last_word.end());

        int size = multiline_string.size();
        unsigned short* str_new = new unsigned short[size + 1];

        for (int i = 0; i < size; ++i)
        {
            str_new[i] = multiline_string[i];
        }

        str_new[size] = '\0';

        this->setString(str_new, false);
        
        CC_SAFE_DELETE_ARRAY(str_new);
    }

    // Step 2: Make alignment
    if (m_pAlignment != kCCTextAlignmentLeft)
    {
        int i = 0;

        int lineNumber = 0;
        int str_len = cc_wcslen(m_sString);
        vector<unsigned short> last_line;
        for (int ctr = 0; ctr <= str_len; ++ctr)
        {
            if (m_sString[ctr] == '\n' || m_sString[ctr] == 0)
            {
                float lineWidth = 0.0f;
                unsigned int line_length = last_line.size();
				// if last line is empty we must just increase lineNumber and work with next line
                if (line_length == 0)
                {
                    lineNumber++;
                    continue;
                }
                int index = i + line_length - 1 + lineNumber;
                if (index < 0) continue;

                CCSprite* lastChar = (CCSprite*)getChildByTag(index);
                if ( lastChar == NULL )
                    continue;

                lineWidth = lastChar->getPosition().x + lastChar->getContentSize().width/2.0f;

                float shift = 0;
                switch (m_pAlignment)
                {
                case kCCTextAlignmentCenter:
                    shift = getContentSize().width/2.0f - lineWidth/2.0f;
                    break;
                case kCCTextAlignmentRight:
                    shift = getContentSize().width - lineWidth;
                    break;
                default:
                    break;
                }

                if (shift != 0)
                {
                    for (unsigned j = 0; j < line_length; j++)
                    {
                        index = i + j + lineNumber;
                        if (index < 0) continue;

                        CCSprite* characterSprite = (CCSprite*)getChildByTag(index);
						if (characterSprite != NULL)
						{
							characterSprite->setPosition(ccpAdd(characterSprite->getPosition(), ccp(shift, 0.0f)));
						}
                    }
                }

                i += line_length;
                lineNumber++;

                last_line.clear();
                continue;
            }

            last_line.push_back(m_sString[ctr]);
        }
    }
}

// LabelBMFont - Alignment
void CCLabelBMFont::setAlignment(CCTextAlignment alignment)
{
    this->m_pAlignment = alignment;
    updateLabel();
}

void CCLabelBMFont::setWidth(float width)
{
    this->m_fWidth = width;
    updateLabel();
}

void CCLabelBMFont::setLineBreakWithoutSpace( bool breakWithoutSpace )
{
    m_bLineBreakWithoutSpaces = breakWithoutSpace;
    updateLabel();
}

void CCLabelBMFont::setScale(float scale)
{
    CCSpriteBatchNode::setScale(scale);
    updateLabel();
}

void CCLabelBMFont::setScaleX(float scaleX)
{
    CCSpriteBatchNode::setScaleX(scaleX);
    updateLabel();
}

void CCLabelBMFont::setScaleY(float scaleY)
{
    CCSpriteBatchNode::setScaleY(scaleY);
    updateLabel();
}

float CCLabelBMFont::getLetterPosXLeft( CCSprite* sp )
{
    return sp->getPosition().x * m_fScaleX - (sp->getContentSize().width * m_fScaleX * sp->getAnchorPoint().x);
}

float CCLabelBMFont::getLetterPosXRight( CCSprite* sp )
{
    return sp->getPosition().x * m_fScaleX + (sp->getContentSize().width * m_fScaleX * sp->getAnchorPoint().x);
}

// LabelBMFont - FntFile
void CCLabelBMFont::setFntFile(const char* fntFile)
{
    if (fntFile != NULL && strcmp(fntFile, m_sFntFile.c_str()) != 0 )
    {
        CCBMFontConfiguration *newConf = FNTConfigLoadFile(fntFile);

        CCAssert( newConf, "CCLabelBMFont: Impossible to create font. Please check file");

        m_sFntFile = fntFile;

        CC_SAFE_RETAIN(newConf);
        CC_SAFE_RELEASE(m_pConfiguration);
        m_pConfiguration = newConf;

        this->setTexture(CCTextureCache::sharedTextureCache()->addImage(m_pConfiguration->getAtlasName()));
        this->createFontChars();
    }
}

const char* CCLabelBMFont::getFntFile()
{
    return m_sFntFile.c_str();
}

CCBMFontConfiguration* CCLabelBMFont::getConfiguration() const
{
	return m_pConfiguration;
}


void CCLabelBMFont::setTextShadowEnabled(bool textShadowEnabled)
{
	this->m_textShadowEnabled=textShadowEnabled;
}

bool CCLabelBMFont::getTextShadowEnabled()
{
	return m_textShadowEnabled;
}

void CCLabelBMFont::setTextFadeEnabled(bool textFadeEnabled)
{
	this->m_textFadeEnabled=false;
	/*this->m_textFadeEnabled=textFadeEnabled;
	m_pobTextureAtlas->setupExtraVBO();*/
}

bool CCLabelBMFont::getTextFadeEnabled()
{
	return m_textFadeEnabled;
}


void CCLabelBMFont::setTextShadowFourDirEnabled(bool fourDirEnable){
	m_textShadowFourDirEnabled = fourDirEnable;
}
bool CCLabelBMFont::getTextShadowFourDirEnabled(){
	return m_textShadowFourDirEnabled;
}

void CCLabelBMFont::setTexShadowOffset(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX = shadowOffsetX;
	m_fShadowOffsetY = shadowOffsetY;

}

void CCLabelBMFont::setTexShadowOffset2(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX2 = shadowOffsetX;
	m_fShadowOffsetY2 = shadowOffsetY;

}

void CCLabelBMFont::setTexShadowOffset3(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX3 = shadowOffsetX;
	m_fShadowOffsetY3 = shadowOffsetY;

}

void CCLabelBMFont::setTexShadowOffset4(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX4 = shadowOffsetX;
	m_fShadowOffsetY4 = shadowOffsetY;

}

void CCLabelBMFont::setTextShadowColor(float _r, float _g, float _b, float _a)
{
	m_shadowColor = ccc4f(_r,_g,_b,_a);
}

void CCLabelBMFont::setTextBorderColor(float _r, float _g, float _b, float _a)
{
	m_borderColor = ccc4f(_r,_g,_b,_a);
}

void CCLabelBMFont::setTextBorderEnabled(bool textBorderEnabled)
{
	this->m_textBorderEnabled=textBorderEnabled;
}

bool CCLabelBMFont::getTextBorderEnabled()
{
	return m_textBorderEnabled;
}

void CCLabelBMFont::setTextFadeImageURL(std::string fadeImageUrl)
{
	this->m_textFadeImageURL=fadeImageUrl;
	if (m_fadeTexture)
	{
		m_fadeTexture->release();
	}
	m_fadeTexture = CCTextureCache::sharedTextureCache()->addImage(m_textFadeImageURL.c_str());
	m_fadeTexture->retain();
	setTextFadeEnabled(true);
}

void CCLabelBMFont::renderShadow(void)
{
	CCTextShadowSH t_shader_helper(CCShaderCache::sharedShaderCache()->programForKey(SHADER_BMFONT_TEXT_SHADOW));
	t_shader_helper.init();
	t_shader_helper.setColor(m_shadowColor.r,m_shadowColor.g,m_shadowColor.b,m_shadowColor.a);

	float offsetx = m_fShadowOffsetX/m_pobTextureAtlas->getTexture()->getPixelsWide();
	float offsety = m_fShadowOffsetY/m_pobTextureAtlas->getTexture()->getPixelsWide();
	t_shader_helper.setOff(offsetx,offsety);
	t_shader_helper.begin();
	m_pobTextureAtlas->drawQuads();
	

	//four direction offset to mimic the bord effect
	if (m_textShadowFourDirEnabled)
	{
 		offsetx = m_fShadowOffsetX2/m_pobTextureAtlas->getTexture()->getPixelsWide();
		offsety = m_fShadowOffsetY2/m_pobTextureAtlas->getTexture()->getPixelsWide();
		t_shader_helper.setOff(offsetx,offsety);
		t_shader_helper.begin();
		m_pobTextureAtlas->drawQuads();

 		offsetx = m_fShadowOffsetX3/m_pobTextureAtlas->getTexture()->getPixelsWide();
		offsety = m_fShadowOffsetY3/m_pobTextureAtlas->getTexture()->getPixelsWide();
		t_shader_helper.setOff(offsetx,offsety);
		t_shader_helper.begin();
		m_pobTextureAtlas->drawQuads();

 		offsetx = m_fShadowOffsetX4/m_pobTextureAtlas->getTexture()->getPixelsWide();
		offsety = m_fShadowOffsetY4/m_pobTextureAtlas->getTexture()->getPixelsWide();
		t_shader_helper.setOff(offsetx,offsety);
		t_shader_helper.begin();
		m_pobTextureAtlas->drawQuads();
	}
	t_shader_helper.end();

	CCShaderHelper t_ori_shader(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor));
	t_ori_shader.init();
	t_ori_shader.begin();
	m_pobTextureAtlas->drawQuads();
	t_ori_shader.end();


}


//void CCLabelBMFont::renderFade(void)
//{
//
//	CCTextFadeSH t_shader_helper(CCShaderCache::sharedShaderCache()->programForKey(SHADER_BMFONT_TEXT_FADE));
//	t_shader_helper.init();
//	t_shader_helper.setSrcTexture(m_pobTextureAtlas->getTexture());
//	t_shader_helper.setFadeTexture(m_fadeTexture);
//	t_shader_helper.begin();
//	m_pobTextureAtlas->drawNumberOfQuads(m_pobTextureAtlas->getTotalQuads(),0,m_pTex1,m_pTex2,m_iTexCoordCapa);
//	t_shader_helper.end();
//}

void CCLabelBMFont::renderBorder(void)
{
	CCTextBorderSH tshaderHelper(CCShaderCache::sharedShaderCache()->programForKey(SHADER_BMFONT_TEXT_BORDER));
	tshaderHelper.init();
	static float tAlph = 0.0;
	tshaderHelper.setBorderColor(m_borderColor.r,m_borderColor.g,m_borderColor.b,tAlph);
	float foffset = 0.000005f;
	tshaderHelper.setBorderWidth(foffset ,foffset );
	tAlph+= 0.0005;
	if(tAlph>1.0)
		tAlph = 0.0;
	tshaderHelper.begin();

	m_pobTextureAtlas->drawQuads();

	tshaderHelper.end();
}

void CCLabelBMFont::setFadeTexture(CCTexture2D * tex){
	if (tex)
	{
		tex->retain();
		if (m_fadeTexture)
		{
			m_fadeTexture->release();
		}
		m_fadeTexture = tex;
	}	
}

//
//void CCLabelBMFont::genAndInsertTextureCoords(CCRect& rect, int i)
//{
//	CCTexture2D *tex = m_pobTextureAtlas->getTexture() ;
//	if (! tex)
//	{
//		return;
//	}
//
//	float atlasWidth = (float)tex->getPixelsWide();
//	float atlasHeight = (float)tex->getPixelsHigh();
//
//	float left, right, top, bottom;
//
//#if CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
//	left    = (2*rect.origin.x+1)/(2*atlasWidth);
//	right    = left+(rect.size.height*2-2)/(2*atlasWidth);
//	top        = (2*rect.origin.y+1)/(2*atlasHeight);
//	bottom    = top+(rect.size.width*2-2)/(2*atlasHeight);
//#else
//		left    = rect.origin.x/atlasWidth;
//		right    = (rect.origin.x+rect.size.height) / atlasWidth;
//		top        = rect.origin.y/atlasHeight;
//		bottom    = (rect.origin.y+rect.size.width) / atlasHeight;
//#endif // CC_FIX_ARTIFACTS_BY_STRECHING_TEXEL
//
//		/*ccTex2F texcoor1 = tex2(left,top);
//		ccTex2F texcoor2 = tex2(right,bottom);*/
//
//		if (m_pTex1 &&m_pTex2 )
//		{
//			m_pTex1[i*4] = m_pTex1[i*4+1] =m_pTex1[i*4+2] =m_pTex1[i*4+3] = tex2(left,bottom);
//			m_pTex2[i*4] = m_pTex2[i*4+1] =m_pTex2[i*4+2] =m_pTex2[i*4+3] = tex2(right,top);
//		}
//		
//}

void CCLabelBMFont::draw()
{
	CC_PROFILER_START("CCSpriteBatchNode - draw");

	// Optimization: Fast Dispatch
	if( m_pobTextureAtlas->getTotalQuads() == 0 )
	{
		return;
	}

	CC_NODE_DRAW_SETUP();

	arrayMakeObjectsPerformSelector(m_pChildren, updateTransform, CCSprite*);

	//ccGLBlendFunc( m_blendFunc.src, m_blendFunc.dst );
	glBlendFuncSeparate(m_blendFunc.src, m_blendFunc.dst, m_blendFunc.src, m_blendFunc.dst);

	CCTexture2D* pTexture = m_pobTextureAtlas->getTexture();
	if (pTexture && pTexture->isPaletteTexture() && m_pShaderProgram &&
		m_pShaderProgram == CCTextureCache::sharedTextureCache()->getPaletteGLProgram())
	{		
		ccGLBindTexture2DN(1, pTexture->getPaletteTexture()->getName());

		int paletteTexLocation = glGetUniformLocation(m_pShaderProgram->getProgram(), "CC_Palette");
		if (paletteTexLocation >= 0)
			m_pShaderProgram->setUniformLocationWith1i(paletteTexLocation, 1);

		int texSizeLocation = glGetUniformLocation(m_pShaderProgram->getProgram(), "CC_TexSize");
		if (texSizeLocation >= 0)
			m_pShaderProgram->setUniformLocationWith2f(texSizeLocation, pTexture->getContentSize().width, pTexture->getContentSize().height);		
	}

	if(m_textBorderEnabled && false)
	{
		renderBorder();
	}

	if (m_textShadowEnabled)
	{
		renderShadow();
	}

	/*if (false)
	{
	renderFade();
	}*/



	if(!m_textShadowEnabled&&!m_textFadeEnabled&&!m_textBorderEnabled)
	{
		m_pobTextureAtlas->drawQuads();
	}

	
	CC_PROFILER_STOP("CCSpriteBatchNode - draw");

}

NS_CC_END
