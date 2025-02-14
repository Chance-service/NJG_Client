#ifndef __LUA_HTTPS_BRIDGE_H__
#define __LUA_HTTPS_BRIDGE_H__

#include "cocos2d.h"

#include <iostream>
#include "cocos2d.h"
#include "BCWebRequest.h"

using namespace cocos2d;
using namespace std;

#include "CCLuaEngine.h"

extern "C" {
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
};

namespace Lua_HttpsBridge {
	// ���Ucpp �禡�� lua ����
	void register_function();
}


#endif  // __LUA_HTTPS_BRIDGE_H__