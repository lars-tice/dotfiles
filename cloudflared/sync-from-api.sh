#!/usr/bin/env python3
"""Regenerate config.reference.yml from Cloudflare's authoritative API.

Requires environment variables:
  CLOUDFLARE_API_TOKEN   — token with Account:Cloudflare Tunnel:Read
  CLOUDFLARE_ACCOUNT_ID  — account UUID (Dash -> Overview sidebar)

Optional:
  TUNNEL_NAME            — defaults to "a4c-k3s-tunnel"

Usage:
  export CLOUDFLARE_API_TOKEN=...
  export CLOUDFLARE_ACCOUNT_ID=...
  ./sync-from-api.sh
"""

import json
import os
import subprocess
import sys
from datetime import date
from pathlib import Path
from urllib.request import Request, urlopen

TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN")
ACCOUNT = os.environ.get("CLOUDFLARE_ACCOUNT_ID")
TUNNEL_NAME = os.environ.get("TUNNEL_NAME", "a4c-k3s-tunnel")

if not TOKEN or not ACCOUNT:
    sys.exit("set CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID env vars")


def api(path: str) -> dict:
    req = Request(
        f"https://api.cloudflare.com/client/v4{path}",
        headers={"Authorization": f"Bearer {TOKEN}"},
    )
    with urlopen(req) as r:
        return json.load(r)


tunnels = api(f"/accounts/{ACCOUNT}/cfd_tunnel?name={TUNNEL_NAME}&is_deleted=false")
matches = tunnels.get("result") or []
if not matches:
    sys.exit(f"no tunnel named {TUNNEL_NAME!r} found in account")
tunnel_id = matches[0]["id"]

cfg = api(f"/accounts/{ACCOUNT}/cfd_tunnel/{tunnel_id}/configurations")["result"]


def yaml_scalar(v) -> str:
    if isinstance(v, bool):
        return "true" if v else "false"
    if isinstance(v, str):
        if v.startswith("*") or any(c in v for c in (":", "#", "&", "*", "!")) \
                or v.lower() in ("yes", "no", "true", "false", "null"):
            return f'"{v}"'
        return v
    return json.dumps(v)


lines = [
    "# ==========================================================================",
    f"# Cloudflare Tunnel: {TUNNEL_NAME}  —  REFERENCE MIRROR",
    "# ==========================================================================",
    "# This file is NOT loaded by cloudflared. It mirrors the authoritative",
    "# config that lives in Cloudflare's control plane (dashboard-managed).",
    "# To edit the live config: see README.md.",
    "# Regenerate this file with: ./sync-from-api.sh",
    "#",
    f"# Last synced:        {date.today().isoformat()}",
    f"# API config version: {cfg['version']}",
    f"# Source:             {cfg['source']}",
    "# ==========================================================================",
    "",
    f"tunnel: {TUNNEL_NAME}",
    "",
    "ingress:",
]

for rule in cfg["config"]["ingress"]:
    lines.append("")
    host = rule.get("hostname")
    if host:
        lines.append(f"  - hostname: {yaml_scalar(host)}")
        lines.append(f"    service: {rule['service']}")
    else:
        lines.append("  # Catch-all")
        lines.append(f"  - service: {rule['service']}")

    origin = rule.get("originRequest") or {}
    if origin:
        lines.append("    originRequest:")
        for k, v in origin.items():
            lines.append(f"      {k}: {yaml_scalar(v)}")

out = Path(__file__).resolve().parent / "config.reference.yml"
out.write_text("\n".join(lines) + "\n")
print(f"Wrote: {out}")

try:
    subprocess.run(
        ["git", "-C", str(out.parent), "diff", "--stat", "--", out.name],
        check=False,
    )
except FileNotFoundError:
    pass
