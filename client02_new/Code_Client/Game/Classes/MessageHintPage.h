#pragma once

#include "cocos2d.h"
#include "cocos-ext.h"
#include "CustomPage.h"
#include "ContentBase.h"
#include "StateMachine.h"
#include "MainFrame.h"

class MessageHintPage 
	: public CustomPage 
	, public State<MainFrame>
	, public CCBContainer::CCBContainerListener
{
public:
	MessageHintPage(void);
	~MessageHintPage(void);

	virtual PAGE_TYPE getPageType() {return PT_CONTENT;}

	CREATE_FUNC(MessageHintPage);
	
	//this will execute when the state is entered
	virtual void Enter(MainFrame*);
	//this is the states normal update function
	virtual void Execute(MainFrame*);
	//this will execute when the state is exited. (My word, isn't
	//life full of surprises... ;o))
	virtual void Exit(MainFrame*);

	virtual void load(void);
	virtual void unload(void);

	void onMenuItemAction( const std::string& itemName, cocos2d::CCObject* sender, int tag );

	void onClose();

	void showHint(void);

	void setMsgString(const std::string& msgSteing){mMsgString = msgSteing;}

	void setShowEnter(bool showEnter){ mShowEnter = showEnter; }

	static void Msg_Hint(const std::string& msgString,int tag = 0);
private:
	std::string mMsgString;
	bool mShowEnter = true;
};