#ifndef __VoiceMenu_H_
#define __VoiceMenu_H_
#include "cocos2d.h"
#include "VoiceMenuItem.h"
USING_NS_CC;

	class   VoiceMenu : public CCMenu
	{
	public:
		VoiceMenu() : m_tTouchPoint(CCPoint(0,0)),m_pSelectedItem(NULL), m_bScrollViewChild(false), m_bEnabled(false){};
		~VoiceMenu(){};

		static VoiceMenu* create(CCMenuItem* item, ...);
		static VoiceMenu* createWithItem(CCMenuItem* item); //void draw();

		/**
		@brief For phone event handle functions
		*/
		virtual bool ccTouchBegan(CCTouch* touch, CCEvent* event);
		virtual void ccTouchEnded(CCTouch* touch, CCEvent* event);
		virtual void ccTouchCancelled(CCTouch *touch, CCEvent* event);
		virtual void ccTouchMoved(CCTouch* touch, CCEvent* event);
		virtual void registerWithTouchDispatcher();


		//一下用于重写成员属性
		virtual bool isEnabled() { return m_bEnabled; }
		virtual void setEnabled(bool value) { m_bEnabled = value; };
		virtual void onExit();
		bool initWithItems(CCMenuItem* item, va_list args);
		bool initWithArray(CCArray* pArrayOfItems);
		void setScrollViewChild(bool child);
		virtual void removeChild(CCNode* child, bool cleanup);
		CCMenuItem* itemForTouch(CCTouch * touch);

	protected:
		//父类不能被继承的属性Private
		VoiceMenuItem *m_pSelectedItem;
		/** whether or not the menu will receive events */
		bool m_bEnabled;
		bool m_bScrollViewChild;
		CCPoint m_tTouchPoint;
	};
#endif