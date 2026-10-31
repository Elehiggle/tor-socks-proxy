# Tor SOCKS Proxy

A small Docker image for a Tor SOCKS5 and DNS proxy. Fork of [PeterDaveHello/tor-socks-proxy](https://github.com/PeterDaveHello/tor-socks-proxy).

## Usage

```sh
docker run -d \
  --name torproxy \
  --restart unless-stopped \
  -p 127.0.0.1:9050:9150 \
  -v torproxy-data:/var/lib/tor \
  ghcr.io/elehiggle/tor-socks-proxy:latest
```

This starts the proxy directly; no provenance tooling or GitHub login is required. For LAN access, replace `127.0.0.1` with your server's LAN IP.

### Check the proxy

```sh
curl --socks5-hostname 127.0.0.1:9050 https://check.torproject.org/api/ip
docker logs torproxy
```

### Start or stop

```sh
docker stop torproxy
docker start torproxy
```

### DNS over Tor

Add `-p 127.0.0.1:8853:8853/udp` to the run command to publish DNS. The SOCKS listener inside the container remains on port `9150`.

### Custom configuration

Mount your configuration with `-v /path/to/torrc:/etc/tor/torrc:ro`. Tor runs as UID/GID `10001:10001`; the data volume preserves its state across image updates. Lyrebird is included, with `/usr/bin/obfs4proxy` available for existing bridge configurations.

## Images

Images for **AMD64 and ARM64** are built and published by [GitHub Actions](https://github.com/Elehiggle/tor-socks-proxy/actions). Use `latest` for updates, or `ghcr.io/elehiggle/tor-socks-proxy@sha256:DIGEST` to pin an immutable image.

Signed build provenance is available. Verification is optional: see [verification](docs/verification.md). For stricter runtime settings, use [Docker Compose](docker-compose.yml).

## Build locally

```sh
docker build --pull -t tor-socks-proxy .
```

## Security and license

[Security guidance](SECURITY.md) · [Source audit](docs/security-audit.md) · [GPLv3](LICENSE)
