@echo off
chcp 65001 >nul 2>&1

echo Skills install script (junction links)
echo.

set "SOURCE_DIR=%~dp0"

rem ===== Target: uncomment more lines to enable =====
call :install_to "%USERPROFILE%\.claude\skills"
rem call :install_to "%USERPROFILE%\.codex\skills"

echo.
echo Done. Skill updates will sync automatically.
pause
exit /b

:install_to
set "target=%~1"
echo === Target: %target% ===

if not exist "%target%" (
    mkdir "%target%"
    echo   Created: %target%
)

for /d %%D in ("%SOURCE_DIR%*") do (
    set "skill_name=%%~nxD"
    call :process_skill "%target%" "%%D" "%%~nxD"
)
echo.
exit /b

:process_skill
set "target=%~1"
set "source=%~2"
set "name=%~3"

rem Skip excluded dirs
if "%name%"==".git" exit /b
if "%name%"==".claude" exit /b
if "%name%"==".github" exit /b
if "%name%"=="bmad" exit /b

set "link=%target%\%name%"

if exist "%link%" (
    echo   SKIP %name% (already exists^)
    exit /b
)

mklink /J "%link%" "%source%" >nul 2>&1
if exist "%link%" (
    echo   OK   %name%
) else (
    echo   FAIL %name%
)
exit /b
