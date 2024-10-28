@echo off
setlocal enabledelayedexpansion
set version=v2

title MediaSort !version!
echo MediaSort !version! by @lnxsnw
echo.
echo This script organizes your media files into the following structure:
echo /CAMERA_MODEL/YYYY/MM/DD
echo.
echo For example:
echo /ILCE-6700/2014/08/05/DSC1485.jpg
echo.
echo For @lnxsnw's use, he uses an additional "CAMERA_OWNER" folder before the "CAMERA_MODEL" folder. Like:
echo /@lnxsnw/ILCE-6700/2014/08/05/DSC1485.jpg
echo.
echo Although the "CAMERA_OWNER" folder won't be added by this script,
echo Please ensure that you run the script from within the "CAMERA_OWNER" folder (or whatever folder it is in).
echo.
echo.
powershell Write-Host "IMPORTANT: Place your media files alongside this script!" -ForegroundColor White -BackgroundColor DarkRed
echo.
echo The script will process all media files next to it and moves them into their respective "CAMERA_MODEL" folders first.
echo.
echo However, some files may lack a "CAMERA_MODEL" tag, like video files. Those will be placed in a folder named "Unknown".
echo.
echo You will need to manually sort/move the files inside of it to their appropriate "CAMERA_MODEL" folder
echo AND delete the folder named "Unknown" before proceeding.
echo.
echo Afterwards, the script will organize the files from their "CAMERA_MODEL" folders into their /YYYY/MM/DD folders.
echo.
echo.
pause

cls

REM The ExifTool Dependency Check =========================================================================================================
title MediaSort !version! - ExifTool Dependency Check
set "executable_name=exiftool"
where "%executable_name%" > nul
if %errorlevel% equ 0 (
    echo %executable_name% Present
) else (
    title MediaSort - ExifTool is Missing!
    echo.
    powershell Write-Host "Looks like ExifTool is missing on your device." -ForegroundColor White -BackgroundColor DarkYellow
    echo This script uses ExifTool to do the sorting process. It's free and open source too.
    echo.
    echo Download ExifTool here: https://exiftool.org/
    echo or an easier way here: https://oliverbetz.de/pages/Artikel/ExifTool-for-Windows
    echo.
    echo Should you be using the easier way, 
    echo select the "ExifTool_install_##.##_64.exe" one. The hashtags could be any number.
    echo.
    echo After installing, run this script once again.
    echo No need to change anything for ExifTool.
    echo.
    pause
    exit /b
)

cls

REM Stage 1 of 2: Sort files to their "CAMERA_MODEL" folders ==============================================================================
title MediaSort !version! - Stage 1 of 2 is Starting
echo Stage 1 of 2: Sort files to their "CAMERA_MODEL" folders
echo.

REM Set the destination folder name
REM By default (.), it places it within the directory itself
set "destination=."

REM Create the destination folder if it doesn't exist
if not exist "%destination%" mkdir "%destination%"

REM Count the total number of files in the current directory (excluding the script)
set "total_file_count=0"
for %%F in (*) do (
    if /I not "%%F"=="%~nx0" set /a "total_file_count+=1"
)

REM Initialize variables for counting and displaying progress
set "current_file_count=0"
set "current_percentage=0"

REM Begin sorting prompt
echo There are %total_file_count% files present, excluding this script.
echo Begin Stage 1? (Enter Y to continue, any other to exit.)
set /p "choice="
if /i "%choice%" neq "Y" exit /b

cls

echo Stage 1 of 2: Sort files to their "CAMERA_MODEL" folders. Total File Count: %total_file_count%
echo.

REM Loop through each file in the current directory
for %%A in (*) do (
    REM Skip checking the script itself
    if /I "%%A" neq "%~nx0" (
        REM Check if the file has "Camera Model" EXIF metadata
        for /F "tokens=*" %%M in ('exiftool -s -s -s -Model "%%A" 2^>nul') do (
            set "camera_model=%%M"
        )

        REM If the "Camera Model" metadata exists, move the file to the corresponding folder
        if defined camera_model (
            set "destination_folder=%destination%\!camera_model!"
        ) else (
            REM If the "Camera Model" metadata is missing, move the file to the "Unknown" folder
            set "destination_folder=%destination%\Unknown"
        )

        REM Create the destination folder if it doesn't exist
        if not exist "!destination_folder!" mkdir "!destination_folder!"

        REM Update progress and display the current percentage
        set /a "current_file_count+=1"
        set /a "current_percentage=(current_file_count * 100) / total_file_count"
        echo Stage 1 - File !current_file_count! of !total_file_count!: "%%A" ^===^> "!destination_folder!"
        REM Move the file to the destination folder
        move "%%A" "!destination_folder!\"

        REM Update Title Bar
        title MediaSort !version! - Stage 1 of 2: File !current_file_count! of !total_file_count! Sorted. !current_percentage!%% Done.
    )

    REM Sanitize Variables
    set "camera_model="
)

