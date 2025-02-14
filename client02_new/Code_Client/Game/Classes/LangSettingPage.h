#pragma once
#include "cocos-ext.h"
#include "cocos2d.h"
#include "CCBManager.h"
#include "CustomPage.h"
#include "LoadingFrame.h"
#include "MainFrame.h"
#include "CCBContainer.h"
#include "ContentBase.h"
#include "DataTableManager.h"
#include "GameMessages.h"
#include "MessageManager.h"

USING_NS_CC;
/*
»y¨t¿ï¾Ü¤¶­±
*/

class LangSettingPage;

class LangSettingPage
	: public CustomPage
	, public State<MainFrame>
	, public CCBContainer::CCBContainerListener
	, public libOSListener
	, public platformListener
{
public:
	LangSettingPage(void);
	~LangSettingPage(void);
	CREATE_FUNC(LangSettingPage);
	virtual PAGE_TYPE getPageType(){ return CustomPage::PT_CONTENT; }
	virtual void Enter(MainFrame*);
	virtual void Execute(MainFrame*);
	virtual void Exit(MainFrame*);

	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender);
	virtual void load(void);
	void closePage();
private:
	void refreshPage();
private:
	int tempSelectId;
};