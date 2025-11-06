#!/bin/bash
# ================================================
# Script Name : system_health_report.sh
# Purpose     : Generate system health summary
# Author      : Sreekanth CloudDevOps
# ================================================

DATE=$(date '+%Y-%m-%d_%H-%M-%S')
HOST=$(hostname)
OUTPUT="/tmp/system_report_${HOST}_${DATE}.log"

echo "===================================" > $OUTPUT
echo "      SYSTEM HEALTH REPORT" >> $OUTPUT
echo "Generated on: $(date)" >> $OUTPUT
echo "===================================" >> $OUTPUT
echo "" >> $OUTPUT

# Host and uptime
echo "Hostname       : $HOST" >> $OUTPUT
echo "Uptime         : $(uptime -p)" >> $OUTPUT

# Disk usage
echo "" >> $OUTPUT
echo "----- Disk Usage -----" >> $OUTPUT
df -h >> $OUTPUT

# Memory usage
echo "" >> $OUTPUT
echo "----- Memory Usage -----" >> $OUTPUT
free -m >> $OUTPUT

# Top 5 CPU-consuming processes
echo "" >> $OUTPUT
echo "----- Top 5 Processes by CPU -----" >> $OUTPUT
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6 >> $OUTPUT

# Network check
echo "" >> $OUTPUT
echo "----- Network Interfaces -----" >> $OUTPUT
ip -br addr >> $OUTPUT

# Load average check
echo "" >> $OUTPUT
LOAD=$(uptime | awk -F'load average:' '{ print $2 }')
echo "Load Average   : $LOAD" >> $OUTPUT

# Check service status (if provided)
SERVICE=$1
if [ -n "$SERVICE" ]; then
    echo "" >> $OUTPUT
    echo "----- Service Status Check: $SERVICE -----" >> $OUTPUT
    systemctl status $SERVICE | grep Active >> $OUTPUT 2>/dev/null || echo "Service not found or no access" >> $OUTPUT
fi

echo "" >> $OUTPUT
echo "Report saved at: $OUTPUT"