echo.
title MediaSort !version! - Stage 1 Complete. All !total_file_count! has been sorted.
echo Stage 1 Complete. All !total_file_count! has been sorted.
echo.
echo Review Changes before proceediing. You can CTRL+A and CTRL+C to copy all the contents of this window to your clipboard.
echo This will be cleared when you are ready for Stage 2.
echo.
echo Begin Stage 2? (Enter Y to continue, any other to exit.)
set /p "choice="
if /i "%choice%" neq "Y" exit /b

cls

REM Stage 2 of 2 Pre-Check: "Unknown" Folder Presence Check ===============================================================================
title MediaSort !version! - Stage 2 of 2 Pre-Check: "Unknown" Folder Presence Check.
echo Stage 2 of 2 Pre-Check: "Unknown" Folder Presence Check.
echo.

if exist ".\Unknown" (
    powershell Write-Host "Hey There" -ForegroundColor White -BackgroundColor DarkYellow
    echo The "Unknown" folder is still there.
    echo Please move all the files inside the Unknown folder to their respective "CAMERA_MODEL" folders.
    echo and DELETE the "Unknown" folder.
    echo.
    echo Ignore this warning if you want to treat the "Unknown" folder like a "CAMERA_MODEL" folder.
    pause
)

cls

if exist ".\Unknown" (
    powershell Write-Host "ARE YOU SURE?" -ForegroundColor White -BackgroundColor DarkYellow
    echo The "Unknown" folder is still there. Again.
    echo Please move all the files inside the Unknown folder to their respective "CAMERA_MODEL" folders.
    echo and DELETE the "Unknown" folder.
    echo.
    echo This will be the last safety message.
    echo.
    echo Ignore this warning if you want to treat the "Unknown" folder like a "CAMERA_MODEL" folder.
    pause
)

cls

REM Stage 2 of 2: Sort files to their /YYYY/MM/DD folders =================================================================================
title MediaSort !version! - Stage 2 of 2 is Starting
echo Stage 2 of 2: Sort files to their /YYYY/MM/DD folders.
echo.

cls
REM Stage 2: Sort files within each folder based on "DATE TAKEN" exif

REM Count the total number of folders to process (excluding the script folder)
set "total_folder_count=0"
for /d %%F in (*) do (
    if /I not "%%F"=="%~nx0" set /a "total_folder_count+=1"
)

REM Initialize variables for counting and displaying progress
set "current_folder_count=0"
set "current_percentage=0"
set "files_left=!total_file_count!"
set "method="

