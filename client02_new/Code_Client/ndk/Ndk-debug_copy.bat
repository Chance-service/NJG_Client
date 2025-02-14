cd /d %~dp0
xcopy ..\Game\proj.android\libs\armeabi\*.so ..\build\Debug-android\armeabi\ /e /y
xcopy ..\Game\proj.android\libs\armeabi-v7a\*.so ..\build\Debug-android\armeabi-v7a\ /e /y