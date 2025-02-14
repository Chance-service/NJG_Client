cd /d %~dp0

call .\Ndk-clean64.bat
call .\Generate_Android_mk.bat
call .\buildReleaseGameSO64.bat

pause