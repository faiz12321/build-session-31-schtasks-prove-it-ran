# Re-record the repaired lesson and check it, Windows only.
$ErrorActionPreference = 'Stop'
$folder='C:\lesson31-demo';$madeFolder=$false;$madeTask=$false
function Check($ok,$name) { if(-not $ok){throw "FAIL: $name"};"PASS: $name" }
function Setup {
# Run in Windows PowerShell. Refuses to reuse an existing practice folder or task.
$ErrorActionPreference = 'Stop'
$folder = 'C:\lesson31-demo'
$existing = @(Get-ScheduledTask -TaskPath '\' -ErrorAction Stop | Where-Object TaskName -eq 'Lesson31Demo')
if ($existing.Count -gt 0) { throw 'Lesson31Demo already exists. Stop. Do not replace or delete it.' }
if (Test-Path -LiteralPath $folder) { throw 'C:\lesson31-demo already exists. Stop. Do not reuse or delete it.' }
New-Item -ItemType Directory -Path $folder | Out-Null
New-Item -ItemType Directory -Path "$folder\out" | Out-Null
'@echo off','echo %date% %time% backup ran >> out\log.txt' | Set-Content -LiteralPath "$folder\backup-note.bat" -Encoding Ascii
'Practice files created. Open Command Prompt (cmd.exe) for the recorded commands.'
'If any task-creation command asks to replace an existing task, answer N and stop.'
}
function Show-Cmd($label,$block,$expected) {
 ''
 "### CMD: $label"
 & $block 2>&1 | ForEach-Object {
  $line="$_" -replace '^(Last Run Time|Next Run Time|Start Date): .*','$1: (depends on when you run this)'
  if($line -match 'backup ran$'){$line='(when it ran) backup ran'}
  $line
 }
 $rc=$LASTEXITCODE
 "### EXIT: $rc"
 if($null -ne $expected -and $rc -ne $expected){throw "Unexpected exit $rc for $label"}
}
try {
 Setup | Out-Null
 $madeFolder=$true
 Check (Test-Path -LiteralPath "$folder\out") 'practice output folder exists'
 # Re-running setup must stop before modifying any file.
 $before=(Get-FileHash -LiteralPath "$folder\backup-note.bat").Hash
 $refused=$false
 try {Setup | Out-Null} catch {$refused=$true}
 Check $refused 'setup refuses an existing folder'
 Check ((Get-FileHash -LiteralPath "$folder\backup-note.bat").Hash -eq $before) 'existing script unchanged'
 Show-Cmd 'type C:\lesson31-demo\backup-note.bat' {cmd /c 'type C:\lesson31-demo\backup-note.bat'} 0
 Show-Cmd 'schtasks /create /tn "Lesson31Demo" /tr "C:\lesson31-demo\backup-note.bat" /sc daily /st 09:00' {schtasks /create /tn 'Lesson31Demo' /tr 'C:\lesson31-demo\backup-note.bat' /sc daily /st 09:00} 0
 $madeTask=$true
 Check (-not (Get-ScheduledTask -TaskName Lesson31Demo).Settings.StartWhenAvailable) 'no missed-run catch-up configured'
 $refused=$false
 try {Setup | Out-Null} catch {$refused=$true}
 Check $refused 'setup refuses an existing task'
 Show-Cmd 'schtasks /run /tn "Lesson31Demo"' {schtasks /run /tn 'Lesson31Demo'} 0
 Start-Sleep -Seconds 6
 Check ((Get-ScheduledTaskInfo -TaskName Lesson31Demo).LastTaskResult -eq 1) 'relative output path fails with result 1'
 Show-Cmd 'schtasks /query /tn "Lesson31Demo" /v /fo list' {schtasks /query /tn 'Lesson31Demo' /v /fo list} 0
 # cmd error output is expected, not a PowerShell exception.
 $old=$ErrorActionPreference;$ErrorActionPreference='Continue'
 Show-Cmd 'type C:\lesson31-demo\out\log.txt' {cmd /c 'type C:\lesson31-demo\out\log.txt'} 1
 $ErrorActionPreference=$old
 Check (-not(Test-Path -LiteralPath "$folder\out\log.txt")) 'failed task left no expected log'
 '@echo off','cd /d "%~dp0"','echo %date% %time% backup ran >> out\log.txt' | Set-Content -LiteralPath "$folder\backup-note.bat" -Encoding Ascii
 Show-Cmd 'type C:\lesson31-demo\backup-note.bat' {cmd /c 'type C:\lesson31-demo\backup-note.bat'} 0
 Show-Cmd 'schtasks /run /tn "Lesson31Demo"' {schtasks /run /tn 'Lesson31Demo'} 0
 Start-Sleep -Seconds 6
 Check ((Get-ScheduledTaskInfo -TaskName Lesson31Demo).LastTaskResult -eq 0) 'fixed script result 0'
 Show-Cmd 'schtasks /query /tn "Lesson31Demo" /v /fo list' {schtasks /query /tn 'Lesson31Demo' /v /fo list} 0
 Check ((Get-Content -LiteralPath "$folder\out\log.txt").Count -eq 1) 'fixed script wrote exactly one log line'
 Show-Cmd 'type C:\lesson31-demo\out\log.txt' {cmd /c 'type C:\lesson31-demo\out\log.txt'} 0
 Show-Cmd 'schtasks /delete /tn "Lesson31Demo" /f' {schtasks /delete /tn 'Lesson31Demo' /f} 0
 $madeTask=$false
 Check (@(Get-ScheduledTask -TaskPath '\' | Where-Object TaskName -eq 'Lesson31Demo').Count -eq 0) 'practice task removed'
 'PASS: all critical release checks passed'
} finally {
 if($madeTask){schtasks /delete /tn 'Lesson31Demo' /f | Out-Null}
 if($madeFolder){Remove-Item -LiteralPath $folder -Recurse -Force}
}
$global:LASTEXITCODE=0
