#include "Lua_HttpsBridge.h"

namespace Lua_HttpsBridge {


	// ㄧΑノㄓ倒 lua 秸ノ

	int lua_release_print(lua_State* ls) {
		CCLog(lua_tostring(ls, 1));

		return 0;
	}

	void onHttpCallback(BCWebRequest::HttpResult callback){
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_getglobal(ls, "_cpp_notify_Http_callback");
		lua_pushboolean(ls, callback.isError);
		lua_pushstring(ls, callback.responseData.c_str());
		lua_pushstring(ls, callback.tag.c_str());
		lua_pushnumber(ls, callback.code);
		lua_call(ls, 4, 0);	// 材把计:ㄧ计把计计材把计:ㄧ计计
	}

	int lua_WebRequest_Post(lua_State* ls){
		std::string url(lua_tostring(ls, 1));
		std::string tag(lua_tostring(ls, 2));
		std::string data(lua_tostring(ls, 3));
		BCWebRequest::getInstance()->post(url, tag, data, onHttpCallback);
		return 0;
	}

	int lua_WebRequest_Get(lua_State* ls){
		std::string url(lua_tostring(ls, 1));
		BCWebRequest::getInstance()->get(url, onHttpCallback);
		return 0;
	}

	void register_function() {
		// 盢SDK 闽ㄧΑ爹 lua 吏挂
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_register(ls, "WebRequest_Post_Cpp", lua_WebRequest_Post);
		lua_register(ls, "WebRequest_Get_Cpp", lua_WebRequest_Get);
		//lua_register(ls, "ecchigamersdk_get_login_url", lua_ecchigamersdk_get_login_url);
		//lua_register(ls, "ecchigamersdk_get_token", lua_ecchigamersdk_get_token);
		//lua_register(ls, "ecchigamersdk_openlogin", lua_ecchigamersdk_openlogin);
		//lua_register(ls, "ecchigamersdk_openlogout", lua_ecchigamersdk_openlogout);
		//lua_register(ls, "ecchigamersdk_openpayment", lua_ecchigamersdk_openpayment);
		//lua_register(ls, "ecchigamersdk_openaccountbindgame", lua_ecchigamersdk_openaccountbindgame);
		//lua_register(ls, "ecchigamersdk_postaccountbindgame", lua_ecchigamersdk_postaccountbindgame);

		lua_register(ls, "release_print", lua_release_print);
	}

}