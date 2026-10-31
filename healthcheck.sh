#!/bin/sh
set -eu

response=$(
    curl --disable --fail --silent --show-error \
        --proto '=https' \
        --connect-timeout 10 \
        --max-time 20 \
        --max-filesize 4096 \
        --noproxy '' \
        --proxy 'socks5h://127.0.0.1:9150' \
        'https://check.torproject.org/api/ip'
) || exit 1

printf '%s\n' "$response" |
    grep -Eq '"IsTor"[[:space:]]*:[[:space:]]*true[[:space:]]*[,}]'
