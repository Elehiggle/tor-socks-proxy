# Build provenance

Plain `docker run ghcr.io/elehiggle/tor-socks-proxy:latest` works without verification tools. To pin content, use its `@sha256:...` digest instead of a mutable tag.

The build workflow signs provenance for the tested native images and the combined AMD64/ARM64 index, using GitHub OIDC. The package is linked to its source repository; workflow summaries link the actual attestations. A universal package-page "Verified" badge is not promised for personal GitHub accounts.

## Optional verification

Use an authenticated current GitHub CLI (2.103.3 or newer) and the published index digest:

```sh
gh attestation verify \
  oci://ghcr.io/elehiggle/tor-socks-proxy@sha256:DIGEST \
  --repo Elehiggle/tor-socks-proxy \
  --cert-identity 'https://github.com/Elehiggle/tor-socks-proxy/.github/workflows/docker-build.yml@refs/heads/master' \
  --source-ref refs/heads/master \
  --deny-self-hosted-runners
```

For a specific build, additionally require `--source-digest COMMIT --signer-digest COMMIT`. These checks establish artifact bytes, producing workflow, source ref/commit and hosted-runner identity. Authorized source code and repository maintainers remain trusted.

GitHub Container Registry does not provide the same tag-locking contract as GitHub Immutable Releases. The immutable package reference is the content digest; `latest` intentionally moves to subsequent tested builds. This project publishes container packages and creates no GitHub Releases.
