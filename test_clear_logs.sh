#!/usr/bin/env bash

# Test script for clear_logs function

# Source the script
cp Conky_app-gui.sh /tmp/test_gui.sh
sed -i "/readonly LOGFILE/d" /tmp/test_gui.sh
source /tmp/test_gui.sh

# Mock functions
clear_log_file_called=false
dmsg_called=false
log_called=false
dmsg_arg=""
log_arg=""

function clear_log_file() {
    clear_log_file_called=true
}

function dmsg() {
    dmsg_called=true
    dmsg_arg="$1"
}

function log() {
    log_called=true
    log_arg="$1"
}

# Run the function
clear_logs

# Assertions
failed=false

if [ "$clear_log_file_called" != true ]; then
    echo "Test failed: clear_log_file was not called."
    failed=true
fi

if [ "$dmsg_called" != true ]; then
    echo "Test failed: dmsg was not called."
    failed=true
elif [ "$dmsg_arg" != "Log file cleared." ]; then
    echo "Test failed: dmsg called with wrong argument: '$dmsg_arg'"
    failed=true
fi

if [ "$log_called" != true ]; then
    echo "Test failed: log was not called."
    failed=true
elif [ "$log_arg" != "Log file truncated." ]; then
    echo "Test failed: log called with wrong argument: '$log_arg'"
    failed=true
fi

if [ "$failed" = true ]; then
    exit 1
else
    echo "All tests passed successfully."
    exit 0
fi
