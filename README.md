# Log Analyzer Tool

A powerful, bash-based utility designed to analyze web server access logs (Apache/Nginx format). It provides deep insights into traffic patterns, identifies common errors, and detects potential security threats through automated log parsing and analytics.

## Features

- **Automated Summaries**: Get total requests, top IP addresses, and status code distributions (2xx, 4xx, 5xx) at a glance.
- **Security Monitoring**: Identify suspicious activity like brute-force attempts (401 Unauthorized) or excessive scanning (404 Not Found).
- **Traffic Analysis**: Visualize requests per hour and identify peak traffic periods.
- **HTML Reports**: Generates a clean, professional HTML report for easy sharing and documentation.
- **Email Alerts**: Automatically sends security alerts to administrators when suspicious activity thresholds are met.

## Prerequisites

Ensure you have the following installed on your Linux system:
- `bash`
- `awk`
- `mailutils` (for email alerts)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Shriyans406/Log_Analyzer.git
   cd Log_Analyzer
   ```
2. Make the script executable:
   ```bash
   chmod +x log_analyzer.sh
   ```

## Usage

Run the script by providing the path to your log file using the `-f` flag.

### Basic Analysis
```bash
./log_analyzer.sh -f sample_logs/access.log
```

### Advanced Options
- `-f <file>`: Specify the log file (Required).
- `-t <count>`: Number of top IPs/Endpoints to display (Default: 5).
- `-l <threshold>`: Threshold for security alerts (Default: 3).

Example with custom thresholds:
```bash
./log_analyzer.sh -f access.log -t 10 -l 5
```

## Project Structure

- `log_analyzer.sh`: The core analysis engine.
- `sample_logs/`: Directory containing example logs for testing.
- `reports/`: Destination for generated HTML reports.
- `README.md`: This file.

## Sample Output (Console)
```text
===============================================
            LOG ANALYZER REPORT
===============================================
Log File: sample_logs/access.log
Total Requests: 25

------------- ANALYTICS -------------

Top 5 IP Addresses:
      8 192.168.1.10
      5 10.0.0.5
      ...

Peak Traffic Hour:
      12
---------------------------------------------
```

## Security Alerts
The tool monitors for:
- **Excessive 401 Unauthorized**: Potential login brute-force.
- **Excessive 404 Not Found**: Potential vulnerability scanning or broken links.

If thresholds are exceeded, an email is sent to the configured `ADMIN_EMAIL` in the script.

---
**Author**: Shriyans406
**Objective**: Simplify log management and enhance server security monitoring.
