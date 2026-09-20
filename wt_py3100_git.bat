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

@REM Создаем временную папку
if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%"
)
mkdir "%TEMP_DIR%"

@REM Получаем даныне о последнем релизе терминала
<nul set /p "=[1/8] Getting latest release . . ."
curl -fsSL "https://api.github.com/repos/%REPO%/releases/latest" -o "%TEMP_DIR%\release.json"
if errorlevel 1 (
    echo.
    echo ERROR: Failed to get GitHub release information.
    pause
)
echo  Done

@REM Получаем ссылку на msixbundle файл
<nul set /p "=[2/8] Finding MSIX bundle . . ."
for /f "delims=" %%A in ('powershell.exe -NoProfile -Command "$json = Get-Content -Raw '%TEMP_DIR%\release.json' | ConvertFrom-Json; $json.assets | Where-Object { $_.name -like 'Microsoft.WindowsTerminal_*.msixbundle' } | Select-Object -First 1 -ExpandProperty browser_download_url"') do (set "DOWNLOAD_URL=%%A")
if not defined DOWNLOAD_URL (
    echo.
    echo ERROR: Windows Terminal MSIX bundle was not found.
    pause
)

for /f "delims=" %%A in ('powershell.exe -NoProfile -Command "$json = Get-Content -Raw '%TEMP_DIR%\release.json' | ConvertFrom-Json; $json.assets | Where-Object { $_.name -like 'Microsoft.WindowsTerminal_*.msixbundle' } | Select-Object -First 1 -ExpandProperty name"') do (set "FILE_NAME=%%A")
echo  Done

echo.
echo FILE:   "!FILE_NAME!"
echo URL:    "!DOWNLOAD_URL!"
echo GITHUB: "!GITHUB_URL!"
echo TEMP:   "!TEMP_DIR!"
echo.

@REM Скачиваем msixbundle файл во временную папку
<nul set /p "=[3/8] Downloading Windows Terminal . . ."
curl -fLs "!DOWNLOAD_URL!" -o "%TEMP_DIR%\!FILE_NAME!"
if errorlevel 1 (
    echo.
    echo ERROR: Download failed.
    pause
)
echo  Done

@REM Устанавливаем терминал
<nul set /p "=[4/8] Installing Windows Terminal . . ."
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -Path '%TEMP_DIR%\!FILE_NAME!'"
if errorlevel 1 (
    echo.
    echo ERROR: Installation failed.
    echo The installer may require additional dependencies.
    pause
)
echo  Done

@REM Python 3.10
<nul set /p "=[5/8] Downloading Python 3.10.0 . . ."
set "PYTHON_URL=https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
set "PYTHON_INSTALLER=%TEMP_DIR%\python-3.10.0-amd64.exe"

@REM Скачиваем python
curl.exe -fLs "%PYTHON_URL%" -o "%PYTHON_INSTALLER%"
if errorlevel 1 (
    echo.
    echo ERROR: Python download failed.
    pause
)
echo  Done

@REM Устанавливаем python
<nul set /p "=[6/8] Installing Python 3.10.0 . . ."
"%PYTHON_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1 Include_test=0
if errorlevel 1 (
    echo.
    echo ERROR: Python installation failed.
    pause
)
echo  Done

@REM GIT
<nul set /p "=[7/8] Downloading Git . . ."
set "GIT_URL=https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe"
set "GIT_INSTALLER=%TEMP_DIR%\Git-64-bit.exe"

@REM Скачиваем GIT
curl.exe -fLs "%GIT_URL%" -o "%GIT_INSTALLER%"
if errorlevel 1 (
    echo.
    echo ERROR: Git download failed.
    pause
)
echo  Done

@REM Устнавливаем GIT
<nul set /p "=[8/8] Installing Git . . ."
"%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /SP-
if errorlevel 1 (
    echo.
    echo ERROR: Git installation failed.
    pause
)
echo  Done

@REM Удаляем временную папку
rmdir /s /q "%TEMP_DIR%"

echo.
pause
