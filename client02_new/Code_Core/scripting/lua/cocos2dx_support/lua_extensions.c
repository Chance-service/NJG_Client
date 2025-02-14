// ----- lua_extensions.c -----

#include "lua_extensions.h"
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) ||  (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)

#include "../lua/luasocket_scripts.h"


#else

#include "luasocket_scripts.h"

#endif

#if __cplusplus
extern "C" {
#endif

	// socket
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32) ||  (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "../lua/luasocket.h"
#include "../lua/mime.h"

    
#else
    
#include "luasocket.h"
#include "mime.h"
    
#endif
    


	static luaL_Reg luax_exts[] = {
		{"socket.core", luaopen_socket_core},
		{"mime.core", luaopen_mime_core},

		{NULL, NULL}
	};

#include "tolua_fix.h"

	void luaopen_lua_extensions(lua_State *L)
	{
		luaL_Reg* lib = luax_exts;
		lua_getglobal(L, "package");
		lua_getfield(L, -1, "preload");
		for (; lib->func; lib++)
		{
			lua_pushcfunction(L, lib->func);
			lua_setfield(L, -2, lib->name);
		}
		lua_pop(L, 2);

		// load extensions script
		luaopen_luasocket_scripts(L);
	}

#if __cplusplus
} // extern "C"
#endif