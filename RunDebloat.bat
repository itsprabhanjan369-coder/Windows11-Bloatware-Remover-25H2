@echo off
cd /d "%~dp0"

:: Check if the script exists in the current directory
if not exist "Bloatware_Remover.ps1" (
    echo Error: Bloatware_Remover.ps1 not found in this folder!
    pause
    exit /b
)

:: Check for administrator privileges
net session >nul 2>&1
if %errorLevel% == 0 (
    goto :run_script
) else (
    goto :elevate
)

:elevate
echo Requesting administrator privileges...
powershell -Command "Start-Process cmd -ArgumentList '/c ^\"%~f0^\"' -Verb RunAs"
exit /b

:run_script
echo Running Bloatware_Remover.ps1 as Administrator...
powershell -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0Bloatware_Remover.ps1'"
pause
