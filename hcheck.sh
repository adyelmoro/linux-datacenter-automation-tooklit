#!/bin/bash

# Project: VA Health Check
# Purpose: Rapid hardware/OS diagnostics for rack-mounted servers

echo "--- STARTING SYSTEM HEALTH CHECK ---"
date
echo "------------------------------------"

# 1. CHECKING CPU LOAD (weather server is struggling)
# The 1-minute load average.
LOAD=$(uptime | awk -F'load average:' '{ print $2 }' | cut -d, -f1)
echo "[CPU] 1-Min Load Average: $LOAD"

# 2. CHECKING MEMORY (for leaks)
# Showing free vs used RAM in MBs.
free -m | grep "Mem" | awk '{print "[RAM] Total: "$2"MB | Used: "$3"MB | Free: "$4"MB"}'

# 3. CHECKING DISK SPACE
# Checking the '/' partition specifically.
DISK_USAGE=$(df -h / | grep / | awk '{ print $5 }')
echo "[DISK] Root Partition Usage: $DISK_USAGE"

# 4. CHECKING HARDWARE ERRORS IN KERNEL LOGS
echo "[LOGS] Searching dmesg for Hardware/I/O Errors..."
ERRORS=$(dmesg | grep -iE "error|fail|critical|hardware" | tail -n 5)

if [ -z "$ERRORS" ]; then
    echo "Result: No recent hardware errors detected in dmesg."
else
    echo "CRITICAL: Recent errors found!"
    echo "$ERRORS"
fi

echo "------------------------------------"
echo "--- HEALTH CHECK COMPLETE ---"
