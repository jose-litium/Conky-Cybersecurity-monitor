#!/usr/bin/env bash

# Test script for clear_log_file in Conky_app-gui.sh

# Create a temporary copy of the script to modify it for testing
cp ./Conky_app-gui.sh /tmp/Conky_app-gui-test.sh

# Remove readonly attribute from LOGFILE
sed -i 's/^readonly LOGFILE/LOGFILE/' /tmp/Conky_app-gui-test.sh

# Source the main script
source /tmp/Conky_app-gui-test.sh

# Override LOGFILE to a dummy file for testing
export LOGFILE="/tmp/test_conky_gui.log"

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
    rm -f "$LOGFILE" /tmp/Conky_app-gui-test.sh
    exit 0
fi
