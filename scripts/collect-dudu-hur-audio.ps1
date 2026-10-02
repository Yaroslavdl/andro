param(
    [string]$Device='192.168.1.35:5555',
    [string]$OutRoot='D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs\audio_events',
    [string]$Adb='D:\platform-tools\adb.exe'
)
$ErrorActionPreference='Stop'
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'; $OutDir=Join-Path $OutRoot "hur_audio_$stamp"; New-Item -ItemType Directory -Force -Path $OutDir|Out-Null
$timeline=Join-Path $OutDir 'timeline.txt'
function Mark([string]$m){$x="$(Get-Date -Format o) $m";Write-Host $x;$x|Add-Content $timeline -Encoding utf8}
function A([string]$cmd){& $Adb -s $Device shell $cmd 2>&1}
function Snap([string]$name){
 $d=Join-Path $OutDir $name;New-Item -ItemType Directory -Force -Path $d|Out-Null;Mark "snapshot=$name"
 (A 'date; cat /proc/uptime; getprop sys.boot_completed')|Out-File "$d\state.txt" -Encoding utf8 -Width 4096
 (A "ps -A -ef | grep -Ei 'sdAutoReverse|sd_carplay|sdsdk|carsyso|suding|speedplay|ght-play|audioserver|audio.service'")|Out-File "$d\processes.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys audio 2>&1')|Out-File "$d\dumpsys-audio.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys media.audio_flinger 2>&1')|Out-File "$d\audio-flinger.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys media.audio_policy 2>&1')|Out-File "$d\audio-policy.txt" -Encoding utf8 -Width 4096
 (A 'tinymix 2>&1')|Out-File "$d\tinymix.txt" -Encoding utf8 -Width 4096
 (A 'for f in /proc/asound/card*/pcm*/sub*/status /proc/asound/card*/pcm*/sub*/hw_params; do if [ -r "$f" ]; then echo ===== "$f" =====; cat "$f"; fi; done')|Out-File "$d\pcm-state.txt" -Encoding utf8 -Width 4096
 (A 'cat /proc/asound/cards; echo; cat /proc/asound/pcm')|Out-File "$d\proc-asound.txt" -Encoding utf8 -Width 4096
 (A 'for p in $(pidof ght-play) $(pidof sdAutoReverse); do if [ -n "$p" ]; then echo ===== PID $p =====; cat /proc/$p/cmdline | tr "\000" " "; echo; ls -lZ /proc/$p/fd 2>&1; fi; done')|Out-File "$d\audio-relevant-fds.txt" -Encoding utf8 -Width 4096
}
Mark 'collector_started'
& $Adb connect $Device|Out-Host; & $Adb -s $Device wait-for-device
$id=(& $Adb -s $Device shell id 2>&1|Out-String).Trim();if($id-notmatch'uid=0\(root\)'){throw "Root ADB shell required: $id"}
Mark "connected $id"
Write-Host '';Write-Host 'Prerequisite: HUR must already show the X21 UI and be stable. Do not change mixer controls manually.'
Write-Host 'Prepare a local media track/app on X21, but keep playback STOPPED/PAUSED. Press ENTER.';[void](Read-Host);Snap '00_hur_idle'
Write-Host '';Write-Host 'Start LOCAL MEDIA playback on X21. Confirm that you can tell whether it is audible through HUR/head-unit. Wait ~10 seconds, then press ENTER.';[void](Read-Host);Snap '01_playing'
Write-Host '';Write-Host 'PAUSE playback. Wait ~5 seconds, then press ENTER.';[void](Read-Host);Snap '02_paused'
Write-Host '';Write-Host 'RESUME the same playback. Wait ~10 seconds, then press ENTER.';[void](Read-Host);Snap '03_resumed'
Write-Host '';Write-Host 'STOP playback completely. Wait ~10 seconds, then press ENTER.';[void](Read-Host);Snap '04_stopped'
Mark 'capturing_logs'
(& $Adb -s $Device logcat -d -b all -v threadtime 2>&1)|Out-File (Join-Path $OutDir 'logcat-all.txt') -Encoding utf8 -Width 4096
(A 'dmesg 2>&1')|Out-File (Join-Path $OutDir 'dmesg.txt') -Encoding utf8 -Width 4096
Mark 'capture_complete'
@("device=$Device","scenario=HUR stable -> local media idle -> play -> pause -> resume -> stop",'read_only=true','IMPORTANT=operator must record whether audio was actually audible at play/resume and silent at pause/stop')|Set-Content (Join-Path $OutDir 'README.txt') -Encoding utf8
Write-Host '';Write-Host "HUR audio transition capture complete: $OutDir";Write-Host 'Please report whether sound was audible during PLAY and RESUME, and whether it stopped during PAUSE and STOP.'
