LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := cocos_lua_static

LOCAL_MODULE_FILENAME := liblua

LOCAL_SRC_FILES := ../cocos2dx_support/CCLuaBridge.cpp \
          ../cocos2dx_support/CCLuaEngine.cpp \
          ../cocos2dx_support/CCLuaStack.cpp \
          ../cocos2dx_support/CCLuaValue.cpp \
          ../cocos2dx_support/Cocos2dxLuaLoader.cpp \
          ../cocos2dx_support/LuaCocos2d.cpp \
          ../tolua/tolua_event.c \
          ../tolua/tolua_is.c \
          ../tolua/tolua_map.c \
          ../tolua/tolua_push.c \
          ../tolua/tolua_to.c \
          ../cocos2dx_support/tolua_fix.c \
		   ../cocos2dx_support/lua_extensions.c \
		  ../lua/auxiliar.c \
		  ../lua/luasocket_buffer.c \
		  ../lua/except.c \
		  ../lua/inet.c \
		  ../lua/luasocket_io.c \
		  ../lua/luasocket.c \
		  ../lua/mime.c \
		  ../lua/options.c \
		  ../lua/select.c \
		  ../lua/serial.c \
		  ../lua/socket_scripts.c \
		  ../lua/tcp.c \
		  ../lua/timeout.c \
		  ../lua/udp.c \
		  ../lua/unix.c \
		  ../lua/usocket.c
          
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../luajit/include \
                           $(LOCAL_PATH)/../tolua \
                           $(LOCAL_PATH)/../cocos2dx_support 
          
          

		  
LOCAL_C_INCLUDES := $(LOCAL_PATH)/ \
					$(LOCAL_PATH)/../luajit/include \
					$(LOCAL_PATH)/../tolua \
					$(LOCAL_PATH)/../cocos2dx_support \
                    $(LOCAL_PATH)/../../../cocos2dx \
					$(LOCAL_PATH)/../../../extensions \
					$(LOCAL_PATH)/../../../extensions/RichControls \
                    $(LOCAL_PATH)/../../../cocos2dx/include \
                    $(LOCAL_PATH)/../../../cocos2dx/platform \
                    $(LOCAL_PATH)/../../../cocos2dx/platform/android \
                    $(LOCAL_PATH)/../../../cocos2dx/kazmath/include \
                    $(LOCAL_PATH)/../../../CocosDenshion/include

LOCAL_WHOLE_STATIC_LIBRARIES := luajit_static

LOCAL_CFLAGS += -Wno-psabi
LOCAL_EXPORT_CFLAGS += -Wno-psabi

include $(BUILD_STATIC_LIBRARY)

$(call import-module,scripting/lua/luajit)
