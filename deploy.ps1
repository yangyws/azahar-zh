param(
    [string]$ApkPath = "",
    [switch]$LaunchApp = $true
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  AzaharPlus-zh 掌機/設備自動部署工具 (ADB)" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# 1. 檢查 ADB 工具
$adbCmd = "adb"
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    if (Test-Path "C:\platform-tools\adb.exe") {
        $adbCmd = "C:\platform-tools\adb.exe"
    } else {
        Write-Host "[錯誤] 找不到 adb 指令，請確認已安裝 Android Platform Tools！" -ForegroundColor Red
        exit 1
    }
}

# 2. 檢查連接的設備
Write-Host "`n[1/4] 檢查已連接的 Android 設備..." -ForegroundColor Yellow
$rawLines = & $adbCmd devices
$deviceLines = $rawLines | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith("List of") }

if (-not $deviceLines) {
    Write-Host "[警告] 未檢測到已連接的 Android 設備！" -ForegroundColor Red
    Write-Host "請確認：" -ForegroundColor Yellow
    Write-Host " 1. 設備已透過 USB 連接電腦（或已使用 adb connect 進行無線偵錯）"
    Write-Host " 2. 設備已開啟「開發人員選項」與「USB 偵錯 (USB Debugging)」"
    exit 1
}

$unauthorized = $deviceLines | Where-Object { $_ -match "unauthorized" }
if ($unauthorized) {
    Write-Host "[提示] 檢測到設備尚未授權偵錯 (unauthorized)！" -ForegroundColor Magenta
    Write-Host "👉 請查看您的掌機/手機螢幕，會彈出「允許 USB 偵錯？」提示，請勾選「一律允許」並點擊「確定」。" -ForegroundColor Yellow
    Write-Host "等待授權中 (可按 Ctrl+C 中斷)..."
    while ($true) {
        Start-Sleep -Seconds 2
        $rawLines = & $adbCmd devices
        $check = $rawLines | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith("List of") -and ($_ -match "\s+device\b") }
        if ($check) {
            Write-Host "設備已成功授權！" -ForegroundColor Green
            $deviceLines = $check
            break
        }
    }
}

$connected = $deviceLines | Where-Object { $_ -match "\s+device\b" } | Select-Object -First 1
if (-not $connected) {
    Write-Host "[錯誤] 設備狀態非 device (可能離線或無法連接)。" -ForegroundColor Red
    exit 1
}

$deviceId = ($connected -split "\s+")[0]
Write-Host "目標設備已就緒：$deviceId" -ForegroundColor Green

# 3. 尋找 APK 檔案
Write-Host "`n[2/4] 尋找待安裝的 APK 檔案..." -ForegroundColor Yellow
$targetApk = $null

if ($ApkPath -and (Test-Path $ApkPath)) {
    $targetApk = (Resolve-Path $ApkPath).Path
} else {
    $searchPaths = @(
        "$PSScriptRoot\artifacts\*.apk",
        "$PSScriptRoot\src\android\app\build\outputs\apk\vanilla\release\*.apk",
        "$PSScriptRoot\src\android\app\build\outputs\apk\googlePlay\release\*.apk",
        "$PSScriptRoot\src\android\app\build\bundle\*.apk"
    )
    $localCandidates = Get-ChildItem -Path $searchPaths -ErrorAction SilentlyContinue
    if ($localCandidates) {
        # 優先選擇 vanilla 版本
        $vanilla = $localCandidates | Where-Object { $_.Name -like "*vanilla*" } | Select-Object -First 1
        if ($vanilla) {
            $targetApk = $vanilla.FullName
        } else {
            $targetApk = $localCandidates[0].FullName
        }
    }
}

