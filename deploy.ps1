param(
    [string]$ApkPath = "",
    [switch]$LaunchApp = $true,
    [string]$DeviceId = "",
    [int]$WaitSeconds = 5
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  AzaharPlus ZH 掌機 / Android 設備自動部署管線 (ADB)" -ForegroundColor Cyan
Write-Host "  套件識別碼: io.github.lime3ds.android.zh" -ForegroundColor Cyan
Write-Host "  追蹤索引: [MOD-20260920-15]" -ForegroundColor DarkGray
Write-Host "==========================================================" -ForegroundColor Cyan

# 輔助函式：安全取得 GitHub Token（環境變數 -> User/Machine 環境 -> gh CLI -> Git 認證管理員）
function Get-GitHubTokenSafe {
    if ($env:GITHUB_TOKEN) { return $env:GITHUB_TOKEN.Trim() }
    
    $userToken = [System.Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "User")
    if ($userToken) { return $userToken.Trim() }
    
    $machineToken = [System.Environment]::GetEnvironmentVariable("GITHUB_TOKEN", "Machine")
    if ($machineToken) { return $machineToken.Trim() }
    
    try {
        $ghCmd = Get-Command gh -ErrorAction SilentlyContinue
        if ($ghCmd) {
            $ghToken = & gh auth token 2>$null
            if ($LASTEXITCODE -eq 0 -and $ghToken) { return $ghToken.Trim() }
        }
    } catch {}
    
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "git.exe"
        $psi.Arguments = "credential fill"
        $psi.UseShellExecute = $false
        $psi.RedirectStandardInput = $true
        $psi.RedirectStandardOutput = $true
        $psi.CreateNoWindow = $true
        $p = [System.Diagnostics.Process]::Start($psi)
        $p.StandardInput.WriteLine("protocol=https")
        $p.StandardInput.WriteLine("host=github.com")
        $p.StandardInput.WriteLine("")
        $p.StandardInput.Flush()
        $out = $p.StandardOutput.ReadToEnd()
        [void]$p.WaitForExit(3000)
        $pwdMatch = ($out -split "`r?`n") | Where-Object { $_ -match "^password=(.+)$" } | Select-Object -First 1
        if ($pwdMatch -and $pwdMatch -match "^password=(.+)$") {
            $candidate = $Matches[1].Trim()
            if ($candidate.Length -ge 20) { return $candidate }
        }
    } catch {}
    
    return $null
}

# 輔助函式：從候選 APK 清單中優先挑選 vanilla release
function Select-PreferredApk {
    param([array]$candidates)
    if (-not $candidates) { return $null }
    $vanillaRelease = $candidates | Where-Object { $_.Name -like "*vanilla*" -and $_.Name -like "*release*" } | Select-Object -First 1
    if ($vanillaRelease) { return $vanillaRelease.FullName }
    $vanilla = $candidates | Where-Object { $_.Name -like "*vanilla*" } | Select-Object -First 1
    if ($vanilla) { return $vanilla.FullName }
    $release = $candidates | Where-Object { $_.Name -like "*release*" } | Select-Object -First 1
    if ($release) { return $release.FullName }
    return $candidates[0].FullName
}

# 輔助函式：安全下載 GitHub Actions 產物 Zip
function Download-ArtifactArchive {
    param(
        [string]$downloadUrl,
        [string]$destZip,
        [string]$token
    )
    $curlCmd = Get-Command curl.exe -ErrorAction SilentlyContinue
    if ($curlCmd -and $token) {
        & curl.exe -f -s -S -L -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $token" -o $destZip $downloadUrl
        if ($LASTEXITCODE -ne 0) {
            throw "curl 下載失敗，結束代碼: $LASTEXITCODE"
        }
    } elseif ($token) {
        $req = [System.Net.HttpWebRequest]::Create($downloadUrl)
        $req.AllowAutoRedirect = $false
        $req.Headers["Authorization"] = "Bearer $token"
        $req.Headers["Accept"] = "application/vnd.github+json"
        $req.UserAgent = "PowerShell-AzaharDeploy"
        try {
            $resp = $req.GetResponse()
            $redirectUrl = $resp.GetResponseHeader("Location")
            $resp.Close()
        } catch [System.Net.WebException] {
            $resp = $_.Exception.Response
            if ($resp -and ($resp.StatusCode.value__ -in 301, 302, 303, 307, 308)) {
                $redirectUrl = $resp.Headers["Location"]
            } else {
                throw $_
            }
        }
        if ($redirectUrl) {
            Invoke-WebRequest -Uri $redirectUrl -OutFile $destZip
        } else {
            throw "無法取得產物重導向下載網址"
        }
    } else {
        throw "未提供 GitHub Token，無法下載私有或 GitHub Actions 產物"
    }
}

