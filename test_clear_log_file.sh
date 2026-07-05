#!/usr/bin/env bash

# Test script for clear_log_file in Conky_app-gui.sh

# Override LOGFILE to a dummy file for testing
export LOGFILE="/tmp/test_conky_gui.log"

# Create a modified copy of the script that doesn't make LOGFILE readonly
TMP_TEST_SCRIPT=$(mktemp)
cp ./Conky_app-gui.sh "$TMP_TEST_SCRIPT"
sed -i "s/^readonly LOGFILE/LOGFILE/" "$TMP_TEST_SCRIPT"

# Source the modified script
source "$TMP_TEST_SCRIPT"

# Create some dummy content
echo "dummy log entry 1" > "$LOGFILE"
echo "dummy log entry 2" >> "$LOGFILE"

# Call the function
clear_log_file

# Check if the file is empty
if [ -s "$LOGFILE" ]; then
    echo "TEST FAILED: Log file is not empty."
    rm -f "$LOGFILE"
    rm -f "$TMP_TEST_SCRIPT"
    exit 1
else
    echo "TEST PASSED: Log file is empty."
    rm -f "$LOGFILE"
    rm -f "$TMP_TEST_SCRIPT"
    exit 0
fi
