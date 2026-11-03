@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Launch.ps1" -Action Check
set "RC=%ERRORLEVEL%"
echo.
if not "%RC%"=="0" echo Failed with error code %RC%.
pause
exit /b %RC%
