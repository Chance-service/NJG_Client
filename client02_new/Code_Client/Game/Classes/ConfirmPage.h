#pragma once

#include "CustomPage.h"
#include "MainFrame.h"

typedef void (*ConfirmCallback)(bool);
class ConfirmPage
	: public CustomPage
	, public State<MainFrame>
{
public:
	ConfirmPage(void);
	~ConfirmPage(void);

	virtual PAGE_TYPE getPageType() {return PT_CONTENT;}

	CREATE_FUNC(ConfirmPage);
	virtual void Enter(MainFrame*);
	virtual void Execute(MainFrame*) {};
	virtual void Exit(MainFrame*);
	virtual void load(void);
	void showPage(std::string confirmMsg, std::string confirmTitle, ConfirmCallback cb, std::string yesStr = "@Determine", std::string noStr = "@Cancel", bool canCancel = true, bool hideBtn = false);
	void refresh();

	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender);
private:
	void _clear();
	void _popSelf();

	std::string mMsg;
	std::string mTitle;
	std::string myesStr;
	std::string mnoStr;
	bool mCancel;
	bool mHideBtn;
	ConfirmCallback mCb;
};

#define ShowConfirmPage(msg,title, cbFunc) dynamic_cast<ConfirmPage* >(CCBManager::Get()->getPage("ConfirmPage"))->showPage(msg,title, cbFunc);
#define ShowConfirmPage2(msg,title,cbFunc,yesStr) dynamic_cast<ConfirmPage* >(CCBManager::Get()->getPage("ConfirmPage"))->showPage(msg,title,cbFunc,yesStr);
#define ShowConfirmPage3(msg,title,cbFunc,yesStr,noStr,canCancel) dynamic_cast<ConfirmPage* >(CCBManager::Get()->getPage("ConfirmPage"))->showPage(msg,title,cbFunc,yesStr,noStr,canCancel);
#define ShowConfirmPage4(msg,title,cbFunc,yesStr,noStr,canCancel) dynamic_cast<ConfirmPage* >(CCBManager::Get()->getPage("ConfirmPage"))->showPage(msg,title,cbFunc,yesStr,noStr,canCancel,true);