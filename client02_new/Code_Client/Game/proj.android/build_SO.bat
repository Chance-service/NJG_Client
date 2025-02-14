cd /d %~dp0

call .\Ndk-clean.bat
call .\Generate_Android_mk.bat
call .\buildReleaseGameSO.bat
call .\copy_to_javabuild.bat

pause