#pragma once
#include "cocos-ext.h"
#include "cocos2d.h"
#include "CCBManager.h"
#include "CustomPage.h"
#include "StateMachine.h"
#include "MainFrame.h"
#include "CCBContainer.h"
#include "ContentBase.h"
#include "DataTableManager.h"
#include "GameMessages.h"
#include "MessageManager.h"
#include "GameMaths.h"
#include "CurlDownload.h"
#include "SeverConsts.h"
#include "json/json.h"
#include <time.h>
#include "MessageBoxPage.h"
/*
客服反饋介面
*/
class FeedBackPage 
	: public Singleton<FeedBackPage>
	, public CustomPage
	, public State<MainFrame>
	, public CCBContainer::CCBContainerListener
	, public libOSListener
	, public platformListener
{
public:
	FeedBackPage(void);
	~FeedBackPage(void);

	CREATE_FUNC(FeedBackPage);

	virtual PAGE_TYPE getPageType(){return CustomPage::PT_CONTENT;}
	virtual void Enter( MainFrame* );
	virtual void Execute( MainFrame* );
	virtual void Exit( MainFrame* );
	virtual void onMenuItemAction( const std::string& itemName, cocos2d::CCObject* sender, int tag );
	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender);
	void URLlabelCallback(cocos2d::extension::IRichNode* root, cocos2d::extension::IRichElement* ele, int _id);
	void URLlabelForLuaCallback(std::string url);
	virtual void load( void );

	static FeedBackPage* getInstance();

private:
	void	loadConfigFile(const std::string& announcementFile, bool isDownload = false);
	CCNode* memberRootNode;
	cocos2d::extension::CCScrollView* members;
	typedef std::vector<ContentBase*> ContentList;
	void closePage();
};

