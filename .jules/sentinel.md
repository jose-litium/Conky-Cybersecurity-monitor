## 2026-06-28 - [Fix Insecure Temporary Files]
**Vulnerability:** Predictable temporary files in /tmp/ (e.g. /tmp/rkhunter_warnings.txt)
**Learning:** Unified state files are critical. When migrating temporary files to a secure location, ensure that both root-level services (systemd timers) and user-level scripts (manual scans) can access the unified file. In this case, setting up /var/log/rkhunter_warnings.txt with correct permissions allows both to use a single state tracker without splitting the conky widget logic.
**Prevention:** Avoid /tmp/ for predictable files. Use /var/log/ for system-wide logs, and ensure shared files have explicitly managed permissions (e.g. chmod 666 if a non-root user needs write access, or chown).

## 2026-06-29 - [Fix Sudoers Wrapper Pattern & Predictable Tmp Files]
**Vulnerability:** Predictable /tmp files during package downloads and over-permissive sudoers commands
**Learning:** Hardcoding paths in world-writable directories (like /tmp) for package installations enables symlink attacks. Using `mktemp -d` ensures a unique, secure directory is created for the operation. Furthermore, granting `NOPASSWD` sudo privileges directly to a command like `rkhunter` with specific arguments can sometimes be bypassed or difficult to manage securely. A dedicated wrapper script limits the execution to strict, predefined parameters.
**Prevention:** Avoid hardcoded /tmp paths; use `mktemp` consistently. For `sudoers` configurations, prefer creating a dedicated, read-only root wrapper script with bounded arguments, and grant `NOPASSWD` access only to that wrapper script.
