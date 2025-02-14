
@echo off

set curdir=%~dp0

set protoFilePath = "%curdir%proto"
set protocExepath="..\protoExe\protoc.exe"

cls
:input
set input=:
set /p input= Input proto file : 
if "%input%"==":" goto input
if not exist "%input%" goto input
set "input=%input:"=%"

echo %input%


set file=%input%

cd proto

@echo protocol file generator...
@echo off

for /f "delims="  %%i in ("%file%") do (
   echo %%~ni.proto
   %protocExepath% --lua_out=..\lua --plugin=protoc-gen-lua="..\..\plugin\protoc-gen-lua.bat" %%~ni.proto
   echo %%~ni.lua
)
cd ..
@pause

start buildproto_luaSingle.bat