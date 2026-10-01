#!/usr/bin/env bash

# Exit on any failure
set -e

# Create a clean version of the script that we can source without running the UI
TMP_SCRIPT="$(mktemp)"
cp Conky_app-gui.sh "$TMP_SCRIPT"
sed -i "s/^readonly LOGFILE/LOGFILE/" "$TMP_SCRIPT"
sed -i '/^# Main Menu (GUI with dialog)/,$d' "$TMP_SCRIPT"

# Source the functions
source "$TMP_SCRIPT"

# Use a temporary log file for testing
LOGFILE="$(mktemp)"
export LOGFILE

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

# Test 5: run_cmd logs command and output
clear_log_file
run_cmd echo "Hello, Run Cmd"
if grep -q "Running: echo Hello, Run Cmd" "$LOGFILE" && grep -q "Hello, Run Cmd" "$LOGFILE"; then
    echo "✅ PASS: run_cmd logs the command and its output."
else
    echo "❌ FAIL: run_cmd did not log the command or output correctly."
    cat "$LOGFILE"
    FAIL=1
fi

# Clean up
rm -f "$LOGFILE"
rm -f "$TMP_SCRIPT"

if [ $FAIL -eq 0 ]; then
    echo "🎉 All tests passed successfully!"
    exit 0
else
    echo "💥 Some tests failed."
    exit 1
fi
