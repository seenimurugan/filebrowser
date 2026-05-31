# FileBrowser — maintenance

**On this page:** [Restart the pod](#restart-the-pod) · [Logs](#logs) · [Update FileBrowser version](#update-filebrowser-version) · [Backup the database](#backup-the-database) · [Reset admin password (forgot it)](#reset-admin-password-forgot-it) · [Common issues](#common-issues) · [Stop FileBrowser](#stop-filebrowser) · [Uninstall completely](#uninstall-completely)

## Restart the pod

```bash
kubectl rollout restart deployment/filebrowser -n homelab
kubectl rollout status deployment/filebrowser -n homelab
```

## Logs

```bash
kubectl logs -n homelab deployment/filebrowser --tail=50 -f
```

Useful for debugging login issues, slow indexing, or 401/403 errors.

## Update FileBrowser version

The deployment pins `image: filebrowser/filebrowser:v2.32.0`. To upgrade:

```bash
# 1. Edit k8s/filebrowser-server.yaml — bump the image tag
# 2. Apply
./deploy.sh

# 3. Watch the rollout
kubectl rollout status deployment/filebrowser -n homelab
```

The SQLite DB schema is auto-migrated on container start. Existing users + settings carry over.

## Backup the database

The user accounts, shared links, and FB settings live in a SQLite DB at `/database/filebrowser.db` inside the pod. It's on a local-path PVC, so it survives pod restarts — but if you `orbctl reset` the OrbStack VM you lose it.

Quick manual backup:

```bash
# Adjust the destination path to wherever your local backups live:
kubectl cp homelab/$(kubectl get pod -n homelab -l app=filebrowser -o name | head -1 | cut -d/ -f2):/database/filebrowser.db \
  ~/backups/filebrowser-db-$(date +%Y%m%d).db
```

Or just rely on the weekly `backup-immich.sh` if you extend it to grab this PVC too.

The DB is small (KBs), so even monthly backups are fine. The actual document data is your `~/Documents/` folder which is on the Mac SSD, separate from the FB DB.

## Reset admin password (forgot it)

`kubectl exec` into the pod and use the FB CLI:

```bash
POD=$(kubectl get pod -n homelab -l app=filebrowser -o name | head -1 | cut -d/ -f2)
kubectl exec -n homelab $POD -- filebrowser -d /database/filebrowser.db users update admin --password NEW_PASSWORD_HERE
```

Then refresh the browser and log in with the new password.

## Common issues

### "Permission denied" when deleting / uploading

The pod runs as root via `securityContext.runAsUser: 0` and the hostPath bind-mount goes through virtiofs (which strips owner mapping). Writes should work for any file `~/Documents` can reach.

If it actually fails:

```bash
# Check from inside the pod:
kubectl exec -n homelab deployment/filebrowser -- ls -la /srv | head
# Look for any files that say "?" for owner — those would be virtiofs hiccups
# A pod restart usually fixes it:
kubectl rollout restart deployment/filebrowser -n homelab
```

### Login page loads but credentials don't work

Check if the DB got initialised with a different admin user:

```bash
kubectl exec -n homelab deployment/filebrowser -- filebrowser -d /database/filebrowser.db users ls
```

Reset password (see above) if needed.

### Search results stale / missing recent files

FileBrowser indexes on a schedule. To force a re-index:

```bash
# Easiest: restart the pod, which re-scans on startup
kubectl rollout restart deployment/filebrowser -n homelab
```

### URL `files.stoat-perch.ts.net` doesn't resolve

Tailscale magic DNS takes 30-60s to propagate when a new node joins.

```bash
# Verify the tailscale proxy pod is up:
kubectl get pod -n tailscale | grep filebrowser
# Should show ts-filebrowser-XXXX-0 Running 1/1

# Verify the ingress was picked up:
kubectl describe ingress -n homelab filebrowser
```

If still not resolving after a couple of minutes, restart the operator:

```bash
kubectl rollout restart deployment/operator -n tailscale
```

### Documents disappeared from the UI

The `/srv` mount comes from `~/Documents/` on the Mac. If the Mac is asleep or the file disappears (deleted via Finder), it disappears from FB too.

Check: `ls ~/Documents` on the Mac. If it's still there but FB doesn't show it, restart the pod.

## Stop FileBrowser

```bash
kubectl scale deployment/filebrowser -n homelab --replicas=0
```

To re-enable:

```bash
kubectl scale deployment/filebrowser -n homelab --replicas=1
```

The PV/PVC and DB remain; nothing is lost.

## Uninstall completely

```bash
./undeploy.sh
```

`~/Documents/` on the Mac is untouched.
