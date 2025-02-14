cd /d %~dp0
rd /s /q .\obj
rd /s /q .\libs
C:\DevToolChain\android-ndk-r10e\ndk-build -C ./ clean NDK_DEBUG=0 "NDK_MODULE_PATH=../../;../../../Code_Core;../../../Code_Core/cocos2dx/platform/third_party/android/prebuilt" "APP_OPTIM=release" "APP_CPPFLAGS=-frtti -DCOCOS2D_DEBUG=0 -fexceptions -DANDROID -O3"

pause