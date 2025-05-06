cd /d %~dp0
rmdir /s /q Resource_Encrypt
mkdir Resource_Encrypt
utility\Utility.exe -VE ../Resource_Client none Resource_Encrypt update.php preupdate.php 2.140.0
