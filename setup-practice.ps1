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
