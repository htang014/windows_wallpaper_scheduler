@ECHO OFF

:: Run wallpaper scheduler initialization via powershell
CALL :NORMALIZEPATH "%0\..\powershell_scripts\init.ps1"
SET PS_INIT_PATH=%RETVAL%
powershell -ExecutionPolicy ByPass -File %PS_INIT_PATH%

:: Set absolute powershell script paths
CALL :NORMALIZEPATH "%0\..\powershell_scripts\refresh_wallpaper.ps1"
SET PS_WP_REFRESH_PATH=%RETVAL%

CALL :NORMALIZEPATH "%0\..\powershell_scripts\refresh_dawn_dusk_times.ps1"
SET PS_DD_REFRESH_PATH=%RETVAL%

:: Add wallpaper refresh task (on logon)
SET TASK_NAME="WallpaperRefresh_LOGON_%USERNAME%"
SchTasks /Create /RU %USERNAME% /IT /SC ONLOGON /TN %TASK_NAME% /TR "powershell -ExecutionPolicy ByPass -WindowStyle hidden -File \"%PS_WP_REFRESH_PATH%\""

:: Prompt the user to specify the wallpaper refresh interval
:try_again
SET /P "INTERVAL=Enter desired delay (in minutes) between wallpaper refreshes: "
ECHO %INTERVAL%|findstr /r "[^0-9]" && (
    ECHO Enter a number
    GOTO :try_again
)
::clears the leading zeroes.
cmd /c exit /b %INTERVAL%
SET /a month=%errorlevel%
IF %INTERVAL% gtr 1439  (
   ECHO Enter a number between 1 and 1439
   GOTO :try_again
)

IF %INTERVAL% lss 1 (
   ECHO Enter a number between 1 and 1439
   GOTO :try_again
)

:: Add wallpaper refresh task (periodically)
SET TASK_NAME="WallpaperRefesh_Period_%USERNAME%"
SchTasks /Create /RU %USERNAME% /IT /SC MINUTE /MO %INTERVAL% /TN %TASK_NAME% /TR "powershell -ExecutionPolicy ByPass -WindowStyle hidden -File \"%PS_WP_REFRESH_PATH%\"" /ST 09:00

:: Add dawn dusk time refresh task (on logon)
SET TASK_NAME="WallpaperRefreshDawnDusk_LOGON_%USERNAME%"
SchTasks /Create /RU %USERNAME% /IT /SC ONLOGON /TN %TASK_NAME% /TR "powershell -ExecutionPolicy ByPass -WindowStyle hidden -File \"%PS_DD_REFRESH_PATH%\""


ECHO.
ECHO Installation complete.
ECHO.
ECHO You can now populate the subfolders 'dawn', 'day', 'dusk' and 'night'
ECHO in your chosen wallpaper directory with .jpg images.
ECHO.
ECHO.
SET /p FOO="Press any key to continue..."


:: ========== FUNCTIONS ==========
EXIT /B

:NORMALIZEPATH
  SET RETVAL=%~dpfn1
  EXIT /B