@ECHO OFF
SET CLIENT=0
SET SERVER=1
SET ARGS={'host','open steam/friends'}
PowerShell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -Command "& '%~dp0src\launch_windows.ps1'"
