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
#if [ $# -ne 1 ]; then
#    echo "Usage: $0 <log_file>"
#    exit 1
#fi

#LOG_FILE="$1"

# ----------- Default Values -----------
TOP_COUNT=5
LOGIN_THRESHOLD=3
LOG_FILE=""


# ----------- Parse Command Line Options -----------
while getopts "f:t:l:h" opt; do
    case $opt in
        f) LOG_FILE="$OPTARG" ;;
        t) TOP_COUNT="$OPTARG" ;;
        l) LOGIN_THRESHOLD="$OPTARG" ;;
        h)
            echo "Usage: $0 -f <log_file> [-t top_count] [-l login_threshold]"
            exit 0
            ;;
        *)
            echo "Invalid option"
            exit 1
            ;;
    esac
done


# ----------- Validate Log File -----------
if [ -z "$LOG_FILE" ]; then
    echo "Error: Log file must be specified using -f"
    exit 1
fi

if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File does not exist."
    exit 1
fi

if [ ! -s "$LOG_FILE" ]; then
    echo "Error: File is empty."
    exit 1
fi


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
TOP_IPS=$(awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -$TOP_COUNT)
echo "$TOP_IPS"

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

SUSPICIOUS_401=$(awk '$8 == 401 {print $1}' "$LOG_FILE" | sort | uniq -c | awk -v threshold="$LOGIN_THRESHOLD" '$1 > threshold')

if [ -z "$SUSPICIOUS_401" ]; then
    echo "No suspicious 401 activity detected."
else
    echo "$SUSPICIOUS_401"
fi

echo ""
echo "Suspicious IPs (More than 3 Not Found Errors - 404):"

SUSPICIOUS_404=$(awk '$8 == 404 {print $1}' "$LOG_FILE" | sort | uniq -c | awk -v threshold="$LOGIN_THRESHOLD" '$1 > threshold')

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
PEAK_HOUR=$(awk '{split($4, a, ":"); print a[2]}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -1)
echo "$PEAK_HOUR"

echo ""
echo "Hourly Error Distribution (4xx + 5xx):"
awk '$8 ~ /^[45]/ {split($4, a, ":"); print a[2]}' "$LOG_FILE" | sort | uniq -c | sort -nr

# ----------- HTML Report Generation -----------

REPORT_FILE="reports/report.html"


echo ""
echo "Generating HTML report..."

cat > "$REPORT_FILE" <<EOF
<!DOCTYPE html>
<html>
<head>
    <title>Log Analysis Report</title>
    <style>
        body { font-family: Arial; background-color: #f4f4f4; padding: 20px; }
        h1 { color: #333; }
        .section { margin-bottom: 20px; padding: 15px; background: white; border-radius: 5px; }
        pre { background: #eee; padding: 10px; }
    </style>
</head>
<body>

<h1>Log Analysis Report</h1>

<div class="section">
<h2>Summary</h2>
<p><b>Log File:</b> $LOG_FILE</p>
<p><b>Total Requests:</b> $TOTAL_REQUESTS</p>
<p><b>4xx Errors:</b> $FOUR_XX</p>
<p><b>5xx Errors:</b> $FIVE_XX</p>
<p><b>401 Unauthorized:</b> $UNAUTHORIZED</p>
</div>

<div class="section">
<h2>Top $TOP_COUNT IP Addresses</h2>
<pre>
$TOP_IPS
</pre>
</div>

<div class="section">
<h2>Peak Traffic Hour</h2>
<pre>
$PEAK_HOUR
</pre>
</div>

</body>
</html>
EOF

echo "HTML Report Generated: $REPORT_FILE"

# -------------------------------
# EMAIL ALERT SECTION
# -------------------------------

ADMIN_EMAIL="shriyans.s.sahoo@gmail.com"

ALERT_MSG=""

# Check suspicious 401
SUSPICIOUS_401=$(awk '$9 == 401 {print $1}' $LOG_FILE | sort | uniq -c | awk '$1 > 3')

if [ ! -z "$SUSPICIOUS_401" ]; then
    ALERT_MSG+="Suspicious 401 Attempts:\n$SUSPICIOUS_401\n\n"
fi

# Check suspicious 404
SUSPICIOUS_404=$(awk '$9 == 404 {print $1}' $LOG_FILE | sort | uniq -c | awk '$1 > 3')

if [ ! -z "$SUSPICIOUS_404" ]; then
    ALERT_MSG+="Suspicious 404 Attempts:\n$SUSPICIOUS_404\n\n"
fi

# Send mail if alert exists
if [ ! -z "$ALERT_MSG" ]; then
    echo -e "$ALERT_MSG" | mail -s "SECURITY ALERT - Log Analyzer" $ADMIN_EMAIL
    echo "Email alert sent to $ADMIN_EMAIL"
else
    echo "No email alert needed."
fi
