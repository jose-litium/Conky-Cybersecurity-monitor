## 2025-02-18 - Fixed Predictable Temporary File Vulnerability
**Vulnerability:** Insecure Temporary File usage in `/tmp`. The log file was written to `/tmp/conky_gui_$$_.log`, which is predictable and world-writable.
**Learning:** `$$` (PID) in `/tmp` directory makes scripts vulnerable to symlink attacks where an attacker could potentially overwrite arbitrary files that the user has write access to.
**Prevention:** Avoid writing to world-writable directories like `/tmp` with predictable names. Use `mktemp` for temporary files, or store logs and persistent state in secure, user-controlled directories (like `$HOME/.local/...`) with restrictive permissions (e.g., `0700`).
