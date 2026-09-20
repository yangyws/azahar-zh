# 專案變更日誌與追溯索引 (Changelog & Traceability Index)

本檔案遵循全域規範，記錄專案重要修改歷史與技術決策索引。每次修改皆給定唯一索引識別碼，以利後續追溯與維護。

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
