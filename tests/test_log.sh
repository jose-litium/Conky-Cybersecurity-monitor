#!/usr/bin/env bash

# Exit on any failure
set -e

# Create a clean version of the script that we can source without running the UI
cp Conky_app-gui.sh /tmp/Conky_app-gui-test.sh
sed -i '/^# Main Menu (GUI with dialog)/,$d' /tmp/Conky_app-gui-test.sh
sed -i 's/readonly LOGFILE/LOGFILE/g' /tmp/Conky_app-gui-test.sh

# Source the functions
source /tmp/Conky_app-gui-test.sh

# Use a temporary log file for testing
LOGFILE="/tmp/test_conky_log_$$.log"

# Clean up before testing
rm -f "$LOGFILE"

echo "🧪 Running tests for logging functions..."

FAIL=0

# Test 1: clear_log_file creates empty file
clear_log_file
if [ -f "$LOGFILE" ] && [ ! -s "$LOGFILE" ]; then
    echo "✅ PASS: clear_log_file creates an empty file."
else
    echo "❌ FAIL: clear_log_file did not create an empty file."
    FAIL=1
fi

# Test 2: log writes to file with correct date format
log "This is a test message"
if grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} - This is a test message$" "$LOGFILE"; then
    echo "✅ PASS: log writes message with correct format."
else
    echo "❌ FAIL: log did not write correctly."
    cat "$LOGFILE"
    FAIL=1
fi

# Test 3: log appends to the file correctly
log "Second message"
LINES=$(wc -l < "$LOGFILE")
if [ "$LINES" -eq 2 ]; then
    echo "✅ PASS: log appends messages to the file."
else
    echo "❌ FAIL: log did not append correctly. Found $LINES lines instead of 2."
    FAIL=1
fi

# Test 4: clear_log_file clears the file successfully
clear_log_file
if [ -f "$LOGFILE" ] && [ ! -s "$LOGFILE" ]; then
    echo "✅ PASS: clear_log_file clears an existing file."
else
    echo "❌ FAIL: clear_log_file did not clear the file."
    FAIL=1
fi

# Clean up
rm -f "$LOGFILE"
rm -f /tmp/Conky_app-gui-test.sh

if [ $FAIL -eq 0 ]; then
    echo "🎉 All tests passed successfully!"
    exit 0
else
    echo "💥 Some tests failed."
    exit 1
fi
