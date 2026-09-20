[English](README.md) | **台灣繁體中文**

---

<b>AzaharPlus</b> 是基於 Azahar 3DS 模擬器的功能強化分支版本。

每個版本皆對齊 Azahar 的對應版本，但具備以下額外改進：
- 相容於所有遊戲檔案。若某個檔案能在任何 Citra 分支上運作，它就能在 AzaharPlus 上運作。
- 支援直接從官方伺服器下載系統檔案。無需擁有真實的 3DS 主機。
- 相容於較舊款的 CPU（無需 SSE4.2 指令集支援）。
- 相容於 Android 9。
- ZipPass：透過 zip 壓縮檔交換 StreetPass（擦身通訊）資料的全新方式。
- 內建金手指作弊碼。
- Amiibo 虛擬生成。
- 與其他 Citra 分支具備更佳的多人連線相容性。

Azahar 標誌版權歸 PabloMK7 與 angyartanddraw 所有。

---

![Azahar Emulator](https://azahar-emu.org/resources/images/logo/azahar-name-and-logo.svg)
![Plus](https://cdn-icons-png.flaticon.com/128/226/226974.png)

![GitHub Release](https://img.shields.io/github/v/release/AzaharPlus/AzaharPlus?label=Current%20Release)
![GitHub Downloads](https://img.shields.io/github/downloads/AzaharPlus/AzaharPlus/total?logo=github&label=GitHub%20Downloads)

# 安裝指南 (Installation)

請至 [Releases 發布頁面](https://github.com/AzaharPlus/AzaharPlus/releases) 下載最新版本。

### Android

Android 建置版本提供 2 種變體：

- 覆蓋版 (Replace)：使用與 Azahar 相同的應用程式 ID，因此安裝時會直接取代裝置上的原版應用程式。
其顯示名稱為「AzaharPlus」，圖示背景為藍色。
若您有其他指向 Azahar 的應用程式（例如前端啟動器），請使用此版本。

- 共存版 (Coexist)：採用全新獨立的應用程式 ID，因此可與 Azahar 並存安裝且互不衝突。
其顯示名稱為「+AzaharPlus+」，圖示背景為紅色。

### Cocoon

在 Cocoon 上使用 AzaharPlus 最簡單的方式是解除安裝 Azahar，並安裝 AzaharPlus 的覆蓋版 (Replace)。Cocoon 會將其視為 Azahar。

### Batocera

若要在 Batocera 上使用 AzaharPlus，您可以安裝 Batocera 非官方擴充套件：

https://github.com/batocera-unofficial-addons/batocera-unofficial-addons

# ZipPass

ZipPass 讓您能夠以 zip 壓縮檔的形式分享 StreetPass（擦身通訊）資料。<br>
在電腦桌面端位於「檔案 > ZipPass」。在 Android 端位於主選單中。

- 僅能在未執行任何遊戲時使用。
- 需要啟用系統檔案與 LLE 模組。
- 您需要在遊戲中開啟 StreetPass 功能。
- 匯出功能會將您所有遊戲的 StreetPass 資料儲存至一個 `xxx.pass.zip` 檔案中。
- 匯入功能讓您挑選一個或多個 `xxx.pass.zip` 檔案，並模擬擦身通訊標記。
- 匯入時可依喜好選取任意數量的檔案，但每款遊戲都有其佇列上限，超出上限的資料將會被忽略。
- 此功能仍處於實驗性質，因此為防發生問題，我加入了一個選單可用於在每款遊戲上停用 StreetPass。您不會遺失任何資料，只需重新啟用 StreetPass 即可。
- 我在 GitHub 上開啟了一個討論串供大家互相分享擦身資料：[ZipPass Exchange](https://github.com/AzaharPlus/AzaharPlus/discussions/117)

# 建置指示 (Build instructions)

原始碼編譯指示請參閱本儲存庫的 [Wiki](https://github.com/AzaharPlus/AzaharPlus/wiki/Building-From-Source)。

# 最低系統需求 (Minimum requirements)
以下為執行 AzaharPlus 的最低硬體需求：

### 電腦桌面端 (Desktop)
```text
作業系統：Windows 10 (64 位元)，或現代 64 位元 Linux
處理器 (CPU)：x86-64 / ARM64 CPU（不支援 Windows on ARM）。Passmark 單核心效能高於 1,800 分
顯示晶片 (GPU)：支援 OpenGL 4.3 或 Vulkan 1.1
記憶體 (RAM)：2 GB RAM。建議 4 GB
```
### 行動裝置端 (Android)
```text
作業系統：Android 9.0+ (64 位元)
處理器 (CPU)：Snapdragon 835 SoC 或更高階晶片
顯示晶片 (GPU)：支援 OpenGL ES 3.2 或 Vulkan 1.1
記憶體 (RAM)：2 GB RAM。建議 4 GB
```

# 專案相關位置 (Where to find this project)
- GitHub: https://github.com/AzaharPlus/AzaharPlus
- Radicle: [rad:z3A98CGFJYqHnttims4N7jYNzRoDu](https://radicle.network/nodes/rosa.radicle.network/rad%3Az3A98CGFJYqHnttims4N7jYNzRoDu)
