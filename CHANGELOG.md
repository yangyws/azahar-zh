# 專案變更日誌與追溯索引 (Changelog & Traceability Index)

本檔案遵循全域規範，記錄專案重要修改歷史與技術決策索引。每次修改皆給定唯一索引識別碼，以利後續追溯與維護。

---

## 🔖 [MOD-20260920-22] 100% 繁中字串補齊與台灣在地化用語全方位淨化

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[在地化精修 / 台灣繁體中文標準 / 詞彙純淨化]`
* **涉及檔案清單**：
  * 修改：`src/android/app/src/main/res/values-b+zh+TW/strings.xml`（100% 補齊未翻譯字串與淨化台灣用語）
  * 修改：`CHANGELOG.md`（記錄變更日誌與索引追溯）
  * 修改：`.gitignore`（忽略本地建置與下載產物）
* **修改動機與問題**（Why）：
  * 深度稽核發現 `values-b+zh+TW/strings.xml` 中仍遺留 175 條英文純文字未翻譯（涵蓋多人連線大廳 Multiplayer、核心載入錯誤 Core Error、檔案壓縮/解壓、版本更新通道、Amiibo、CIA 通知等模組）。
  * 同時排查出多處中國大陸習慣用語與非台灣風格詞彙（如「轉儲」、「丟失」、「崩潰」、「日誌」、「列表」、「重置」、「高清」、「老 3DS」、「後臺」、「設備」等），嚴重違背台灣在地化科技標準。
* **技術方案與關鍵決策**（How）：
  1. **全數補齊未翻譯英文**：依據台灣 3DS 玩家社群與 Android 科技術語習慣，完成全部 175 條未翻譯字串之台灣繁體中文在地化。
  2. **全面用語純淨化轉換**：
     - `轉儲` $\rightarrow$ `傾印`（傾印材質、傾印系統檔案）
     - `丟失` $\rightarrow$ `遺失`
     - `崩潰` $\rightarrow$ `當機`
     - `日誌` $\rightarrow$ `記錄檔` / `記錄`
     - `列表` $\rightarrow$ `清單`（公開大廳清單、好友清單、應用程式清單）
     - `重置` $\rightarrow$ `重設`（全部重設、重設虛擬按鍵、重設為預設值）
     - `高清` $\rightarrow$ `高畫質`
     - `老 3DS` $\rightarrow$ `舊版 3DS`
     - `後臺` $\rightarrow$ `背景`（在背景編譯著色器）
     - `設備` $\rightarrow$ `裝置`
     - `卡頓` $\rightarrow$ `畫面頓挫與延遲`
  3. **語法與節點校驗**：經由 XML 解析器與自動稽核腳本嚴格驗證，全部 1,044 條字串結構完全合法，大陸習慣用語命中數徹底歸零。
* **測試與驗證結果**（Verification）：
  * PowerShell `[xml]` 驗證 1,044 個節點全部解析成功。
  * 稽核腳本比對確認未翻譯人類可讀英文字串歸零、非台灣用語命中歸零。

---

## 🔖 [MOD-20260920-21] 繁體中文在地化精修：修正攝像頭與簡中習慣用語

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[在地化精修 / 台灣繁體中文標準]`
* **涉及檔案清單**：
  * 修改：`src/android/app/src/main/res/values-b+zh+TW/strings.xml`
* **修改動機與問題**（Why）：
  * 掌機使用者反饋設定選單出現非台灣習慣用語「攝像頭」。
  * 台灣 Android 系統與科技術語嚴格使用「相機」或「鏡頭」，「攝像頭」為中國大陸習慣用語。
* **技術方案與關鍵決策**（How）：
  1. 將 21 處「攝像頭」替換為台灣標準用語「相機」或「鏡頭」（前鏡頭/後鏡頭/相機權限）。
  2. 同步修復「許可權」$\rightarrow$「權限」、「影象」$\rightarrow$「影像」、「訪問」$\rightarrow$「存取」、「自定義」$\rightarrow$「自訂」。
* **測試與驗證結果**（Verification）：
  * 本地字串檢驗無誤，建立 commit `f2b3acbb8`。

---

