echo sh build_native.sh all
cd /d %~dp0

C:\DevToolChain\android-ndk-r11c\ndk-build -j 4 -C ./ -B NDK_DEBUG=0 "NDK_MODULE_PATH=../../;../../../Code_Core;../../../Code_Core/cocos2dx/platform/third_party/android/prebuilt" "APP_OPTIM=release" "APP_CPPFLAGS=-frtti -DCOCOS2D_DEBUG=0 -fexceptions -O3 -DANDROID -Wno-error=format-security"

pause