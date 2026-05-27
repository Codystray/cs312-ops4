#!/bin/bash
# Snapshot the Minecraft world from the running Pod and push it to S3.
# AWS access uses the EC2 instance profile; no credentials are stored here.
set -euo pipefail

BUCKET="ops3-minecraft-backups-413777480403"
STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
ARCHIVE="/tmp/minecraft-${STAMP}.tar.gz"

POD="$(kubectl get pod -l app=minecraft -o jsonpath='{.items[0].metadata.name}')"

# Flush the world to disk via RCON so the archive is consistent.
RCON_PW="$(kubectl get secret minecraft-secret \
  -o jsonpath='{.data.rcon-password}' | base64 --decode)"
kubectl exec "${POD}" -- rcon-cli --password "${RCON_PW}" save-all flush

# Archive /data from inside the container and stream it to the host.
kubectl exec "${POD}" -- tar -czf - -C /data . > "${ARCHIVE}"

# Upload a timestamped artifact and update the latest pointer.
aws s3 cp "${ARCHIVE}" "s3://${BUCKET}/minecraft-${STAMP}.tar.gz"
aws s3 cp "${ARCHIVE}" "s3://${BUCKET}/latest.tar.gz"

rm -f "${ARCHIVE}"
echo "Backup complete: s3://${BUCKET}/minecraft-${STAMP}.tar.gz"
