@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"
set "WORK=%TEMP%\focus_offline"
set "FIX_BLOCKLIST="
for /f %%a in ('copy /Z "%~f0" nul') do set "CR=%%a"
for /f %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

set "ELEVATED_FLAG="
set "PASS_ARGS="
:parse
if "%~1"=="" goto after_parse
if /i "%~1"=="--uac" set "ELEVATED_FLAG=1" & shift & goto parse
if /i "%~1"=="--b" set "FIX_BLOCKLIST=1" & set "PASS_ARGS=!PASS_ARGS! --b" & shift & goto parse
if /i "%~1"=="--r" goto do_clean
shift
goto parse

:after_parse
fltmc >nul 2>&1 && goto admin_ok
net session >nul 2>&1 && goto admin_ok
whoami /groups 2>nul | findstr /c:"S-1-16-12288" >nul 2>&1 && goto admin_ok
if defined ELEVATED_FLAG goto fail
where powershell >nul 2>&1
if not errorlevel 1 (
    set "SELF=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList ('/c \"\"' + $env:SELF + '\" --uac' + $env:PASS_ARGS + '\"') -Verb RunAs" >nul 2>&1
    exit /b
)
echo Set sh = CreateObject("Shell.Application") > "%TEMP%\focus-uac.vbs"
echo sh.ShellExecute "cmd.exe", "/c %~f0 --uac!PASS_ARGS!", "", "runas", 1 >> "%TEMP%\focus-uac.vbs"
cscript //nologo "%TEMP%\focus-uac.vbs" >nul 2>&1
del /f /q "%TEMP%\focus-uac.vbs" >nul 2>&1
exit /b

:admin_ok
title SoSi Launcher
pushd "%ROOT%"
if errorlevel 1 goto fail

call :need "%ROOT%\chhbayvm6f.exe"
call :need "%ROOT%\jpqsqat8a6.sys"
call :need "%ROOT%\z223qn5e3j.bin"
call :need "%ROOT%\core_8134_72294906.dll"
call :need "%ROOT%\robrun_menu.dll"
call :need "%ROOT%\focus.exe"
if defined MISSING goto fail

if not defined FIX_BLOCKLIST goto blocklist_check
reg add "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable /t REG_DWORD /d 0 /f >nul 2>&1
if errorlevel 1 echo     blocklist: reg write failed
echo     reboot, then run again
goto hold

:blocklist_check
reg query "HKLM\SYSTEM\CurrentControlSet\Control\CI\Config" /v VulnerableDriverBlocklistEnable 2>nul | findstr /i "0x0" >nul
if errorlevel 1 echo     [!] VulnerableDriverBlocklist is ON (use --b if driver fails)

taskkill /f /im focus.exe >nul 2>&1
taskkill /f /im chhbayvm6f.exe >nul 2>&1
if exist "%WORK%" rmdir /s /q "%WORK%" >nul 2>&1
mkdir "%WORK%" >nul 2>&1 || goto fail
copy /y "%ROOT%\chhbayvm6f.exe" "%WORK%\chhbayvm6f.exe" >nul || goto fail
copy /y "%ROOT%\jpqsqat8a6.sys" "%WORK%\jpqsqat8a6.sys" >nul || goto fail
copy /y "%ROOT%\z223qn5e3j.bin" "%WORK%\z223qn5e3j.bin" >nul || goto fail
copy /y "%ROOT%\core_8134_72294906.dll" "%WORK%\core_8134_72294906.dll" >nul || goto fail
copy /y "%ROOT%\robrun_menu.dll" "%WORK%\robrun_menu.dll" >nul || goto fail
copy /y "%ROOT%\focus.exe" "%WORK%\focus.exe" >nul || goto fail
if exist "%ROOT%\assets" robocopy "%ROOT%\assets" "%WORK%\assets" /E /NFL /NDL /NJH /NJS /nc /ns /np >nul
if exist "%TEMP%\focus.key" del /f /q "%TEMP%\focus.key" >nul 2>&1

set "CHOICE=%LOCALAPPDATA%\robrun\visit.txt"
set "VISIT=0"
if exist "%CHOICE%" goto saved_choice
call :banner
echo     Хотите ли вы посетить страницы авторов?
echo     [Y] да    [N] нет
call :ask_yn
if "!errorlevel!"=="1" set "VISIT=1"
echo.
echo     Сохранить выбор на будущее?
echo     [Y] да    [N] нет
call :ask_yn
if "!errorlevel!"=="1" goto save_choice
goto fresh_screen

:save_choice
if not exist "%LOCALAPPDATA%\robrun" mkdir "%LOCALAPPDATA%\robrun"
if "!VISIT!"=="1" (echo yes>"%CHOICE%") else (echo no>"%CHOICE%")
goto fresh_screen

