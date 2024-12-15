@echo off
if "%~1"=="" (
    echo Please drag and drop a video file onto this script or use the SendTo menu.
    pause
    exit /b
)

set "input=%~1"

if %errorlevel% == 1 goto remux

ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -of csv=p=0 "%input%" > %temp%\video_info.txt

for /f "tokens=1,2,3 delims=," %%a in (%temp%\video_info.txt) do (
    set width=%%a
    set height=%%b
    set fps=%%c
)

if exist "%temp%\video_info.txt" del "%temp%\video_info.txt"

set /p scale="Enter the scaling factor (e.g., 2 to scale down by half) or press Enter to keep original: "
if "%scale%"=="" set scale=1

set /p fps_input="Enter the frames per second (FPS) or press Enter to use original (%fps%): "
if not "%fps_input%"=="" set fps=%fps_input%

set /a width=%width%/%scale%
set /a height=%height%/%scale%

set /a width=(%width%/2)*2
set /a height=(%height%/2)*2

set "filters=scale=%width%:%height%:flags=lanczos,fps=%fps%"

set "output=%~dpn1.gif"

ffmpeg -i "%input%" -vf "%filters%" -loop 0 "%output%"

echo GIF has been created: %output%
pause
exit

:remux
echo Remuxing...
pause
exit
