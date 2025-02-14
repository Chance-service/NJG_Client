

#ifndef __cocos2dx__ccArabic__
#define __cocos2dx__ccArabic__

#include "platform/CCPlatformMacros.h"

NS_CC_BEGIN

/*
 * check_char_is_arabic:
 * @selfC: char code
 *
 * Check charcode is arabic char
 *
 * Return value: if @selfC is arabic return true
 * */
 CC_DLL bool check_char_is_arabic(unsigned short selfC);


/*
* check_char_is_arabic_spec:
* @selfC: char code
*
* Check charcode is english or number
*
* Return value: if @selfC is english char or number return true
* */
 CC_DLL bool check_char_is_arabic_spec(unsigned short selfC);



 /**
 * get_arabic_sign_replace_change:
 * @selfC: self char code
 *
 *
 * change arabic char by normal rule
 *
 *
 * Return value: @selfC or changed char code
 **/
 CC_DLL unsigned short
	 get_arabic_sign_replace_change
	 (unsigned short selfC);



/**
 * get_arabic_char_normal_change:
 * @selfC: self char code
 * @rightC: char code on the right
 * @leftC: char code on the left
 *
 *
 * change arabic char by normal rule
 * 
 *
 * Return value: @selfC or changed char code
 **/
CC_DLL unsigned short
get_arabic_char_normal_change
			(unsigned short selfC,
			 unsigned short rightC = 0x0,
			 unsigned short leftC = 0x0);

/*
* get_arabic_char_spec_change:
* @selfC: self char code
* @rightC: char code on the right
* @leftC: char code on the left
*
*
* change arabic char by specil rule
*
* Return value: changed char code or 0x9
* */
CC_DLL unsigned short
get_arabic_char_spec_change
		(unsigned short selfC,
		 unsigned short rightC,
		 unsigned short leftC = 0x0);



CC_DLL bool get_is_text_render_left_2_right();
CC_DLL void set_is_text_render_left_2_right(bool isLeft2Right);


NS_CC_END

#endif /* defined(__cocos2dx__ccArabic__) */
