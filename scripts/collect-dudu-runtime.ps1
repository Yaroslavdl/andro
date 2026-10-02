param(
    [string]$Device = '192.168.1.35:5555',
    [string]$OutRoot = 'D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs',
    [string]$Adb = 'adb'
)

$ErrorActionPreference = 'Stop'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$OutDir = Join-Path $OutRoot "baseline_$stamp"
$dirs = @('identity','boot','kernel','services','packages','audio','bluetooth','cpaa','filesystem','meta')
$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path (Join-Path $OutDir $_) | Out-Null }

function Invoke-AdbText {
    param([string[]]$Args, [string]$RelativePath)
    $dest = Join-Path $OutDir $RelativePath
    try {
        $output = & $Adb -s $Device @Args 2>&1
        $output | Out-File -FilePath $dest -Encoding utf8 -Width 4096
    } catch {
        "ERROR: $($_.Exception.Message)" | Out-File -FilePath $dest -Encoding utf8
    }
}

function Shell {
    param([string]$Command, [string]$RelativePath)
    Invoke-AdbText -Args @('shell', $Command) -RelativePath $RelativePath
}

Write-Host "Connecting to $Device ..."
& $Adb connect $Device | Out-Host
& $Adb -s $Device wait-for-device

Invoke-AdbText @('get-state') 'meta\adb-state.txt'
Invoke-AdbText @('shell','id') 'identity\id.txt'
Shell 'su -c id 2>&1' 'identity\su-id.txt'
Shell 'date; uptime; uname -a; cat /proc/version' 'identity\system.txt'
Shell 'getprop' 'identity\getprop.txt'
Shell 'getprop ro.build.fingerprint; getprop ro.build.version.incremental; getprop ro.build.version.release; getprop ro.build.version.sdk; getprop ro.vendor.build.version.sdk; getprop ro.product.first_api_level; getprop ro.build.version.security_patch; getprop ro.vendor.build.security_patch' 'identity\build-summary.txt'

# Boot/kernel: passive reads only.
Shell 'dmesg 2>&1' 'boot\dmesg.txt'
Invoke-AdbText @('logcat','-d','-b','all','-v','threadtime') 'boot\logcat-all.txt'
Shell 'cat /proc/cmdline 2>&1; echo; cat /proc/bootconfig 2>&1' 'boot\cmdline-bootconfig.txt'
Shell 'cat /proc/modules 2>&1' 'kernel\proc-modules.txt'
Shell 'lsmod 2>&1' 'kernel\lsmod.txt'
Shell 'cat /proc/interrupts 2>&1' 'kernel\interrupts.txt'

# Processes/services/HALs.
Shell 'ps -A -o USER,PID,PPID,VSZ,RSS,WCHAN,ADDR,S,NAME,ARGS 2>&1 || ps -A -ef 2>&1' 'services\ps.txt'
Shell 'service list 2>&1' 'services\service-list.txt'
Shell 'lshal 2>&1' 'services\lshal.txt'
Shell 'hwservicemanager list 2>&1' 'services\hwservicemanager.txt'
Shell 'vndservicemanager list 2>&1' 'services\vndservicemanager.txt'
Shell 'dumpsys -l 2>&1' 'services\dumpsys-list.txt'
Shell "ps -A -ef 2>&1 | grep -Ei 'sd|car|reverse|mirror|bluetooth|sdsdk|audio|radio|ril|cnss'" 'services\oem-processes.txt'

# Filesystem/mount state. Do not infer SELinux metadata from Windows-extracted stock trees.
Shell 'mount 2>&1' 'filesystem\mount.txt'
Shell 'cat /proc/mounts 2>&1' 'filesystem\proc-mounts.txt'
Shell 'df -h 2>&1' 'filesystem\df.txt'
Shell 'ls -l /dev/block/by-name 2>&1' 'filesystem\block-by-name.txt'
Shell 'cat /proc/partitions 2>&1' 'filesystem\partitions.txt'
Shell 'ls -lZ /dev/goc_serial 2>&1; ls -lZ /dev 2>&1 | grep -Ei "goc|tty|uart|bt|bluetooth"' 'filesystem\bt-device-nodes.txt'

