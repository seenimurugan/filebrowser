#!/usr/bin/env bash
# undeploy.sh — tear down filebrowser deployments/services/ingress/PVCs
# NOTE: The PV (filebrowser-content-pv) is NOT deleted — it points at your
#       host's documents folder (HOMELAB_DOCUMENTS_PATH) which is safe to keep.
# NOTE: filebrowser-db-pvc IS deleted here (it only holds FileBrowser user
#       accounts and settings). The actual documents remain on the host.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Load .env for HOMELAB_NAMESPACE ──────────────────────────────────────────
ENV_FILE="$SCRIPT_DIR/.env"
if [[ -f "$ENV_FILE" ]]; then
  # shellcheck disable=SC1090
  set -a; source "$ENV_FILE"; set +a
fi
HOMELAB_NAMESPACE="${HOMELAB_NAMESPACE:-homelab}"

echo "Undeploying filebrowser from namespace '$HOMELAB_NAMESPACE'..."
echo "(The host documents folder is untouched. The PV is retained.)"
echo ""

# ── Ingress ───────────────────────────────────────────────────────────────────
kubectl -n "$HOMELAB_NAMESPACE" delete ingress filebrowser --ignore-not-found

# ── Service ───────────────────────────────────────────────────────────────────
kubectl -n "$HOMELAB_NAMESPACE" delete service filebrowser --ignore-not-found

# ── Deployment ────────────────────────────────────────────────────────────────
kubectl -n "$HOMELAB_NAMESPACE" delete deployment filebrowser --ignore-not-found

# ── PVCs ──────────────────────────────────────────────────────────────────────
# filebrowser-db-pvc: SQLite DB (users, settings) — deleted on undeploy.
# filebrowser-content-pvc: reference to host documents — deleted, but PV is retained.
kubectl -n "$HOMELAB_NAMESPACE" delete pvc filebrowser-db-pvc      --ignore-not-found
kubectl -n "$HOMELAB_NAMESPACE" delete pvc filebrowser-content-pvc --ignore-not-found

# ── PV (cluster-scoped) ───────────────────────────────────────────────────────
# Retained by default (reclaimPolicy: Retain). Only delete if you want a clean slate.
# kubectl delete pv filebrowser-content-pv --ignore-not-found

echo ""
echo "  filebrowser torn down."
echo ""
echo "  Kept:"
echo "    - filebrowser-content-pv  (PV retained; your documents folder is untouched)"
echo "    - HOMELAB_DOCUMENTS_PATH  ($HOMELAB_NAMESPACE filesystem unaffected)"
echo ""
echo "  To redeploy:  ./deploy.sh"
echo "  To also delete the PV:  kubectl delete pv filebrowser-content-pv"