## 🔖 [MOD-20260920-17] 隔離外部依賴與排查 libretro / format 工作流錯誤

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[CI/CD 優化 / 分支過濾防護]`
* **涉及檔案清單**：
  * 修改：`.github/workflows/libretro.yml`（push 觸發條件排除 `main-zh` 與 `i18n-zh` 分支）
  * 修改：`.github/workflows/format.yml`（push 觸發條件排除 `main-zh` 與 `i18n-zh` 分支）
  * 修改：`CHANGELOG.md`（記錄變更日誌與排查索引追溯）
* **修改動機與問題**（Why）：
  * 推送至 `main-zh` 分支時，觸發了未排除該分支的 `citra-libretro` 與 `citra-format` 工作流。
  * `citra-libretro` 工作流中的 `windows` 任務嘗試自外部私有 Registry 拉取映像檔 `git.libretro.com:5050/libretro-infrastructure/libretro-build-mxe-win-cross-cores:mingw12`。因外部伺服器連線超時，產生致命錯誤：
    `Error response from daemon: Get "https://git.libretro.com:5050/v2/": context deadline exceeded`、`Error: Process completed with exit code 1`。
  * `main-zh` 分支的核心定位為 AzaharPlus Android 掌機繁體中文版之發行與 APK 雲端編譯發布，非 libretro 核心發布或桌面版編譯，觸發此類工作流不僅徒增 CI 計算資源浪費，更因第三方服務不穩定導致假警報中斷流程。
* **技術方案與關鍵決策**（How）：
  1. **比照 `build.yml` 標準過濾規範**：在 `.github/workflows/libretro.yml` 的 `on.push.branches` 中增設 `- '!main-zh'` 與 `- '!i18n-zh'` 排除規則。
  2. **全面防護程式碼格式工作流**：在 `.github/workflows/format.yml` 的 `on.push.branches` 同步增設 `- '!main-zh'` 與 `- '!i18n-zh'` 排除規則，避免多餘的 clang-format 容器任務干擾。
  3. **確保主管線專注運行**：確保推送到 `main-zh` 時僅專注觸發 `Build Android APK`（`build-android.yml`）建置工作流，徹底隔絕外部非必要依賴風險。
* **測試與驗證結果**（Verification）：
  * YAML 語法與縮排結構檢驗合規，分支名稱正規表達模式相符。
  * 各工作流觸發條件比對一致，達成與 `build.yml` 相同之分支隔離目標。

---

## 🔖 [MOD-20260920-16] 修復 Android 語系設定衝突與雲端 APK 建置管線優化

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[CI/CD 修復 / 建置配置調校]`
* **涉及檔案清單**：
  * 修改：`src/android/app/build.gradle.kts`（將 `generateLocaleConfig` 明確設為 `false`）
  * 修改：`.github/workflows/build-android.yml`（優化 APK 產物遞迴搜尋與歸檔邏輯）
  * 新增：`CHANGELOG.md`（建立專案變更日誌與索引紀錄）
* **修改動機與問題**（Why）：
  * GitHub Actions 雲端 Android APK 建置任務（Run ID: `35496901345`）在執行 45 分鐘後，於 `:app:processGooglePlayReleaseMainManifest` 步驟報錯中斷：
    `Locale config generation was requested but user locale config is present in manifest. See https://developer.android.com/r/studio-ui/build/automatic-per-app-languages`
  * 原先在 `build.gradle.kts` 中啟用了 `generateLocaleConfig = true`，而 `AndroidManifest.xml` 中已依原生標準手動宣告了 `android:localeConfig="@xml/locales_config"`，導致 Android Gradle Plugin (AGP) 判定兩者配置衝突而中止建置。
* **技術方案與關鍵決策**（How）：
  1. **停用自動語系生成**：在 `src/android/app/build.gradle.kts` 中將 `androidResources.generateLocaleConfig` 設為 `false`，全面採用手動配置之 `res/xml/locales_config.xml` 與 `AndroidManifest.xml`。
  2. **穩健搜尋 APK 產物**：在 `.github/workflows/build-android.yml` 的打包階段，使用 `find src/android/app/build -type f -name "*.apk" -exec cp {} artifacts/ \;` 取代原本固定路徑之萬用字元，確保不論哪種變體（Flavor/Build Type）產出的 APK 都能穩定歸檔並上傳至 GitHub 產物庫。
