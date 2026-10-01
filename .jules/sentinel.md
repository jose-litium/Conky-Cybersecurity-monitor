## 2025-02-18 - Fix missing secure cleanup trap for temporary file
**Vulnerability:** The script creating the `rkhunter` wrapper executed inside Conky used a temporary file and removed it at the end of the script manually. If the script was interrupted or exited early (e.g. `set -e` failure or kill signal), the temporary file would be left on the filesystem.
**Learning:** Temporary files should always be removed using a secure `trap cleanup EXIT` pattern to ensure cleanup regardless of exit status. Additionally, when using unquoted heredocs (`cat <<EOF`) to write the script containing the trap, the variable in the `trap` function must be properly escaped (`\$TMP_RESULT`) to prevent premature evaluation by the parent script.
**Prevention:** Use an EXIT trap for all temporary files in bash scripts and pay close attention to escaping when writing bash code using heredocs.

## 2025-02-18 - Fix overly permissive sudoers Runas configuration
**Vulnerability:** The dynamically generated sudoers entries in both `Conky_app-gui.sh` and `Cybersecurity-monitor-conky` allowed the defined user to execute the `conky-rkhunter-wrapper.sh` script without a password as ANY user on the system by specifying `ALL=(ALL) NOPASSWD:`.
**Learning:** Because the purpose of `rkhunter` requires it to be executed as `root` (and `sudo` defaults to `root`), explicitly restricting the `Runas` specifier to `root` prevents edge-case privilege escalation scenarios where a user might attempt to run the script under a different context.
**Prevention:** Always follow the Principle of Least Privilege when defining sudoers rules. Restrict the `Runas` user (the user the command runs as) specifically to the required user, which in most cases is `root` (e.g., `ALL=(root) NOPASSWD:`).

## 2026-08-26 - Fix silent alert dropping in RKHunter execution
**Vulnerability:** The `rkhunter` scan command in `Conky_app-gui.sh` was executed inside an `if` condition (`if rkhunter --check; then`). Because security scanners return non-zero exit statuses when they detect threats, the `then` block (responsible for extracting and logging alerts) was bypassed whenever an actual threat was found, silently masking the alerts.
**Learning:** Commands that intentionally return non-zero statuses to indicate findings should never be placed directly in conditional checks if their output needs to be processed unconditionally.
**Prevention:** Always execute security scanners unconditionally (e.g., appending `|| true`) and parse the resulting log or output file afterwards instead of relying on the exit status for execution flow.

## 2025-02-18 - Fix complex inline bash commands in systemd service
**Vulnerability:** In `Cybersecurity-monitor-conky`, the `rkhunter-auto.service` executed a complex series of commands using `ExecStart=/bin/bash -c '...'`, which included the generation and deletion of a temporary file without utilizing `trap` for secure cleanup, and failed to properly sandbox the systemd service (e.g. using `PrivateTmp=true`).
**Learning:** Using inline `bash -c` commands in systemd services bypasses the benefits of systemd sandboxing and makes secure cleanup using patterns like `trap` extremely difficult and fragile.
**Prevention:** Avoid using complex inline `bash -c` commands with temporary file generation in systemd `ExecStart` directives. Instead, use a dedicated standalone wrapper script to properly leverage systemd sandboxing (e.g., `PrivateTmp=true`) and `trap` for secure temporary file cleanup.

## 2025-10-24 - Fix silent exit code masking in readonly declarations
**Vulnerability:** Combining a `readonly` declaration with command substitution (e.g., `readonly VAR="$(cmd)"`) masks the exit code of `cmd`. In scripts running under `set -e`, a failure in `cmd` (like `mktemp` failing to create a file) will be ignored, leading to execution continuing with an empty variable or unexpected state, potentially causing destructive behavior or security bypasses later in the script.
**Learning:** In bash, `readonly` is a command itself and always returns success (exit code 0), overriding the exit code of the subshell command substitution.
**Prevention:** To safely capture exit codes and enforce immutability without triggering 'readonly variable' errors, always assign the value first, then declare it readonly on the next line (e.g., `VAR="$(cmd)"` followed by `readonly VAR`).

## 2025-02-18 - Fix overly permissive group assignment
**Vulnerability:** In `Cybersecurity-monitor-conky`, the script granted the user broad access to the `adm` group (`sudo usermod -aG adm "$(whoami)"`) merely to resolve localized permission issues for reading RKHunter logs. The `adm` group typically grants read access to all system authorization logs (e.g., `/var/log/auth.log`, `/var/log/syslog`), creating a significant authorization bypass and privilege escalation risk.
**Learning:** Never grant access to broad, powerful system groups (like `adm`, `wheel`, or `docker`) just to resolve localized file permission issues.
**Prevention:** Instead, pre-create the specific required files (e.g., log files) and explicitly assign ownership (`chown`) or fine-grained ACLs to the application's user to enforce the principle of least privilege.

## 2025-02-18 - Fix CWE-377 insecure temporary files in test scripts
**Vulnerability:** Test scripts (`tests/test_log.sh` and `test_clear_log_file.sh`) used predictable, hardcoded filenames (like `/tmp/test_conky_gui.log` and `/tmp/Conky_app-gui-test.sh`) in the world-writable `/tmp` directory. An attacker could pre-create these files as symlinks pointing to critical system files, causing the script to inadvertently overwrite them when run.
**Learning:** Even test scripts are vulnerable to local symlink attacks if they use predictable filenames in shared directories. While testing locally, scripts are often run with elevated privileges (e.g. `sudo ./test.sh`), making this a valid privilege escalation/clobbering vector.
**Prevention:** Never use predictable filenames in world-writable directories. Always use `mktemp` to securely generate unpredictable temporary files and directories.
