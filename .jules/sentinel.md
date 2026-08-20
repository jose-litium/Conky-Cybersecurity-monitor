## 2025-02-18 - Fix missing secure cleanup trap for temporary file
**Vulnerability:** The script creating the `rkhunter` wrapper executed inside Conky used a temporary file and removed it at the end of the script manually. If the script was interrupted or exited early (e.g. `set -e` failure or kill signal), the temporary file would be left on the filesystem.
**Learning:** Temporary files should always be removed using a secure `trap cleanup EXIT` pattern to ensure cleanup regardless of exit status. Additionally, when using unquoted heredocs (`cat <<EOF`) to write the script containing the trap, the variable in the `trap` function must be properly escaped (`\$TMP_RESULT`) to prevent premature evaluation by the parent script.
**Prevention:** Use an EXIT trap for all temporary files in bash scripts and pay close attention to escaping when writing bash code using heredocs.

## 2025-02-18 - Fix overly permissive sudoers Runas configuration
**Vulnerability:** The dynamically generated sudoers entries in both `Conky_app-gui.sh` and `Cybersecurity-monitor-conky` allowed the defined user to execute the `conky-rkhunter-wrapper.sh` script without a password as ANY user on the system by specifying `ALL=(ALL) NOPASSWD:`.
**Learning:** Because the purpose of `rkhunter` requires it to be executed as `root` (and `sudo` defaults to `root`), explicitly restricting the `Runas` specifier to `root` prevents edge-case privilege escalation scenarios where a user might attempt to run the script under a different context.
**Prevention:** Always follow the Principle of Least Privilege when defining sudoers rules. Restrict the `Runas` user (the user the command runs as) specifically to the required user, which in most cases is `root` (e.g., `ALL=(root) NOPASSWD:`).

## 2025-02-18 - Fix missing read-write paths for systemd isolated rkhunter wrapper
**Vulnerability:** Hardening `rkhunter` inside a systemd service using `ProtectSystem=strict` mounted the entire file system as read-only. Without explicitly adding `/var/lib/rkhunter` to `ReadWritePaths`, database and property updates (`rkhunter --update` and `rkhunter --propupd`) failed silently.
**Learning:** When using systemd sandboxing features on services that require writing to specific state files (like databases or virus signatures), you must fully map out all required read-write paths, not just log directories. Additionally, absolute paths (like `/usr/bin/rkhunter`) should be avoided in favor of relying on `$PATH` to prevent cross-distro breakage.
**Prevention:** Always verify the file system write requirements of the tools being wrapped before enforcing strict systemd constraints.
