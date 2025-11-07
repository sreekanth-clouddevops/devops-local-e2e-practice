#!/usr/bin/env bash
set -euo pipefail
		THRESHOLD=80
PART="/"
		usage() {
  echo "Usage: $0 [-t threshold%] [-p mountpoint]"
  echo "  -t  threshold percentage (default: 80)"
  echo "  -p  partition/mountpoint to check (default: /)"
}
		while getopts ":t:p:h" opt; do
  case "$opt" in
    t) THRESHOLD="${OPTARG}" ;;
    p) PART="${OPTARG}" ;;
    h) usage; exit 0 ;;
    \?) echo "Invalid option: -$OPTARG"; usage; exit 2 ;;
  esac
done
		# current usage number (strip %)
USAGE=$(df -P "${PART}" | awk 'NR==2 {gsub("%","",$5); print $5+0}')
if (( USAGE > THRESHOLD )); then
  echo "CRITICAL: ${PART} usage ${USAGE}% > ${THRESHOLD}%"
  exit 1
else
  echo "OK: ${PART} usage ${USAGE}% <= ${THRESHOLD}%"
  exit 0
fi
