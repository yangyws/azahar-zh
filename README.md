<div align="center">

# AzaharPlus (台灣繁體中文版)

**AzaharPlus** 是基於任天堂 3DS 模擬器 Azahar 的社群功能強化版本。

[English](README.en.md) | **台灣繁體中文**

---

![Azahar Emulator](https://azahar-emu.org/resources/images/logo/azahar-name-and-logo.svg)
![Plus](https://cdn-icons-png.flaticon.com/128/226/226974.png)

![GitHub Release](https://img.shields.io/github/v/release/AzaharPlus/AzaharPlus?label=Upstream%20Release)
![Android](https://img.shields.io/badge/Android-9.0%2B-3DDC84?logo=android&logoColor=white)
![i18n](https://img.shields.io/badge/i18n-Traditional%20Chinese%20(zh--TW)-blue)
![License](https://img.shields.io/badge/license-GPL%20v2.0-blue)

</div>

本儲存庫為 **台灣繁體中文 (zh-TW) 深度在地化與 Android 掌機部署專用分支**，具備完整的 Android 官方標準原生多語系架構、獨立 Package ID（可與官方版本共存）、以及掌機一鍵 ADB 部署腳本。

---

## 🌟 AzaharPlus 核心特色

相較於原版 Azahar，AzaharPlus 具備以下強化特性：
- **廣泛的遊戲檔案相容性**：只要在任何 Citra 衍生版能執行的遊戲檔案，皆可在 AzaharPlus 上順暢運作。
- **官方伺服器系統檔案一鍵下載**：可直接自官方伺服器下載必要系統韌體檔案，不再需要從實體 3DS 主機手動提取。
- **舊款處理器相容**：解除對 SSE4.2 指令集的強制依賴，讓較舊款的 CPU 也能順暢運行。
- **Android 9.0 系統支援**：最低相容門檻降至 Android 9.0 (API 28)，老舊掌機或手機也能遊玩。
- **ZipPass 瞬間交錯通訊 (StreetPass)**：透過 zip 壓縮檔跨裝置交換擦身通訊資料的全新功能。
- **內建金手指 (Cheats)**：整合便捷的遊戲作弊碼功能。
- **Amiibo 虛擬生成**：內建直接模擬生成 Amiibo 虛擬公仔資料。
- **跨 Citra 衍生版多人連線最佳化**：大幅強化與其他 Citra 分支的多人連線相容性。

> [!NOTE]
> Azahar 標誌版權屬於 PabloMK7 與 angyartanddraw 所有。

---

## 🇹🇼 台灣繁體中文版特有功能 (zh-TW Edition Features)

1. **100% Android 原生標準資源在地化**：
   - 零侵入式手寫字典，全面採用 Android 官方原生 `res/values-b+zh+TW/strings.xml` 資源體系。
   - 完整中文化 1,044 條字串，嚴格遵循台灣在地化標準科技用語（專案、程式碼、儲存庫、記憶體、螢幕、畫面幀率、最佳化等）。
   - 支援 Android 13+ (API 33+) 原生 `locales_config.xml` 應用程式專屬語言（Per-App Language）動態切換。
2. **獨立 Application ID（無痛並存，不影響存檔）**：
   - Package ID 設定為 `io.github.lime3ds.android.zh`。
   - 可與您裝置上既有的官方 AzaharPlus 或 Lime3DS **同時安裝並存**，完全不會覆蓋或衝突。
   - 遊戲存檔（Save Data）存放在外部儲存目錄（SAF），安全讀取、無縫互通、絕不被刪除。
3. **掌機 / 設備一鍵 ADB 自動部署工具**：
   - 內建 `deploy.ps1`、`deploy.bat` 與 `build_and_deploy.py`。
   - 自動檢測連線掌機（AYN Odin / Thor、Retroid Pocket 等），自動下載雲端最新編譯產物並完成安裝啟動。

---

## 📦 安裝說明 (Installation)

請至 [Releases](https://github.com/yangyws/azahar-zh/releases) 下載最新版本 APK 或執行檔。

### Android 版本說明

本專案在 Android 平台提供以下版本型態：
* **台灣繁體中文版 (zh Edition)**：
  * Application ID：`io.github.lime3ds.android.zh`
  * 獨立共存，內建完整台灣繁中在地化與掌機部署工具，適合各類 Android 掌機與手機。
* **官方 Replace 版**：使用與 Azahar 相同的 Application ID，安裝時會覆蓋官方版本（適用於特定前端如 Daijishō、EmulationStation 已指定原包名者）。
* **官方 Coexist 版**：使用原官方共存 ID（名稱帶有 `+AzaharPlus+`），圖示為紅色背景。

### 前端整合：Cocoon
若欲在 Cocoon 前端中使用 AzaharPlus，最簡單的方式是安裝 Replace 版本，Cocoon 會自動辨識為預設 3DS 核心。

### 系統整合：Batocera
若在 Batocera Linux 上運行，可透過安裝 Batocera 非官方外掛（Unofficial Add-ons）取得支援：
* [batocera-unofficial-addons](https://github.com/batocera-unofficial-addons/batocera-unofficial-addons)

---

## 📬 ZipPass 擦身交錯通訊使用指南

ZipPass 讓玩家可以透過 `.zip` 壓縮檔跨網路與實體限制交換 3DS 的 StreetPass 擦身通訊資料：
* **功能入口**：
  * 電腦桌面端：點選頂部功能表 `檔案 (File)` > `ZipPass`。
  * Android 端：位於主功能表選單中。
* **使用須知與流程**：
  1. 必須在**遊戲未執行**的狀態下開啟。
  2. 必須已下載系統檔案並啟用 LLE 模組。
  3. 請先在各遊戲內部確認已開啟「擦身通訊 (StreetPass)」功能。
  4. **匯出 (Export)**：會將您所有遊戲的擦身資料打包匯出為 `xxx.pass.zip` 檔案。
  5. **匯入 (Import)**：可選取一個或多個 `xxx.pass.zip` 檔案，模擬與其他玩家擦身互動。
  6. 匯入檔案數量無限制，但各遊戲本身有擦身佇列上限，超出上限之資料將自動略過。
  7. 本功能仍具實驗性，若遇異常可在選單中一鍵停用所有遊戲的 StreetPass（不會遺失存檔，之後重新啟用即可）。
  8. 官方討論區提供社群資料交換：[ZipPass Exchange 交流專區](https://github.com/AzaharPlus/AzaharPlus/discussions/117)。

---

## 🛠️ 編譯說明 (Build Instructions)

* **GitHub Actions 雲端自動編譯**：
  * 本儲存庫已配置 [`.github/workflows/build-android.yml`](.github/workflows/build-android.yml)，推送至 `main-zh` 分支或手動觸發 `workflow_dispatch` 即可自動產出最新 APK。
* **本機原始碼編譯**：
  * 詳細環境與依賴配置請參考官方 [Wiki 編譯指南](https://github.com/AzaharPlus/AzaharPlus/wiki/Building-From-Source)。

---

## 💻 最低系統硬體需求 (Minimum Requirements)

### 電腦桌面端 (Desktop)
```text
作業系統：Windows 10 (64 位元) 或 現代 64 位元 Linux
處理器 (CPU)：x86-64 / ARM64 CPU（不支援 Windows on ARM）；Passmark 單核心效能高於 1,800 分
顯示晶片 (GPU)：支援 OpenGL 4.3 或 Vulkan 1.1
記憶體 (RAM)：最低 2 GB，建議 4 GB 以上
```

### 行動與掌機端 (Android)
```text
作業系統：Android 9.0+ (64 位元)
處理器 (SoC)：Qualcomm Snapdragon 835 或更高等級晶片
顯示晶片 (GPU)：支援 OpenGL ES 3.2 或 Vulkan 1.1
記憶體 (RAM)：最低 2 GB，建議 4 GB 以上
```

---

## 🔗 相關專案連結

* **繁體中文版儲存庫**：[yangyws/azahar-zh](https://github.com/yangyws/azahar-zh)
* **AzaharPlus 上游專案**：[AzaharPlus/AzaharPlus](https://github.com/AzaharPlus/AzaharPlus)
* **Azahar 官方母體主線**：[azahar-emu/azahar](https://github.com/azahar-emu/azahar)
* **Radicle 分散式代碼網絡**：[rad:z3A98CGFJYqHnttims4N7jYNzRoDu](https://radicle.network/nodes/rosa.radicle.network/rad%3Az3A98CGFJYqHnttims4N7jYNzRoDu)
