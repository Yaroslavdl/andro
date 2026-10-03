param(
    [string]$Device = '192.168.1.35:5555',
    [string]$OutRoot = 'D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs\boot_hur',
    [string]$Adb = 'D:\platform-tools\adb.exe',
    [int]$PollSeconds = 2
)
$ErrorActionPreference='Stop'
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'; $OutDir=Join-Path $OutRoot "boot_hur_$stamp"; New-Item -ItemType Directory -Force -Path $OutDir|Out-Null
$timeline=Join-Path $OutDir 'timeline.txt'
function Mark([string]$m){ $line="$(Get-Date -Format o) $m"; Write-Host $line; $line|Add-Content $timeline -Encoding utf8 }
function A([string]$cmd){ & $Adb -s $Device shell $cmd 2>&1 }
function Snapshot([string]$name){
  $d=Join-Path $OutDir $name; New-Item -ItemType Directory -Force -Path $d|Out-Null; Mark "snapshot=$name"
  (A 'date; cat /proc/uptime; getprop sys.boot_completed; getprop dev.bootcomplete')|Out-File "$d\state.txt" -Encoding utf8 -Width 4096
  (A 'ps -A -ef')|Out-File "$d\processes.txt" -Encoding utf8 -Width 4096
  (A "ps -A -ef | grep -Ei 'sdAutoReverse|sdCarplaySvc|sd_carplay|sd_mdnsd|carsyso|suding|speedplay|ght-play|audio|bluetooth|sdsdk'")|Out-File "$d\projection-processes.txt" -Encoding utf8 -Width 4096
  (A 'dumpsys media.audio_policy 2>&1')|Out-File "$d\audio-policy.txt" -Encoding utf8 -Width 4096
  (A 'dumpsys media.audio_flinger 2>&1')|Out-File "$d\audio-flinger.txt" -Encoding utf8 -Width 4096
  (A 'tinymix 2>&1')|Out-File "$d\tinymix.txt" -Encoding utf8 -Width 4096
  (A 'for f in /proc/asound/card*/pcm*/sub*/status /proc/asound/card*/pcm*/sub*/hw_params; do [ -r $f ] && { echo ===== $f =====; cat $f; }; done')|Out-File "$d\pcm-state.txt" -Encoding utf8 -Width 4096
  (A 'for n in /dev/goc_serial /dev/carplaySvc_serial; do echo ===== $n =====; ls -lZ $n 2>&1; readlink -f $n 2>&1; done')|Out-File "$d\device-nodes.txt" -Encoding utf8 -Width 4096
  $pidsText=(A "ps -A -o PID,ARGS | awk 'NR > 1 && `$2 ~ /^(sdAutoReverse|sdCarplaySvc|sdCarplaySvc_wire|sd_carplay|sd_mdnsd|sd_mdnsd_wire|sdsdk816|audioserver|android.hardware.audio.service|android.hardware.bluetooth@1.0-service-qti|com.android.bluetooth|com.carsyso.main|com.carsyso.bluetooth|com.carhomekit.mirror|com.suding.speedplay(:daemon)?|ght-play)$/ {print `$1}'" | Out-String)
  $matched=@($pidsText -split '\s+'|?{$_ -match '^\d+$'}|Select-Object -Unique); "matched_pids=$($matched -join ',')"|Set-Content "$d\pid-inventory.txt" -Encoding utf8
  foreach($processId in $matched){ "===== PID $processId ====="|Add-Content "$d\runtime.txt" -Encoding utf8; (A "printf 'cmdline: '; tr '\000' ' ' < /proc/$processId/cmdline 2>&1; echo; printf 'exe: '; readlink /proc/$processId/exe 2>&1; echo --maps--; cat /proc/$processId/maps 2>&1; echo --fds--; ls -lZ /proc/$processId/fd 2>&1")|Add-Content "$d\runtime.txt" -Encoding utf8 }
}
Mark 'collector_started; expected device to be OFF/unreachable'
Write-Host ''; Write-Host 'Now connect/power the X21 from the tablet and let its normal HUR auto-connect sequence run.'; Write-Host 'Waiting for Wi-Fi ADB...'
$firstSeen=$null
while(-not $firstSeen){
  try { & $Adb connect $Device 2>&1|Out-Null; $s=(& $Adb -s $Device get-state 2>&1|Out-String).Trim(); if($s -eq 'device'){ $id=(& $Adb -s $Device shell id 2>&1|Out-String).Trim(); if($id -match 'uid=0\(root\)'){ $firstSeen=Get-Date; Mark "adb_first_seen shell_id=$id"; break } } } catch {}
  Start-Sleep -Seconds $PollSeconds
}
Snapshot 'initial'
Start-Sleep -Seconds 10; Snapshot 't_plus_10s'
Start-Sleep -Seconds 20; Snapshot 't_plus_30s'
Write-Host ''; Write-Host 'When HUR is fully connected and the X21 UI is visible/usable on the tablet, press ENTER.'; [void](Read-Host)
Snapshot 'hur_active'
Mark 'capturing boot-wide logs'
(& $Adb -s $Device logcat -d -b all -v threadtime 2>&1)|Out-File (Join-Path $OutDir 'logcat-all.txt') -Encoding utf8 -Width 4096
(& $Adb -s $Device shell dmesg 2>&1)|Out-File (Join-Path $OutDir 'dmesg.txt') -Encoding utf8 -Width 4096
(A 'ls -lt /data/tombstones 2>&1 | head -40')|Out-File (Join-Path $OutDir 'tombstones.txt') -Encoding utf8 -Width 4096
(A 'getprop')|Out-File (Join-Path $OutDir 'getprop.txt') -Encoding utf8 -Width 4096
Mark 'capture_complete'
@("device=$Device","started=$stamp","adb_first_seen=$($firstSeen.ToString('o'))",'scenario=cold power-on -> Android boot -> automatic projection -> HUR active','read_only=true')|Set-Content (Join-Path $OutDir 'README.txt') -Encoding utf8
Write-Host ''; Write-Host "Cold-boot HUR capture complete: $OutDir"; Write-Host 'Keep the box powered until you have copied/reviewed the output path.'
