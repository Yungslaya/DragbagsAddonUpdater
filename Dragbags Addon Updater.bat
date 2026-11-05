@echo off
rem Dragbags Addon Updater - opens the updater window
start "" powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0updater.ps1"
