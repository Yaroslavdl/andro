param(
    [string]$Device='192.168.1.35:5555',
    [string]$OutRoot='D:\carlinkit\DUDU_stock_opt\2609261951_2609241005\06_live_logs\audio_events',
    [string]$Adb='D:\platform-tools\adb.exe',
    [ValidateSet('AAC','PCM')][string]$Mode='AAC'
)
$ErrorActionPreference='Stop'
$stamp=Get-Date -Format 'yyyyMMdd_HHmmss'; $OutDir=Join-Path $OutRoot ("hur_audio_v2_{0}_{1}" -f $Mode.ToLower(),$stamp); New-Item -ItemType Directory -Force -Path $OutDir|Out-Null
$timeline=Join-Path $OutDir 'timeline.txt'; $observations=Join-Path $OutDir 'operator-observations.txt'
function Mark([string]$m){$x="$(Get-Date -Format o) $m";Write-Host $x;$x|Add-Content $timeline -Encoding utf8}
function A([string]$cmd){& $Adb -s $Device shell $cmd 2>&1}
function Ask([string]$event,[string]$text){Write-Host '';Write-Host $text;[void](Read-Host);Mark $event}
function Observe([string]$event){$v=Read-Host 'Operator observation (AUDIBLE/SILENT/OTHER)';$x="$(Get-Date -Format o) $event=$v";$x|Add-Content $observations -Encoding utf8;Mark "operator_$event=$v"}
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
Write-Host '';Write-Host "Mode: $Mode. HUR must already be stable. Use the SAME prepared local test file for this run. Do not change mixer controls manually."
Ask 'READY_IDLE' 'Prepare the test file, keep playback STOPPED, then press ENTER.';Snap '00_idle_stable';Observe 'IDLE'
Ask 'PLAY_PRESSED' 'Press PLAY now, then immediately return here and press ENTER.';Snap '01_play_immediate';Start-Sleep -Seconds 8;Snap '02_play_stable';Observe 'PLAY_STABLE'
Ask 'PAUSE_PRESSED' 'Press PAUSE now, then immediately return here and press ENTER.';Snap '03_pause_immediate';Start-Sleep -Seconds 5;Snap '04_pause_stable';Observe 'PAUSE_STABLE'
Ask 'RESUME_PRESSED' 'Press RESUME now, then immediately return here and press ENTER.';Snap '05_resume_immediate';Start-Sleep -Seconds 8;Snap '06_resume_stable';Observe 'RESUME_STABLE'
Ask 'STOP_PRESSED' 'Press STOP now, then immediately return here and press ENTER.';Snap '07_stop_immediate';Start-Sleep -Seconds 8;Snap '08_stop_stable';Observe 'STOP_STABLE'
Mark 'post_stop_watch_begin';Start-Sleep -Seconds 25;Snap '09_post_stop_25s';Observe 'POST_STOP_25S'
Mark 'capturing_logs';(& $Adb -s $Device logcat -d -b all -v threadtime 2>&1)|Out-File (Join-Path $OutDir 'logcat-all.txt') -Encoding utf8 -Width 4096;(A 'dmesg 2>&1')|Out-File (Join-Path $OutDir 'dmesg.txt') -Encoding utf8 -Width 4096;Mark 'capture_complete'
@("device=$Device","mode=$Mode",'scenario=HUR stable -> local media play -> pause -> resume -> stop -> 25s post-stop','read_only=true','AAC mode should use the same known AAC test file as the validated reference. PCM mode should use an ordinary local WAV/PCM file and avoid changing any other test variable where possible.','operator observations are stored in operator-observations.txt')|Set-Content (Join-Path $OutDir 'README.txt') -Encoding utf8
Write-Host '';Write-Host "HUR audio v2 capture complete: $OutDir";Write-Host 'Keep this directory together with timeline.txt and operator-observations.txt.'
