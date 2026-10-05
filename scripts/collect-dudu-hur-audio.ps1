param(
    [string]$Device='192.168.1.35:5555',
    [string]$OutRoot='D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs\audio_events',
    [string]$Adb='D:\platform-tools\adb.exe',
    [ValidateSet('AAC','PCM','MIXER')][string]$Mode='AAC'
)
$ErrorActionPreference='Stop'
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'; $OutDir=Join-Path $OutRoot ("hur_audio_v3_{0}_{1}" -f $Mode.ToLower(),$stamp); New-Item -ItemType Directory -Force -Path $OutDir|Out-Null
$timeline=Join-Path $OutDir 'timeline.txt'
function Mark([string]$m){$x="$(Get-Date -Format o) $m";Write-Host $x;$x|Add-Content $timeline -Encoding utf8}
function WaitEnter([string]$event,[string[]]$lines){Write-Host '';foreach($line in $lines){Write-Host $line};[void](Read-Host);Mark $event}
function A([string]$cmd){& $Adb -s $Device shell $cmd 2>&1}
function Capture-Tinymix([string]$d){$old=$ErrorActionPreference;try{$ErrorActionPreference='Continue';& $Adb -s $Device shell 'tinymix' 1> (Join-Path $d 'tinymix-stdout.txt') 2> (Join-Path $d 'tinymix-stderr.txt')}finally{$ErrorActionPreference=$old}}
function FastSnap([string]$name){
 $d=Join-Path $OutDir $name;New-Item -ItemType Directory -Force -Path $d|Out-Null;Mark "snapshot_begin=$name";Write-Host "    Capturing $name (fast snapshot)..."
 (A 'date; cat /proc/uptime')|Out-File "$d\state.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys media.audio_flinger 2>&1')|Out-File "$d\audio-flinger.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys media.audio_policy 2>&1')|Out-File "$d\audio-policy.txt" -Encoding utf8 -Width 4096
 Capture-Tinymix $d
 (A 'for f in /proc/asound/card*/pcm*/sub*/status /proc/asound/card*/pcm*/sub*/hw_params; do if [ -r "$f" ]; then echo ===== "$f" =====; cat "$f"; fi; done')|Out-File "$d\pcm-state.txt" -Encoding utf8 -Width 4096
 (A 'for p in $(pidof ght-play) $(pidof sdAutoReverse) $(pidof audioserver) $(pidof android.hardware.audio.service) $(pidof com.syu.music) $(pidof x21-mixer-player); do [ -n "$p" ] && { echo ===== PID $p =====; cat /proc/$p/cmdline | tr "\000" " "; echo; ls -l /proc/$p/fd 2>&1; }; done')|Out-File "$d\runtime-fds.txt" -Encoding utf8 -Width 4096
 Mark "snapshot_end=$name"
}
function DeepCapture(){
 $d=Join-Path $OutDir 'deep-final';New-Item -ItemType Directory -Force -Path $d|Out-Null;Mark 'deep_capture_begin';Write-Host 'Capturing slower deep diagnostics now that timing-critical test is finished...'
 (A 'ps -A -T -o USER,PID,TID,PPID,VSZ,RSS,WCHAN,ADDR,S,NAME 2>&1; echo ===== FULL_PS_EF =====; ps -A -ef 2>&1')|Out-File "$d\processes-full.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys audio 2>&1')|Out-File "$d\dumpsys-audio.txt" -Encoding utf8 -Width 4096
 (A 'cat /proc/asound/cards; echo; cat /proc/asound/pcm')|Out-File "$d\proc-asound.txt" -Encoding utf8 -Width 4096
 (A 'for p in $(pidof ght-play) $(pidof sdAutoReverse) $(pidof audioserver) $(pidof android.hardware.audio.service) $(pidof com.syu.music) $(pidof x21-mixer-player); do if [ -n "$p" ]; then echo ===== PID $p =====; cat /proc/$p/cmdline | tr "\000" " "; echo; echo --- status ---; cat /proc/$p/status; echo --- fds ---; ls -lZ /proc/$p/fd 2>&1; echo --- maps ---; cat /proc/$p/maps 2>&1; fi; done')|Out-File "$d\runtime-fd-maps.txt" -Encoding utf8 -Width 4096
 (& $Adb -s $Device logcat -d -b all -v threadtime 2>&1)|Out-File "$d\logcat-all.txt" -Encoding utf8 -Width 4096
 (A 'dmesg 2>&1')|Out-File "$d\dmesg.txt" -Encoding utf8 -Width 4096
 Mark 'deep_capture_end'
}
Mark "collector_started mode=$Mode"
& $Adb connect $Device|Out-Host;& $Adb -s $Device wait-for-device
$id=(& $Adb -s $Device shell id 2>&1|Out-String).Trim();if($id-notmatch'uid=0\(root\)'){throw "Root ADB shell required: $id"};Mark "connected $id"
Write-Host '';Write-Host '============================================================';Write-Host " AUDIO TEST: $Mode (fast snapshots)";Write-Host ' HUR must already work. Player actions: PLAY / PAUSE only.';if($Mode-eq'MIXER'){Write-Host ' MIXER mode: use x21-mixer-player, not the OEM music player.';Write-Host ' Goal: verify AudioFlinger MIXER/no DIRECT/no COMPRESS_OFFLOAD.'};Write-Host '============================================================'
WaitEnter 'READY_PAUSED' @('[STEP 1/6] PREPARE','Open/prepare the test source. Leave it PAUSED and silent.','Press ENTER here when ready.')
FastSnap '00_paused_initial'
WaitEnter 'PLAY_CONFIRMED_AUDIBLE' @('[STEP 2/6] PLAY','Press PLAY now.','As soon as you HEAR sound through HUR, press ENTER here.')
FastSnap '01_play_audible';Start-Sleep -Seconds 3;FastSnap '02_play_stable'
WaitEnter 'PAUSE_CONFIRMED_SILENT' @('[STEP 3/6] PAUSE','Press PAUSE now.','As soon as sound DISAPPEARS, press ENTER here.')
FastSnap '03_pause_silent';Start-Sleep -Seconds 3;FastSnap '04_pause_stable'
WaitEnter 'RESUME_CONFIRMED_AUDIBLE' @('[STEP 4/6] PLAY AGAIN','Press PLAY again.','As soon as you HEAR sound through HUR, press ENTER here.')
FastSnap '05_resume_audible';Start-Sleep -Seconds 3;FastSnap '06_resume_stable'
WaitEnter 'FINAL_PAUSE_CONFIRMED_SILENT' @('[STEP 5/6] PAUSE AGAIN','Press PAUSE again. Keep HUR connected.','As soon as sound DISAPPEARS, press ENTER here.')
FastSnap '07_final_pause_silent';Start-Sleep -Seconds 3;FastSnap '08_final_pause_stable'
Write-Host '';Write-Host '[STEP 6/6] DO NOT TOUCH ANYTHING';Write-Host 'Leave playback paused. Waiting 15 seconds...';Mark 'post_pause_watch_begin';Start-Sleep -Seconds 15;FastSnap '09_post_pause_15s'
DeepCapture
@("device=$Device","mode=$Mode",'scenario=pause -> play -> pause -> play -> pause -> 15s post-pause','read_only=true','timing-critical snapshots intentionally omit slow maps/full-ps/progression work','deep diagnostics are captured only after the transition sequence','operator ENTER after PLAY means audible through HUR; ENTER after PAUSE means physically silent','MIXER mode is valid only if AudioFlinger evidence confirms a mixer output without DIRECT/COMPRESS_OFFLOAD')|Set-Content (Join-Path $OutDir 'README.txt') -Encoding utf8
Write-Host '';Write-Host '============================================================';Write-Host ' DONE';Write-Host " $OutDir";Write-Host '============================================================'