* **測試與驗證結果**（Verification）：
  * 檢查 Gradle 與工作流語法結構無誤。
  * 解決 AGP Manifest 合併階段的致命錯誤。

---

## 🔖 [MOD-20260920-15] 部署管線增強：即時雲端編譯狀態監控與雙擊安全防護

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[自動化部署 / 使用者體驗提升]`
* **涉及檔案清單**：
  * 修改：`deploy.ps1`
  * 修改：`deploy.bat`
* **修改動機與問題**（Why）：
  * 雲端建置耗時較長，原先若本地未下載 APK 且雲端建置中，使用者雙擊執行 `deploy.bat` 時會立即結束，無法得知當前雲端進度或需等待至何時。
* **技術方案與關鍵決策**（How）：
  1. 雙擊防呆保護：若未連接設備且未找到 APK，顯示清楚引導說明並暫停視窗。
  2. 即時監控雲端建置：整合 GitHub Actions REST API，偵測正在執行的任務並顯示當前進行步驟。
  3. ADB 喚醒螢幕：安裝完成後自動發送喚醒與解鎖指令，自動啟動 App。

---

## 🔖 [MOD-20260920-14] 雙向獨立共存支援與 AzaharPlus ZH 識別化

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[架構設計 / 套件識別]`
* **涉及檔案清單**：
  * 修改：`src/android/app/src/main/res/values/strings.xml`
  * 修改：`src/android/app/src/main/res/values-b+zh+TW/strings.xml`
  * 修改：`deploy.ps1`
* **修改動機與問題**（Why）：
  * 使用者設備上可能已安裝原版 Lime3DS / Azahar，為避免安裝覆蓋或資料衝突，需達成與原版並存且在桌面圖示上能清楚區隔。
* **技術方案與關鍵決策**（How）：
  1. 將 App 名稱標註為 `AzaharPlus ZH`。
  2. 在部署管線中新增共存驗證邏輯，偵測原版與中文獨立版之安裝狀態。

---

## 🔖 [MOD-20260920-07] 獨立 ApplicationId 與自動化雲端建置與部署環境建立

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[CI/CD / 部署腳本 / 文件]`
* **涉及檔案清單**：
  * 新增：`.github/workflows/build-android.yml`
  * 新增：`build_and_deploy.py`
  * 新增：`deploy.ps1`
  * 新增：`deploy.bat`
  * 新增：`README.zh-TW.md`
  * 修改：`src/android/app/build.gradle.kts`（`applicationId = "io.github.lime3ds.android.zh"`）
  * 修改：`src/android/app/src/main/AndroidManifest.xml`
  * 新增：`src/android/app/src/main/res/xml/locales_config.xml`
* **修改動機與問題**（Why）：
  * 提供獨立安裝識別碼與單鍵 ADB 自動部署至 Android 掌機之自動化管線。

---

## 🔖 [MOD-20260920-06] Android 前端 100% 台灣繁體中文 (zh-TW) 原生在地化

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[在地化 / 資源正規化]`
* **涉及檔案清單**：
  * 修改：`src/android/app/src/main/res/values-b+zh+TW/strings.xml`（1052 行繁體中文字串）
* **修改動機與問題**（Why）：
  * 全面符合 Android 官方多語系架構，依台灣繁體中文規範提供高品質科技用語介面，杜絕大陸用語與簡體字。

---

## 🔖 [MOD-20260920-21] 繁體中文字串全面深度審查與台灣科技用語修正 (攝像頭→相機/鏡頭、許可權→權限)

* **修改日期**：2026-09-20
* **目標分支**：`main-zh`
* **修改分類**：`[在地化 / 台灣用語修正]`
* **涉及檔案清單**：
  * 修改：[`src/android/app/src/main/res/values-b+zh+TW/strings.xml`](src/android/app/src/main/res/values-b+zh+TW/strings.xml)
* **修改動機與問題**（Why）：
  - 排查並修正原由上游帶入之中國大陸習慣用語（如「攝像頭」→「相機/鏡頭」、「許可權」→「權限」、「影象」→「影像」、「訪問」→「存取」、「自定義」→「自訂」等共 50 餘處詞彙），使其 100% 符合台灣繁體中文標準語系與 Android 官方系統命名習慣。

