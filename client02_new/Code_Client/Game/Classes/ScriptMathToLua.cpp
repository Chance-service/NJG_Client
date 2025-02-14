
#include "stdafx.h"

#include "ScriptMathToLua.h"
#include "ServerDateManager.h"
#include "StringConverter.h"
#include "DataTableManager.h"
#include "BlackBoard.h"
#include "Language.h"
#include "GameMessages.h"
#include "PacketManager.h"
#include "HP.pb.h"
#include "libOS.h"
USING_NS_CC;
ScriptMathToLua::ScriptMathToLua(void)
{

}

ScriptMathToLua::~ScriptMathToLua(void)
{
}


void ScriptMathToLua::showWXChat()
{
    
}

void ScriptMathToLua::setSwallowsTouches(CCScrollView* _scroll)
{
	CCTouchHandler* pHandler = CCDirector::sharedDirector()->getTouchDispatcher()->findHandler(_scroll);
	if (pHandler)
	{
		CCTargetedTouchHandler* pTh = dynamic_cast<CCTargetedTouchHandler*>(pHandler);
		if (pTh)
		{
			pTh->setSwallowsTouches(true);
		}
	}
}
