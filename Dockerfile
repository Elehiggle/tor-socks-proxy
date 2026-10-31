FROM alpine:3.24@sha256:be2656061b536c1883c4034790e21d0a09c5aaaf51968b89368a3c0371ea2c9a

LABEL org.opencontainers.image.title="tor-socks-proxy" \
    org.opencontainers.image.description="Tor SOCKS5 and DNS client proxy with pluggable transports" \
    org.opencontainers.image.source="https://github.com/Elehiggle/tor-socks-proxy" \
    org.opencontainers.image.licenses="GPL-3.0-only"

RUN apk add --no-cache tor lyrebird curl && \
    addgroup -S -g 10001 torproxy && \
    adduser -S -D -H -h /var/lib/tor -u 10001 -G torproxy torproxy && \
    chown 10001:10001 /var/lib/tor && \
    chmod 0700 /var/lib/tor && \
    ln -s /usr/bin/lyrebird /usr/bin/obfs4proxy

COPY --chown=0:0 --chmod=0444 torrc /etc/tor/torrc
COPY --chown=0:0 --chmod=0555 healthcheck.sh /usr/local/bin/tor-healthcheck

HEALTHCHECK --interval=30s --timeout=30s --start-period=90s --retries=3 \
    CMD ["/usr/local/bin/tor-healthcheck"]

USER 10001:10001
EXPOSE 8853/udp 9150/tcp

CMD ["/usr/bin/tor", "-f", "/etc/tor/torrc"]
