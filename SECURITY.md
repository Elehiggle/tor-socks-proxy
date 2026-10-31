# Security

Use current images from `ghcr.io/elehiggle/tor-socks-proxy`. The image uses stable Alpine packages and runs Tor as UID/GID10001. Configuration is root-owned; persistent Tor state belongs in a private data volume. SOCKS/DNS are intentionally unauthenticated, so published host addresses and network access are operator-controlled.

Images are built and tested in native GitHub Actions runners. Signed SLSA provenance is attached to each platform image and the multiarch index. See [verification](docs/verification.md). Image digests are immutable content identities; tags such as `latest` are mutable. A normal `docker run` verifies registry content integrity but does not enforce provenance policy.

Maintainers, GitHub Actions/GHCR, the Docker daemon and signed Alpine package infrastructure are trusted. Provenance identifies the producing workflow and source; it is not proof that source code is harmless. The [upstream audit](docs/security-audit.md) records its reviewed revision and scope.

Report concrete security issues through this repository's private vulnerability reporting. Include the affected revision, trust boundary, minimal dummy-data reproduction and observed result. Keep credentials and private Tor state out of reports.
