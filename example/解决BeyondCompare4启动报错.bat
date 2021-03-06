@echo off

echo 解决 BeyondCompare 4 的启动报错，提示信息：
echo.
echo ——————————————————————————————————————————
echo — 错误：                                                                         —
echo — 这个授权密钥已被吊销：1822-9597 要了解更多细节，联系 sales@scootersoftware.com —
echo ——————————————————————————————————————————
echo.
echo 需要将 BCState.xml 文件中 CheckID 的值，与 BCSessions.xml 文件中 Flags 的值，设为一致
echo.

for /f "usebackq tokens=3,*" %%i ^
in (`reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders" /v "AppData"`) ^
do set "appdata_roaming_dir=%%i"
echo AppData Roaming 路径：%appdata_roaming_dir%

set "bc_session_file=%appdata_roaming_dir%\Scooter Software\Beyond Compare 4\BCSessions.xml"
echo 读取文件：%bc_session_file%

for /f usebackq^ tokens^=1^,2^,*^ delims^=^" %%i in ("%bc_session_file%") do (
    REM echo %%i
    REM echo %%j
    REM echo %%k
    if "%%i"=="<BCSessions Flags=" (
        set "bc_Flags=%%j"
        echo Flags: %%j
    )
)
if "%bc_Flags%"=="" (
    echo.
    echo Flags 的值为空，无需修改
    echo.
    goto :final
)

set "bc_state_file=%appdata_roaming_dir%\Scooter Software\Beyond Compare 4\BCState.xml"
echo 读取文件：%bc_state_file%

for /f usebackq^ tokens^=1^,2^,*^ delims^=^" %%i in ("%bc_state_file%") do (
    REM echo %%i
    REM echo %%j
    REM echo %%k
    for /f "tokens=*" %%i in ("%%i") do (
        REM echo %%i
        if "%%i"=="<CheckID Value=" (
            set "bc_CheckID=%%j"
            echo CheckID: %%j
        )
    )
)
if "%bc_CheckID%"=="" (
    echo.
    echo CheckID 的值为空，无需修改
    echo.
    goto :final
)

echo.
if "%bc_Flags%" neq "%bc_CheckID%" (
    echo 修改设置 CheckID 为：%bc_Flags%
    echo "%bc_state_file%.bak"
    type nul>"%bc_state_file%.bak"
    for /f "usebackq tokens=* delims=" %%i in ("%bc_state_file%") do (
        REM echo %%i
        set "line_saved=%%i"
        set "line=%%i"
        setlocal enabledelayedexpansion
        if "!line!" neq "" (
            call set "line=!line:%bc_CheckID%=%bc_Flags%!"
            REM echo !line!
            if "!line!" neq "!line_saved!" (
                REM echo !line_saved!
                echo "!line_saved!" | findstr "^!" 1>nul 2>nul
                if !errorlevel! neq 0 (
                    echo !line!
                )
            )
        )
        echo !line!>>"%bc_state_file%.bak"
        endlocal
    )
    copy /Y "%bc_state_file%.bak" "%bc_state_file%"
) else (
    echo CheckID 与 Flags 的值相等，无需修改
)
echo.

:final
pause
exit