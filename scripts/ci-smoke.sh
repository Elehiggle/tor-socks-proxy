#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
    printf 'Usage: %s IMAGE\n' "$0" >&2
    exit 2
fi

image=$1
nonce=$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')
image_container="torproxy-image-test-$nonce"
cleanup() {
    timeout --kill-after=2s 10s docker rm -f "$image_container" \
        >/dev/null 2>&1 || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# These checks need no Tor peers, DNS servers or other external services.
timeout --kill-after=5s 60s docker run --rm --name "$image_container" \
    --network none --read-only --log-driver none \
    --cap-drop ALL --security-opt no-new-privileges=true \
    --pids-limit 128 --memory 512m --memory-swap 512m --cpus 2 \
    --ulimit fsize=16777216:16777216 --ulimit nofile=256:256 \
    --tmpfs /tmp:rw,nosuid,nodev,noexec,size=16m \
    --tmpfs /dev/shm:ro,nosuid,nodev,noexec,size=1m \
    --tmpfs /var/lib/tor:rw,nosuid,nodev,noexec,size=32m,uid=10001,gid=10001,mode=0700 \
    --entrypoint /usr/bin/env "$image" -i \
    PATH=/usr/sbin:/usr/bin:/sbin:/bin HOME=/tmp TMPDIR=/tmp XDG_CACHE_HOME=/tmp \
    /bin/sh -eu -c '
        test "$(id -u)" = 10001
        test "$(id -g)" = 10001
        test "$(stat -c %u:%g:%a /etc/tor/torrc)" = 0:0:444
        test "$(stat -c %u:%g:%a /usr/local/bin/tor-healthcheck)" = 0:0:555
        test "$(stat -c %u:%g:%a /var/lib/tor)" = 10001:10001:700
        test ! -w /etc/tor/torrc
        test ! -w /usr/local/bin/tor-healthcheck
        test -x /usr/bin/lyrebird
        test "$(readlink -f /usr/bin/obfs4proxy)" = /usr/bin/lyrebird
        command -v curl >/dev/null
        grep -Eq "^CapEff:[[:space:]]*0+$" /proc/self/status
        grep -Eq "^NoNewPrivs:[[:space:]]*1$" /proc/self/status
        grep -Eq "^SocksPort[[:space:]]+0[.]0[.]0[.]0:9150([[:space:]]|$)" /etc/tor/torrc
        grep -Eq "^DNSPort[[:space:]]+0[.]0[.]0[.]0:8853([[:space:]]|$)" /etc/tor/torrc
        tor --verify-config -f /etc/tor/torrc
        version=$(tor --version | sed -n "1s/^Tor version \([0-9.]*\)\.$/\1/p")
        test -n "$version"
        comparison=$(apk version -t "$version" 0.4.9.15)
        test "$comparison" = "=" || test "$comparison" = ">"

        # Source the unchanged healthcheck inside a subshell, substituting only
        # curl. No executable fixtures or real network requests are needed.
        (
            curl() { printf "%s\n" "{\"IsTor\":true,\"IP\":\"192.0.2.1\"}"; }
            . /usr/local/bin/tor-healthcheck
        )
        if (
            curl() { printf "%s\n" "{\"IsTor\":false,\"IP\":\"192.0.2.1\"}"; }
            . /usr/local/bin/tor-healthcheck
        ); then
            printf "Healthcheck accepted IsTor=false\n" >&2
            exit 1
        fi
        if (
            curl() { printf "%s\n" "{\"IsTor\":true}"; return 22; }
            . /usr/local/bin/tor-healthcheck
        ); then
            printf "Healthcheck accepted a failed HTTP request\n" >&2
            exit 1
        fi
        printf "Offline image checks passed; Tor %s\n" "$version"
    '
