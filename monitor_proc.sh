#!/bin/bash

PROC_DIR="/proc"
LOG_FILE="$HOME/proc_monitor.log"
STATE_FILE="$HOME/proc_state.prev"
TMP_FILE="$HOME/proc_state.curr"

echo "===== Script run: $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOG_FILE"

printf "%-8s | %-30s | %-20s | %-10s | %-20s | %-30s\n" \
"PID" "Name" "Cmdline" "State" "Limits" "CWD" >> "$LOG_FILE"

printf "%s\n" "-------------------------------------------------------------------------------------------------------------" >> "$LOG_FILE"

> "$TMP_FILE"

for entry in "$PROC_DIR"/*; do
    if [[ -d "$entry" ]]; then
        pid=$(basename "$entry")

        if [[ "$pid" =~ ^[0-9]+$ ]]; then
            echo "$pid" >> "$TMP_FILE"

            # Если PID уже был — пропускаем
            if [[ -f "$STATE_FILE" ]] && grep -q "^$pid$" "$STATE_FILE"; then
                continue
            fi

            name=$(readlink "$PROC_DIR/$pid/exe" 2>/dev/null)
            cmdline=$(tr '\0' ' ' < "$PROC_DIR/$pid/cmdline" 2>/dev/null)
            state=$(grep "^State:" "$PROC_DIR/$pid/status" 2>/dev/null | awk '{print $2}')
            limits=$(head -n 1 "$PROC_DIR/$pid/limits" 2>/dev/null)
            cwd=$(readlink "$PROC_DIR/$pid/cwd" 2>/dev/null)

            printf "%-8s | %-30s | %-20s | %-10s | %-20s | %-30s\n" \
            "$pid" "${name:-N/A}" "${cmdline:-N/A}" "${state:-N/A}" "${limits:-N/A}" "${cwd:-N/A}" >> "$LOG_FILE"
        fi
    fi
done

mv "$TMP_FILE" "$STATE_FILE"
