# wg-easy-development

**A nightly image of the newest upstream [wg-easy](https://github.com/wg-easy/wg-easy)**.
The [Dockerfile](https://github.com/jwklijnsma/wg-easy-development/blob/main/Dockerfile) clones
`wg-easy/wg-easy` at build time, so every build has upstream's latest code; it is published
as `ghcr.io/jwklijnsma/wg-easy-development`.

!!! warning "Development builds"
    This follows upstream's default branch, untested. For a stable setup use
    [wg-easy](https://jwklijnsma.github.io/wg-easy/), which has its own tests.

## Run it

```bash
docker run -d --name wg-easy-dev \
  -e WG_HOST=vpn.example.org -e PASSWORD='choose-a-password' \
  -v ~/.wg-easy-dev:/etc/wireguard \
  -p 51820:51820/udp -p 51821:51821/tcp \
  --cap-add NET_ADMIN --cap-add SYS_MODULE \
  --sysctl net.ipv4.conf.all.src_valid_mark=1 --sysctl net.ipv4.ip_forward=1 \
  ghcr.io/jwklijnsma/wg-easy-development:nightly
```

Settings are upstream's environment variables (`WG_HOST`, `PASSWORD`, `WG_DEFAULT_ADDRESS`,
`WG_DEFAULT_DNS`, `WG_ALLOWED_IPS`, …); see the
[wg-easy configuration](https://jwklijnsma.github.io/wg-easy/configuration/) for the full table.
Upstream may change them — check its README when a build behaves differently.

## How the image is built

| Stage | |
|---|---|
| `node:18-alpine` | `git clone https://github.com/wg-easy/wg-easy`, then `npm ci --production` in `src/` |
| `ubuntu:22.04` | Node, WireGuard tools, `iproute2`, `iptables`, `dumb-init`; runs `node server.js` |

| When | Tag |
|---|---|
| Every night (09:37 UTC) | `nightly` |
| Push to `main` | `main` |
| You push a tag `vX.Y.Z` | `vX.Y.Z` |

Images are signed with cosign (keyless).
