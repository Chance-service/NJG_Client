LOCAL_PATH := $(call my-dir)

MY_LOCAL_PATH:=$(LOCAL_PATH)

include $(LOCAL_PATH)/prebuild/Android.mk
LOCAL_PATH := ${MY_LOCAL_PATH}

include $(CLEAR_VARS)

LOCAL_MODULE    := Game

LOCAL_CPP_EXTENSION := .cc .cpp

STLPORT_FORCE_REBUILD := true

LOCAL_SRC_FILES += BulletinBoardPage.cpp
LOCAL_SRC_FILES += GameMain.cpp
LOCAL_SRC_FILES += ScreenShotJni.cpp
LOCAL_SRC_FILES += ../../Classes/AboutPage.cpp
LOCAL_SRC_FILES += ../../Classes/ActiveCodePage.cpp
LOCAL_SRC_FILES += ../../Classes/AdjustManager.cpp
LOCAL_SRC_FILES += ../../Classes/AnimMgr.cpp
LOCAL_SRC_FILES += ../../Classes/AnnouncementNewPage.cpp
LOCAL_SRC_FILES += ../../Classes/AnnouncementPage.cpp
LOCAL_SRC_FILES += ../../Classes/AnnouncePage.cpp
LOCAL_SRC_FILES += ../../Classes/AppDelegate.cpp
LOCAL_SRC_FILES += ../../Classes/ArmatureContainer.cpp
LOCAL_SRC_FILES += ../../Classes/AsyncSprite.cpp
LOCAL_SRC_FILES += ../../Classes/BasePage.cpp
LOCAL_SRC_FILES += ../../Classes/BCWebRequest.cpp
LOCAL_SRC_FILES += ../../Classes/BlackBoard.cpp
LOCAL_SRC_FILES += ../../Classes/BlurSprite.cpp
LOCAL_SRC_FILES += ../../Classes/BulletinManager.cpp
LOCAL_SRC_FILES += ../../Classes/buyingCheck.cpp
LOCAL_SRC_FILES += ../../Classes/CCBContainer.cpp
LOCAL_SRC_FILES += ../../Classes/CCBLuaContainer.cpp
LOCAL_SRC_FILES += ../../Classes/CCBManager.cpp
LOCAL_SRC_FILES += ../../Classes/CCBScriptContainer.cpp
LOCAL_SRC_FILES += ../../Classes/CCRichLabelTTF.cpp
LOCAL_SRC_FILES += ../../Classes/CCTagedRichTTF.cpp
LOCAL_SRC_FILES += ../../Classes/CDKeyMsgPage.cpp
LOCAL_SRC_FILES += ../../Classes/ChangeUserPage.cpp
LOCAL_SRC_FILES += ../../Classes/CharacterConsts.cpp
LOCAL_SRC_FILES += ../../Classes/ConfirmPage.cpp
LOCAL_SRC_FILES += ../../Classes/CoverSprite.cpp
LOCAL_SRC_FILES += ../../Classes/CParticleFlow.cpp
LOCAL_SRC_FILES += ../../Classes/CShiftToAction.cpp
LOCAL_SRC_FILES += ../../Classes/CurlDownloadForScript.cpp
LOCAL_SRC_FILES += ../../Classes/DataTableManager.cpp
LOCAL_SRC_FILES += ../../Classes/DeviceCfgMgr.cpp
LOCAL_SRC_FILES += ../../Classes/FeedBackPage.cpp
LOCAL_SRC_FILES += ../../Classes/fpconv.c
LOCAL_SRC_FILES += ../../Classes/GameConsts.cpp
LOCAL_SRC_FILES += ../../Classes/Gamelua.cpp
LOCAL_SRC_FILES += ../../Classes/GameMessages.cpp
LOCAL_SRC_FILES += ../../Classes/GameNotification.cpp
LOCAL_SRC_FILES += ../../Classes/GamePacketManager.cpp
LOCAL_SRC_FILES += ../../Classes/GamePackets.cpp
LOCAL_SRC_FILES += ../../Classes/GamePlatformInfo.cpp
LOCAL_SRC_FILES += ../../Classes/GamePrecedure.cpp
LOCAL_SRC_FILES += ../../Classes/GraySprite.cpp
LOCAL_SRC_FILES += ../../Classes/H365API.cpp
LOCAL_SRC_FILES += ../../Classes/HttpImg.cpp
LOCAL_SRC_FILES += ../../Classes/LangSettingPage.cpp
LOCAL_SRC_FILES += ../../Classes/LibPlatformForScript.cpp
LOCAL_SRC_FILES += ../../Classes/LightSweepSprite.cpp
LOCAL_SRC_FILES += ../../Classes/LoadingAniPage.cpp
LOCAL_SRC_FILES += ../../Classes/LoadingFrame.cpp
LOCAL_SRC_FILES += ../../Classes/LoginBCPage.cpp
LOCAL_SRC_FILES += ../../Classes/LoginPacket.cpp
LOCAL_SRC_FILES += ../../Classes/LoginUserPage.cpp
LOCAL_SRC_FILES += ../../Classes/LogoFrame.cpp
LOCAL_SRC_FILES += ../../Classes/LogReport.cpp
LOCAL_SRC_FILES += ../../Classes/lua_cjson.c
LOCAL_SRC_FILES += ../../Classes/Lua_EcchiGamerSDKBridge.cpp
LOCAL_SRC_FILES += ../../Classes/Lua_HttpsBridge.cpp
LOCAL_SRC_FILES += ../../Classes/MainFrame.cpp
LOCAL_SRC_FILES += ../../Classes/MessageBoxPage.cpp
LOCAL_SRC_FILES += ../../Classes/MessageHintPage.cpp
LOCAL_SRC_FILES += ../../Classes/MessageManager.cpp
LOCAL_SRC_FILES += ../../Classes/NoticeBox.cpp
LOCAL_SRC_FILES += ../../Classes/NumberChangeAction.cpp
LOCAL_SRC_FILES += ../../Classes/PackageLogic.cpp
LOCAL_SRC_FILES += ../../Classes/pb.cpp
LOCAL_SRC_FILES += ../../Classes/Popup1stPayTipPage.cpp
LOCAL_SRC_FILES += ../../Classes/RadialBlurSprite.cpp
LOCAL_SRC_FILES += ../../Classes/ResManager.cpp
LOCAL_SRC_FILES += ../../Classes/RestrictedWord.cpp
LOCAL_SRC_FILES += ../../Classes/ScriptContentBase.cpp
LOCAL_SRC_FILES += ../../Classes/ScriptMathToLua.cpp
LOCAL_SRC_FILES += ../../Classes/ServerDateManager.cpp
LOCAL_SRC_FILES += ../../Classes/SoundManager.cpp
LOCAL_SRC_FILES += ../../Classes/SpineContainer.cpp
LOCAL_SRC_FILES += ../../Classes/SpriteShader.cpp
LOCAL_SRC_FILES += ../../Classes/strbuf.c
LOCAL_SRC_FILES += ../../Classes/StrokeSample.cpp
LOCAL_SRC_FILES += ../../Classes/StrokeSprite.cpp
LOCAL_SRC_FILES += ../../Classes/TapDB.cpp
LOCAL_SRC_FILES += ../../Classes/TestHTMLPopup.cpp
LOCAL_SRC_FILES += ../../Classes/TimeCalculator.cpp
LOCAL_SRC_FILES += ../../Classes/UpateVersion.cpp
LOCAL_SRC_FILES += ../../Classes/waitingManager.cpp
LOCAL_SRC_FILES += ../../Classes/WebRequest.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/Adjust2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustAdRevenue2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustAppStorePurchase2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustAppStoreSubscription2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustAttribution2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustConfig2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustDeeplink2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustEvent2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustEventFailure2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustEventSuccess2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustPlayStorePurchase2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustPlayStoreSubscription2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustProxy2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustPurchaseVerificationResult2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustSessionFailure2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustSessionSuccess2dx.cpp
LOCAL_SRC_FILES += ../../Classes/Adjust/AdjustThirdPartySharing2dx.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/APIUtil.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/ConfigLoader.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/Coresdk.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/DeepLink.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/DeepLinkAndroidBridge.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/DeepLinkIosBridge.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/DeepLinkWin32Bridge.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/util.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/webapi.cpp
LOCAL_SRC_FILES += ../../Classes/coresdk/WebRequest.cpp
LOCAL_SRC_FILES += ../../Protobuf/Attribute.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Const.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Consume.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Equip.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/HP.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Item.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Login.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Player.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Reward.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Skill.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/Status.pb.cc
LOCAL_SRC_FILES += ../../Protobuf/SysProtocol.pb.cc
#mark1

