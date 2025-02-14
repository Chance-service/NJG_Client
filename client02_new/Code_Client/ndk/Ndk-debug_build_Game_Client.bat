cd /d %~dp0
ndk-build -C ../Game/proj.android -B NDK_DEBUG=1 "NDK_MODULE_PATH=./;../../;../../build" "APP_OPTIM=debug" "APP_CPPFLAGS=-frtti -DCOCOS2D_DEBUG=1 -fexceptions -DANDROID -D_DEBUG"