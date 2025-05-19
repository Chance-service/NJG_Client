#include "Lua_EcchiGamerSDKBridge.h"

#include "ecchigamer/EcchiGamerSDK.h"
#include "LoginUserPage.h"
#include "LoadingFrame.h"
#include "coresdk/Enum.h"
#include "TimeCalculator.h"

namespace Lua_EcchiGamerSDKBridge {

	void onOpenLoginCallback_ByC(coresdk::ProfileResult result)
	{
		bool isok = result.isSuccess;
		if (isok) {	//登入成功
			std::string userID = result.data.user_info.user_id;
			std::string token = ecchigamer::EcchiGamerSDK::getToken();
			bool isGuest = result.data.user_info.account.empty();
			CCLog("userID: %s, token: %s, isGuest: %s", userID.c_str(), token.c_str(), isGuest ? "true" : "false");
			//LoadingFrame* pLoadingFrame = GamePrecedure::Get()->getLoadingFrame();
			libPlatformManager::getPlatform()->setLoginName(userID);
			GamePrecedure::getInstance()->setDefaultPwd("888888");
			libPlatformManager::getPlatform()->setIsGuest(isGuest ? 1 : 0);
			CCUserDefault::sharedUserDefault()->setStringForKey("ecchigamer.token", token);
			CCLog("ecchigamer.token : %s", CCUserDefault::sharedUserDefault()->getStringForKey("ecchigamer.token").c_str());
			CCLog("ecchigamer::EcchiGamerSDK::getToken : %s", token.c_str());
			//pLoadingFrame->onEnterGame();
		}
		else {
			std::string theErrorCode = result.data.result;
			CCLog("ErrorCode: %s", theErrorCode.c_str());
		}
	}
	void onLogoutCallback_ByC(coresdk::LogoutResult result)
	{
		if (!result.exception.empty())
		{
			return;
		}

		libPlatformManager::getPlatform()->setLoginName("");
		// delay 2sec to call loglin
		TimeCalculator::getInstance()->createTimeCalcultor("R18checkLogin", 2);

		/*CCUserDefault::sharedUserDefault()->setStringForKey("LastLoginPUID", "");
		CCUserDefault::sharedUserDefault()->setStringForKey("PassKey", "");
		CCUserDefault::sharedUserDefault()->setStringForKey("ecchigamer.token", "");
		CCUserDefault::sharedUserDefault()->setStringForKey("EroLoginType", "");
		LoadingFrame* mLoadingFrame = dynamic_cast<LoadingFrame*>(CCBManager::Get()->getPage("LoadingFrame"));
		if (mLoadingFrame)
		{
			mLoadingFrame->showLoginUser();
		}*/
	}

	void onInitCCCallback(bool isCompleted)
	{
		CCLog("onInitializeCallback:%s", isCompleted ? "true" : "false");

		if (isCompleted)	//SDK初始化成功
		{
			CCLog("Completed");
			//ecchigamer::EcchiGamerSDK::openLogin(onOpenLoginCallback_ByC);
		}
	}

	void onPostAccountBindCallback_ByC(coresdk::ProfileResult result)
	{
		if (result.isSuccess) {
			CCLog("Bind Success");
		}
		else {
			string errorCode = result.data.result;
			CCLog("ErrorCode: %s", errorCode.c_str());
		}
	}

	void onInitializeCallback(bool result) {
		// 通知 lua，初始化完成
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_getglobal(ls, "_cpp_notify_initialize_callback");
		lua_pushboolean(ls, result);

		lua_call(ls, 1, 0);	// 第一個參數:函數的參數個數，第二個參數:函數返回值個數
	}

