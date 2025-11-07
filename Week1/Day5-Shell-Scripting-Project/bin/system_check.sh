#!/usr/bin/env bash
set -euo pipefail

LOG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/logs"
mkdir -p "${LOG_DIR}"
LOG_FILE="${LOG_DIR}/system_check_$(date +%F).log"

log() { printf "[%s] %s\n" "$(date '+%F %T')" "$*" | tee -a "${LOG_FILE}"; }

check_disk()  { df -h | awk 'NR==1 || /^\/dev\//'; }
check_mem()   { free -h; }
check_uptime(){ uptime -p; }
check_load()  { uptime; }

main() {
  log "===== System Check Start ====="
  log "Hostname: $(hostname)"
  log "Uptime: $(check_uptime)"
  log "Disk:"
  check_disk | tee -a "${LOG_FILE}"
  log "Memory:"
  check_mem  | tee -a "${LOG_FILE}"
  log "Load:"
  check_load | tee -a "${LOG_FILE}"
  log "===== System Check End ====="
}

main "$@"
