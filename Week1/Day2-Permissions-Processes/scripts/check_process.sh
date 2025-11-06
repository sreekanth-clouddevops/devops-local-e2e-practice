#!/bin/bash
# Simple process checker script
# Usage: ./check_process.sh <process_name>

process=$1
if [ -z "$process" ]; then
  echo "Usage: $0 <process_name>"
  exit 1
fi

if ps -ef | grep -q "[${process:0:1}]${process:1}"; then
  echo "✅ Process '$process' is running."
else
  echo "⚠️ Process '$process' not found. Starting..."
  sudo systemctl start $process 2>/dev/null || echo "Manual start needed for '$process'"
fi
