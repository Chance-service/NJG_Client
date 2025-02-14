cd /d %~dp0
rmdir /s /q ..\ResourcesEncryptionExport
mkdir ..\ResourcesEncryptionExport
utility\Utility.exe -VE ../Resources ../none ../ResourcesEncryptionExport update.php
pause