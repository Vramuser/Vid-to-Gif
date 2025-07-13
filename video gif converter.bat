@echo off
setlocal EnableDelayedExpansion

if "%~1"=="" (
    echo Please drag and drop a video file onto this script or use the SendTo menu.
    pause
    exit /b
)

set "input=%~1"
set "temp_info=%temp%\video_info.txt"

ffprobe -v error -select_streams v:0 -show_entries stream=width,height,r_frame_rate -of csv=p=0 "%input%" > "%temp_info%"

for /f "tokens=1,2,3 delims=," %%a in ('type "%temp_info%"') do (
    set "width=%%a"
    set "height=%%b"
    set "fps=%%c"
)

del "%temp_info%" 2>nul

:: Prompt for scaling factor
set /p "scale=Enter the scaling factor (e.g., 2 to scale down by half) or press Enter to keep original: "
if not defined scale set "scale=1"

:: Prompt for FPS override
set /p "fps_input=Enter the frames per second (FPS) or press Enter to use original (!fps!): "
if defined fps_input set "fps=!fps_input!"

set /a width=!width!/scale
set /a height=!height!/scale
set /a width=(width/2)*2
set /a height=(height/2)*2

set "filters=scale=!width!:!height!:flags=lanczos,fps=!fps!"

set "output=%~dpn1.gif"

ffmpeg -i "%input%" -vf "%filters%" -loop 0 "%output%"

echo.
echo GIF has been created:
echo "!output!"
pause
exit /b

:remux
echo Remuxing...
pause
exit /b