	void onOpenLoginCallback(coresdk::ProfileResult result) {
		// 通知 lua，openLogin 完成
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_getglobal(ls, "_cpp_notify_openlogin_callback");
		lua_pushboolean(ls, result.isSuccess);
		lua_pushstring(ls, result.exception.c_str());
		lua_pushstring(ls, result.data.result.c_str());
		lua_pushnumber(ls, result.data.server_time);
		lua_pushstring(ls, result.data.user_info.account.c_str());
		lua_pushstring(ls, result.data.user_info.account_status.c_str());
		lua_pushstring(ls, result.data.user_info.birthday.c_str());
		lua_pushnumber(ls, result.data.user_info.coins);
		lua_pushstring(ls, result.data.user_info.country.c_str());
		lua_pushnumber(ls, result.data.user_info.free_coins);
		lua_pushnumber(ls, result.data.user_info.gender);
		lua_pushstring(ls, result.data.user_info.hobbies.c_str());
		lua_pushstring(ls, result.data.user_info.nickname.c_str());
		lua_pushstring(ls, result.data.user_info.user_id.c_str());

		lua_call(ls, 14, 0);	// 第一個參數:函數的參數個數，第二個參數:函數返回值個數
	}

	void onOpenLogoutCallback(coresdk::LogoutResult result) {
		// 通知 lua，openLogout 完成
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_getglobal(ls, "_cpp_notify_openlogout_callback");
		lua_pushstring(ls, result.exception.c_str());

		lua_call(ls, 1, 0);	// 第一個參數:函數的參數個數，第二個參數:函數返回值個數
	}

	void onOpenAccountBindGameCallback(coresdk::ProfileResult result) {
		// 通知 lua，openLogin 完成
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_getglobal(ls, "_cpp_notify_openaccountbindgame_callback");
		lua_pushboolean(ls, result.isSuccess);
		lua_pushstring(ls, result.exception.c_str());
		lua_pushstring(ls, result.data.result.c_str());
		lua_pushnumber(ls, result.data.server_time);
		lua_pushstring(ls, result.data.user_info.account.c_str());
		lua_pushstring(ls, result.data.user_info.account_status.c_str());
		lua_pushstring(ls, result.data.user_info.birthday.c_str());
		lua_pushnumber(ls, result.data.user_info.coins);
		lua_pushstring(ls, result.data.user_info.country.c_str());
		lua_pushnumber(ls, result.data.user_info.free_coins);
		lua_pushnumber(ls, result.data.user_info.gender);
		lua_pushstring(ls, result.data.user_info.hobbies.c_str());
		lua_pushstring(ls, result.data.user_info.nickname.c_str());
		lua_pushstring(ls, result.data.user_info.user_id.c_str());

		lua_call(ls, 14, 0);	// 第一個參數:函數的參數個數，第二個參數:函數返回值個數
	}

	void onPostAccountBindGameCallback(coresdk::ProfileResult result) {
		// 通知 lua，openLogin 完成
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_getglobal(ls, "_cpp_notify_postaccountbindgame_callback");
		lua_pushboolean(ls, result.isSuccess);
		lua_pushstring(ls, result.exception.c_str());
		lua_pushstring(ls, result.data.result.c_str());
		lua_pushnumber(ls, result.data.server_time);
		lua_pushstring(ls, result.data.user_info.account.c_str());
		lua_pushstring(ls, result.data.user_info.account_status.c_str());
		lua_pushstring(ls, result.data.user_info.birthday.c_str());
		lua_pushnumber(ls, result.data.user_info.coins);
		lua_pushstring(ls, result.data.user_info.country.c_str());
		lua_pushnumber(ls, result.data.user_info.free_coins);
		lua_pushnumber(ls, result.data.user_info.gender);
		lua_pushstring(ls, result.data.user_info.hobbies.c_str());
		lua_pushstring(ls, result.data.user_info.nickname.c_str());
		lua_pushstring(ls, result.data.user_info.user_id.c_str());

		lua_call(ls, 14, 0);	// 第一個參數:函數的參數個數，第二個參數:函數返回值個數
	}

	// 此函式用來給 lua 調用
	int lua_ecchigamersdk_initialize(lua_State* ls) {
		ecchigamer::EcchiGamerSDK::initialize(coresdk::Platform::R18,onInitializeCallback);

		return 0; // 返給Lua值數量
	}

