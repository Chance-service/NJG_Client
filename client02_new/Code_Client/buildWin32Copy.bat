@echo off

echo./*
echo. * Check VC++ environment...
echo. */
echo.



if defined VS100COMNTOOLS set VSTOOLS="%VS100COMNTOOLS%"
if defined VS100COMNTOOLS set VC_VER=100

set VSTOOLS=%VSTOOLS:"=%
set "VSTOOLS=%VSTOOLS:\=/%"

echo -----VSTOOLS---------------------
echo %VSTOOLS%

set VSVARS="%VSTOOLS%vsvars32.bat"

if not defined VSVARS  echo Can't find VC2010 installed!
if not defined VSVARS  goto ERROR

echo./*
echo. * Building cocos2d-x library binary, please wait a while...
echo. */
echo.

call %VSVARS%
devenv "%~dp0/gjwow-core-win32.vc2010.sln" /ReBuild "Debug|Win32" /Project Game

:ERROR


:EOF