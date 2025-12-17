#!/bin/bash

PREFIX="$1"
INTERFACE="$2"
SUBNET="$3"
HOST="$4"


if [[ "$EUID" -ne 0 ]]; then
    echo "Script must be run as root"
    exit 1
fi


if [[ -z "$PREFIX" ]]; then
    echo "PREFIX must be passed as first positional argument"
    exit 1
fi

if [[ -z "$INTERFACE" ]]; then
    echo "INTERFACE must be passed as second positional argument"
    exit 1
fi


re_prefix='^([0-9]{1,3}\.){1}[0-9]{1,3}$'
re_octet='^([1-9][0-9]?|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'


if [[ ! "$PREFIX" =~ $re_prefix ]]; then
    echo "Invalid PREFIX format. Expected: xxx.xxx"
    exit 1
fi


if [[ -n "$SUBNET" && ! "$SUBNET" =~ $re_octet ]]; then
    echo "Invalid SUBNET value"
    exit 1
fi


if [[ -n "$HOST" && ! "$HOST" =~ $re_octet ]]; then
    echo "Invalid HOST value"
    exit 1
fi


scan_ip() {
    local ip="$1"
    echo "[*] IP : $ip"
    arping -c 3 -i "$INTERFACE" "$ip" 2>/dev/null
}

# Диапазоны по умолчанию 
SUBNET_START=1
SUBNET_END=255
HOST_START=1
HOST_END=255


if [[ -n "$SUBNET" ]]; then
    SUBNET_START="$SUBNET"
    SUBNET_END="$SUBNET"
fi

if [[ -n "$HOST" ]]; then
    HOST_START="$HOST"
    HOST_END="$HOST"
fi


for ((s=SUBNET_START; s<=SUBNET_END; s++)); do
    for ((h=HOST_START; h<=HOST_END; h++)); do
        scan_ip "${PREFIX}.${s}.${h}"
    done
done