# Packages and actual install paths/versions.
Shell 'pm list packages -f 2>&1' 'packages\packages-f.txt'
Shell "pm list packages 2>&1 | grep -Ei 'dudu|carsyso|suding|bluetooth|mirror|carplay|aibox|reverse|media'" 'packages\oem-packages.txt'
$pkgCmd = @'
for p in $(pm list packages | cut -d: -f2 | grep -Ei 'dudu|carsyso|suding|bluetooth|mirror|carplay|aibox|reverse|media'); do
  echo "===== $p ====="
  pm path "$p"
  dumpsys package "$p" 2>/dev/null | grep -E 'versionName=|versionCode=|codePath=|primaryCpuAbi=|secondaryCpuAbi=|nativeLibraryDir='
done
'@
Shell $pkgCmd 'packages\oem-package-details.txt'

# Audio: all commands below are observation only. No tinymix control is written.
Shell 'dumpsys audio 2>&1' 'audio\dumpsys-audio.txt'
Shell 'dumpsys media.audio_flinger 2>&1' 'audio\audio-flinger.txt'
Shell 'dumpsys media.audio_policy 2>&1' 'audio\audio-policy.txt'
Shell 'tinymix 2>&1' 'audio\tinymix-passive.txt'
Shell 'cat /proc/asound/cards 2>&1; echo; cat /proc/asound/pcm 2>&1; echo; cat /proc/asound/devices 2>&1' 'audio\proc-asound.txt'
Shell "find /vendor/etc /odm/etc -maxdepth 3 -type f 2>/dev/null | grep -Ei 'audio|mixer|sound' | sort" 'audio\config-paths.txt'

# Bluetooth / OEM second-BT.
Shell 'dumpsys bluetooth_manager 2>&1' 'bluetooth\bluetooth-manager.txt'
Shell 'dumpsys bluetooth 2>&1' 'bluetooth\bluetooth.txt'
Shell "getprop | grep -Ei 'bluetooth|bt\.|sdsdk|goc'" 'bluetooth\properties.txt'
Shell "ps -A -ef 2>&1 | grep -Ei 'bluetooth|sdsdk|carsyso|suding|goc'" 'bluetooth\processes.txt'
Shell "find /system /system_ext /product /vendor /odm -type f 2>/dev/null | grep -Ei 'sdsdk816|libSdBTBridge|libcarsyso_serial_port|SdBluetooth'" 'bluetooth\component-paths.txt'

# CP/AA / mirroring stack.
Shell "ps -A -ef 2>&1 | grep -Ei 'sdAutoReverse|sdCarplaySvc|MainAiBox|SdMirror|reverse|carplay|mirror'" 'cpaa\processes.txt'
Shell "find /system /system_ext /product /vendor /odm -type f 2>/dev/null | grep -Ei 'sdAutoReverse|sdCarplaySvc|MainAiBox|SdMirror|sd-reverse|libSdAutoReverse|libSdBridge|libSdCarplay|libAirPlay|libCoreUtils|sd_mdnsd'" 'cpaa\component-paths.txt'
Shell "getprop | grep -Ei 'carplay|androidauto|reverse|mirror|aibox|sd\.'" 'cpaa\properties.txt'

# Small summary for quick validation.
$summary = @(
    "device=$Device",
    "collected=$(Get-Date -Format o)",
    "output=$OutDir",
    'mode=read-only baseline; no setprop/remount/kill/restart/tinymix writes performed'
)
$summary | Set-Content -Encoding UTF8 (Join-Path $OutDir 'meta\README.txt')

Write-Host ''
Write-Host 'Baseline collection complete.'
Write-Host "Output: $OutDir"
Write-Host 'Do not post raw logs publicly before checking for phone numbers, contacts, Wi-Fi names, IPs, account/device identifiers or other private data.'
