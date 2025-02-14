xcopy obj\local\armeabi\*.a ..\..\build\Release-android\armeabi\ /e /y
xcopy obj\local\armeabi-v7a\*.a ..\..\build\Release-android\armeabi-v7a\ /e /y
xcopy libs\armeabi\*.so ..\..\build\Release-android\armeabi\ /e /y
xcopy libs\armeabi-v7a\*.so ..\..\build\Release-android\armeabi-v7a\ /e /y
xcopy libs\armeabi\*.so ..\proj.android\libs\armeabi\ /e /y
xcopy libs\armeabi-v7a\*.so ..\proj.android\libs\armeabi-v7a\ /e /y

pause