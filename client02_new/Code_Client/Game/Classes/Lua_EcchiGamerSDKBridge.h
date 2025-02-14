#ifndef __LUA_ECCHI_GAMER_SDK_BRIDGE_H__
#define __LUA_ECCHI_GAMER_SDK_BRIDGE_H__

#include "cocos2d.h"

#include <iostream>
#include "cocos2d.h"

using namespace cocos2d;
using namespace std;

#include "CCLuaEngine.h"

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
};

namespace Lua_EcchiGamerSDKBridge {

	// 註冊cpp 函式給 lua 環境
	void register_function();
	void callinitbyC();
	void callLoginbyC();
	void callLogoutbyC();
	void callopenPaymentbyC();
	void callPostAccountBindbyC(std::string gameAccount);
};

#endif  // __LUA_ECCHI_GAMER_SDK_BRIDGE_H__
