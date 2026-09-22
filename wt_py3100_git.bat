@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "REPO=microsoft/terminal"
set "TEMP_DIR=%TEMP%\windows-terminal-install"
set "GITHUB_URL=https://github.com/%REPO%/releases"

echo.
echo ================================================================================
echo   Autoinstall Windows Terminal + Python 3.10.0 + Git
echo ================================================================================
echo.

@REM Create temp dir
if exist "%TEMP_DIR%" (
    rmdir /s /q "%TEMP_DIR%"
)
mkdir "%TEMP_DIR%"

@REM Getting latest wt release data
<nul set /p "=[1/11] Getting latest release . . ."
curl -fsSL "https://api.github.com/repos/%REPO%/releases/latest" -o "%TEMP_DIR%\release.json"
if errorlevel 1 (
    echo.
    echo ERROR: Failed to get GitHub release information.
    pause
)
echo  Done

@REM Getting link for msixbundle file
<nul set /p "=[2/11] Finding MSIX bundle . . ."
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

@REM Find Microsoft.UI.Xaml dependency
<nul set /p "=[3/11] Finding Microsoft.UI.Xaml dependency . . ."
for /f "delims=" %%A in ('powershell.exe -NoProfile -Command "$json = Get-Content -Raw ''%TEMP_DIR%\release.json'' | ConvertFrom-Json; $json.assets | Where-Object { $_.name -match ''Microsoft\.UI\.Xaml.*\.appx$'' -and $_.name -match ''x64'' } | Select-Object -First 1 -ExpandProperty browser_download_url"') do (set "XAML_URL=%%A")
if not defined XAML_URL (
    echo.
    echo ERROR: Microsoft.UI.Xaml dependency was not found.
    pause
)

for /f "delims=" %%A in ('powershell.exe -NoProfile -Command "$json = Get-Content -Raw ''%TEMP_DIR%\release.json'' | ConvertFrom-Json; $json.assets | Where-Object { $_.name -match ''Microsoft\.UI\.Xaml.*\.appx$'' -and $_.name -match ''x64'' } | Select-Object -First 1 -ExpandProperty name"') do (set "XAML_FILE=%%A")

echo.
echo XAML FILE: "!XAML_FILE!"
echo XAML URL:  "!XAML_URL!"
echo.

@REM Download Microsoft.UI.Xaml
<nul set /p "=[4/11] Downloading Microsoft.UI.Xaml . . ."
curl.exe -fLs "!XAML_URL!" -o "%TEMP_DIR%\!XAML_FILE!"
if errorlevel 1 (
    echo.
    echo ERROR: Microsoft.UI.Xaml download failed.
    pause
)
echo  Done

@REM Install Microsoft.UI.Xaml
<nul set /p "=[5/11] Installing Microsoft.UI.Xaml . . ."
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -Path '%TEMP_DIR%\!XAML_FILE!'"
if errorlevel 1 (
    echo.
    echo ERROR: Microsoft.UI.Xaml installation failed.
    pause
)
echo  Done

@REM Download msixbundle in temp dir
<nul set /p "=[6/11] Downloading Windows Terminal . . ."
curl -fLs "!DOWNLOAD_URL!" -o "%TEMP_DIR%\!FILE_NAME!"
if errorlevel 1 (
    echo.
    echo ERROR: WT Download failed.
    pause
)
echo  Done

@REM Install terminal
<nul set /p "=[7/11] Installing Windows Terminal . . ."
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "Add-AppxPackage -Path '%TEMP_DIR%\!FILE_NAME!'"
if errorlevel 1 (
    echo.
    echo ERROR: WT Installation failed.
    pause
)
echo  Done

@REM Python 3.10
<nul set /p "=[8/11] Downloading Python 3.10.0 . . ."
set "PYTHON_URL=https://www.python.org/ftp/python/3.10.0/python-3.10.0-amd64.exe"
set "PYTHON_INSTALLER=%TEMP_DIR%\python-3.10.0-amd64.exe"

@REM Download python
curl.exe -fLs "%PYTHON_URL%" -o "%PYTHON_INSTALLER%"
if errorlevel 1 (
    echo.
    echo ERROR: Python download failed.
    pause
)
echo  Done

@REM Install python
<nul set /p "=[9/11] Installing Python 3.10.0 . . ."
"%PYTHON_INSTALLER%" /quiet InstallAllUsers=1 PrependPath=1 Include_pip=1 Include_test=0
if errorlevel 1 (
    echo.
    echo ERROR: Python installation failed.
    pause
)
echo  Done

@REM GIT
<nul set /p "=[10/11] Downloading Git 2.56.0 . . ."
set "GIT_URL=https://github.com/git-for-windows/git/releases/download/v2.56.0-rc1.windows.1/Git-2.56.0-rc1-64-bit.exe"
set "GIT_INSTALLER=%TEMP_DIR%\Git.exe"

@REM Download GIT
curl.exe -fLs "%GIT_URL%" -o "%GIT_INSTALLER%"
if errorlevel 1 (
    echo.
    echo ERROR: Git download failed.
    pause
)
echo  Done

@REM Install GIT
<nul set /p "=[11/11] Installing Git 2.56.0 . . ."
"%GIT_INSTALLER%" /VERYSILENT /NORESTART /NOCANCEL /SP-
if errorlevel 1 (
    echo.
    echo ERROR: Git installation failed.
    pause
)
echo  Done

@REM Remove temp dir
rmdir /s /q "%TEMP_DIR%"
if exist "%TEMP%\wt_install.bat" (
    del "%TEMP%\wt_install.bat"
)

echo.
pause
