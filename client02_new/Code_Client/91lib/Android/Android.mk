LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE := lp91_static

LOCAL_MODULE_FILENAME := liblp91

LOCAL_SRC_FILES := libAndroid.cpp \
../include/libPlatform.cpp \
LastLoginHelp.cpp \
libPlatformHelpJni.cpp \
libVoiceChat.cpp

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/../include

LOCAL_C_INCLUDES := $(LOCAL_PATH)/../include
LOCAL_C_INCLUDES += $(LOCAL_PATH)
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../include/cocos2dx
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../include/cocos2dx/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../include/cocos2dx/kazmath/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../include/cocos2dx/platform/android
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../include/core
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../libOS/include
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../com4lovesSDK/com4lovesSDK
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../../include/jsoncpp

include $(BUILD_STATIC_LIBRARY)
