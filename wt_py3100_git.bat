@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion

:: cls && curl -sL https://raw.githubusercontent.com/OxFF00FF/wt-autoinstall-windows10/main/wt_py3100_git.bat -o "%TEMP%\wt_install.bat" && call "%TEMP%\wt_install.bat" && del "%TEMP%\wt_install.bat"

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
