cd /d %~dp0
rmdir /s /q ..\ServerEncryptionExport
mkdir ..\ServerEncryptionExport
utility\Utility.exe -VE ../ServerTxt ../none ../ServerEncryptionExport update.php
pause