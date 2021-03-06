@echo off
SetLocal EnableExtensions
cd /d "%~dp0"

:: File name of project
set "ProjFile=_HijackThis.vbp"

:: Name of the task to create / run
set "TaskName=Run HJT Project"

echo.
echo ---  Loading HiJackthis Fork Project ...
echo.
echo.

Call :GetOSBitness OSBitness
if "%OSBitness%"=="x32" (set "PF=%ProgramFiles%") else (set "PF=%ProgramFiles(x86)%")

if not exist "%PF%\Microsoft Visual Studio\VB98\vb6.exe" (echo VB6 IDE either not installed or located in unknown folder! & pause >NUL & exit /B)

::XP ?
ver |>NUL find " 5." && (start "" "%PF%\Microsoft Visual Studio\VB98\vb6.exe" "%~dp0%ProjFile%" & exit /b)

call :TaskExist

if defined TaskExist (
  call :RunProject NoCheck
) else (
  if "%~1" neq "Admin" (
    call :GetPrivileges
  ) else (
    tools\RegTLib\REGTLIB.EXE %SystemRoot%\System32\msdatsrc.tlb /admin
    tools\RegTLib\REGTLIB.EXE %SystemRoot%\SysWow64\msdatsrc.tlb /admin
    regsvr32.exe /s MSCOMCTL.OCX
    call :CreateTask
    call :RunProject
  )
)

goto :eof

:CreateTask
  schtasks.exe /create /tn "%TaskName%" /SC ONCE /ST 00:00 /F /RL HIGHEST /tr "\"%PF%\Microsoft Visual Studio\VB98\vb6.exe\" \"%~dp0%ProjFile%\""
exit /b

:RunProject
  if "%~1"=="NoCheck" (
    rem if project already run
    schtasks.exe /query /FO LIST /tn "%TaskName%" | findstr /i /C:"Running" /C:"�믮������" && (
      echo.&echo Project already run !
      pause >NUL
    ) || (
      schtasks.exe /run /tn "%TaskName%" || start "" "%ProjFile%"
    )
  ) else (
    rem Task exists ?
    schtasks.exe /query /FO LIST /tn "%TaskName%" | find /i "%TaskName%" && (
      schtasks.exe /run /tn "%TaskName%"
    ) || (
      start "" "%ProjFile%"
    )
  )
exit /B

:TaskExist
  set "TaskExist="
  schtasks.exe /query /FO LIST | find /i "%TaskName%" && set "TaskExist=1"
exit /B

:GetPrivileges
  net session >NUL 2>NUL || (
    echo.
    echo Administrative privileges required.
    echo.
    mshta "vbscript:CreateObject("Shell.Application").ShellExecute("%~fs0", "Admin", "", "runas", 1) & Close()"
    exit /B 1
  )
exit /B

:GetOSBitness
  :: ��।������ ��⭮�� ��
  set xOS=x64& If "%PROCESSOR_ARCHITECTURE%"=="x86" If Not Defined PROCESSOR_ARCHITEW6432 set xOS=x32
  set "%~1=%xOS%"
Exit /B
