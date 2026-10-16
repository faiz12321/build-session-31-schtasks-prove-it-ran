# Run a script every day on Windows and prove it ran

Teaching files for AI Tools That Work, build session 31. Windows only.

The interactive lesson is a replay, not a live terminal. The commands and scripts run for real only if you choose to run them yourself.

## Practice safely

Read `setup-practice.ps1`, then run it in Windows PowerShell. It refuses to reuse an existing `C:\lesson31-demo` folder or `Lesson31Demo` task. Stop on any error. Use Command Prompt (cmd.exe) for the recorded commands. Task creation deliberately omits `/f`. If Windows asks to replace an existing task, answer N and stop.

This creates a daily practice task. Delete only the task you created, as shown at the end. The visible lesson leaves the small sample folder for inspection. It does not configure waking a sleeping PC, catch-up after missed runs, logged-out runs or battery runs. A result of 0 is not proof that a real backup worked; inspect useful output too.

## Tests and recording

`verify31.ps1` is a self-contained Windows check. It refuses existing practice data, checks ten conditions, records the expected failure and fix, then removes only the task and folder it created. CI runs on standard GitHub-hosted Windows. Ubuntu does not provide schtasks.

The repaired session ran twice on 16 October 2026. Both raw transcripts are included. They match after replacing scheduler date fields and the timestamp in the one log line, as disclosed in the lesson. The raw files retain the differing log timestamps.

References:
- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-create
- https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/schtasks-query
- https://learn.microsoft.com/en-us/windows/win32/taskschd/tasksettings-startwhenavailable

MIT license for this teaching code. No warranty. Only made-up practice files are used. No personal files, analytics or credentials are included.
