@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

set "REPO=microsoft/terminal"
set "TEMP_DIR=%TEMP%\windows-terminal-install"
set "GITHUB_URL=https://github.com/%REPO%/releases"

echo.
echo ================================================================================
echo   Autoinstall Windows Terminal + Python 3.10.0 + Git
echo ================================================================================
echo.

echo.
pause