$(info "这里可以使用Eclipse C/C++ Build的Environment环境变量")
$(info "ProjDirPath: " $(PWD))
$(info "LOCAL_PATH: " $(LOCAL_PATH))


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../Classes/Fight
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../Classes/Config
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../Platform
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../Protobuf
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../include/CocosDenshion
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../com4lovesSDK/com4lovesSDK
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../LibOS/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../Lib91/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../include/extensions
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../include/cocos2dx/platform
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../tinyxml
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../../Code_Core/protobuf-2.5.0rc1/src
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../../Code_Core/jsoncpp-src-0.5.0/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../../Code_Core/core/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../../Code_Core/core/src
#LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../../../Code_Core/external/bugly




LOCAL_WHOLE_STATIC_LIBRARIES := core
LOCAL_WHOLE_STATIC_LIBRARIES += cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static
LOCAL_WHOLE_STATIC_LIBRARIES += protobuf_static
LOCAL_WHOLE_STATIC_LIBRARIES += jsoncpp_static
LOCAL_WHOLE_STATIC_LIBRARIES += tinyxml_static
LOCAL_WHOLE_STATIC_LIBRARIES += OS_static
LOCAL_WHOLE_STATIC_LIBRARIES += lp91_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_lua_static
#LOCAL_WHOLE_STATIC_LIBRARIES += bugly_crashreport_cocos_static
#LOCAL_WHOLE_STATIC_LIBRARIES += bugly_agent_cocos_static_lua

#与Game.so无关，不需要
#LOCAL_SHARED_LIBRARIES := udid

#这个不能用，早期arm7硬件不保险支持
#LOCAL_ARM_NEON := true

#默认是thumb16位指令，设arm mode意思编译为32位指令
#LOCAL_ARM_MODE := arm

LOCAL_CFLAGS += -DANDROID
LOCAL_CPPFLAGS += -DANDROID
LOCAL_CPPFLAGS += -std=gnu++0x

include $(BUILD_SHARED_LIBRARY)

$(call import-module,core/proj.android)
$(call import-module,cocos2dx)
$(call import-module,CocosDenshion/android)
$(call import-module,extensions)
$(call import-module,protobuf-2.5.0rc1/proj.android)
$(call import-module,jsoncpp-src-0.5.0/makefiles)
#$(call import-module,tinyxml/proj.android)
$(call import-module,libOS/android)
$(call import-module,91Lib/android)
$(call import-module,scripting/lua/proj.android)
#$(call import-module,external/bugly)
#$(call import-module,external/bugly/lua)







