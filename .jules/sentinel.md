## 2026-06-28 - [Fix Insecure Temporary Files]
**Vulnerability:** Predictable temporary files in /tmp/ (e.g. /tmp/rkhunter_warnings.txt)
**Learning:** Unified state files are critical. When migrating temporary files to a secure location, ensure that both root-level services (systemd timers) and user-level scripts (manual scans) can access the unified file. In this case, setting up /var/log/rkhunter_warnings.txt with correct permissions allows both to use a single state tracker without splitting the conky widget logic.
**Prevention:** Avoid /tmp/ for predictable files. Use /var/log/ for system-wide logs, and ensure shared files have explicitly managed permissions (e.g. chmod 666 if a non-root user needs write access, or chown).

## 2026-06-28 - [Fix Insecure Temporary File for Google Chrome Download]
**Vulnerability:** Predictable temporary file usage (`/tmp/google-chrome-stable_current_amd64.deb`) when downloading and installing Google Chrome. This could allow a local attacker to perform a symlink attack, potentially leading to arbitrary file overwrite or privilege escalation since `dpkg` is run via `sudo`.
**Learning:** Hardcoding paths in world-writable directories like `/tmp/` is dangerous, especially when combined with high-privilege operations like `sudo dpkg -i`. An attacker could pre-create a symlink at the predictable location pointing to a critical system file.
**Prevention:** Always use secure temporary file creation mechanisms like `mktemp` to generate unpredictable filenames, preferably in a user-specific directory with restricted permissions (e.g., `$HOME/.local/...`), and ensure cleanup after use.