# 若本地無現成 APK，自動嘗試從 GitHub Actions 下載最新雲端編譯產出
if (-not $targetApk -or -not (Test-Path $targetApk)) {
    Write-Host "本地無現成 APK，正在查詢 GitHub Actions 最新雲端編譯產物..." -ForegroundColor Cyan
        $token = $env:GITHUB_TOKEN
        if (-not $token) {
            $ghToken = & gh auth token 2>$null
            if ($LASTEXITCODE -eq 0 -and $ghToken) { $token = $ghToken.Trim() }
        }
        $headers = @{ 
            "User-Agent" = "PowerShell"
            "Accept" = "application/vnd.github+json"
        }
        if ($token) { $headers["Authorization"] = "token $token" }
        
        $artifacts = Invoke-RestMethod -Uri "https://api.github.com/repos/yangyws/azahar-zh/actions/artifacts" -Headers $headers
        $targetArtifact = $artifacts.artifacts | Where-Object { ($_.name -like "*azahar-android*" -or $_.name -like "*android*") -and -not $_.expired } | Select-Object -First 1
        if ($targetArtifact) {
            Write-Host "找到雲端編譯產出：$($targetArtifact.name)，正在下載..." -ForegroundColor Green
            $destDir = "$PSScriptRoot\artifacts"
            if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
            $zipPath = "$destDir\downloaded_artifact.zip"
            Invoke-WebRequest -Uri $targetArtifact.archive_download_url -Headers $headers -OutFile $zipPath
            Expand-Archive -Path $zipPath -DestinationPath $destDir -Force
            Remove-Item $zipPath -Force
            $downloadedApk = Get-ChildItem -Path "$destDir\*.apk" | Where-Object { $_.Name -like "*vanilla*" } | Select-Object -First 1
            if (-not $downloadedApk) {
                $downloadedApk = Get-ChildItem -Path "$destDir\*.apk" | Select-Object -First 1
            }
            if ($downloadedApk) {
                $targetApk = $downloadedApk.FullName
            }
        }
    } catch {
        Write-Host "查詢雲端 Artifact 失敗：$($_.Exception.Message)" -ForegroundColor DarkGray
    }
}

if (-not $targetApk) {
    Write-Host "[錯誤] 未找到任何可安裝的 APK 檔案！" -ForegroundColor Red
    Write-Host "請先至 GitHub Actions 確認編譯完成，或執行 python build_and_deploy.py" -ForegroundColor Yellow
    exit 1
}

Write-Host "使用 APK: $targetApk" -ForegroundColor Green

# 4. 安裝 APK
$packageName = "io.github.lime3ds.android.zh"
Write-Host "`n[3/4] 正在將 APK 安裝/部署至設備 ($deviceId)..." -ForegroundColor Yellow
$installOutput = & $adbCmd -s $deviceId install -r -d $targetApk 2>&1
Write-Host $installOutput

if ($installOutput -match "INSTALL_FAILED_UPDATE_INCOMPATIBLE") {
    Write-Host "[提示] 檢測到簽章不相符（切換編譯環境），正在為您自動解除安裝舊版本並重新安裝..." -ForegroundColor Magenta
    & $adbCmd -s $deviceId uninstall $packageName | Out-Null
    $installOutput = & $adbCmd -s $deviceId install -r -d $targetApk 2>&1
    Write-Host $installOutput
}

if ($installOutput -match "Success") {
    Write-Host "[成功] APK 已成功部署至設備！" -ForegroundColor Green
} else {
    Write-Host "[警告] 安裝未完成，請檢查上方 ADB 訊息。" -ForegroundColor Yellow
}

# 5. 啟動 App
if ($LaunchApp) {
    $mainActivity = "org.citra.citra_emu.ui.main.MainActivity"
    Write-Host "`n[4/4] 正在啟動 AzaharPlus-zh ($packageName)..." -ForegroundColor Yellow
    & $adbCmd -s $deviceId shell am start -n "$packageName/$mainActivity" | Out-Null
    Write-Host "已啟動應用程式！" -ForegroundColor Green
}

Write-Host "`n部署流程已完成！" -ForegroundColor Cyan
