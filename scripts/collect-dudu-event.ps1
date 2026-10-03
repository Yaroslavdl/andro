param(
    [Parameter(Mandatory=$true)][string]$Name,
    [string]$Device = '192.168.1.35:5555',
    [string]$OutRoot = 'D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs\events',
    [string]$Adb = 'D:\platform-tools\adb.exe'
)
$ErrorActionPreference='Stop'
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'
$safeName=($Name -replace '[^A-Za-z0-9._-]','_')
$OutDir=Join-Path $OutRoot "${stamp}_${safeName}"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
function Save([string]$file,[string]$cmd){ Write-Host "  -> $file"; (& $Adb -s $Device shell sh -c $cmd 2>&1) | Out-File (Join-Path $OutDir $file) -Encoding utf8 -Width 4096 }
function Snapshot([string]$stage){
  Write-Host "[$stage] snapshot"
  $d=Join-Path $OutDir $stage; New-Item -ItemType Directory -Force -Path $d | Out-Null
  function S([string]$f,[string]$c){ (& $Adb -s $Device shell sh -c $c 2>&1) | Out-File (Join-Path $d $f) -Encoding utf8 -Width 4096 }
  S 'time.txt' 'date; cat /proc/uptime'
  S 'processes.txt' 'ps -A -ef'
  S 'selinux.txt' 'getenforce 2>&1; cat /sys/fs/selinux/enforce 2>&1'
  S 'bt-manager.txt' 'dumpsys bluetooth_manager 2>&1'
  S 'audio-policy.txt' 'dumpsys media.audio_policy 2>&1'
  S 'audio-flinger.txt' 'dumpsys media.audio_flinger 2>&1'
  S 'tinymix.txt' 'tinymix 2>&1'
  S 'pcm-state.txt' 'for f in /proc/asound/card*/pcm*/sub*/status /proc/asound/card*/pcm*/sub*/hw_params; do [ -r "$f" ] && { echo "===== $f ====="; cat "$f"; }; done'
  S 'device-nodes.txt' 'for n in /dev/goc_serial /dev/carplaySvc_serial; do echo "===== $n ====="; ls -lZ "$n" 2>&1; readlink -f "$n" 2>&1; done'
  S 'runtime.txt' 'for pid in $(ps -A -o PID,ARGS 2>/dev/null | grep -Ei "sdAutoReverse|sdCarplaySvc|sd_carplay|com.carsyso.main|com.carsyso.bluetooth|com.carhomekit.mirror|sdsdk816|audioserver|android.hardware.audio" | grep -v grep | awk "{print \$1}"); do echo "===== PID $pid ====="; printf "cmdline: "; tr "\000" " " < /proc/$pid/cmdline 2>/dev/null; echo; printf "exe: "; readlink /proc/$pid/exe 2>&1; echo "-- maps --"; grep -E "\.so($| )|/apex/|/system/|/vendor/|/odm/|/product/" /proc/$pid/maps 2>/dev/null; echo "-- fds --"; ls -l /proc/$pid/fd 2>/dev/null; done'
}
& $Adb connect $Device | Out-Host
$state=(& $Adb -s $Device get-state 2>&1 | Out-String).Trim(); if($state -ne 'device'){throw "ADB state: $state"}
$id=(& $Adb -s $Device shell id 2>&1 | Out-String).Trim(); if($id -notmatch 'uid=0\(root\)'){throw "Root ADB shell required; got $id"}
@("name=$Name","device=$Device","started=$(Get-Date -Format o)","shell_id=$id") | Set-Content (Join-Path $OutDir 'README.txt') -Encoding utf8
Snapshot 'before'
Write-Host ''; Write-Host "Perform event now: $Name"; Write-Host 'When the event is ACTIVE/stable, press ENTER.'; [void](Read-Host)
Snapshot 'active'
Write-Host ''; Write-Host 'Now stop/disconnect/return from the event. When restored, press ENTER.'; [void](Read-Host)
Snapshot 'after'
Write-Host '[logs] capturing current buffers without clearing them'
(& $Adb -s $Device logcat -d -b all -v threadtime 2>&1) | Out-File (Join-Path $OutDir 'logcat-all.txt') -Encoding utf8 -Width 4096
(& $Adb -s $Device shell dmesg 2>&1) | Out-File (Join-Path $OutDir 'dmesg.txt') -Encoding utf8 -Width 4096
(& $Adb -s $Device shell sh -c 'ls -lt /data/tombstones 2>&1 | head -40' 2>&1) | Out-File (Join-Path $OutDir 'tombstones.txt') -Encoding utf8 -Width 4096
"completed=$(Get-Date -Format o)" | Add-Content (Join-Path $OutDir 'README.txt') -Encoding utf8
Write-Host ''; Write-Host "Event capture complete: $OutDir"; Write-Host 'Review logs for phone numbers, contacts and identifiers before sharing publicly.'
