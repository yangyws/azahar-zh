@echo off
chcp 65001 >nul
title AzaharPlus ZH 自動部署工具
echo ==========================================================
echo   正在執行 AzaharPlus ZH 掌機/設備自動部署...
echo ==========================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1" %*
if %errorlevel% neq 0 (
    echo.
    echo [提示] 部署過程中發生錯誤或未完成，請檢視上方訊息。
)
pause
