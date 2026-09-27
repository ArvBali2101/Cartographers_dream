@echo off
cd /d "%~dp0"
if not exist "%~dp0merged_game\project.godot" (
  echo The merged_game project is missing. Do not launch the older root project.
  pause
  exit /b 1
)
if not exist "%~dp0merged_game\.godot\imported\Caveat.ttf-3cbd2c23f57c75d34d02577b2dbcb96f.fontdata" (
  "%~dp0Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe" --headless --path "%~dp0merged_game" --import
  if errorlevel 1 exit /b 1
)
start "Cartographer's Dream - friend merged build" "%~dp0Godot_v4.7-stable\Godot_v4.7-stable_win64.exe" --path "%~dp0merged_game"