# 1. 尋找待安裝的 APK 檔案
# 搜尋順序：指定路徑 -> artifacts/*.apk -> src/android/app/build/outputs/apk/*/*/*.apk -> 雲端下載與監控
Write-Host "`n[1/4] 尋找待安裝的 APK 檔案..." -ForegroundColor Yellow
$targetApk = $null

# 優先順序 1: 命令列指定路徑
if ($ApkPath -and (Test-Path $ApkPath)) {
    $targetApk = (Resolve-Path $ApkPath).Path
    Write-Host "採用指定之 APK 路徑：$targetApk" -ForegroundColor Cyan
}

# 優先順序 2: 本地 artifacts/*.apk
if (-not $targetApk) {
    $artifactApks = @(Get-ChildItem -Path "$PSScriptRoot\artifacts\*.apk" -ErrorAction SilentlyContinue)
    if ($artifactApks.Count -gt 0) {
        $targetApk = Select-PreferredApk -candidates $artifactApks
        Write-Host "於 artifacts/ 資料夾找到候選 APK：$targetApk" -ForegroundColor Cyan
    }
}

# 優先順序 3: 本地 build/outputs/apk/*/*/*.apk
if (-not $targetApk) {
    $buildApks = @(Get-ChildItem -Path "$PSScriptRoot\src\android\app\build\outputs\apk" -Filter "*.apk" -Recurse -ErrorAction SilentlyContinue)
    if ($buildApks.Count -gt 0) {
        $targetApk = Select-PreferredApk -candidates $buildApks
        Write-Host "於本地 build/outputs/apk 找到編譯產物：$targetApk" -ForegroundColor Cyan
    }
}

