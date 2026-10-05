param(
    [string]$Device='192.168.1.35:5555',
    [string]$OutRoot='D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs\audio_events',
    [string]$Adb='D:\platform-tools\adb.exe',
    [ValidateSet('AAC','PCM')][string]$Mode='AAC'
)
$ErrorActionPreference='Stop'
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'; $OutDir=Join-Path $OutRoot ("hur_audio_v2_{0}_{1}" -f $Mode.ToLower(),$stamp); New-Item -ItemType Directory -Force -Path $OutDir|Out-Null
$timeline=Join-Path $OutDir 'timeline.txt'
function Mark([string]$m){$x="$(Get-Date -Format o) $m";Write-Host $x;$x|Add-Content $timeline -Encoding utf8}
function WaitEnter([string]$event,[string[]]$lines){Write-Host '';foreach($line in $lines){Write-Host $line};[void](Read-Host);Mark $event}
function A([string]$cmd){& $Adb -s $Device shell $cmd 2>&1}
function Snap([string]$name){
 $d=Join-Path $OutDir $name;New-Item -ItemType Directory -Force -Path $d|Out-Null;Mark "snapshot_begin=$name"
 (A 'date; cat /proc/uptime; getprop sys.boot_completed')|Out-File "$d\state.txt" -Encoding utf8 -Width 4096
 (A 'ps -A -T -o USER,PID,TID,PPID,VSZ,RSS,WCHAN,ADDR,S,NAME 2>&1; echo ===== FULL_PS_EF =====; ps -A -ef 2>&1')|Out-File "$d\processes-full.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys audio 2>&1')|Out-File "$d\dumpsys-audio.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys media.audio_flinger 2>&1')|Out-File "$d\audio-flinger.txt" -Encoding utf8 -Width 4096
 (A 'dumpsys media.audio_policy 2>&1')|Out-File "$d\audio-policy.txt" -Encoding utf8 -Width 4096
 (& $Adb -s $Device shell 'tinymix' 1> "$d\tinymix-stdout.txt" 2> "$d\tinymix-stderr.txt")
 (A 'for f in /proc/asound/card*/pcm*/sub*/status /proc/asound/card*/pcm*/sub*/hw_params; do if [ -r "$f" ]; then echo ===== "$f" =====; cat "$f"; fi; done')|Out-File "$d\pcm-state.txt" -Encoding utf8 -Width 4096
 (A 'cat /proc/asound/cards; echo; cat /proc/asound/pcm')|Out-File "$d\proc-asound.txt" -Encoding utf8 -Width 4096
 (A 'for f in /proc/asound/card*/pcm*/sub*/status; do if [ -r "$f" ]; then echo ===== "$f" =====; cat "$f"; sleep 0.25; cat "$f"; sleep 0.25; cat "$f"; fi; done')|Out-File "$d\pcm-progression.txt" -Encoding utf8 -Width 4096
 (A 'for p in $(pidof ght-play) $(pidof sdAutoReverse) $(pidof audioserver) $(pidof android.hardware.audio.service) $(pidof com.syu.music); do if [ -n "$p" ]; then echo ===== PID $p =====; cat /proc/$p/cmdline | tr "\000" " "; echo; echo --- status ---; cat /proc/$p/status; echo --- fds ---; ls -lZ /proc/$p/fd 2>&1; echo --- maps ---; cat /proc/$p/maps 2>&1; fi; done')|Out-File "$d\runtime-fd-maps.txt" -Encoding utf8 -Width 4096
 Mark "snapshot_end=$name"
}
Mark "collector_started mode=$Mode"
& $Adb connect $Device|Out-Host; & $Adb -s $Device wait-for-device
$id=(& $Adb -s $Device shell id 2>&1|Out-String).Trim();if($id-notmatch'uid=0\(root\)'){throw "Root ADB shell required: $id"};Mark "connected $id"
Write-Host '';Write-Host '============================================================';Write-Host " AUDIO TEST: $Mode";Write-Host ' HUR must already show the X21 interface and work normally.';Write-Host ' The player only needs PLAY/PAUSE. There is NO STOP step.';Write-Host ' Do not change tinymix, volume routing or other settings.';Write-Host '============================================================'
WaitEnter 'READY_PAUSED' @('[STEP 1/6] PREPARE','Open the test audio file on X21.','Leave it PAUSED: there must be NO sound from the tablet/HUR.','When ready, press ENTER here.')
Snap '00_paused_initial'
WaitEnter 'PLAY_CONFIRMED_AUDIBLE' @('[STEP 2/6] PLAY','Press PLAY on X21 now.','Wait until you can REALLY HEAR the test sound from the tablet through HUR.','Only after the sound is audible, press ENTER here.')
Snap '01_play_audible';Start-Sleep -Seconds 8;Snap '02_play_stable'
WaitEnter 'PAUSE_CONFIRMED_SILENT' @('[STEP 3/6] PAUSE','Press PAUSE on X21 now.','Wait until the sound from the tablet/HUR DISAPPEARS.','Only after there is silence, press ENTER here.')
Snap '03_pause_silent';Start-Sleep -Seconds 5;Snap '04_pause_stable'
WaitEnter 'RESUME_CONFIRMED_AUDIBLE' @('[STEP 4/6] PLAY AGAIN','Press PLAY on X21 again.','Wait until you can REALLY HEAR the test sound from the tablet through HUR again.','Only after the sound is audible, press ENTER here.')
Snap '05_resume_audible';Start-Sleep -Seconds 8;Snap '06_resume_stable'
WaitEnter 'FINAL_PAUSE_CONFIRMED_SILENT' @('[STEP 5/6] PAUSE AGAIN','Press PAUSE on X21. Do NOT close the player and do NOT disconnect HUR.','Wait until the sound DISAPPEARS.','Only after there is silence, press ENTER here.')
Snap '07_final_pause_silent';Start-Sleep -Seconds 8;Snap '08_final_pause_stable'
Write-Host '';Write-Host '[STEP 6/6] DO NOT TOUCH ANYTHING';Write-Host 'Leave the player paused and HUR connected.';Write-Host 'Waiting 25 seconds automatically...';Mark 'post_pause_watch_begin';Start-Sleep -Seconds 25;Snap '09_post_pause_25s'
Mark 'capturing_logs';Write-Host 'Capturing final logs...';(& $Adb -s $Device logcat -d -b all -v threadtime 2>&1)|Out-File (Join-Path $OutDir 'logcat-all.txt') -Encoding utf8 -Width 4096;(A 'dmesg 2>&1')|Out-File (Join-Path $OutDir 'dmesg.txt') -Encoding utf8 -Width 4096;Mark 'capture_complete'
@("device=$Device","mode=$Mode",'scenario=HUR stable -> initial pause -> play audible -> pause silent -> play audible -> final pause silent -> 25s post-pause','read_only=true','operator ENTER markers explicitly mean audible/silent state was physically confirmed as instructed','there is no STOP action in this scenario; final state is PAUSE','AAC mode uses AAC test file; PCM mode uses WAV PCM 48kHz stereo S16_LE where possible')|Set-Content (Join-Path $OutDir 'README.txt') -Encoding utf8
Write-Host '';Write-Host '============================================================';Write-Host ' DONE';Write-Host " $OutDir";Write-Host '============================================================'
