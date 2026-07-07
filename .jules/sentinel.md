## 2025-05-18 - Unquoted Variables in Bash Commands

**Vulnerability:** Unquoted variable `$file` was used in `rm -f $file` inside `Conky_app-gui.sh`.
**Learning:** Bash variables must be enclosed in double quotes to prevent word splitting and unintended globbing, particularly in security-critical paths or file operations, since a filename containing spaces or wildcards could result in deleting entirely unrelated or important files.
**Prevention:** Always quote shell variables representing file paths (e.g., `rm -f "$file"`) unless word splitting is explicitly intended. Run ShellCheck on scripts as part of the pre-commit review process to catch such mistakes early.