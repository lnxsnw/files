@echo off
setlocal
:: Required for Colored Text Feature. This code goes first! See the colorprint part (found below) for more info.
call :initColorPrint

:: https://ss64.com/nt/delayedexpansion.html
:: Place this after "call :initColorPrint" or the code will break
setlocal enableDelayedExpansion

set version=1.0.0
title Windows Quick Configuration Script v!version! - Starting Up

:: Admin Check. If not admin, try to restart as admin.
:: Source Code: https://forums.mydigitallife.net/threads/74769/
cls
fltmc >nul 2>nul || set _=^"set _ELEV=1^& cd /d """%cd%"""^& "%~f0" %* ^"&&((if "%_ELEV%"=="" (echo Requesting administrator privileges...&((powershell -nop -c start cmd -args '/d/x/s/v:off/r',$env:_ -verb runas >nul 2>nul) || (mshta vbscript:execute^("createobject(""shell.application"").shellexecute(""cmd"",""/d/x/s/v:off/r ""&createobject(""WScript.Shell"").Environment(""PROCESS"")(""_""),,""runas"",1)(window.close)"^) >nul 2>nul))) else (echo This script requires administrator privileges. Yes, the script failed to run as admin automatically.& pause))& exit /b)

:: Exclude this folder from being checked by Windows Defender.
:: Press 0 on the main menu to remove the exclusion path and exit
set script_directory="%~dp0\"
set cleanup_script_directory="%~dp0"
set powershell_script_directory='%~dp0'
powershell -Command Add-MpPreference -ExclusionPath !powershell_script_directory!
echo.
call :colorPrint 06 "See an error above this message? Message me. (Submit an Issue if you found this on GitHub lol)" /n
timeout 3

:: External Script Sources:
:: Insert External Script Here
set variable_script_1_name=
set variable_script_1_folder=
:: Insert External Script Here
set variable_script_2_name=
set variable_script_2_folder=
:: Insert External Script Here
set variable_script_3_name=
set variable_script_3_folder=

:function_mainmenu
    cls
    title Windows Quick Configuration Script v!version!
    call :colorPrint 03 "Windows Quick Configuration Script" &call :colorPrint 07 " v!version!" /n
    echo This script is meant to run other scripts and pre-typed commands for quick configuration in one single file.
    call :colorPrint 08 "Primarily used for freshly installed Windows." /n
    echo.
    call :colorPrint 06 "Do not exit the program by closing this window, ever. " /n
    echo Simply exit by pressing zero when given the option.
    echo.
    call :colorPrint 07 "Press" &call :colorPrint 02 " 1 "  &call :colorPrint 07 "to launch !variable_script_1_name!" /n
    call :colorPrint 07 "Press" &call :colorPrint 02 " 2 "  &call :colorPrint 07 "to launch !variable_script_2_name!" /n
    call :colorPrint 07 "Press" &call :colorPrint 02 " 3 "  &call :colorPrint 07 "to launch !variable_script_3_name!" /n
    echo.
    call :colorPrint 07 "Press" &call :colorPrint 06 " 7 "  &call :colorPrint 07 "to open Command Prompt." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 8 "  &call :colorPrint 07 "to open Quick Toggles." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 9 "  &call :colorPrint 07 "to open One-Off Commands." /n
    echo.
    call :colorPrint 07 "Press" &call :colorPrint 04 " 0 "  &call :colorPrint 07 "to exit." /n
    call :colorPrint 08 "It is recommended to close by pressing 0" /n
    call :colorPrint 08 "to let the script clean itself properly." /n
    echo.

    call :colorPrint 07 "Your Choice: "
    set "errorlevel="
    choice /c 12347890 /n >nul
    if !errorlevel! equ 1 (
        echo 1
        goto function_script_1
    ) else if !errorlevel! equ 2 (
        echo 2
        goto function_script_2
    ) else if !errorlevel! equ 3 (
        echo 3
        goto function_script_3
    ) else if !errorlevel! equ 4 (
        echo 4
        goto function_script_4
    ) else if !errorlevel! equ 5 (
        echo 7
        control
        goto function_mainmenu
    ) else if !errorlevel! equ 6 (
        echo 8
        goto function_toggle_menu
    ) else if !errorlevel! equ 7 (
        echo 9
        goto function_oneoff_menu
    ) else if !errorlevel! equ 8 (
        echo 0
        goto function_exit
    )

:function_script_1
    cls
    call :colorPrint 70 "Running Script: !variable_script_1_name!" /n
    echo.
    call :colorPrint 06 "Do not exit the program by closing this window, ever. " /n
    echo Simply exit by pressing zero when given the option.
    echo.
    echo Script did not launch or did nothing after the countdown below? Message me! (Submit an Issue if you found this on GitHub lol)
    timeout 3
    cls
    call !script_directory!!variable_script_1_folder!!variable_script_1_name!
    goto function_mainmenu

:function_script_2
    cls
    call :colorPrint 70 "Running Script: !variable_script_2_name!" /n
    echo.
    call :colorPrint 06 "Do not exit the program by closing this window, ever. " /n
    echo Simply exit by pressing zero when given the option.
    echo.
    echo Script did not launch or did nothing after the countdown below? Message me! (Submit an Issue if you found this on GitHub lol)
    timeout 3
    cls
    call !script_directory!!variable_script_2_folder!!variable_script_2_name!
    goto function_mainmenu

:function_script_3
    cls
    call :colorPrint 70 "Running Script: !variable_script_3_name!" /n
    echo.
    call :colorPrint 06 "Do not exit the program by closing this window, ever. " /n
    echo Simply exit by pressing zero when given the option.
    echo.
    echo Script did not launch or did nothing after the countdown below? Message me! (Submit an Issue if you found this on GitHub lol)
    timeout 3
    cls
    call !script_directory!!variable_script_3_folder!!variable_script_3_name!
    goto function_mainmenu

:function_toggle_menu
    cls
    title Windows Quick Configuration Script v!version! - Quick Toggles
    call :colorPrint 03 "Windows Quick Configuration Script" &call :colorPrint 07 " v!version!  - Quick Toggles" /n
    echo.
    echo Checking Up Things, Please Wait.
    :: Check Status First ==========================================================
        :: Check for Application Theme Status. 0 is Dark Theme, 1 is Light Theme.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize').AppsUseLightTheme"') do set    "qa-darklighttheme_app_theme=%%i"
            if !qa-darklighttheme_app_theme! equ 0 (
                set "qa-darklighttheme_app_theme=Dark"
            ) else (
                set "qa-darklighttheme_app_theme=Light"
            )
            :: echo Application Theme: !qa-darklighttheme_app_theme!
        :: Check for System Theme Status. 0 is Dark Theme, 1 is Light Theme.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path  'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize').SystemUsesLightTheme"') do set     "qa-darklighttheme_system_theme=%%i"
            if !qa-darklighttheme_system_theme! equ 0 (
                set "qa-darklighttheme_system_theme=Dark"
            ) else (
                set "qa-darklighttheme_system_theme=Light"
            )
            :: echo System Theme: !qa-darklighttheme_system_theme!
        :: Check for BingSearchEnabled Status. 0 is Disabled, 1 is Enabled.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search').BingSearchEnabled"') do set "qa-bingsearch_status=%%i"
            if !qa-bingsearch_status! equ 0 (
                set "qa-bingsearch_status=Disabled"
            ) else (
                set "qa-bingsearch_status=Enabled"
            )
            :: echo Bing Search: !qa-bingsearch_status!
        :: Check for InitialKeyboardIndicators Status. 0 is Disabled, 1 is Enabled.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path 'HKCU:\Control Panel\Keyboard').InitialKeyboardIndicators"') do set "qa-numlockstartup_status=%%i"
            if !qa-numlockstartup_status! equ 2 (
                set "qa-numlockstartup_status=Enabled"
            ) else (
                set "qa-numlockstartup_status=Disabled"
            )
            :: echo Numlock on Startup: !qa-numlockstartup_status!
        :: Check for VerboseStatus Status. 0 is Disabled, 1 is Enabled.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System').VerboseStatus"') do set "qa-verboselogonmessage_status=%%i"
            if !qa-verboselogonmessage_status! equ 0 (
                set "qa-verboselogonmessage_status=Disabled"
            ) else (
                set "qa-verboselogonmessage_status=Enabled"
            )
            :: echo Numlock on Startup: !qa-verboselogonmessage_status!
        :: Check for HideFileExt Status. 0 is Shown, 1 is Hidden.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced').HideFileExt"') do set "qa-fileextensions_status=%%i"
            if !qa-fileextensions_status! equ 0 (
                set "qa-fileextensions_status=Shown"
            ) else (
                set "qa-fileextensions_status=Hidden"
            )
            :: echo File Extensions: !qa-fileextensions_status!
        :: Check for MouseSpeed Status. 0 is Disabled, 1 is Enabled.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path 'HKCU:\Control Panel\Mouse').MouseSpeed"') do set "qa-mouseacceleration_status=%%i"
            if !qa-mouseacceleration_status! equ 0 (
                set "qa-mouseacceleration_status=Disabled"
            ) else (
                set "qa-mouseacceleration_status=Enabled"
            )
            :: echo Mouse Acceleration: !qa-mouseacceleration_status!
        :: Check for Flags Status. 122 is Disabled, anything else is Enabled.
            for /f "delims=" %%i in ('powershell -Command "(Get-ItemProperty -path 'HKCU:\Control Panel\Accessibility\StickyKeys').Flags"') do set "qa-stickykeys_status=%%i"
            if !qa-stickykeys_status! equ 122 (
                set "qa-stickykeys_status=Disabled"
            ) else (
                set "qa-stickykeys_status=Enabled"
            )
            :: echo Sticky Keys: !qa-stickykeys_status!
    :: Display all the stuff =======================================================
    cls
    call :colorPrint 03 "Windows Quick Configuration Script" &call :colorPrint 07 " v!version!  - Quick Toggles" /n
    echo.
    call :colorPrint 70 "[ Current Theme: !qa-darklighttheme_app_theme! Theme ]" /n
    if "!qa-darklighttheme_app_theme!"=="Light" (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 1 "  &call :colorPrint 07 "to switch to Dark Theme." /n
    ) else (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 1 "  &call :colorPrint 07 "to switch to Light Theme." /n
    )

    echo.
    call :colorPrint 70 "[ Bing Search: !qa-bingsearch_status! ]" /n
    if "!qa-bingsearch_status!"=="Enabled" (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 2 "  &call :colorPrint 07 "to Disable Bing Search." /n
    ) else (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 2 "  &call :colorPrint 07 "to Enable Bing Search." /n
    )

    echo.
    call :colorPrint 70 "[ Numlock on Startup: !qa-numlockstartup_status! ]" /n
    if "!qa-numlockstartup_status!"=="Enabled" (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 3 "  &call :colorPrint 07 "to Disable Numlock on Startup." /n
    ) else (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 3 "  &call :colorPrint 07 "to Enable Numlock on Startup." /n
    )

    echo.
    call :colorPrint 70 "[ Verbose Logon Message: !qa-verboselogonmessage_status! ]" /n
    if "!qa-verboselogonmessage_status!"=="Enabled" (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 4 "  &call :colorPrint 07 "to Disable Verbose Logon Message." /n
    ) else (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 4 "  &call :colorPrint 07 "to Enable Verbose Logon Message." /n
    )

    echo.
    call :colorPrint 70 "[ File Extensions: !qa-fileextensions_status! ]" /n
    if "!qa-fileextensions_status!"=="Enabled" (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 5 "  &call :colorPrint 07 "to Show File Extensions." /n
    ) else (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 5 "  &call :colorPrint 07 "to Hide File Extensions." /n
    )

    echo.
    call :colorPrint 70 "[ Mouse Acceleration: !qa-mouseacceleration_status! ]" /n
    if "!qa-mouseacceleration_status!"=="Enabled" (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 6 "  &call :colorPrint 07 "to Disable Mouse Acceleration." /n
    ) else (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 6 "  &call :colorPrint 07 "to Enable Mouse Acceleration." /n
    )

    echo.
    call :colorPrint 70 "[ Sticky Keys: !qa-stickykeys_status! ]" /n
    if "!qa-stickykeys_status!"=="Enabled" (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 7 "  &call :colorPrint 07 "to Disable Sticky Keys." /n
    ) else (
        call :colorPrint 07 "Press" &call :colorPrint 02 " 7 "  &call :colorPrint 07 "to Enable Sticky Keys." /n
    )

    ::echo.
    ::call :colorPrint 70 "[ 8: !qa-8_status! ]" /n
    ::if "!qa-?_status!"=="Enabled" (
    ::    call :colorPrint 07 "Press" &call :colorPrint 02 " 8 "  &call :colorPrint 07 "to Disable 8." /n
    ::) else (
    ::    call :colorPrint 07 "Press" &call :colorPrint 02 " 8 "  &call :colorPrint 07 "to Enable 8." /n
    ::)

    ::echo.
    ::call :colorPrint 70 "[ 9: !qa-9_status! ]" /n
    ::if "!qa-9_status!"=="Enabled" (
    ::    call :colorPrint 07 "Press" &call :colorPrint 02 " 9 "  &call :colorPrint 07 "to Disable 9." /n
    ::) else (
    ::    call :colorPrint 07 "Press" &call :colorPrint 02 " 9 "  &call :colorPrint 07 "to Enable 9." /n
    ::)

    echo.
    call :colorPrint 07 "Press" &call :colorPrint 0C " 0 "  &call :colorPrint 07 "to go back." /n
    echo.
    call :colorPrint 07 "Your Choice: "
    set "errorlevel="
    choice /c 1234567890 /n >nul
    if !errorlevel! equ 1 (
        goto function_toggle_darklighttheme
    ) else if !errorlevel! equ 2 ( 
        goto function_toggle_bingsearch
    ) else if !errorlevel! equ 3 ( 
        goto function_toggle_numlockstartup
    ) else if !errorlevel! equ 4 (
        goto function_toggle_verboselogonmessage
    ) else if !errorlevel! equ 5 (
        goto function_toggle_fileextensions
    ) else if !errorlevel! equ 6 (
        goto function_toggle_mouseacceleration
    ) else if !errorlevel! equ 7 (
        goto function_toggle_stickykeys
    ) else if !errorlevel! equ 8 (
        goto function_toggle_8
    ) else if !errorlevel! equ 9 (
        goto function_toggle_9
    ) else if !errorlevel! equ 10 (
        goto function_mainmenu
    )

:: Quick Toggles STUFF ==================================================================================================================

:function_toggle_darklighttheme
    cls
    if "!qa-darklighttheme_app_theme!"=="Light" (
        call :colorPrint 60 "[Toggle: Dark/Light Theme] Setting to Dark Theme" /n
        reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 0 /f
        reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 0 /f
    ) else (
        call :colorPrint 60 "[Toggle: Dark/Light Theme] Setting to Light Theme" /n
        reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "AppsUseLightTheme" /t REG_DWORD /d 1 /f
        reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v "SystemUsesLightTheme" /t REG_DWORD /d 1 /f
    )
    timeout 3 >nul
    goto function_toggle_menu

:function_toggle_bingsearch
    cls
    if "!qa-bingsearch_status!"=="Enabled" (
        call :colorPrint 60 "[Toggle: Bing Search] Disabling Bing Search" /n
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 0 /f
    ) else (
        call :colorPrint 60 "[Toggle: Bing Search] Enabling Bing Search" /n
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Search" /v "BingSearchEnabled" /t REG_DWORD /d 1 /f
    )
    timeout 3 >nul
    goto function_toggle_menu

:function_toggle_numlockstartup
    cls
    if "!qa-numlockstartup_status!"=="Enabled" (
        call :colorPrint 60 "[Toggle: Numlock on Startup] Disabling Numlock on Startup" /n
        reg add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_DWORD /d 0 /f
    ) else (
        call :colorPrint 60 "[Toggle: Numlock on Startup] Enabling Numlock on Startup" /n
        reg add "HKCU\Control Panel\Keyboard" /v "InitialKeyboardIndicators" /t REG_DWORD /d 2 /f
    )
    timeout 3 >nul
    goto function_toggle_menu

:function_toggle_verboselogonmessage
    cls
    if "!qa-verboselogonmessage_status!"=="Enabled" (
        call :colorPrint 60 "[Toggle: Verbose Logon Message] Disabling Verbose Logon Message" /n
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d 0 /f
    ) else (
        call :colorPrint 60 "[Toggle: Verbose Logon Message] Enabling Verbose Logon Message" /n
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v "VerboseStatus" /t REG_DWORD /d 1 /f
    )
    timeout 3 >nul
    goto function_toggle_menu

:function_toggle_fileextensions
    cls
    if "!qa-fileextensions_status!"=="Enabled" (
        call :colorPrint 60 "[Toggle: File Extensions] Showing File Extensions" /n
        pause
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 0 /f
    ) else (
        call :colorPrint 60 "[Toggle: File Extensions] Hiding File Extensions" /n
        pause
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "HideFileExt" /t REG_DWORD /d 1 /f
    )
    timeout 3 >nul
    goto function_toggle_menu

:function_toggle_mouseacceleration
    cls
    if "!qa-mouseacceleration_status!"=="Enabled" (
        call :colorPrint 60 "[Toggle: Mouse Acceleration] Disabling Mouse Acceleration" /n
        reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_DWORD /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_DWORD /d 0 /f
        reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_DWORD /d 0 /f
    ) else (
        call :colorPrint 60 "[Toggle: Mouse Acceleration] Enabling Mouse Acceleration" /n
        reg add "HKCU\Control Panel\Mouse" /v "MouseSpeed" /t REG_DWORD /d 1 /f
        reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold1" /t REG_DWORD /d 6 /f
        reg add "HKCU\Control Panel\Mouse" /v "MouseThreshold2" /t REG_DWORD /d 10 /f
        
    )
    timeout 3 >nul
    goto function_toggle_menu

:function_toggle_stickykeys
    cls
    if "!qa-stickykeys_status!"=="Enabled" (
        call :colorPrint 60 "[Toggle: Sticky Keys] Disabling Sticky Keys" /n
        reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_DWORD /d 506 /f
        reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v "Flags" /t REG_DWORD /d 122 /f
        reg add "HKCU\Control Panel\Accessibility\ToggleKeys" /v "Flags" /t REG_DWORD /d 58 /f
    ) else (
        call :colorPrint 60 "[Toggle: Mouse Acceleration] Enabling Sticky Keys" /n
        reg add "HKCU\Control Panel\Accessibility\StickyKeys" /v "Flags" /t REG_DWORD /d 510 /f
    )
    timeout 3 >nul
    goto function_toggle_menu

:function_toggle_8
    goto function_toggle_menu
    ::    cls
    ::    if "!qa-8_status!"=="Enabled" (
    ::        call :colorPrint 60 "[Toggle: 8] Disabling 8" /n
    ::        
    ::        ::
    ::    ) else (
    ::        call :colorPrint 60 "[Toggle: 8] Enabling 8" /n
    ::        
    ::        ::
    ::    )
    ::    goto function_toggle_menu

:function_toggle_9
    goto function_toggle_menu
    ::    cls
    ::    if "!qa-9_status!"=="Enabled" (
    ::        call :colorPrint 60 "[Toggle: 9] Disabling 9" /n
    ::        
    ::        ::
    ::    ) else (
    ::        call :colorPrint 60 "[Toggle: 9] Enabling 9" /n
    ::        
    ::        ::
    ::    )
    ::    goto function_toggle_menu

:function_oneoff_menu
    cls
    title Windows Quick Configuration Script v!version! - Quick Toggles
    call :colorPrint 03 "Windows Quick Configuration Script" &call :colorPrint 07 " v!version!  - One-Off Commands" /n
    echo.
    call :colorPrint 4F "Heads Up!" /n
    echo Before proceeding, ensure you know the correct actions to take.
    echo Not all may work, but worth a try.
    echo.
    call :colorPrint 07 "Press" &call :colorPrint 06 " 1 "  &call :colorPrint 07 "to Add and Activate Ultimate Performance Power Plan." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 2 "  &call :colorPrint 07 "to Disable Hibernate." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 3 "  &call :colorPrint 07 "to Enable Hibernate." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 4 "  &call :colorPrint 07 "to Never Sleep on AC Power." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 5 "  &call :colorPrint 07 "to Clear Recent Items and Restart Explorer." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 6 "  &call :colorPrint 07 "to Turn off Weather and News icons in the taskbar." /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 7 "  &call :colorPrint 07 "to Set Wi-Fi and Ethernet Interfaces to use DNS IP of 127.0.0.1" /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 8 "  &call :colorPrint 07 "to Uninstall Windows Web Experience Pack via winget" /n
    call :colorPrint 07 "Press" &call :colorPrint 06 " 9 "  &call :colorPrint 07 "to Remove these Windows Apps: Disney, Solitaire Collection, Twitter, TikTok, Facebook, and Spotify" /n
    echo.
    call :colorPrint 0F "Press" &call :colorPrint 04 " 0 "  &call :colorPrint 07 "to go back." /n
    echo.

    call :colorPrint 07 "Your Choice: "
    set "errorlevel="
    choice /c 1234567890 /n >nul
    if !errorlevel! equ 1 (
        echo 1
        powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
        powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61
        goto function_oneoff_menu
    ) else if !errorlevel! equ 2 (
        echo 2
        powercfg.exe /hibernate off
        goto function_oneoff_menu
    ) else if !errorlevel! equ 3 (
        echo 3
        powercfg.exe /hibernate on
        goto function_oneoff_menu
    ) else if !errorlevel! equ 4 (
        echo 4
        powercfg /Change standby-timeout-ac 0
        goto function_oneoff_menu
    ) else if !errorlevel! equ 5 (
        echo 5
        del /F /Q %APPDATA%\Microsoft\Windows\Recent\*
        del /F /Q %APPDATA%\Microsoft\Windows\Recent\AutomaticDestinations\*
        del /F /Q %APPDATA%\Microsoft\Windows\Recent\CustomDestinations\*
        taskkill /f /im explorer.exe
        start explorer.exe
        goto function_oneoff_menu
    ) else if !errorlevel! equ 6 (
        echo 6
        taskkill /f /im explorer.exe
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Feeds" /v "ShellFeedsTaskbarViewMode" /t REG_DWORD /d 2 /f
        timeout 3 >nul
        start explorer.exe
        goto function_oneoff_menu
    ) else if !errorlevel! equ 7 (
        echo 7
        netsh interface ip set dns name="Wi-Fi" static 127.0.0.1
        netsh interface ip set dns name="Ethernet" static 127.0.0.1
        echo It should say it worked lol
        goto function_oneoff_menu
    ) else if !errorlevel! equ 8 (
        echo 8
        PowerShell -Command "winget uninstall 'windows web experience pack'"
        echo Execute Done. Please Wait...
        timeout 3 >nul
        goto function_oneoff_menu
    ) else if !errorlevel! equ 9 (
        echo 9
        echo.
        echo Removing Disney app...
        PowerShell -Command "Get-AppxPackage *disney* | Remove-AppxPackage"

        echo Removing Microsoft Solitaire Collection app...
        PowerShell -Command "Get-AppxPackage *solitairecollection* | Remove-AppxPackage"

        echo Removing Twitter app...
        PowerShell -Command "Get-AppxPackage *twitter* | Remove-AppxPackage"

        echo Removing TikTok app...
        PowerShell -Command "Get-AppxPackage *tiktok* | Remove-AppxPackage"

        echo Removing Facebook app...
        PowerShell -Command "Get-AppxPackage *facebook* | Remove-AppxPackage"

        echo Removing Spotify app...
        PowerShell -Command "Get-AppxPackage *spotify* | Remove-AppxPackage"
        echo.
        echo Done. Restarting Explorer...
        taskkill /f /im explorer.exe
        timeout 3 >nul
        start explorer.exe
        goto function_oneoff_menu
    ) else if !errorlevel! equ 10 (
        echo 0
        goto function_mainmenu
    )

:function_exit
    cls
    echo Script is Closing!
    powershell -Command Remove-MpPreference -ExclusionPath !powershell_script_directory!
    call :colorPrint 06 "See an error above this message? Message me. (Submit an Issue if you found this on GitHub lol)" /n
    timeout 3
    start cmd.exe /c "cd %tmp% && title Windows Quick Configuration Script - Cleaning Up && echo Cleaning Up, Please Wait. && timeout /t 3 && echo "!cleanup_script_directory!" && rd /s /q !cleanup_script_directory!"
    exit /b

:: Please place this part of the code below to the very bottom! ============================================
:: The Color Print Code. Coloring the texts on the windows terminal.
:: 0: Black   4: Red      8: Gray          C: Light Red
:: 1: Blue    5: Purple   9: Light Blue    D: Light Purple
:: 2: Green   6: Yellow   A: Light Green   E: Light Yellow
:: 3: Aqua    7: White    B: Light Aqua    F: Bright White
:: First character is background. Second character is foreground. To use, use it like this:
:: call :colorPrint 07 "Hello World, You can also" &call :colorPrint 02 " chain it! "&call :colorPrint 08 "(add the n thing to make a newline)" /n
:colorPrint Color  Str  [/n]
setlocal
set "str=%~2"
call :colorPrintVar %1 str %3
exit /b

:colorPrintVar  Color  StrVar  [/n]
if not defined %~2 exit /b
setlocal enableDelayedExpansion
set "str=a%DEL%!%~2:\=a%DEL%\..\%DEL%%DEL%%DEL%!"
set "str=!str:/=a%DEL%/..\%DEL%%DEL%%DEL%!"
set "str=!str:"=\"!"
pushd "%temp%"
findstr /p /A:%1 "." "!str!\..\x" nul
if /i "%~3"=="/n" echo(
exit /b

:initColorPrint
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do set "DEL=%%a"
<nul >"%temp%\x" set /p "=%DEL%%DEL%%DEL%%DEL%%DEL%%DEL%.%DEL%"
exit /b

:cleanupColorPrint
del "%temp%\x"
exit /b
:: Color text in batch script is made by dbenham and jeb. Source Code: https://stackoverflow.com/a/10407642
:: Please place this part of the code above to the very bottom! ============================================