# FileBrowser — usage

**On this page:** [Opening it](#opening-it) · [Daily operations](#daily-operations) · [Daily flow tips](#daily-flow-tips) · [What it's NOT for](#what-its-not-for)

## Opening it

From any tailnet device: `https://files.stoat-perch.ts.net`

Login with `admin` and whatever password you set on first run. The session cookie keeps you signed in for a while.

## Daily operations

### Browse

The left sidebar shows the folder tree. Click any folder to open it. Files show a preview icon (PDFs, images, video previews inline).

### Open / preview a file

- **PDF / image / video / audio / text / code** → click the filename, opens an inline viewer
- **Office docs (.docx, .xlsx, .pptx, .odt)** → click the filename → "Download" (FileBrowser doesn't render Office formats inline)
- **Zip archives** → preview tab in the file detail panel shows zip contents (but you have to download to extract)

### Search

Click the magnifying glass top-right. Searches filenames AND text content of indexed files (PDFs, text, code).

Use the filter chips to narrow by file type (image, audio, video, pdf, archive).

The search index is built incrementally as you browse / upload. For a freshly-deployed instance it may take a few minutes to fully index large folders like `Books & Learning/`.

### Upload

Drag and drop files into the browser window, or click the "+" button → Upload. New files appear on the Mac at `~/Documents/<current-path>/<filename>` immediately.

### Delete

- Select files (checkbox)
- Click the trash icon top-right (or press Delete)
- Confirm

⚠️ This is a HARD delete — files are removed from `~/Documents/` on the Mac immediately, no recycle bin. If you want a soft-delete pattern, create a `Trash/` folder and move files there instead.

### Rename / move

- Right-click → Rename, OR
- Select + click pencil icon → enter new name
- For move: cut (Ctrl-X / Cmd-X) → navigate to target → paste

### Create folder

Click the "+" → New folder

### Share links

Select a file → click the share icon → "Create link". Configure expiry / password. Anyone with the link (and on your tailnet) can access. Useful for sharing a specific PDF to a family member's phone without giving them full FileBrowser access.

## Daily flow tips

- Search is fastest for "where's that bank statement from June" → just search "june statement"
- The Uncategorized folder is where the auto-classifier dumped files it couldn't bucket. Triage it occasionally — drag files into the right category from the sidebar
- Installers and Code Archives are auto-bucketed but rarely need browsing. Consider deleting old installers periodically — they grow

## What it's NOT for

- **Photos and videos** — those are in [Immich](../immich/README.md). Don't upload media to FileBrowser, it doesn't have face recognition, no mobile auto-backup, no map view
- **Movies and TV shows** — those are in [Jellyfin](../jellyfin/README.md)
- **Markdown homelab docs** — those render properly in [docsify](../docs-server/README.md); FileBrowser shows the source text
