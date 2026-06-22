#!/usr/bin/env bash

# Test script for clear_log_file in Conky_app-gui.sh

# Use sed to remove the readonly attribute to allow LOGFILE modification
cp ./Conky_app-gui.sh /tmp/Conky_app-gui_test.sh
sed -i 's/readonly LOGFILE/LOGFILE/g' /tmp/Conky_app-gui_test.sh

# Source the main script
source /tmp/Conky_app-gui_test.sh

# Override LOGFILE to a dummy file for testing
LOGFILE="/tmp/test_conky_gui.log"

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
