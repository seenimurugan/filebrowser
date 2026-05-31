# FileBrowser — documents web UI

[FileBrowser](https://filebrowser.org) is a self-hosted web UI that lets you browse, search, upload, rename, and delete arbitrary files. Deployed alongside the docs site to handle non-markdown documents (PDFs, docx, zips, ebooks, etc.) — things Docsify can't serve. The entire `~/Documents/` folder on the Mac is exposed live via a hostPath bind-mount.

Source: `/Users/nila/Developer/apps/filebrowser/`

---

## Access

| Where | URL |
|---|---|
| **iPhone / TV / family on Tailscale** | https://files.stoat-perch.ts.net |
| **Cluster DNS** (other pods / Mac shell) | http://filebrowser.homelab.svc.cluster.local |
| **Ad-hoc debug port-forward** | `kubectl -n homelab port-forward svc/filebrowser 8091:80` → http://localhost:8091 |

---

## Initial credentials

| | |
|---|---|
| User | `admin` |
| Password | `admin` |

**Change immediately** on first login: Settings (gear icon, top right) → Users → admin → set a new password → Save.

---

## What it does

- Browse, search, upload, rename, and delete files in `~/Documents/`.
- Changes made via the UI are reflected on the Mac filesystem immediately and vice versa.
- Complementary to the Docsify docs site: Docsify is read-only markdown; FileBrowser handles everything else.

Top-level document categories (populated by `categorize-docs.py`):

- `Bank & Finance/`, `ID & Personal Docs/`, `Tax/`, `Work & Career/`, `Books & Learning/`
- `Bills & Receipts/`, `Insurance/`, `Medical/`, `Legal & Contracts/`, `Travel/`
- `Uncategorized/` — files the keyword classifier couldn't bucket; triage from the UI

---

## Stack & framework

| Layer | Tech |
|---|---|
| App | FileBrowser (off-the-shelf, single Go binary) |
| Container | `filebrowser/filebrowser:s6` |
| Storage (documents) | hostPath PVC pointing at `$HOMELAB_DOCUMENTS_PATH` (`~/Documents/`) |
| Storage (DB / config) | PVC on `local-path` (VM ext4) — FileBrowser's SQLite database |
| Deploy | Kubernetes (`homelab` namespace), Tailscale Ingress |

---

## Storage

Two PVCs:

| PVC | Purpose |
|---|---|
| `filebrowser-content-pvc` | hostPath bind-mount of `$HOMELAB_DOCUMENTS_PATH` — the browsable files |
| `filebrowser-db-pvc` | FileBrowser's SQLite database (user accounts, settings) on `local-path` |

---

## See also

- [Usage guide](USAGE.md) — browse, search, upload, delete, share links
- [Maintenance](MAINTENANCE.md) — restart, backup the DB, common issues
- [Architecture](ARCHITECTURE.md) — why FileBrowser + Docsify split, how the bind-mount works

## File reference

| File | Purpose |
|---|---|
| `/Users/nila/Developer/apps/filebrowser/k8s/filebrowser-server.yaml` | Deployment + Service + Ingress + PV + PVC |
