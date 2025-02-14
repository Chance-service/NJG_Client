cd /d %~dp0
rmdir /s /q ..\FixResourcesEncryptionExport
mkdir ..\FixResourcesEncryptionExport
utility\Utility.exe -VE ../FixResources ../none ../FixResourcesEncryptionExport update.php
pause