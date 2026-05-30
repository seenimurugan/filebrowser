# FileBrowser — documents web UI

[FileBrowser](https://filebrowser.org) is a self-hosted web UI that lets you browse, search, upload, rename, and delete arbitrary files. Deployed alongside the docs site to handle non-markdown documents (PDFs, docx, zips, ebooks, etc.) — things docsify can't serve.

## What it serves

The entire `~/Documents/` folder on the Mac, exposed live via a hostPath bind-mount. Any change made via the FileBrowser UI is reflected on the Mac filesystem immediately and vice versa.

## Access

| Where | URL |
|---|---|
| **iPhone / TV / family with Tailscale** | https://files.stoat-perch.ts.net |
| **This Mac (browser, cluster DNS)** | http://filebrowser.homelab.svc.cluster.local |
| **This Mac (localhost via port-forward)** | not configured by default |
| **LAN devices (without Tailscale)** | not configured |

## Initial credentials

| | |
|---|---|
| User | `admin` |
| Password | `admin` ⚠️ change immediately |

Change on first login: Settings (gear icon, top right) → Users → admin → set a new password → Save.

## Detailed docs

- [📋 USAGE](USAGE.md) — browse, search, upload, delete, share links
- [🛠 MAINTENANCE](MAINTENANCE.md) — restart, backup the DB, common issues
- [🏛 ARCHITECTURE](ARCHITECTURE.md) — why FileBrowser + docsify split, how the bind-mount works, why root user

## Quick tour

Top-level folders you'll see on first login (these are categorical buckets populated by [`categorize-docs.py`](../../configs/categorize-docs.py)):

- `Bank & Finance/` — statements, transfer requests, IBANs
- `ID & Personal Docs/` — passports, licenses, invitation letters
- `Tax/` — P60, council tax, payslips
- `Work & Career/` — employment, payslips, wisetech
- `Books & Learning/` — AI/LLM ebooks, Arduino tutorials
- `Installers/` — .dmg/.pkg/.exe (low priority, FB can ignore visually)
- `Bills & Receipts/`, `Insurance/`, `Medical/`, `Legal & Contracts/`, `Travel/`, `Code Archives/`, `Manuals & Warranties/`
- `Uncategorized/` — files the keyword classifier couldn't bucket; triage from the UI
- `Arduino/` — left untouched as the original hardware-kit folder
- `Autodesk/`, `EdgeTX/`, `Fusion 360/`, `OpenTX/`, `email-program/`, etc. — software product folders, untouched