# 優先順序 4: 雲端下載與監控 (GitHub Actions Artifacts)
if (-not $targetApk) {
    Write-Host "本地未找到現成 APK，正在查詢 GitHub Actions 雲端編譯狀態與產物..." -ForegroundColor Cyan
    
    $token = Get-GitHubTokenSafe
    $headers = @{
        "User-Agent" = "PowerShell-AzaharDeploy"
        "Accept"     = "application/vnd.github+json"
    }
    if ($token) {
        $headers["Authorization"] = "Bearer $token"
    }
    
    $repoBase = "https://api.github.com/repos/yangyws/azahar-zh"
    $pollInterval = 15
    $maxPollSeconds = 1800 # 最多監控 30 分鐘
    $elapsedSeconds = 0
    
    while ($true) {
        # 1. 優先檢查是否已有上傳完成的產物
        try {
            $artifactsResp = Invoke-RestMethod -Uri "$repoBase/actions/artifacts?per_page=30" -Headers $headers -ErrorAction Stop
            $targetArtifact = $artifactsResp.artifacts | Where-Object {
                ($_.name -eq "azahar-android-apk" -or $_.name -like "*azahar-android*" -or $_.name -like "*android*") -and -not $_.expired
            } | Select-Object -First 1
            
            if ($targetArtifact) {
                Write-Host "找到雲端編譯產物：$($targetArtifact.name) (ID: $($targetArtifact.id)，大小: $([math]::Round($targetArtifact.size_in_bytes / 1MB, 2)) MB)" -ForegroundColor Green
                
                if (-not $token) {
                    Write-Host "`n[提示] 下載 GitHub Actions 編譯產物需要 GitHub 授權 Token。" -ForegroundColor Yellow
                    Write-Host "請使用以下任一方式授權下載：" -ForegroundColor Yellow
                    Write-Host " 1. 設定環境變數：`$env:GITHUB_TOKEN = '<您的 GitHub Token>'"
                    Write-Host " 2. 登入 GitHub CLI：執行 gh auth login"
                    Write-Host " 3. 或至瀏覽器直接下載產物並解壓縮至 artifacts 資料夾："
                    Write-Host "    https://github.com/yangyws/azahar-zh/actions`n"
                    break
                }
                
                Write-Host "正在下載雲端產物至 artifacts 資料夾..." -ForegroundColor Cyan
                $destDir = "$PSScriptRoot\artifacts"
                if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
                $zipPath = "$destDir\downloaded_artifact.zip"
                
                Download-ArtifactArchive -downloadUrl $targetArtifact.archive_download_url -destZip $zipPath -token $token
                
                if (Test-Path $zipPath) {
                    Write-Host "下載完成，正在解壓縮產物..." -ForegroundColor Cyan
                    Expand-Archive -Path $zipPath -DestinationPath $destDir -Force
                    Remove-Item $zipPath -Force
                    
                    $downloadedCandidates = @(Get-ChildItem -Path "$destDir\*.apk" -Recurse -ErrorAction SilentlyContinue)
                    if ($downloadedCandidates.Count -gt 0) {
                        $targetApk = Select-PreferredApk -candidates $downloadedCandidates
                        Write-Host "成功解壓縮並就緒 APK：$targetApk" -ForegroundColor Green
                        break
                    }
                }
            }
        } catch {
            Write-Host "查詢產物清單時發生例外：$($_.Exception.Message)" -ForegroundColor DarkGray
        }
        
        # 2. 若無產物，檢查是否有正在執行中的 Build Android APK（優先追蹤啟動最久的 Run）
        try {
            $runsResp = Invoke-RestMethod -Uri "$repoBase/actions/runs?per_page=10" -Headers $headers -ErrorAction Stop
            $activeRuns = $runsResp.workflow_runs | Where-Object {
                $_.name -eq "Build Android APK" -and $_.status -in @("in_progress", "queued", "waiting")
            } | Sort-Object { [DateTime]$_.created_at }
            
            $activeRun = $activeRuns | Select-Object -First 1
            
            if ($activeRun) {
                # 取得當前步驟資訊
                $stepInfo = "建置中"
                try {
                    $jobsResp = Invoke-RestMethod -Uri "$repoBase/actions/runs/$($activeRun.id)/jobs" -Headers $headers -ErrorAction Stop
                    $curStep = $jobsResp.jobs[0].steps | Where-Object { $_.status -eq "in_progress" } | Select-Object -First 1
                    if ($curStep) {
                        $stepInfo = "$($curStep.name) (步驟 $($curStep.number))"
                    } else {
                        $lastCompleted = $jobsResp.jobs[0].steps | Where-Object { $_.status -eq "completed" } | Select-Object -Last 1
                        if ($lastCompleted) {
                            $stepInfo = "已完成 $($lastCompleted.name)，準備進行下一步"
                        }
                    }
                } catch {}
                
                Write-Host "正在監控 GitHub Actions 雲端編譯進度 (Run #$($activeRun.id)，步驟: [$stepInfo])，請稍候..." -ForegroundColor Yellow
                
                if ($elapsedSeconds -ge $maxPollSeconds) {
                    Write-Host "[逾時] 已等待超過 30 分鐘，請至 GitHub 頁面查看編譯狀況。" -ForegroundColor Red
                    break
                }
                
                Start-Sleep -Seconds $pollInterval
                $elapsedSeconds += $pollInterval
                continue
            } else {
                # 沒有正在執行的建置，且也沒找到可用產物
                Write-Host "目前無正在執行中的 Android 雲端編譯任務，且未在雲端找到已發布之產物。" -ForegroundColor DarkGray
                break
            }
        } catch {
            Write-Host "查詢雲端建置狀態時發生例外：$($_.Exception.Message)" -ForegroundColor DarkGray
            break
        }
    }
}