	int lua_ecchigamersdk_openlogin(lua_State* ls) {
		ecchigamer::EcchiGamerSDK::openLogin(onOpenLoginCallback);

		return 0; // 返給Lua值數量
	}

	int lua_ecchigamersdk_openlogout(lua_State* ls) {
		ecchigamer::EcchiGamerSDK::openLogout(onOpenLogoutCallback);

		return 0; // 返給Lua值數量
	}

	int lua_ecchigamersdk_openaccountbindgame(lua_State* ls) {
		std::string game_account(lua_tostring(ls, 1));

		ecchigamer::EcchiGamerSDK::openAccountBindGame(game_account, onOpenAccountBindGameCallback);

		return 0; // 返給Lua值數量
	}

	int lua_ecchigamersdk_postaccountbindgame(lua_State* ls) {
		std::string game_account(lua_tostring(ls, 1));

		ecchigamer::EcchiGamerSDK::postAccountBindGame(game_account, onPostAccountBindGameCallback);

		return 0; // 返給Lua值數量
	}

	int lua_ecchigamersdk_openpayment(lua_State* ls) {
		ecchigamer::EcchiGamerSDK::openPayment();

		return 0; // 返給Lua值數量
	}

	int lua_ecchigamersdk_get_login_url(lua_State* ls) {
		std::string login_url = ecchigamer::EcchiGamerSDK::getLoginURL();

		lua_pushstring(ls, login_url.c_str());

		return 1; // 返給Lua值數量
	}

	int lua_ecchigamersdk_get_token(lua_State* ls) {
		std::string token = ecchigamer::EcchiGamerSDK::getToken();

		lua_pushstring(ls, token.c_str());

		return 1; // 返給Lua值數量
	}

	int lua_release_print(lua_State* ls) {
		CCLog(lua_tostring(ls, 1));

		return 0;
	}

	void callinitbyC()
	{
		CCLog("callinitbyC");
		ecchigamer::EcchiGamerSDK::initialize(coresdk::Platform::R18,onInitCCCallback);
	}

	void callLoginbyC()
	{
		CCLog("callLoginbyC");
		ecchigamer::EcchiGamerSDK::openLogin(onOpenLoginCallback_ByC);
	}

	void callLogoutbyC()
	{
		ecchigamer::EcchiGamerSDK::openLogout(onLogoutCallback_ByC);
	}
	
	void callopenPaymentbyC()
	{
		ecchigamer::EcchiGamerSDK::openPayment();
	}

	void callPostAccountBindbyC(std::string gameAccount)
	{
		ecchigamer::EcchiGamerSDK::postAccountBindGame(gameAccount, onPostAccountBindCallback_ByC);
	}

	void register_function() {
		// 將SDK 相關函式註冊至 lua 環境
		lua_State* ls = CCLuaEngine::defaultEngine()->getLuaStack()->getLuaState();
		lua_register(ls, "ecchigamersdk_initialize", lua_ecchigamersdk_initialize);
		lua_register(ls, "ecchigamersdk_get_login_url", lua_ecchigamersdk_get_login_url);
		lua_register(ls, "ecchigamersdk_get_token", lua_ecchigamersdk_get_token);
		lua_register(ls, "ecchigamersdk_openlogin", lua_ecchigamersdk_openlogin);
		lua_register(ls, "ecchigamersdk_openlogout", lua_ecchigamersdk_openlogout);
		lua_register(ls, "ecchigamersdk_openpayment", lua_ecchigamersdk_openpayment);
		lua_register(ls, "ecchigamersdk_openaccountbindgame", lua_ecchigamersdk_openaccountbindgame);
		lua_register(ls, "ecchigamersdk_postaccountbindgame", lua_ecchigamersdk_postaccountbindgame);

		lua_register(ls, "release_print", lua_release_print);
	}
}
