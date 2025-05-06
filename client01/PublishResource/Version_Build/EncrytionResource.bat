cd /d %~dp0
rmdir /s /q ..\hotUpdate\assets
mkdir ..\hotUpdate\assets
utility\Utility.exe -VE ../Resources ../none ../hotUpdate/assets update.php
pause