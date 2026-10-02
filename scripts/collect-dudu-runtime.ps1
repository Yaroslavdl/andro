param(
    [string]$Device = '192.168.1.35:5555',
    [string]$OutRoot = 'D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs',
    [string]$Adb = 'adb'
)

$ErrorActionPreference = 'Stop'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$OutDir = Join-Path $OutRoot "baseline_$stamp"
$dirs = @('identity','boot','kernel','services','packages','audio','bluetooth','cpaa','filesystem','maps','meta')
$dirs | ForEach-Object { New-Item -ItemType Directory -Force -Path (Join-Path $OutDir $_) | Out-Null }
$script:Step = 0
$script:TotalSteps = 42

function Invoke-AdbText {
    param([string[]]$AdbArgs, [string]$RelativePath)
    $script:Step++
    Write-Host ("[{0:D2}/{1:D2}] {2}" -f $script:Step, $script:TotalSteps, $RelativePath)
    $dest = Join-Path $OutDir $RelativePath
    try {
        $output = & $Adb @AdbArgs 2>&1
        $output | Out-File -FilePath $dest -Encoding utf8 -Width 4096
    } catch {
        "ERROR: $($_.Exception.Message)" | Out-File -FilePath $dest -Encoding utf8
    }
}
function Device-Adb { param([string[]]$DeviceArgs,[string]$RelativePath); Invoke-AdbText -AdbArgs (@('-s',$Device)+$DeviceArgs) -RelativePath $RelativePath }
function Shell { param([string]$Command,[string]$RelativePath); Device-Adb -DeviceArgs @('shell','sh','-c',$Command) -RelativePath $RelativePath }

Write-Host "Connecting to $Device ..."
& $Adb connect $Device | Out-Host
& $Adb -s $Device wait-for-device
$state = (& $Adb -s $Device get-state 2>&1 | Out-String).Trim()
if ($state -ne 'device') { throw "ADB device state is '$state', expected 'device'." }
$idProbe = (& $Adb -s $Device shell id 2>&1 | Out-String).Trim()
if ($idProbe -notmatch 'uid=0\(root\)') { throw "Collector requires the already-root ADB shell seen on DUDU. Got: $idProbe" }
$state | Set-Content -Encoding UTF8 (Join-Path $OutDir 'meta\adb-state.txt')
$idProbe | Set-Content -Encoding UTF8 (Join-Path $OutDir 'identity\id.txt')

