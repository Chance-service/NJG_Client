
@echo off

set curdir=%~dp0

set protoFilePath = "%curdir%proto"
set protocExepath="..\protoExe\protoc.exe"

cd proto

@echo protocol java file generator...
@echo off

for /f "delims=" %%i in ('dir /s/a-d /b *.proto') do (
	echo %%i
	%protocExepath% --java_out=..\java  %%~ni.proto
)
@pause
@echo done!