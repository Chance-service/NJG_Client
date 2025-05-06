cd /d %~dp0
rmdir /s /q ..\fixHotUpdate\assets
mkdir ..\fixHotUpdate\assets
utility\Utility.exe -VE ../FixResources ../none ../hotUpdate/assets update.php
pause