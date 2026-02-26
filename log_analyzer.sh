#!/bin/bash

# ===============================
# LOG ANALYZER TOOL
# Phase 2 - Core Analytics
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

echo ""
echo "------------- ANALYTICS -------------"

# ----------- Top 5 IP Addresses -----------
echo ""
echo "Top 5 IP Addresses:"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5

# ----------- 4xx Errors -----------
echo ""
FOUR_XX=$(awk '$8 ~ /^4/' "$LOG_FILE" | wc -l)
echo "4xx Errors: $FOUR_XX"

# ----------- 5xx Errors -----------
FIVE_XX=$(awk '$8 ~ /^5/' "$LOG_FILE" | wc -l)
echo "5xx Errors: $FIVE_XX"

# ----------- 401 Unauthorized -----------
UNAUTHORIZED=$(awk '$8 == 401' "$LOG_FILE" | wc -l)
echo "401 Unauthorized: $UNAUTHORIZED"

# ----------- Most Accessed Endpoint -----------
echo ""
echo "Most Accessed Endpoint:"
awk '{print $6}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1

echo "---------------------------------------------"
echo "==============================================="
