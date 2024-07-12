@echo off
setlocal

:: This file is for development purposes. We are not responsible if it does not work.
set "destination_folder=splits"

if "%1" == "size" (
    dir /s /-c "%destination_folder%"
    exit /b 0
)

if "%1" == "clear" (
    if exist "%destination_folder%" (
        del /q "%destination_folder%\*"
        echo Splits cleared!!!
    ) else (
        echo The folder %destination_folder% does not exist.
    )
    exit /b 0
)

if "%1" == "i-latest" (
    if exist "%destination_folder%" (
        if exist "%destination_folder%" (
            for /f "delims=" %%a in ('dir /b /o-d /a-d "%destination_folder%\*"') do (
                set "latest_file=%destination_folder%\%%a"
                goto :install
            )
            echo No files found in %destination_folder%.
        ) else (
            echo The folder %destination_folder% does not exist.
        )
    ) else (
        echo The folder %destination_folder% does not exist.
    )
    exit /b 0
)

flutter build apk --split-per-abi --no-tree-shake-icons
set "source_file=build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk"
set "current_date=%date:~7,2% %date:~3,3%"

if not exist "%destination_folder%" (
    mkdir "%destination_folder%"
)

set "counter=0"
:check_file
if exist "%destination_folder%\%filename%" (
    if %counter% equ 0 (
        set "filename=eBroker %current_date%.apk"
    ) else (
        set "filename=eBroker %current_date% (%counter%).apk"
    )
    set /a counter+=1
    goto :check_file
)
echo done!! %destination_folder%\%filename%

copy "%source_file%" "%destination_folder%\%filename%"

:install
choice /m "Do you wish to install this app?"
if errorlevel 2 exit /b
adb -s "%2" install "%destination_folder%\%filename%"
