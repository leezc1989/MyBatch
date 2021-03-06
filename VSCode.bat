@echo off

for /f usebackq^ tokens^=1^,2^,*^ delims^=^" %%i ^
in (`reg query "HKCR\Applications\Code.exe\shell\open\command" /ve`) ^
do set "vscode_exe=%%j"
if "%vscode_exe%" neq "" goto :start

for /f usebackq^ tokens^=1^,2^,*^ delims^=^" %%i ^
in (`reg query "HKCU\Software\Classes\VSCodeSourceFile\shell\open\command" /ve`) ^
do set "vscode_exe=%%j"
if "%vscode_exe%" neq "" goto :start

pause & exit

:start - 启动 Visual Studio Code
echo Visual Studio Code 程序路径："%vscode_exe%"
echo Visual Studio Code 启动参数："%vscode_exe%" "%cd%"
start "" "%vscode_exe%" "%cd%"

:: pause
exit