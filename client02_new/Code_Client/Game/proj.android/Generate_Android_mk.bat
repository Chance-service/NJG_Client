cd /d %~dp0
xcopy ..\proj.android\jni\GameMain.cpp .\jni\ /y
xcopy ..\proj.android\jni\BulletinBoardPage.cpp .\jni\ /y
xcopy ..\proj.android\jni\ScreenShotJni.cpp .\jni\ /y
xcopy .\jni\Android.mk .\jni\bak\ /y
echo cd ..\Game\proj.android\
python Gensrc.py jni/gen ./jni ../Platform ../Classes ../Protobuf

xcopy .\jni\gen\Android.mk .\jni\Android.mk /y

pause