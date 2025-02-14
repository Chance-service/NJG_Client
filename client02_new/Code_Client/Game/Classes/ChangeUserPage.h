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
#include "libOS.h"
/*
數據移行介面
*/
enum InputType
{
	INPUT_CODE,
	INPUT_PWD
};
class ChangeUserPage;
class EditBoxDelegate : public CCEditBoxDelegate
{
private:
	ChangeUserPage* mCustom;
	InputType mInputType;
public:
	void setCustom(ChangeUserPage* custom){mCustom = custom;}
	ChangeUserPage* getCustom(){return mCustom;}
	void setInputType(InputType type){mInputType = type;}
	virtual void editBoxEditingDidBegin(CCEditBox* editBox);
	virtual void editBoxEditingDidEnd(CCEditBox* editBox);
	virtual void editBoxTextChanged(CCEditBox* editBox, const std::string& text);
	virtual void editBoxReturn(CCEditBox* editBox);
};
class ChangeUserPage 
	: public CustomPage
	, public State<MainFrame>
	, public CCBContainer::CCBContainerListener
	, public libOSListener
	, public platformListener	
{
public:
	ChangeUserPage(void);
	~ChangeUserPage(void);
	CREATE_FUNC(ChangeUserPage);

	virtual PAGE_TYPE getPageType(){return CustomPage::PT_CONTENT;}
	virtual void Enter( MainFrame* );
	virtual void Execute( MainFrame* );
	virtual void Exit( MainFrame* );
	virtual void onMenuItemAction( const std::string& itemName, cocos2d::CCObject* sender, int tag );
	virtual void onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender);
	void URLlabelCallback(cocos2d::extension::IRichNode* root, cocos2d::extension::IRichElement* ele, int _id);
	virtual void load( void );
	virtual std::string onReceiveCommonMessage(const std::string& tag, const std::string& msg);
	virtual void onInputboxEnter(const std::string& content);
	void onEditboxReturn(cocos2d::extension::CCEditBox* editbox,std::string text,InputType type,bool isChange = false);
	virtual void onCloseKeyboard();
	virtual	void onOpenKeyboard();
	virtual void OnKeyboardHightChange(int nHight);
	void setCodeFrameVisible(bool isVisible){if(mSprite9_Code){mSprite9_Code->setVisible(isVisible);}}
	void setPwdFrameVisible(bool isVisible){if(mSprite9_Pwd){mSprite9_Pwd->setVisible(isVisible);}}
private:
	void loadConfigFile(const std::string& announcementFile, bool isDownload = false);
	void closePage();
	void resetPageData();
	void cursorNode(CCLabelTTF* labelNode, bool isShow);
	void onInputChangeText(const std::string& content);
	
	//cocos2d::extension::CCEditBox* _createEditBox(CCEditBoxDelegate* delegate,const CCSize& size,CCNode* node,const CCPoint& pos,std::string plactHolder="");
private:
	int mInputType;
	std::string mStrCode;
	std::string mStrPwd;
	int keyBoardHeight;
	float  bgNodeDefaultPosX;
    float  bgNodeDefaultPosY;
	bool isOpenKeyBoard;
	bool isMoveFullNode;
	CCLabelTTF* mCodeHintNode;
	CCLabelTTF* mPwdHintNode;
	CCLabelTTF* mCodeTextNode;
	CCLabelTTF* mPwdTextNode;
	CCScale9Sprite* mSprite9_Code;
	CCScale9Sprite* mSprite9_Pwd;
	EditBoxDelegate* mCodeEditBoxDelegate;
	EditBoxDelegate* mPassWordEditBoxDelegate;
};