REM Loop through each folder in the current directory
for /d %%A in (*) do (
    REM Skip checking the script folder itself
    if /I "%%A" neq "%~nx0" (
        REM Increment current folder count
        set /a "current_folder_count+=1"

        REM Initialize variables for counting files within the folder
        set "current_file_count=0"

        REM Count the total number of files in the current folder
        for %%F in ("%%A\*") do (
            set /a "current_file_count+=1"
        )

        echo Stage 2 of 2: Now sorting files in "%%A" Folder. This is Folder !current_folder_count! of !total_folder_count!. !current_percentage!%% Done.
        echo.

        REM Initialize variables for displaying progress within the folder
        set "current_file_index=0"
        set "current_file_percentage=0"

        REM Loop through each file in the current folder
        for %%F in ("%%A\*") do (
            REM Increment current file index and calculate the current file percentage
            set /a "current_file_index+=1"
            set /a "current_file_percentage=(current_file_index * 100) / current_file_count"
            set "filename=%%~nxF"
            REM Check if filename is more than 14 characters
            if "!filename:~14!" neq "" (
                REM Get the total character length in the "filename" variable.
                REM Since batch does not have a native counter and will not be using "goto" functions, this is a way.
                REM This works by counting each successful removed character or maxed out to 32.
                REM No filename is longer than 32 lol (including the extension)
                set "filename_trimmed=!filename!"

                set "length=0"
                for /l %%i in (1, 1, 32) do (
                    if defined filename_trimmed (
                        REM Remove one character from the filename variable and increment the count
                        set "filename_trimmed=!filename_trimmed:~0,-1!"
                        set /A "length+=1"
                    )
                )

                REM Loop through the filename characters
                set "anchor="
                set "found=0"
                rem Loop through the filename characters
                for /l %%i in (0, 1, !length!) do (
                    set "char=!filename:~%%i,1!"
                    if "!char!"=="2" (
                        if "!found!"=="0" (
                            set "found=1"
                            set "anchor=%%i"
                        ) else (
                            set /a "length-=1"
                        )
                    )
                )

                REM Incase finding the number 2 failed.
                REM Usually, this part of the IF statement detects files named like "IMAGE_20140805_112233.jpeg".
                REM Anything other than the YYYYMMDD format, this entire method might fail or malfunction.
                REM And yes, YYYYMMDD format is expected here. Not any other variations like YYYY-MM-DD, etc.
                if not defined anchor (
                    echo Number 2 not found in the filename.
                    pause
                    exit /b
                )

                REM Set the "year" variable
                set /a "start_position=anchor"
                call set "year=%%filename:~!start_position!,4%%"

                REM Set the "month" variable
                set /a "start_position=anchor+4"
                call set "month=%%filename:~!start_position!,2%%"

                REM Set the "day" variable
                set /a "start_position=anchor+6"
                call set "day=%%filename:~!start_position!,2%%"

                set method=FileName

            ) else (
                REM Add a comment saying "Less than 14 here"
                for /f "delims=" %%D in ('exiftool -s -s -s -"DateTimeOriginal" "%%F" 2^>nul') do (
                    set "date_taken=%%D"
                    set method=DateTimeOriginal
                )

                if not defined date_taken (
                    for /f "delims=" %%D in ('exiftool -s -s -s -"EncodingTime" "%%F" 2^>nul') do (
                        set "date_taken=%%D"
                        set method=EncodingTime
                    )
                )

                if not defined date_taken (
                    for /f "delims=" %%D in ('exiftool -s -s -s -"CreateDate" "%%F" 2^>nul') do (
                        set "date_taken=%%D"
                        set method=CreateDate
                    )
                )

                REM Incase Detecting the date by Filename/DateTimeOriginal/EncodingTime/CreateDate does not work
                if not defined date_taken (
                    echo.
                    echo It appears that "%%F" is not a media file. Can you confirm it?
                    echo.
                    pause
                    echo.
                    echo What date is "%%F" taken? Reply with the format YYYY-MM-DD
                    set /p "date_taken="
                )

                rem Extract year, month, and day from "date_token"
                call set "year=!date_taken:~0,4!"
                call set "month=!date_taken:~5,2!"
                call set "day=!date_taken:~8,2!"
            )

            REM Create the destination folder based on the "DATE TAKEN"
            set "destination_folder=%%A\!year!\!month!\!day!"

            REM Create the destination folder if it doesn't exist
            if not exist "!destination_folder!" mkdir "!destination_folder!"

            REM Update progress and display the current file percentage
            set /A files_left-=1
            echo Stage 2 - Folder !current_folder_count! of !total_folder_count!: File !current_file_index! of !current_file_count! [!method!]: "%%~nxF" ^===^> "!destination_folder!"
            title MediaSort !version! - Stage 2 of 2: File !current_file_index! of !current_file_count! [!current_file_percentage!%%]: Folder !current_folder_count! of !total_folder_count!. [!current_percentage!%%] - !files_left! files left.
            REM Move the file to the destination folder
            move "%%F" "!destination_folder!\"

            REM Sanitize Variables
            set "date_taken="
            set "year="
            set "month="
            set "day="
            set "anchor="
            set "filename="
            set "filename_trimmed="
        )

        REM Update progress and display the current folder percentage
        set /a "current_percentage=(current_folder_count * 100) / total_folder_count"
        echo.
        echo Sorting files in "%%A" Folder Complete. This was Folder !current_folder_count! of !total_folder_count!. !current_percentage!%% Done. !files_left! files left to Sort.
        title MediaSort !version! - Stage 2 of 2: Sorting files in "%%A" Folder Complete. This was Folder !current_folder_count! of !total_folder_count!. !current_percentage!%% Done. !files_left! files left to Sort.
        REM The delay here happens after processing a folder. Idk, cooldown?
        timeout 5
        echo.
        REM This part here was "Prompt user before proceeding to the next folder".
    )
)

REM Final message after completing Stage 2
title MediaSort !version! - Stage 2 of 2 Complete. All !total_file_count! files in !total_folder_count! folders has been sorted.
echo Stage 2 of 2 Complete. All !total_file_count! files in !total_folder_count! folders has been sorted.
echo.
echo Review Changes before exiting. You can CTRL+A and CTRL+C to copy all the contents of this window to your clipboard.
echo Type anything and enter to close this window.

REM Script Job is Done ====================================================================================================================
set /p "choice="
if /i "%choice%" neq "justpressanythinglol" exit /b
pause
cls