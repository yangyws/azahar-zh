import urllib.request
import json
import ssl
import time
import os
import zipfile
import subprocess
import sys

token = os.getenv("GITHUB_TOKEN", "")
if not token:
    try:
        gh_proc = subprocess.run(["gh", "auth", "token"], capture_output=True, text=True)
        if gh_proc.returncode == 0 and gh_proc.stdout.strip():
            token = gh_proc.stdout.strip()
    except Exception:
        pass

headers = {
    "User-Agent": "Python/3.11",
    "Accept": "application/vnd.github+json"
}
if token:
    headers["Authorization"] = f"token {token}"
ctx = ssl.create_default_context()

repo = "yangyws/azahar-zh"
branch = "main-zh"
workflow_file = "build-android.yml"

# 1. 觸發 workflow_dispatch
print(f"[*] 正在為分支 {branch} 觸發 GitHub Actions 工作流程 ({workflow_file})...")
dispatch_url = f"https://api.github.com/repos/{repo}/actions/workflows/{workflow_file}/dispatches"
req = urllib.request.Request(dispatch_url, data=json.dumps({"ref": branch}).encode('utf-8'), headers=headers, method='POST')
try:
    with urllib.request.urlopen(req, context=ctx) as resp:
        print(f"[*] 成功觸發工作流程！HTTP {resp.status}")
except Exception as e:
    print(f"[!] 觸發工作流程時回傳：{e}")

time.sleep(5)

# 2. 尋找最新執行的 run
print(f"[*] 正在尋找 {branch} 分支的最新工作流程執行記錄...")
run_id = None
for attempt in range(15):
    try:
        runs_req = urllib.request.Request(f"https://api.github.com/repos/{repo}/actions/runs?branch={branch}&per_page=3", headers=headers)
        with urllib.request.urlopen(runs_req, context=ctx) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            runs = data.get('workflow_runs', [])
            if runs:
                latest = runs[0]
                print(f"[*] 找到最新 Run ID: {latest['id']} | 名稱: {latest['name']} | 狀態: {latest['status']} | 事件: {latest['event']}")
                run_id = latest['id']
                break
    except Exception as e:
        print(f"[!] 查詢工作流程記錄失敗：{e}")
    time.sleep(5)

if not run_id:
    print("[!] 未找到正在執行的工作流程 ID。")
    sys.exit(1)

# 3. 輪詢直到編譯完成
print(f"[*] 開始監控 Run {run_id} 編譯進度...")
start_time = time.time()
while True:
    try:
        run_req = urllib.request.Request(f"https://api.github.com/repos/{repo}/actions/runs/{run_id}", headers=headers)
        with urllib.request.urlopen(run_req, context=ctx) as resp:
            data = json.loads(resp.read().decode('utf-8'))
            status = data.get('status')
            conclusion = data.get('conclusion')
            elapsed = int(time.time() - start_time)
            print(f"[{time.strftime('%H:%M:%S')} | 已耗時 {elapsed}s] Run {run_id}: 狀態={status}, 結果={conclusion}")
            if status == 'completed':
                if conclusion != 'success':
                    print(f"[!] 編譯未成功結束：{conclusion}")
                    sys.exit(1)
                print("[+] 編譯成功完成！")
                break
    except Exception as e:
        print(f"[!] 狀態檢查異常：{e}")
    time.sleep(15)

# 4. 下載 Artifact
print(f"[*] 正在獲取 Run {run_id} 的產物列表...")
art_req = urllib.request.Request(f"https://api.github.com/repos/{repo}/actions/runs/{run_id}/artifacts", headers=headers)
with urllib.request.urlopen(art_req, context=ctx) as resp:
    art_data = json.loads(resp.read().decode('utf-8'))
    artifacts = art_data.get('artifacts', [])
    if not artifacts:
        print("[!] 未找到任何產物！")
        sys.exit(1)
    artifact = artifacts[0]
    dl_url = artifact['archive_download_url']
    print(f"[*] 正在下載產物：{artifact['name']} ({artifact['size_in_bytes']} bytes)...")

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

opener = urllib.request.build_opener(NoRedirect, urllib.request.HTTPSHandler(context=ctx))
dl_req = urllib.request.Request(dl_url, headers=headers)
redirect_url = None
try:
    resp = opener.open(dl_req)
    redirect_url = resp.getheader('Location')
except urllib.error.HTTPError as e:
    if e.code in (301, 302, 303, 307, 308):
        redirect_url = e.headers.get('Location')
    else:
        raise

base_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "artifacts")
os.makedirs(base_dir, exist_ok=True)
zip_path = os.path.join(base_dir, "downloaded_artifact.zip")
blob_req = urllib.request.Request(redirect_url)
with urllib.request.urlopen(blob_req, context=ctx) as resp, open(zip_path, "wb") as f:
    f.write(resp.read())

print(f"[*] 正在解壓縮產物至 {base_dir}...")
with zipfile.ZipFile(zip_path, 'r') as zip_ref:
    zip_ref.extractall(base_dir)
os.remove(zip_path)

apk_files = [os.path.join(base_dir, f) for f in os.listdir(base_dir) if f.endswith('.apk')]
if not apk_files:
    print("[!] 解壓後未找到任何 APK 檔案！")
    sys.exit(1)

# 優先挑選 vanilla
vanilla_apks = [f for f in apk_files if 'vanilla' in os.path.basename(f)]
target_apk = vanilla_apks[0] if vanilla_apks else apk_files[0]
print(f"[+] APK 準備就緒：{target_apk}")

# 5. 檢查 ADB 設備並嘗試安裝
print("[*] 正在檢查 ADB 連接設備...")
adb_cmd = "adb"
res_devices = subprocess.run([adb_cmd, "devices"], capture_output=True, text=True)
device_lines = [l for l in res_devices.stdout.splitlines() if l.strip() and not l.startswith("List of")]

connected_devices = [l.split()[0] for l in device_lines if '\tdevice' in l]
if not connected_devices:
    print("[!] 目前未檢測到已授權連線的 Android 設備。")
    print(f"[+] APK 已妥善保存在：{target_apk}")
    print("[+] 當您連接好掌機或手機後，隨時可雙擊 deploy.bat 進行部署安裝！")
    sys.exit(0)

device_id = connected_devices[0]
package_name = "io.github.lime3ds.android.zh"
main_activity = "org.citra.citra_emu.ui.main.MainActivity"

print(f"[*] 正在部署 APK 至設備 {device_id}...")
res_install = subprocess.run([adb_cmd, "-s", device_id, "install", "-r", "-d", target_apk], capture_output=True, text=True)
print(res_install.stdout)

if "INSTALL_FAILED_UPDATE_INCOMPATIBLE" in res_install.stdout or "INSTALL_FAILED_UPDATE_INCOMPATIBLE" in res_install.stderr:
    print("[提示] 檢測到簽章不相符，正在自動解除安裝舊版本並重新安裝...")
    subprocess.run([adb_cmd, "-s", device_id, "uninstall", package_name], capture_output=True)
    res_retry = subprocess.run([adb_cmd, "-s", device_id, "install", "-r", "-d", target_apk], capture_output=True, text=True)
    print(res_retry.stdout)

# 6. 啟動 App
print(f"[*] 正在設備上啟動 {package_name}...")
res_start = subprocess.run([adb_cmd, "-s", device_id, "shell", "am", "start", "-n", f"{package_name}/{main_activity}"], capture_output=True, text=True)
print(res_start.stdout)

print("[+] 部署流程全部順利完成！")
