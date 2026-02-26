#!/bin/bash

# ===============================
# LOG ANALYZER TOOL
# Phase 1 - Basic Engine
# ===============================

# ----------- Function: Print Banner -----------
print_banner() {
    echo "==============================================="
    echo "            LOG ANALYZER REPORT"
    echo "==============================================="
}

# ----------- Validate Argument -----------
if [ $# -ne 1 ]; then
    echo "Usage: $0 <log_file>"
    exit 1
fi

LOG_FILE="$1"

# ----------- Check File Exists -----------
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File does not exist."
    exit 1
fi

# ----------- Check File Not Empty -----------
if [ ! -s "$LOG_FILE" ]; then
    echo "Error: File is empty."
    exit 1
fi

# ----------- Begin Report -----------
print_banner

echo "Log File: $LOG_FILE"

# ----------- Total Requests -----------
TOTAL_REQUESTS=$(wc -l < "$LOG_FILE")

echo "Total Requests: $TOTAL_REQUESTS"

echo "==============================================="
