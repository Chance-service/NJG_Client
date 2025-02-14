#pragma once
#include "cocos-ext.h"
#include "cocos2d.h"
#include "CCBManager.h"
#include "CustomPage.h"
#include "StateMachine.h"
#include "LoadingFrame.h"
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
#include "libOS.h"
#include "network/HttpRequest.h"
#include "network/HttpClient.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <regex>
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID||CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <regex.h>
#endif
USING_NS_CC;
/*
·sµn¤J¤¶­±
*/


class LoginBCPage;

class EditDelegate : public CCEditBoxDelegate
{
public:
	enum InputType
	{
		INPUT_EMAIL,
		INPUT_CODE
	};
private:

	LoginBCPage* mCustom;
	InputType mInputType;
public:
	void setCustom(LoginBCPage* custom){ mCustom = custom; }
	LoginBCPage* getCustom(){ return mCustom; }
	void setInputType(InputType type){ mInputType = type; }
	virtual void editBoxEditingDidBegin(CCEditBox* editBox);
	virtual void editBoxEditingDidEnd(CCEditBox* editBox);
	virtual void editBoxTextChanged(CCEditBox* editBox, const std::string& text);
	virtual void editBoxReturn(CCEditBox* editBox);
};

class LoginBCPage
	: public CustomPage
	, public State<MainFrame>
	, public CCBContainer::CCBContainerListener
	, public libOSListener
	, public platformListener
{
public:
	enum EditType
	{
		Edit_Email,
		Edit_Code,
	};
	LoginBCPage(void);
	~LoginBCPage(void);
	CREATE_FUNC(LoginBCPage);
	virtual PAGE_TYPE getPageType(){ return CustomPage::PT_CONTENT; }
	virtual void Enter(MainFrame*);
	virtual void Execute(MainFrame*);
	virtual void Exit(MainFrame*);

	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender);
	virtual void onInputboxEnter(const std::string& content);
	void onEditboxReturn(cocos2d::extension::CCEditBox* editbox, std::string text, EditDelegate::InputType type, bool isChange = false);
	void DefaultEmail();
	virtual void load(void);
	void closePage();
	

	cocos2d::extension::CCEditBox* _createBCEditBox(CCEditBoxDelegate* delegate, const CCSize& size, CCNode* node, const CCPoint& pos, std::string plactHolder = "");
private:
	void resetPageData();
	bool checkLabelUI();
	void onInputChangeText(const std::string& content);
	void cursorNode(CCLabelTTF* labelNode, bool isShow);
	void SendCode(const std::string& email);
	void StartGame(const std::string& email, const std::string& aCode);
	void onHttpRequestCompleted(cocos2d::CCNode *sender, void*data);
	void showSendBtn(bool isShow);
private:
	int mInputType;

	std::string mStrCode;
	std::string mStrEmail;

	int keyBoardHeight;
	float  bgNodeDefaultPosX;
	float  bgNodeDefaultPosY;
	bool isOpenKeyBoard;
	bool isMoveFullNode;

	std::map<std::string, CCLabelTTF*> textMap;
	//std::map<std::string, CCLabelTTF*> hintMap;
	std::map<int, CCEditBox*> EditBoxMap;

	EditDelegate* mEmailEditBoxDelegate;
	EditDelegate* mCodeEditBoxDelegate;
	
};