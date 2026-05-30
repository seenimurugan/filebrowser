# filebrowser

Self-hosted [FileBrowser](https://filebrowser.org) — a web UI for browsing, searching, uploading, and deleting files from any tailnet device. Single-container deployment on Kubernetes (OrbStack k3s) exposed via Tailscale ingress.

## What it does

Mounts a local documents folder (configured via `.env`) as a live hostPath bind-mount into the pod. Changes made in the web UI are reflected on the host filesystem immediately, and vice versa. Purpose-built for homelab document management alongside a docsify docs site.

## Depends on

- **cluster-setup** — `homelab` namespace, Tailscale ingress controller: [`github.com/seenimurugan/homelab-cluster-setup`](https://github.com/seenimurugan/homelab-cluster-setup)

## Quick start

```bash
git clone https://github.com/seenimurugan/filebrowser
cd filebrowser

# 1. Set up your env
cp .env.example .env
$EDITOR .env   # set HOMELAB_NAMESPACE and HOMELAB_DOCUMENTS_PATH

# 2. Deploy
./deploy.sh
```

`deploy.sh` is idempotent — safe to re-run. It runs `envsubst` over the YAML before applying, so no secrets or host-specific paths are hardcoded in the manifests.

## Access

| | |
|---|---|
| **Tailnet URL** | https://files.stoat-perch.ts.net |
| **Default login** | `admin` / `admin` — **change immediately** |
| **Debug port-forward** | `kubectl -n homelab port-forward svc/filebrowser 8080:80` |

Change the admin password on first login: Settings (gear icon, top right) → Users → admin → set a new password → Save.

## Tear down

```bash
./undeploy.sh   # removes deployment/service/ingress/PVCs; host documents are untouched
```

## Docs

- [docs/README.md](docs/README.md) — app overview, access URLs
- [docs/USAGE.md](docs/USAGE.md) — browse, search, upload, delete, share links
- [docs/MAINTENANCE.md](docs/MAINTENANCE.md) — restart, backup the DB, troubleshooting
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — design decisions, topology, bind-mount strategy, auth model

## Environment variables

| Variable | Description | Example |
|---|---|---|
| `HOMELAB_NAMESPACE` | Kubernetes namespace | `homelab` |
| `HOMELAB_DOCUMENTS_PATH` | Absolute host path to expose via FileBrowser | `/Users/yourname/Documents` |
