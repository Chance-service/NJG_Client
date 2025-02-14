
if "%1" == "" (set /p apk=apk:) else (set apk=%1)

set year=%date:~0,4%
set month=%date:~5,2%
set day=%date:~8,2%

set hour=%time:~0,2%
set minute=%time:~3,2%

set timeEx=%year%_%month%_%day%_%hour%_%minute%
set apkName=..\..\ApkOut\Game%timeEx%.apk

::copy /Y .\%projectdir%\bin\Gjwow-release.apk %apkName%

copy /Y .\%apk% %apkName%

echo %apkName%

pause