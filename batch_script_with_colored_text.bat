@echo off
setlocal
:: Required for Colored Text Feature. This code goes first! See the colorprint part (found below) for more info.
call :initColorPrint

:: https://ss64.com/nt/delayedexpansion.html
:: Place this after "call :initColorPrint" or the code will break
setlocal enableDelayedExpansion


:: Insert Your Code Here :)
:: btw, for unknown reasons, using colorprint and displaying a ! will not show that exclamation point.

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