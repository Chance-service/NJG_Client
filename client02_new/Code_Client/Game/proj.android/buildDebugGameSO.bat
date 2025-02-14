echo sh build_native.sh all
cd /d %~dp0
D:\DevToolChain\android-ndk-r8e\ndk-build -j 4 -C ./ -B NDK_DEBUG=1 "NDK_MODULE_PATH=../../;../../../Code_Core;../../../Code_Core/cocos2dx/platform/third_party/android/prebuilt" "APP_OPTIM=debug" "APP_CPPFLAGS=-frtti -DCOCOS2D_DEBUG=1 -fexceptions -DANDROID -D_DEBUG -Wno-error=format-security"

pause