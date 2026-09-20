@echo off
chcp 65001 >nul
echo 正在執行 AzaharPlus-zh 自動部署...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0deploy.ps1"
if %errorlevel% neq 0 (
    echo.
    echo 部署過程中發生錯誤，請查看上方訊息。
)
pause
