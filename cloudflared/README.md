# Cloudflare Tunnel (`a4c-k3s-tunnel`) — operator docs

This directory is **documentation and a versioned reference mirror** for the
Cloudflare Tunnel that fronts `firstovertheline.com`. Nothing here is read by
`cloudflared` at runtime — the authoritative configuration is managed in
Cloudflare's control plane.

> **TL;DR** — To change routing, edit in the Zero Trust dashboard, then run
> `./sync-from-api.sh` to update `config.reference.yml` and commit the diff.

## Contents

| File | Purpose |
|---|---|
| `config.reference.yml` | Snapshot of the live tunnel config, pulled from the Cloudflare API. Read-only mirror; editing it has no effect. |
| `sync-from-api.sh` | Regenerates `config.reference.yml` from the API. Run after every dashboard change so git reflects reality. |
| `README.md` | This file. |

## Architecture

```
Internet
   │
   ▼
Cloudflare edge  (DNS: *.firstovertheline.com → <tunnel-uuid>.cfargotunnel.com)
   │   TLS terminated here; optional Zero Trust Access policy applied
   ▼
QUIC tunnel (4 connections, auto-selected by cloudflared)
   │
   ▼
cloudflared (systemd service on larsbox)
   │   runs as user `cloudflared`, config from Cloudflare API (remote-managed)
   │   credentials: /etc/cloudflared/c9fbbb48-...json
   ▼
Origin services on LAN
   ├─ larsbox:22                       (SSH)
   ├─ 192.168.122.42:6443   (k3s-server VM, kube-apiserver)
   ├─ 192.168.122.42:80     (k3s Traefik — host-header routing)
   ├─ 192.168.2.100:30013              (TrueNAS, Jellyfin NodePort)
   └─ 192.168.2.100:30357              (TrueNAS, Jellyseerr NodePort)
```

The `192.168.122.*` network is the libvirt default bridge (`virbr0`) on larsbox.
`192.168.122.1` is larsbox itself as seen from that network; `192.168.122.42`
is the `k3s-server` libvirt VM.

## Hostname routing table

| Hostname | Target | Access | Purpose |
|---|---|---|---|
| `ssh.firstovertheline.com` | `ssh://192.168.122.1:22` | Zero Trust Access | SSH to larsbox, via `cloudflared access ssh` ProxyCommand |
| `k8s.firstovertheline.com` | `https://192.168.122.42:6443` (noTLSVerify) | kubeconfig certs | kube-apiserver on k3s VM |
| `api-a4c.firstovertheline.com` | `http://192.168.122.42:80` (Host: api-a4c) | — | Backend API via Traefik IngressRoute |
| `a4c.firstovertheline.com` | `http://192.168.122.42:80` (Host: a4c) | — | Public app via Traefik IngressRoute |
| `media.firstovertheline.com` | `http://192.168.2.100:30013` | — | Jellyfin on TrueNAS |
| `requests.firstovertheline.com` | `http://192.168.2.100:30357` | — | Jellyseerr on TrueNAS |
| `*.firstovertheline.com` | `http://192.168.122.42:80` | — | Fallback → Traefik (any unlisted subdomain with a DNS record) |
| *(catch-all)* | `http_status:404` | — | Last-resort for requests that have no matching route |

Rules are evaluated top-to-bottom; first match wins. The wildcard sits **after**
all explicit hostnames so they win. The catch-all is effectively unreachable
for `firstovertheline.com` (the wildcard above it catches everything) — it
matters only if traffic somehow arrives with a different base domain.

## Where the real config lives

The tunnel is **remote-managed**:

- Authoritative source: Cloudflare control plane (API-backed)
- UI location: `https://one.dash.cloudflare.com/` → **Networks → Tunnels →
  `a4c-k3s-tunnel` → Public Hostname** tab
- API read:
  `GET /accounts/{account_id}/cfd_tunnel/{tunnel_id}/configurations`
- `cloudflared` receives the config via its QUIC control channel; the local
  file at `/etc/cloudflared/config.yml` is ignored while `remote_config=true`.

### Why not locally-managed?

