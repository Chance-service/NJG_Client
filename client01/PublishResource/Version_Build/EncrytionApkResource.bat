cd /d %~dp0
rmdir /s /q ..\ResourcesApkEncryptionExport
mkdir ..\ResourcesApkEncryptionExport
utility\Utility.exe -VE ../ResourcesApk ../none ../ResourcesApkEncryptionExport update.php
pause