if (-not $targetApk -or -not (Test-Path $targetApk)) {
    Write-Host "`n[錯誤] 未找到任何可安裝的 APK 檔案！" -ForegroundColor Red
    Write-Host "請確認：" -ForegroundColor Yellow
    Write-Host " 1. 本地是否有編譯完成的 APK（放置於 artifacts\ 或 build\outputs\apk\）"
    Write-Host " 2. 或至 GitHub Actions 確認編譯狀態：https://github.com/yangyws/azahar-zh/actions"
    exit 1
}

Write-Host "已就緒 APK：$targetApk" -ForegroundColor Green

# 2. 檢查 ADB 工具
Write-Host "`n[2/4] 檢查 ADB 連線環境..." -ForegroundColor Yellow
$adbCmd = "adb"
if (-not (Get-Command adb -ErrorAction SilentlyContinue)) {
    $fallbackPaths = @(
        "C:\platform-tools\adb.exe",
        "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
        "$env:ANDROID_HOME\platform-tools\adb.exe"
    )
    $foundPath = $fallbackPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($foundPath) {
        $adbCmd = $foundPath
    } else {
        Write-Host "[錯誤] 找不到 adb 工具！請確認已安裝 Android Platform Tools 並加入 PATH 環境變數。" -ForegroundColor Red
        exit 1
    }
}

# 3. 檢查連接的 Android 設備
Write-Host "`n[3/4] 檢查已連接的 Android 設備..." -ForegroundColor Yellow

function Get-ConnectedDevices {
    param([string]$cmd)
    $raw = & $cmd devices 2>$null
    return $raw | Where-Object { $_.Trim() -ne "" -and -not $_.StartsWith("List of") }
}

$deviceLines = Get-ConnectedDevices -cmd $adbCmd

if (-not $deviceLines) {
    Write-Host "[警告] 目前未檢測到已連接的 Android 設備！" -ForegroundColor Red
    Write-Host "請確認以下項目：" -ForegroundColor Yellow
    Write-Host " 1. 掌機 / 手機已透過 USB 傳輸線連接至電腦（或已在同 Wi-Fi 網路使用 adb connect 連線）"
    Write-Host " 2. 設備已開啟「開發人員選項」並啟用「USB 偵錯 (USB Debugging)」"
    
    if ($WaitSeconds -gt 0) {
        Write-Host "正在等待設備連線 (最多等待 $WaitSeconds 秒，可隨時按 Ctrl+C 中斷)..." -ForegroundColor Gray
        $elapsed = 0
        while (-not $deviceLines -and $elapsed -lt $WaitSeconds) {
            Start-Sleep -Seconds 1
            $elapsed++
            $deviceLines = Get-ConnectedDevices -cmd $adbCmd
        }
    }
    
    if (-not $deviceLines) {
        Write-Host "`n[提示] APK 已妥善準備於：$targetApk" -ForegroundColor Cyan
        Write-Host "連接好掌機或手機後，請再次執行 deploy.bat 即可立即完成部署！" -ForegroundColor Cyan
        exit 0
    }
}

# 檢查設備是否未授權 (unauthorized)
$unauthorized = $deviceLines | Where-Object { $_ -match "unauthorized" }
if ($unauthorized) {
    Write-Host "[提示] 檢測到設備尚未取得偵錯授權 (unauthorized)！" -ForegroundColor Magenta
    Write-Host "👉 請查看您的掌機 / 手機螢幕，畫面應會彈出「允許 USB 偵錯？」提示。" -ForegroundColor Yellow
    Write-Host "   建議勾選「一律允許透過這部電腦進行偵錯」並點選「允許」或「確定」。" -ForegroundColor Yellow
    Write-Host "正在等待授權中 (可按 Ctrl+C 中斷)..." -ForegroundColor Gray
    
    while ($true) {
        Start-Sleep -Seconds 2
        $deviceLines = Get-ConnectedDevices -cmd $adbCmd
        $ready = $deviceLines | Where-Object { $_ -match "\s+device\b" }
        if ($ready) {
            Write-Host "設備已成功取得授權！" -ForegroundColor Green
            break
        }
    }
}

