#!/bin/bash

INPUT_FILE="/proc/bus/input/devices"
LOG_FILE="$HOME/input_devices.log"
STATE_FILE="$HOME/input_prev_devices.txt"
TMP_FILE="$HOME/input_curr_devices.txt"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Файл $INPUT_FILE не найден"
    exit 1
fi

echo "===== Script run: $(date '+%Y-%m-%d %H:%M:%S') =====" >> "$LOG_FILE"
printf "%-5s | %-6s | %-7s | %-25s | %-20s | %-30s\n" \
"Bus" "Vendor" "Product" "Name" "Handlers" "Phys" >> "$LOG_FILE"
printf "%s\n" "----------------------------------------------------------------------------------------------------------" >> "$LOG_FILE"

bus=""; vendor=""; product=""; name=""; handlers=""; phys=""

> "$TMP_FILE"

while IFS= read -r line; do
    case "$line" in
        I:*)
            bus=$(echo "$line" | sed -n 's/.*Bus=\([0-9a-fA-F]*\).*/\1/p')
            vendor=$(echo "$line" | sed -n 's/.*Vendor=\([0-9a-fA-F]*\).*/\1/p')
            product=$(echo "$line" | sed -n 's/.*Product=\([0-9a-fA-F]*\).*/\1/p')
            ;;
        N:*)
            name=$(echo "$line" | sed -n 's/N: Name="\(.*\)"/\1/p')
            ;;
        H:*)
            handlers=$(echo "$line" | sed -n 's/H: Handlers=\(.*\)/\1/p')
            ;;
        P:*)
            phys=$(echo "$line" | sed -n 's/P: Phys=\(.*\)/\1/p')
            ;;
        "")

            device_id="${bus}_${vendor}_${product}_${name}_${phys}"

            echo "$device_id" >> "$TMP_FILE"

            if [[ -f "$STATE_FILE" ]] && grep -Fxq "$device_id" "$STATE_FILE"; then
                bus=""; vendor=""; product=""; name=""; handlers=""; phys=""
                continue
            fi

            printf "%-5s | %-6s | %-7s | %-25s | %-20s | %-30s\n" \
            "${bus:-N/A}" "${vendor:-N/A}" "${product:-N/A}" "${name:-N/A}" "${handlers:-N/A}" "${phys:-N/A}" >> "$LOG_FILE"

            bus=""; vendor=""; product=""; name=""; handlers=""; phys=""
            ;;
    esac
done < "$INPUT_FILE"

mv "$TMP_FILE" "$STATE_FILE"
