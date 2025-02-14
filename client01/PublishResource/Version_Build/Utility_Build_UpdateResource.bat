cd /d %~dp0

if "%1" == "" (echo need pass version param)
rmdir /s /q ..\Resource_Update
mkdir ..\Resource_Update
utility\Utility.exe -VE ..\Resource_Client ..\Pre_Resource_Client ..\Resource_Update update.php ..\Pre_Resource_Update\update.php %1
pause
