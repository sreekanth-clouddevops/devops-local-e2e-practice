#!/bin/bash
set -euo pipefail

echo "=============================="
echo "Starting Jenkins Build Job"
echo "=============================="
echo "Build triggered at: $(date)"
echo "Running on host: $(hostname)"
echo
echo "Checking Disk and Memory Status:"
df -h | grep -v tmpfs
echo
free -m
echo
echo "Build step completed successfully!"
echo "=============================="

