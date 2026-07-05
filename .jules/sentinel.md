## 2026-06-28 - [Fix Insecure Temporary Files]
**Vulnerability:** Predictable temporary files in /tmp/ (e.g. /tmp/rkhunter_warnings.txt)
**Learning:** Unified state files are critical. When migrating temporary files to a secure location, ensure that both root-level services (systemd timers) and user-level scripts (manual scans) can access the unified file. In this case, setting up /var/log/rkhunter_warnings.txt with correct permissions allows both to use a single state tracker without splitting the conky widget logic.
**Prevention:** Avoid /tmp/ for predictable files. Use /var/log/ for system-wide logs, and ensure shared files have explicitly managed permissions (e.g. chmod 666 if a non-root user needs write access, or chown).
## 2026-07-05 - [Fix Unquoted Variable and Predictable Temp File Vulnerabilities]
**Vulnerability:** Unquoted variables in file operations (e.g., `rm -f $file`) leading to globbing/word splitting, and predictable temporary files in `/tmp/` leading to symlink attacks.
**Learning:** Hardcoded `/tmp/` files are insecure for downloads or tests; unquoted variables can cause unintended deletions if paths have spaces.
**Prevention:** Use `mktemp` or `mktemp -d` for secure temporary files/directories. Always enclose variables in double quotes (`"$file"`) during file operations.
