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
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#include <regex>
#endif
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID||CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include <regex.h>
#endif
/*
·sµn¤J¤¶­±
*/
enum InputType
{
	INPUT_CODE,
	INPUT_PWD,
	INPUT_RegID,
	INPUT_RegPwd,
	INPUT_RegAgain
};

enum TabMode
{
	NoneMode,
	LoginMode,
	RegisterMode,
};

class LoginUserPage;

class EditUIDelegate : public CCEditBoxDelegate
{
private:
	LoginUserPage* mCustom;
	InputType mInputType;
public:
	void setCustom(LoginUserPage* custom){mCustom = custom;}
	LoginUserPage* getCustom(){return mCustom;}
	void setInputType(InputType type){mInputType = type;}
	virtual void editBoxEditingDidBegin(CCEditBox* editBox);
	virtual void editBoxEditingDidEnd(CCEditBox* editBox);
	virtual void editBoxTextChanged(CCEditBox* editBox, const std::string& text);
	virtual void editBoxReturn(CCEditBox* editBox);
};
class LoginUserPage 
	: public CustomPage
	, public State<MainFrame>
	, public CCBContainer::CCBContainerListener
	, public libOSListener
	, public platformListener	
{
public:
	enum EditType
	{
		Edit_UserID,
		Edit_UserPwd,
		Edit_RegID,
		Edit_RegPwd,
		Edit_RegAgain,
	};
	LoginUserPage(void);
	~LoginUserPage(void);
	CREATE_FUNC(LoginUserPage);

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
	void DefaultLogin(std::string UserId , std::string aPwd );
	void closePage();
	//void setCodeFrameVisible(bool isVisible){if(mSprite9_Code){mSprite9_Code->setVisible(isVisible);}}
	//void setPwdFrameVisible(bool isVisible){if(mSprite9_Pwd){mSprite9_Pwd->setVisible(isVisible);}}
private:
	void loadConfigFile(const std::string& announcementFile, bool isDownload = false);
	void resetPageData();
	void cursorNode(CCLabelTTF* labelNode, bool isShow);
	void onInputChangeText(const std::string& content);
	bool checkLabelUI();
	void switchAllhint(bool swit);
	void clearAllLabel();
	void setInputMode(TabMode aMode);
	void setTabSelect();
	//void switch_cursor(std::string );
	
	cocos2d::extension::CCEditBox* _createEditBox(CCEditBoxDelegate* delegate,const CCSize& size,CCNode* node,const CCPoint& pos,std::string plactHolder="");
private:
	int mInputType;
	int mTabMode;
	std::string mStrCode;
	std::string mStrPwd;
	std::string mStrReg_ID;
	std::string mStrReg_Pwd;
	std::string mStrReg_Again;

	int keyBoardHeight;
	float  bgNodeDefaultPosX;
    float  bgNodeDefaultPosY;
	bool isOpenKeyBoard;
	bool isMoveFullNode;
	CCLabelTTF* mCodeHintNode;
	CCLabelTTF* mPwdHintNode;
	CCLabelTTF* mCodeTextNode;
	CCLabelTTF* mPwdTextNode;
	//CCScale9Sprite* mSprite9_Code;
	//CCScale9Sprite* mSprite9_Pwd;
	EditUIDelegate* mCodeEditBoxDelegate;
	EditUIDelegate* mPassWordEditBoxDelegate;

	CCLabelTTF* mRegIDHintNode;
	CCLabelTTF* mRegPwdHintNode;
	CCLabelTTF* mRegAgainHintNode;
	CCLabelTTF* mRegIDNode;
	CCLabelTTF* mRegPwdNode;
	CCLabelTTF* mRegAgainNode;
	//CCScale9Sprite* mSprite9_RegID;
	//CCScale9Sprite* mSprite9_RegPwd;
	//CCScale9Sprite* mSprite9_RegAgain;
	EditUIDelegate* mRegIDEditBoxDelegate;
	EditUIDelegate* mRegPwdEditBoxDelegate;
	EditUIDelegate* mRegAgainEditBoxDelegate;

	std::map<std::string, CCLabelTTF*> textMap;
	std::map<std::string, CCLabelTTF*> hintMap;
	std::map<int,CCEditBox*> EditBoxMap;

	bool defaultInGame;
};

