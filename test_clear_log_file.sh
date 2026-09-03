#!/usr/bin/env bash

# Test script for clear_log_file in Conky_app-gui.sh

# Create a temporary script for testing
TEST_SCRIPT="$(mktemp /tmp/test_conky_gui.XXXXXX.sh)"
trap 'rm -f "$TEST_SCRIPT" 2>/dev/null || true' EXIT

# Remove readonly attribute from LOGFILE and replace exit with return for testing
sed -e 's/readonly LOGFILE/LOGFILE/g' -e 's/exit/return/g' Conky_app-gui.sh > "$TEST_SCRIPT"

# Source the main script
source "$TEST_SCRIPT"

# Override LOGFILE to a dummy file for testing
LOGFILE="$(mktemp /tmp/test_conky_gui.XXXXXX.log)"
trap 'rm -f "$TEST_SCRIPT" "$LOGFILE" 2>/dev/null || true' EXIT

# Create some dummy content
echo "dummy log entry 1" > "$LOGFILE"
echo "dummy log entry 2" >> "$LOGFILE"

# Call the function
clear_log_file

# Check if the file is empty
if [ -s "$LOGFILE" ]; then
    echo "TEST FAILED: Log file is not empty."
    rm -f "$LOGFILE"
    exit 1
else
    echo "TEST PASSED: Log file is empty."
    rm -f "$LOGFILE"
    exit 0
fi
