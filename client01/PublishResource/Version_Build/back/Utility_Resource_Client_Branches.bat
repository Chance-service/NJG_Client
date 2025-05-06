set /p inVersionPath=input Version:

utility\Utility.exe -VE ../%inVersionPath%/Resource_Client/Resource ../none Resource_Encrypt update.php
pause