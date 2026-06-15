#!/bin/bash
echo "=== git diff --check ==="
git diff --check
echo "=== grep -R \"/tmp/rkhunter\" . ==="
grep -R "/tmp/rkhunter" . || echo "None found."
echo "=== grep -R \"/tmp/cpu_temp\" . ==="
grep -R "/tmp/cpu_temp" . || echo "None found."
echo "=== grep -R \"NOPASSWD\" . ==="
grep -R "NOPASSWD" . || echo "None found."
echo "=== grep -R \"mktemp\" . ==="
grep -R "mktemp" . || echo "None found."
echo "=== grep -R \"rkhunter_warnings\" . ==="
grep -R "rkhunter_warnings" . || echo "None found."
