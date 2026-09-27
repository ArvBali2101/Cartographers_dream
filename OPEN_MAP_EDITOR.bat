@echo off
cd /d "%~dp0"
start "Merged Game Godot Editor" "%~dp0Godot_v4.7-stable\Godot_v4.7-stable_win64.exe" --editor --path "%~dp0merged_game"
