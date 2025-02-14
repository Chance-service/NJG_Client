cd /d %~dp0

call .\Ndk-debug_clean.bat
call .\Generate_Android_mk.bat
call .\buildDebugGameSO.bat
call .\copy_to_javabuild.bat

pause