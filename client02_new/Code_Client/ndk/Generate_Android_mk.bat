cd /d %~dp0
xcopy ..\Game\proj.android\jni\Android.mk ..\Game\proj.android\jni\bak\ /y
cd ..\Game\proj.android\
python Gensrc.py jni/gen ./jni ../Platform ../Classes ../Protobuf
cd ..\..\ndk\
xcopy ..\Game\proj.android\jni\gen\Android.mk ..\Game\proj.android\jni\Android.mk /y
pause