#!/bin/bash
# ================================================
# Script Name : system_health_report.sh
# Purpose     : Generate system health summary, email alert on high CPU, prune old logs
# Author      : Sreekanth CloudDevOps
# ================================================

set -euo pipefail

# --- Config ---
LOG_DIR="${HOME}/system-health-logs"
ALERT_EMAIL="YOUR_EMAIL@gmail.com"      # <-- set your email
CPU_THRESHOLD=80                        # alert if CPU usage (%) > threshold
SERVICE="${1:-}"                        # optional: service to check status
# --------------

mkdir -p "$LOG_DIR"

DATE="$(date '+%Y-%m-%d_%H-%M-%S')"
HOST="$(hostname)"
OUTPUT="${LOG_DIR}/system_report_${HOST}_${DATE}.log"

{
  echo "==================================="
  echo "      SYSTEM HEALTH REPORT"
  echo "Generated on: $(date)"
  echo "==================================="
  echo
  echo "Hostname       : $HOST"
  echo "Uptime         : $(uptime -p)"
  echo

  echo "----- Disk Usage -----"
  df -h
  echo

  echo "----- Memory Usage -----"
  free -m
  echo

  echo "----- Top 5 Processes by CPU -----"
  ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6
  echo

  echo "----- Network Interfaces -----"
  ip -br addr
  echo

  # CPU usage via mpstat (requires sysstat)
  # mpstat prints %idle as last column; CPU% = 100 - idle
  CPU_USAGE="$(mpstat 1 1 | awk '/Average:/ { printf("%.0f", 100 - $NF) }')"
  echo "CPU Usage (%)  : ${CPU_USAGE}"
  LOAD="$(uptime | awk -F'load average:' '{ gsub(/^ +/, "", $2); print $2 }')"
  echo "Load Average   : ${LOAD}"
  echo

  # Optional service status
  if [ -n "$SERVICE" ]; then
    echo "----- Service Status Check: $SERVICE -----"
    systemctl is-active "$SERVICE" >/dev/null 2>&1 \
      && echo "Active: running" \
      || echo "Active: not running or not found"
    echo
  fi

  echo "Report saved at: $OUTPUT"
} > "$OUTPUT"

# --- Alert if CPU exceeds threshold ---
if [ "${CPU_USAGE:-0}" -gt "$CPU_THRESHOLD" ]; then
  SUBJECT="ALERT: CPU > ${CPU_THRESHOLD}% on ${HOST}"
  {
    echo "High CPU detected on ${HOST}"
    echo "CPU Usage: ${CPU_USAGE}%"
    echo "Time: $(date)"
    echo
    echo "Recent Top CPU Processes:"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -6
    echo
    echo "Full report at: ${OUTPUT}"
  } | mail -s "$SUBJECT" "$ALERT_EMAIL" || true
fi

# --- Prune logs older than 7 days ---
find "$LOG_DIR" -type f -name "system_report_*.log" -mtime +7 -delete || true

# Optional: compress yesterday's logs (example)
# find "$LOG_DIR" -type f -name "system_report_*.log" -mtime +1 -not -name "*.gz" -exec gzip {} \; || true

echo "Done."

