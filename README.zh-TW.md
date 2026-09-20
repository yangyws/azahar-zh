<div align="center">

[English](README.md) | **台灣繁體中文**

---

![Azahar 模擬器](https://azahar-emu.org/resources/images/logo/azahar-name-and-logo.svg)

![最新正式版本](https://img.shields.io/github/v/release/azahar-emu/azahar?label=最新正式版本)
![最新預發布版本](https://img.shields.io/github/v/release/azahar-emu/azahar?include_prereleases&label=最新預發布版本)

![GitHub 下載次數](https://img.shields.io/github/downloads/azahar-emu/azahar/total?logo=github&label=GitHub%20下載次數)
![Google Play 下載次數](https://playbadges.pavi2410.com/badge/downloads?id=io.github.lime3ds.android&pretty&label=Google%20Play%20下載次數)
![Flathub 下載次數](https://img.shields.io/flathub/downloads/org.azahar_emu.Azahar?logo=flathub&label=Flathub%20下載次數)
![CI 建置狀態](https://github.com/azahar-emu/azahar/actions/workflows/build.yml/badge.svg)

</div>

**Azahar** 是一款適用於個人電腦與行動裝置的免費且開源任天堂 3DS 高階模擬器。我們的目標是讓 3DS 玩家能夠享受其遊戲庫收藏，並帶來超越原始硬體的提升體驗，例如更高的畫面解析度、現代控制器支援以及即時存檔功能。本模擬器同時也是自製程式（Homebrew）開發者的偵錯中心，以及 3DS 生態系統的研究與數位保存平台。

本專案承襲自 **Citra** 的開源精神，並由社群貢獻者共同積極維護與開發。

*Azahar 與任天堂 (Nintendo) 無關，亦未獲得任天堂之認可或授權。*

---

# 安裝指南 (Installation)

### Windows

Azahar 提供安裝檔（Installer）與可攜式壓縮檔（Zip）兩種格式。

請至 [Releases](https://github.com/azahar-emu/azahar/releases) 發布頁面下載您偏好格式的最新版本。

若您不確定要選擇 MSVC 還是 MSYS2 版本，建議使用 MSYS2 版本。

---

### macOS

若您希望下載可在所有 Mac 電腦上通用的版本，可至 [Releases](https://github.com/azahar-emu/azahar/releases) 頁面下載 `macos-universal` 版本。

或者，若您希望下載專門針對您 Mac 硬體最佳化的版本，可選擇：

- `macos-arm64`：適用於 Apple Silicon (M 系列晶片) Mac
- `macos-x86_64`：適用於 Intel 處理器 Mac

---

### Android

Azahar 在 Android 平台提供兩種建置版本：Vanilla 與 Google Play 版本。

Vanilla 版本在技術上較為優異，因為它採用了更快速的替代檔案管理機制，但此機制未獲 Google Play 商店政策允許。

對於大多數使用者，目前建議透過 Google Play 商店下載 Android 版 Azahar，以獲得最佳便利性：

<a href='https://play.google.com/store/apps/details?id=io.github.lime3ds.android'><img width='180' alt='前往 Google Play 下載' src='https://raw.githubusercontent.com/pioug/google-play-badges/06ccd9252af1501613da2ca28eaffe31307a4e6d/svg/English.svg'/></a>

或者，您可以透過 Obtainium 應用程式安裝，以取得 Vanilla 版本：
1. 從 [此處](https://github.com/ImranR98/Obtainium/releases) 下載並安裝 Obtainium（使用名為 `app-release.apk` 的檔案）。
2. 開啟 Obtainium 並點選「Add App」。
3. 在「App Source URL」欄位輸入 `https://github.com/azahar-emu/azahar`。
4. 點選「Add」。
5. 點選「Install」，並選擇偏好的版本。

若您願意，亦可直接從 [Releases](https://github.com/azahar-emu/azahar/releases) 頁面下載最新版 APK 進行側載安裝。

請注意：透過 APK 手動安裝將無法收到自動更新通知。

---

### Linux

在 Linux 上使用 Azahar 的推薦格式為 Flathub 上的 Flatpak：

<a href='https://flathub.org/apps/org.azahar_emu.Azahar'><img width='180' alt='於 Flathub 下載' src='https://dl.flathub.org/assets/badges/flathub-badge-en.png'/></a>

Azahar 亦在 [Releases](https://github.com/azahar-emu/azahar/releases) 頁面提供 AppImage 格式。

AppImage 提供兩種版本：`azahar.AppImage` 與 `azahar-wayland.AppImage`。

若您不確定該使用哪個版本，建議使用預設的 `azahar.AppImage`。這是因為 Wayland 生態系統上游存在可能導致模擬器執行異常的問題（例如 [#1162](https://github.com/azahar-emu/azahar/issues/1162)）。

除非您明確需要原生 Wayland 支援（例如執行沒有 Xwayland 的系統環境），否則建議使用非 Wayland 版本。

此外，Azahar 的 Flatpak 版本預設亦已停用原生 Wayland 支援。若您需要原生 Wayland 支援，可透過 [Flatseal](https://flathub.org/en/apps/com.github.tchx84.Flatseal) 工具手動啟用。

---

# 編譯指南 (Build Instructions)

原始碼建置環境與編譯指示請參閱本儲存庫的 [Wiki](https://github.com/azahar-emu/azahar/wiki/Building-From-Source)。

---

# 如何參與貢獻？(How Can I Contribute?)

### Pull Requests (程式碼貢獻)

若您希望實作改進並具備相關技術能力，我們非常歡迎您的參與與貢獻。

若您準備貢獻新功能，強烈建議在開始撰寫程式碼前，先發起 Feature Request Issue 進行討論，確保您的寶貴時間不會花在不適合專案規劃的方向上。

建立 Pull Request 後，請勿反覆將 `master` 合併至您的分支。維護者會在適當時機為您更新分支。

### 多語系翻譯 (Language Translations)

此外，我們在 [Transifex](https://app.transifex.com/azahar/azahar) 接受多語系在地化翻譯貢獻。若您精通 Transifex 頁面上列出的任何語系，歡迎隨時協助翻譯。

> [!NOTE]
> 目前暫不接受新增未列入清單的全新語系，請勿要求新增清單外的語系或語系變體。

### 相容性回報 (Compatibility Reports)

即使您不打算貢獻程式碼或翻譯，您也可以透過向我們的相容性清單回報遊戲相容性資料來協助本專案。

詳細操作方式請閱讀 [CONTRIBUTING.md](https://github.com/azahar-emu/compatibility-list/blob/master/CONTRIBUTING.md) 並遵循指示。

提供相容性測試資料有助於更準確地反映模擬器的實際能力，非常感謝您在通關遊戲後參與回報流程。

---

# 最低系統需求 (Minimum Requirements)

以下為執行 Azahar 的最低硬體規格需求：

### 電腦桌面端 (Desktop)
```text
作業系統：Windows 10 (64 位元)、macOS 13.4 (Ventura) 或 現代 64 位元 Linux
處理器 (CPU)：x86-64 / ARM64 CPU（不支援 Windows on ARM）；
              Passmark 單核心效能高於 1,800 分；x86_64 架構需要支援 SSE4.2。
顯示晶片 (GPU)：支援 OpenGL 4.3 或 Vulkan 1.1
記憶體 (RAM)：最低 2 GB，建議 4 GB 以上
```

### 行動裝置端 (Android)
```text
作業系統：Android 10.0+ (64 位元)
處理器 (SoC)：Qualcomm Snapdragon 835 或更高等級晶片
顯示晶片 (GPU)：支援 OpenGL ES 3.2 或 Vulkan 1.1
記憶體 (RAM)：最低 2 GB，建議 4 GB 以上
```

---

# 未來藍圖 (What's Next?)

我們以 GitHub Milestones 的形式公開釋出未來版本的規劃藍圖。

您可於 [GitHub Milestones](https://github.com/azahar-emu/azahar/milestones) 查閱即時進度。

---

# 社群交流 (Join the Conversation)

我們擁有社群 Discord 伺服器，歡迎在此暢聊專案、獲取最新公告、或與開發者協調模擬器進度。

歡迎加入：https://discord.gg/4ZjMpAp3M6
