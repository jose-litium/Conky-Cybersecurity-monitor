## 2026-06-28 - [Fix Insecure Temporary Files]
**Vulnerability:** Predictable temporary files in /tmp/ (e.g. /tmp/rkhunter_warnings.txt)
**Learning:** Unified state files are critical. When migrating temporary files to a secure location, ensure that both root-level services (systemd timers) and user-level scripts (manual scans) can access the unified file. In this case, setting up /var/log/rkhunter_warnings.txt with correct permissions allows both to use a single state tracker without splitting the conky widget logic.
**Prevention:** Avoid /tmp/ for predictable files. Use /var/log/ for system-wide logs, and ensure shared files have explicitly managed permissions (e.g. chmod 666 if a non-root user needs write access, or chown).

## 2026-07-09 - [Fix Predictable /tmp Package Download Vulnerability]
**Vulnerability:** Predictable temporary file path during package download (e.g., wget to `/tmp/google-chrome-stable_current_amd64.deb`) without checking download success before installing with `sudo dpkg -i`.
**Learning:** This pattern allows a local attacker to pre-create the predictable file or symlink in `/tmp/` before the script runs, causing the download to fail or be redirected, and leading the script to blindly install the attacker's malicious package as root.
**Prevention:** Never use predictable filenames in world-writable directories like `/tmp/`. Always use `mktemp -d` to create a secure, randomized temporary directory, download the file into that directory, and verify the download command succeeds before attempting installation. Clean up the temporary directory afterward.

## 2026-08-11 - [Fix Atomic Write Issue for Conky State Files]
**Vulnerability:** Conky continuously reads `cpu_temp.txt` which is written directly with `echo > cpu_temp.txt` in a loop.
**Learning:** For files that are updated frequently and read by external processes (e.g., Conky sensor metrics), writing to them directly can result in the external process reading a partially written file, leading to corruption or display errors.
**Prevention:** Implement atomic writes by writing data to a temporary file via `mktemp` and then moving it into place with `mv`. This ensures that the external process always reads a complete, valid state file.