:saved_choice
set "SAVED="
set /p SAVED=<"%CHOICE%"
if /i "!SAVED!"=="yes" set "VISIT=1"

:fresh_screen
cls
call :banner
if not "!VISIT!"=="1" goto pages_done
start "" "https://yougame.biz/cash/"
start "" "https://yougame.biz/work/"
start "" "https://t.me/fakeanul"

:pages_done
start "" /b /d "%WORK%" cmd /c "chhbayvm6f.exe jpqsqat8a6.sys z223qn5e3j.bin >mapper.log 2>&1"

set "tick=0"
:wait
if exist "%TEMP%\focus.key" goto ready
set /a tick+=1
if !tick! GTR 16 set /a tick=1
set "fill="
for /l %%i in (1,1,!tick!) do set "fill=!fill!$"
set "show=!fill!................"
set "show=!show:~0,16!"
<nul set /p "=!ESC![92m    preparing  !show!    !ESC![0m!CR!"
timeout /t 1 /nobreak >nul
if exist "%TEMP%\focus.key" goto ready
tasklist /fi "imagename eq chhbayvm6f.exe" 2>nul | find /i "chhbayvm6f.exe" >nul
if errorlevel 1 (
    if exist "%TEMP%\focus.key" goto ready
    echo.
    if exist "%WORK%\mapper.log" type "%WORK%\mapper.log"
    goto fail
)
goto wait

:ready
set "DRVKEY="
set /p DRVKEY=<"%TEMP%\focus.key"
set "DRVKEY=!DRVKEY: =!"
if not defined DRVKEY goto fail
if /i not "!DRVKEY:~0,2!"=="0x" set "DRVKEY=0x!DRVKEY!"

echo.
echo !ESC![92m    ready      $$$$$$$$$$$$$$$$
echo.
echo !ESC![33m    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
echo !ESC![93m    $                                                               $
echo !ESC![93m    $   Поддержать проект                                           $
echo !ESC![93m    $   Для скорейшего выпуска новых кряков                         $
echo !ESC![93m    $                                                               $
echo !ESC![93m    $   TRtMKz8R4dzetkCkTZVkZdsE6zdYKrBkRr                          $
echo !ESC![93m    $   USDT    TRC20    TRON                                       $
echo !ESC![93m    $                                                               $
echo !ESC![33m    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
echo !ESC![0m

echo {"product":"robrun","token":"offline-local-context"}>"%WORK%\ctx.json"
"%WORK%\focus.exe" --offline !DRVKEY! < "%WORK%\ctx.json" > "%WORK%\focus.log" 2>&1
goto hold

:banner
echo.
echo !ESC![93m    $$$  $  $       $$$  $$$ $  $ $  $  $$$      $    $$$   $$  $  $ 
echo !ESC![93m    $  $  $$       $    $  $ $  $ $$ $ $  $      $    $    $  $ $ $  
echo !ESC![93m    $$$    $       $ $$ $  $ $  $ $ $$ $  $      $    $$$  $$$$ $$   
echo !ESC![93m    $  $   $       $  $ $  $  $$  $  $ $  $      $    $    $  $ $ $  
echo !ESC![93m    $$$    $        $$$  $$$  $$  $  $  $$$      $$$  $$$  $  $ $  $ 
echo.
echo !ESC![33m    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
echo !ESC![93m    $                         by govno leak                         $
echo !ESC![33m    $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
echo.
echo !ESC![0m
exit /b 0

:ask_yn
where powershell >nul 2>&1
if errorlevel 1 (
    choice /c YN /n >nul
    if errorlevel 2 (echo     нет & exit /b 0)
    echo     да
    exit /b 1
)
powershell -NoProfile -Command "while($true){$k=[Console]::ReadKey($true);if($k.Key -eq 'Y' -or $k.KeyChar -eq [char]0x0414 -or $k.KeyChar -eq [char]0x0434){exit 1};if($k.Key -eq 'N' -or $k.KeyChar -eq [char]0x0422 -or $k.KeyChar -eq [char]0x0442){exit 0}}"
if "!errorlevel!"=="1" (echo     да & exit /b 1)
echo     нет
exit /b 0

:need
if exist "%~1" exit /b 0
echo     missing: %~1
set "MISSING=1"
exit /b 1

:do_clean
if exist "%WORK%" rmdir /s /q "%WORK%" >nul 2>&1
if exist "%TEMP%\focus.key" del /f /q "%TEMP%\focus.key" >nul 2>&1
exit /b 0

:fail
echo.
echo !ESC![91m    failed!ESC![0m
goto hold

:hold
ping -n 86400 127.0.0.1 >nul
goto hold