We evaluated switching to locally-managed (`/etc/cloudflared/config.yml` as
source of truth). **The Cloudflare API does not expose a way to flip an
existing tunnel from remote to local** — `config_src` / `remote_config` are
read-only status fields. The only documented path is the Zero Trust
dashboard. See [cloudflared#843](https://github.com/cloudflare/cloudflared/issues/843).

We chose to keep it remote-managed and mirror to git (this directory) rather
than tear down and recreate the tunnel (which would require updating every
DNS record).

## Editing the config

All routing changes happen in the Zero Trust dashboard. Typical flows:

### Add a new hostname

1. **DNS**: in Cloudflare dashboard (`dash.cloudflare.com` → `firstovertheline.com`
   → DNS → Records), add a CNAME `<name>` → `<tunnel-uuid>.cfargotunnel.com`,
   Proxy status: **Proxied** (orange cloud).
   - If the new name is covered by the existing wildcard, you *technically*
     only need the DNS record — the ingress wildcard will route it to Traefik.
     But if it needs a different origin, add an explicit ingress entry too.
2. **Ingress**: Zero Trust dashboard → Networks → Tunnels → `a4c-k3s-tunnel`
   → Public Hostname → **Add a public hostname**.
3. **Sync the mirror**: `./sync-from-api.sh`
4. Commit the diff.

### Modify an existing hostname

1. Zero Trust dashboard → Networks → Tunnels → `a4c-k3s-tunnel` → Public Hostname
   → click the row → edit service / originRequest → Save.
2. `./sync-from-api.sh`
3. Commit.

### Remove a hostname

1. Zero Trust dashboard → Networks → Tunnels → `a4c-k3s-tunnel` → Public Hostname
   → delete the row.
2. Optionally also delete the DNS record if no other service needs it
   (otherwise it will return Cloudflare error 1016 for deleted-backend traffic).
3. `./sync-from-api.sh`
4. Commit.

### Adjust origin request options (host-header, noTLSVerify, etc.)

In the dashboard, edit the hostname → expand **Additional application
settings** → set values there. `config.reference.yml` keeps them under
`originRequest:`.

## Running the sync script

```sh
export CLOUDFLARE_API_TOKEN='...'      # Account:Cloudflare Tunnel:Read
export CLOUDFLARE_ACCOUNT_ID='...'     # dashboard overview sidebar
cd ~/dotfiles/cloudflared
./sync-from-api.sh
```

The script:
1. Looks up the tunnel UUID by name (`TUNNEL_NAME`, defaults to `a4c-k3s-tunnel`)
2. Fetches `/configurations` from the API
3. Rewrites `config.reference.yml` with a fresh header (version, sync date)
4. Prints `git diff --stat` so you can see what changed

If the diff is empty, the dashboard and the mirror agree. If not, review and
commit.

### Token management

- Use a **read-only** token (`Account:Cloudflare Tunnel:Read`). Mirroring
  never writes back.
- Rotate regularly in Dash → My Profile → API Tokens.
- **Do not commit the token or account ID** — they stay in env vars.

## Related system files (outside dotfiles)

| Path | Notes |
|---|---|
| `/etc/cloudflared/config.yml` | Defensive fallback. Matches `config.reference.yml`; unused while remote-managed. If Cloudflare control plane ever returned a cleared config, cloudflared would read this. |
| `/etc/cloudflared/c9fbbb48-...json` | Tunnel credentials (secret). **Never commit.** |
| `/etc/systemd/system/cloudflared.service` | systemd unit (runs as user `cloudflared`). |
| `~/.cloudflared/*.json` | User-copies of credentials files (historical; the system service uses the `/etc/` copy). |
| `~/.cloudflared/firstovertheline.cloudflareaccess.com-org-token` | Zero Trust team org token cache (client-side). |
| `~/.cloudflared/ssh.firstovertheline.com-*-token` | Cached Access JWT for SSH. Refresh with `cloudflared access login https://ssh.firstovertheline.com`. |

## Gotchas we learned the hard way

- **`~/.cloudflared/config.yml` is ignored by the systemd service.** The
  service loads `/etc/cloudflared/config.yml`. Editing the user copy does
  nothing. If you see one, it's an orphan from a past setup.
- **Remote config silently overrides local config.** Even when
  `/etc/cloudflared/config.yml` has valid ingress rules, `remote_config=true`
  means cloudflared ignores them in favor of what the API pushes. Confirm with:
  ```sh
  journalctl -u cloudflared | grep "Updated to new configuration" | tail -1
  ```
  A `version=N` suffix indicates remote config is active.
- **Wildcard DNS ≠ wildcard ingress.** The ingress `*.firstovertheline.com`
  rule is only reached if DNS resolves. Cloudflare doesn't auto-create DNS;
  each subdomain needs its own record, or you need a DNS wildcard
  (`*` CNAME → `<tunnel-uuid>.cfargotunnel.com`, proxied).
- **Cloudflare doesn't proxy raw TCP/22.** SSH over the tunnel requires
  `cloudflared access ssh --hostname %h` as an SSH `ProxyCommand` on the
  client. Direct `ssh ssh.firstovertheline.com` without the ProxyCommand
  fails.
- **Access policies live in the Zero Trust dashboard**, not in tunnel ingress
  config. The old cloudflared `originRequest.access.required` syntax is
  deprecated. Set Access at Zero Trust → Access → Applications.
- **The API cannot switch a tunnel from remote- to locally-managed.** Only
  the dashboard can (by deleting all Public Hostname entries).

## Troubleshooting

### "Is the tunnel actually connected?"

```sh
systemctl status cloudflared
journalctl -u cloudflared -n 50 --no-pager | grep -E "Registered tunnel|ERR"
```

Healthy: 4 `Registered tunnel connection` lines (one per Cloudflare region).

### "A hostname is returning 530 / 1033 / 1016"

| Error | Meaning |
|---|---|
| 530 | Origin offline or tunnel disconnected |
| 1033 | Tunnel up but hostname not in ingress (or wildcard catch-all missing) |
| 1016 | DNS record points to tunnel but tunnel doesn't know the hostname |

Check:
1. `journalctl -u cloudflared -n 20` on larsbox
2. In the dashboard, is the hostname listed under Public Hostname?
3. Is the origin up? (e.g., for media, is Jellyfin running on TrueNAS?)

### "A hostname is returning 502"

Origin service is unreachable or returning errors. Reach the origin directly
to confirm:

```sh
curl -I http://192.168.2.100:30013           # Jellyfin direct
curl -I http://192.168.122.42:80             # Traefik direct
```

### "cloudflared restart and everything broke"

If `/etc/cloudflared/config.yml` was accidentally deleted or has invalid YAML,
cloudflared can fail to start. Validate:

```sh
sudo cloudflared tunnel --config /etc/cloudflared/config.yml ingress validate
```

Restore from `config.reference.yml` if needed (strip the `# Last synced:`
header but keep the data).

## Recovery scenarios

### Dashboard config accidentally cleared

1. `cloudflared` falls back to `/etc/cloudflared/config.yml` (the defensive
   copy) — most routes still work.
2. Repopulate the dashboard from `config.reference.yml` one hostname at a
   time.
3. `./sync-from-api.sh` once restored.

### Tunnel credentials lost

The `c9fbbb48-...json` file is the tunnel's only proof of identity. If it's
gone:

1. In the dashboard, delete the existing `a4c-k3s-tunnel` connector.
2. Create a new tunnel; get new credentials JSON.
3. Update every DNS CNAME to the new `<tunnel-uuid>.cfargotunnel.com`.
4. Recreate all Public Hostname entries (from `config.reference.yml`).
5. `./sync-from-api.sh`.

### Migration to locally-managed (future)

If Cloudflare ever adds API support to flip `remote_config=false`, or if
you're willing to navigate the Zero Trust dashboard:

1. Confirm `/etc/cloudflared/config.yml` matches the latest
   `config.reference.yml`.
2. In the dashboard, delete all Public Hostname entries from the tunnel.
3. `sudo systemctl restart cloudflared`.
4. Verify logs: no more `Updated to new configuration ... version=N` lines;
   `remote_config` now `false` via API.
5. From this point, edit `/etc/cloudflared/config.yml` and
   `systemctl reload cloudflared`. This directory becomes authoritative.

## Reference links

- Cloudflare Tunnel overview: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/
- Local configuration file format: https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/do-more-with-tunnels/local-management/configuration-file/
- SSH over Cloudflare Access: https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/use-cases/ssh/
- Open issue for remote→local switch: https://github.com/cloudflare/cloudflared/issues/843
