cd /d %~dp0

call .\Game\proj.android.fullbuild\build_SO.bat

cd /d %~dp0
xcopy .\Game\proj.android.fullbuild\libs\armeabi\*.so ..\Code_Android\sdklibs\GameLib\libs\armeabi\ /e /y
xcopy .\Game\proj.android.fullbuild\libs\armeabi\*.so ..\Code_Android\sdklibs\GameLib2.0\libs\armeabi\ /e /y
xcopy .\Game\proj.android.fullbuild\libs\armeabi\*.so ..\Code_Android\sdklibs\GameLib_novoice\libs\armeabi\ /e /y