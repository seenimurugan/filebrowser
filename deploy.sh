#!/usr/bin/env bash
# deploy.sh — idempotent deploy for filebrowser (file-management web UI)
# Usage: ./deploy.sh
# Safe to re-run; existing resources are patched, not replaced.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── 1. Load .env ─────────────────────────────────────────────────────────────
ENV_FILE="$SCRIPT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env not found."
  echo "       Copy .env.example to .env and fill in real values, then re-run."
  echo "         cp .env.example .env && \$EDITOR .env"
  exit 1
fi
# shellcheck disable=SC1090
set -a; source "$ENV_FILE"; set +a

# ── 2. Prereq checks ─────────────────────────────────────────────────────────
if ! command -v kubectl &>/dev/null; then
  echo "ERROR: kubectl not found in PATH."
  exit 1
fi
if ! command -v envsubst &>/dev/null; then
  echo "ERROR: envsubst not found. Install via: brew install gettext"
  exit 1
fi
if ! kubectl cluster-info &>/dev/null; then
  echo "ERROR: Cannot reach the Kubernetes cluster. Is OrbStack running?"
  exit 1
fi

# ── 3. Ensure namespace exists ───────────────────────────────────────────────
HOMELAB_NAMESPACE="${HOMELAB_NAMESPACE:-homelab}"
if ! kubectl get namespace "$HOMELAB_NAMESPACE" &>/dev/null; then
  echo "Namespace '$HOMELAB_NAMESPACE' not found — creating it."
  kubectl create namespace "$HOMELAB_NAMESPACE"
else
  echo "Namespace '$HOMELAB_NAMESPACE' already exists."
fi

# ── 4. Verify HOMELAB_DOCUMENTS_PATH exists on host ──────────────────────────
if [[ -z "${HOMELAB_DOCUMENTS_PATH:-}" ]]; then
  echo "ERROR: HOMELAB_DOCUMENTS_PATH is not set in .env."
  exit 1
fi
if [[ ! -d "$HOMELAB_DOCUMENTS_PATH" ]]; then
  echo "WARNING: HOMELAB_DOCUMENTS_PATH='$HOMELAB_DOCUMENTS_PATH' does not exist on this host."
  echo "         The PersistentVolume will fail to bind. Create the directory first, or update .env."
  echo "         Proceeding anyway (you may be deploying to a different machine)."
fi

# ── 5. Apply manifests via envsubst ──────────────────────────────────────────
K8S_FILE="$SCRIPT_DIR/k8s/filebrowser-server.yaml"
echo "Applying k8s manifests (envsubst → kubectl apply)..."
echo "  → $K8S_FILE"
envsubst < "$K8S_FILE" | kubectl apply -f -

# ── 6. Wait for rollout ───────────────────────────────────────────────────────
echo "Waiting for filebrowser rollout..."
kubectl -n "$HOMELAB_NAMESPACE" rollout status deployment/filebrowser --timeout=5m

# ── 7. Done ───────────────────────────────────────────────────────────────────
echo ""
echo "  filebrowser deployed successfully."
echo ""
echo "  Access (on Tailnet):  https://files.<your-tailnet>.ts.net"
echo "  Default login:        admin / admin"
echo ""
echo "  IMPORTANT: Change the default password immediately:"
echo "    Settings (gear icon, top right) -> Users -> admin -> set a new password -> Save"
echo ""
echo "  To monitor:  kubectl -n ${HOMELAB_NAMESPACE} logs deployment/filebrowser -f"
