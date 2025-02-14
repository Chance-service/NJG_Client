cd /d %~dp0
xcopy ..\Game\proj.android\libs\armeabi\*.so ..\build\Release-android\armeabi\ /e /y
xcopy ..\Game\proj.android\libs\armeabi-v7a\*.so ..\build\Release-android\armeabi-v7a\ /e /y