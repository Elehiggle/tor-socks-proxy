# Runtime hardening

- Stable Alpine package repositories and a digest-pinned base image.
- Tor, curl and Lyrebird only; no added Python, compilers or package-download scripts in the image.
- UID/GID10001, root-owned read-only configuration and health script, private persistent Tor state.
- SOCKS9150, DNS8853/udp, command/config overrides and obfs4 compatibility preserved.
- Bounded HTTPS healthcheck through SOCKS using the official Tor check API.
- Compose drops capabilities, prohibits new privileges, uses a read-only root filesystem and limits CPU, memory and process count.
- Native CI checks configuration, file ownership, capabilities, transport availability and healthcheck success/failure without external networking.
- Native image and multiarch-index digests receive signed GitHub Actions provenance. Pull requests have read-only build/test jobs without publication authority.

The [source audit](security-audit.md) concerns its exact upstream revision; subsequent runtime and publication changes received separate source review. Neither source review nor provenance guarantees absence of defects.
