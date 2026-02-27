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

echo ""
echo "------------- SECURITY ALERTS -------------"
echo ""
echo "Suspicious IPs (More than 3 Failed Logins - 401):"

SUSPICIOUS_401=$(awk '$8 == 401 {print $1}' "$LOG_FILE" | sort | uniq -c | awk '$1 > 3')

if [ -z "$SUSPICIOUS_401" ]; then
    echo "No suspicious 401 activity detected."
else
    echo "$SUSPICIOUS_401"
fi

echo ""
echo "Suspicious IPs (More than 3 Not Found Errors - 404):"

SUSPICIOUS_404=$(awk '$8 == 404 {print $1}' "$LOG_FILE" | sort | uniq -c | awk '$1 > 3')

if [ -z "$SUSPICIOUS_404" ]; then
    echo "No suspicious 404 activity detected."
else
    echo "$SUSPICIOUS_404"
fi

echo ""
echo "------------- TIME ANALYSIS -------------"

echo ""
echo "Requests Per Hour:"
awk '{split($4, a, ":"); print a[2]}' "$LOG_FILE" | sort | uniq -c | sort -n

echo ""
echo "Peak Traffic Hour:"
awk '{split($4, a, ":"); print a[2]}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1

echo ""
echo "Hourly Error Distribution (4xx + 5xx):"
awk '$8 ~ /^[45]/ {split($4, a, ":"); print a[2]}' "$LOG_FILE" | sort | uniq -c | sort -nr