$connectedList = $deviceLines | Where-Object { $_ -match "\s+device\b" }
if (-not $connectedList) {
    Write-Host "[錯誤] 設備狀態非 device (可能處於 offline、recovery 或 bootloader 狀態)。" -ForegroundColor Red
    exit 1
}

if (-not $DeviceId) {
    $DeviceId = ($connectedList[0] -split "\s+")[0]
}

$deviceModel = (& $adbCmd -s $DeviceId shell getprop ro.product.model 2>$null)
if ($deviceModel) { $deviceModel = $deviceModel.Trim() }
Write-Host "目標設備已就緒：$DeviceId ($deviceModel)" -ForegroundColor Green

# 4. 安裝 APK 至設備
$packageName = "io.github.lime3ds.android.zh"
Write-Host "`n[4/4] 正在將 APK 安裝至設備 ($DeviceId)..." -ForegroundColor Yellow
$installOutput = & $adbCmd -s $DeviceId install -r -d $targetApk 2>&1
$installStr = $installOutput | Out-String
Write-Host $installStr.Trim()

if ($installStr -match "INSTALL_FAILED_UPDATE_INCOMPATIBLE") {
    Write-Host "[提示] 檢測到簽章不相符（切換編譯環境），正在自動解除安裝舊版本並重新安裝..." -ForegroundColor Magenta
    & $adbCmd -s $DeviceId uninstall $packageName | Out-Null
    $installOutput = & $adbCmd -s $DeviceId install -r -d $targetApk 2>&1
    $installStr = $installOutput | Out-String
    Write-Host $installStr.Trim()
}

if ($installStr -match "Success") {
    Write-Host "[成功] AzaharPlus ZH 已成功安裝至設備！" -ForegroundColor Green
    
    # 驗證共存狀態
    Write-Host "`n[共存驗證] 檢查設備上 Lime3DS 相關套件安裝狀態：" -ForegroundColor Cyan
    $pkgList = (& $adbCmd -s $DeviceId shell pm list packages lime3ds 2>$null) | Out-String
    $hasOriginal = $pkgList -match "package:io.github.lime3ds.android\r?$"
    $hasZh = $pkgList -match "package:io.github.lime3ds.android.zh"
    if ($hasOriginal -and $hasZh) {
        Write-Host "  ✅ 完美雙向獨立共存！同時檢測到原版 (io.github.lime3ds.android) 與中文獨立版 (io.github.lime3ds.android.zh)。" -ForegroundColor Green
    } elseif ($hasZh) {
        Write-Host "  ✅ 中文版 ($packageName) 已安裝就緒。" -ForegroundColor Green
    }
} else {
    Write-Host "[警告] 安裝未能確認成功，請檢視上方 ADB 輸出訊息。" -ForegroundColor Yellow
}

# 5. 啟動 App
if ($LaunchApp) {
    $mainActivity = "org.citra.citra_emu.ui.main.MainActivity"
    Write-Host "`n正在喚醒設備螢幕並啟動 AzaharPlus ZH ($packageName)..." -ForegroundColor Yellow
    & $adbCmd -s $DeviceId shell input keyevent 224 2>$null
    & $adbCmd -s $DeviceId shell wm dismiss-keyguard 2>$null
    & $adbCmd -s $DeviceId shell am start -n "$packageName/$mainActivity" | Out-Null
    Write-Host "應用程式已啟動！" -ForegroundColor Green
}

Write-Host "`n==========================================================" -ForegroundColor Cyan
Write-Host "  AzaharPlus ZH 自動部署流程全部完成！" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan