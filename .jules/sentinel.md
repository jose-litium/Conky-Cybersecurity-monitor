## 2026-06-28 - [Fix Insecure Temporary Files]
**Vulnerability:** Predictable temporary files in /tmp/ (e.g. /tmp/rkhunter_warnings.txt)
**Learning:** Unified state files are critical. When migrating temporary files to a secure location, ensure that both root-level services (systemd timers) and user-level scripts (manual scans) can access the unified file. In this case, setting up /var/log/rkhunter_warnings.txt with correct permissions allows both to use a single state tracker without splitting the conky widget logic.
**Prevention:** Avoid /tmp/ for predictable files. Use /var/log/ for system-wide logs, and ensure shared files have explicitly managed permissions (e.g. chmod 666 if a non-root user needs write access, or chown).

## 2026-07-04 - [Unquoted Variable Vulnerability in File Deletion]
**Vulnerability:** Unquoted variable (`$file`) in a file deletion command (`rm -f $file`) within `Conky_app-gui.sh`.
**Learning:** Unquoted variables in file operations can lead to word splitting and unintended globbing vulnerabilities. If a variable contains spaces or wildcard characters (like `*`), it can cause the command to unintentionally delete multiple files or files other than the intended one. This is a common and dangerous anti-pattern in shell scripting.
**Prevention:** Always enclose variables containing file paths or other arbitrary strings in double quotes (e.g., `"$file"`) when using them as arguments to commands. This prevents shell expansion features like word splitting and globbing from being applied to the variable's contents.
