cd /d %~dp0
ndk-build -C ../Game/proj.android -B NDK_DEBUG=0 "NDK_MODULE_PATH=./;../../;../../build" "APP_OPTIM=release" "APP_CPPFLAGS=-frtti -DCOCOS2D_DEBUG=0 -fexceptions -O3 -DANDROID"