Shell 'date; uptime; uname -a; cat /proc/version' 'identity\system.txt'
Shell 'getprop' 'identity\getprop.txt'
Shell 'getenforce 2>&1; printf "selinux_enforce="; cat /sys/fs/selinux/enforce 2>&1' 'identity\selinux.txt'
Shell 'getprop ro.build.fingerprint; getprop ro.build.version.incremental; getprop ro.build.version.release; getprop ro.build.version.sdk; getprop ro.vendor.build.version.sdk; getprop ro.product.first_api_level; getprop ro.build.version.security_patch; getprop ro.vendor.build.security_patch' 'identity\build-summary.txt'
Shell 'dmesg 2>&1' 'boot\dmesg.txt'
Device-Adb -DeviceArgs @('logcat','-d','-b','all','-v','threadtime') -RelativePath 'boot\logcat-all.txt'
Shell 'cat /proc/cmdline 2>&1; echo; cat /proc/bootconfig 2>&1' 'boot\cmdline-bootconfig.txt'
Shell 'cat /proc/modules 2>&1' 'kernel\proc-modules.txt'
Shell 'lsmod 2>&1' 'kernel\lsmod.txt'
Shell 'cat /proc/interrupts 2>&1' 'kernel\interrupts.txt'
Shell 'ps -A -o USER,PID,PPID,VSZ,RSS,WCHAN,ADDR,S,NAME,ARGS 2>&1 || ps -A -ef 2>&1' 'services\ps.txt'
Shell 'service list 2>&1' 'services\service-list.txt'
Shell 'lshal 2>&1' 'services\lshal.txt'
Shell 'dumpsys -l 2>&1' 'services\dumpsys-list.txt'
Shell "ps -A -ef 2>&1 | grep -Ei 'sd|car|reverse|mirror|bluetooth|sdsdk|audio|radio|ril|cnss'" 'services\oem-processes.txt'
Shell 'mount 2>&1' 'filesystem\mount.txt'
Shell 'cat /proc/mounts 2>&1' 'filesystem\proc-mounts.txt'
Shell 'df -h 2>&1' 'filesystem\df.txt'
Shell 'ls -l /dev/block/by-name 2>&1' 'filesystem\block-by-name.txt'
Shell 'cat /proc/partitions 2>&1' 'filesystem\partitions.txt'
Shell 'for n in /dev/goc_serial /dev/carplaySvc_serial; do echo "===== $n ====="; ls -lZ "$n" 2>&1; readlink -f "$n" 2>&1; done; echo "===== related dev nodes ====="; ls -lZ /dev 2>/dev/null | grep -Ei "goc|tty|uart|bt|bluetooth|carplay"' 'filesystem\device-nodes.txt'
Shell 'pm list packages -f 2>&1' 'packages\packages-f.txt'
Shell "pm list packages 2>&1 | grep -Ei 'dudu|carsyso|suding|bluetooth|mirror|carplay|aibox|reverse|media'" 'packages\oem-packages.txt'
Shell 'for p in com.carsyso.main com.carsyso.bluetooth com.carhomekit.mirror; do echo "===== $p ====="; pm path "$p" 2>&1; dumpsys package "$p" 2>/dev/null | grep -E "versionName=|versionCode=|codePath=|primaryCpuAbi=|secondaryCpuAbi=|nativeLibraryDir="; done' 'packages\oem-package-details.txt'
Shell 'dumpsys audio 2>&1' 'audio\dumpsys-audio.txt'
Shell 'dumpsys media.audio_flinger 2>&1' 'audio\audio-flinger.txt'
Shell 'dumpsys media.audio_policy 2>&1' 'audio\audio-policy.txt'
Shell 'tinymix 2>&1' 'audio\tinymix-passive.txt'
Shell 'cat /proc/asound/cards 2>&1; echo; cat /proc/asound/pcm 2>&1; echo; cat /proc/asound/devices 2>&1' 'audio\proc-asound.txt'
Shell 'for f in /proc/asound/card*/pcm*/sub*/status /proc/asound/card*/pcm*/sub*/hw_params; do [ -r "$f" ] && { echo "===== $f ====="; cat "$f"; }; done' 'audio\pcm-state.txt'
Shell "find /vendor/etc /odm/etc -maxdepth 3 -type f 2>/dev/null | grep -Ei 'audio|mixer|sound' | sort" 'audio\config-paths.txt'
Shell 'dumpsys bluetooth_manager 2>&1' 'bluetooth\bluetooth-manager.txt'
Shell "getprop | grep -Ei 'bluetooth|bt\.|sdsdk|goc'" 'bluetooth\properties.txt'
Shell "ps -A -ef 2>&1 | grep -Ei 'bluetooth|sdsdk|carsyso|suding|goc'" 'bluetooth\processes.txt'
Shell "ps -A -ef 2>&1 | grep -Ei 'sdAutoReverse|sdCarplaySvc|sd_carplay|MainAiBox|SdMirror|reverse|carplay|mirror'" 'cpaa\processes.txt'
Shell "getprop | grep -Ei 'carplay|androidauto|reverse|mirror|aibox|sd\.'" 'cpaa\properties.txt'
Shell 'for pid in $(ps -A -o PID,ARGS 2>/dev/null | grep -Ei "sdAutoReverse|sdCarplaySvc|sd_carplay|com.carsyso.main|com.carsyso.bluetooth|com.carhomekit.mirror|sdsdk816|audioserver|android.hardware.audio" | grep -v grep | awk "{print \$1}"); do echo "===== PID $pid ====="; printf "cmdline: "; tr "\000" " " < /proc/$pid/cmdline 2>/dev/null; echo; printf "exe: "; readlink /proc/$pid/exe 2>&1; echo "-- maps --"; grep -E "\.so($| )|/apex/|/system/|/vendor/|/odm/|/product/" /proc/$pid/maps 2>/dev/null; echo "-- fds --"; ls -l /proc/$pid/fd 2>/dev/null; done' 'maps\relevant-process-runtime.txt'
Shell 'ls -lt /data/tombstones 2>&1 | head -40' 'boot\tombstones.txt'

$probe = Get-Content -Raw -ErrorAction SilentlyContinue (Join-Path $OutDir 'identity\getprop.txt')
if (-not $probe -or $probe -notmatch '\[ro\.') { throw "Collection validation failed: invalid getprop output: $OutDir" }
$mapsProbe = Get-Content -Raw -ErrorAction SilentlyContinue (Join-Path $OutDir 'maps\relevant-process-runtime.txt')
if (-not $mapsProbe -or $mapsProbe -notmatch '===== PID') { Write-Warning 'Process runtime capture contains no matched PIDs; baseline is otherwise retained.' }
$summary = @("device=$Device","collected=$(Get-Date -Format o)","output=$OutDir","adb_state=$state","shell_id=$idProbe",'validation=passed','mode=read-only runtime baseline; ADB shell already root; no su/setprop/remount/kill/restart/tinymix writes')
$summary | Set-Content -Encoding UTF8 (Join-Path $OutDir 'meta\README.txt')
Write-Host ''; Write-Host 'Baseline collection complete and validation passed.'; Write-Host "Output: $OutDir"
