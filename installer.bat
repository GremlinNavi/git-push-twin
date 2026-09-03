@echo off
setlocal EnableExtensions

set "TWIN_ARCHITECTURE_ROOT=%~dp0"
set "TWIN_TARGET=%~1"
if "%TWIN_TARGET%"=="" set "TWIN_TARGET=%CD%"

echo OSWAP Twin Transport Git remote installer
echo Target checkout: %TWIN_TARGET%
echo.

powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TWIN_ARCHITECTURE_ROOT%tools\Configure-TwinGitRemote.ps1" -RepositoryPath "%TWIN_TARGET%"
set "TWIN_EXIT=%ERRORLEVEL%"
if not "%TWIN_EXIT%"=="0" (
    echo.
    echo Twin setup did not complete. No network or remote repository change was made.
    echo Run this installer from the approved application checkout, or pass that checkout path as its first argument.
    exit /b %TWIN_EXIT%
)

echo.
echo Twin setup completed. Check both hosts first, then publish only when intended:
echo     git push twin --dry-run
echo     git push twin
exit /b 0
