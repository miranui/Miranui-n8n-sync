#!/bin/sh
set -euo pipefail

# Start n8n in background to run migrations + expose health endpoints
echo "[init] starting n8n in background for setup..."

echo "[tmp] N8N_ENCRYPTION_KEY=${WEBHOOK_URL:-undefined}"
echo "[tmp] N8N_ENCRYPTION_KEY=${OWNER_EMAIL:-undefined}"
echo "[tmp] N8N_ENCRYPTION_KEY=${OWNER_PASSWORD:-undefined}"

echo "${WEBHOOK_URL}rest/owner/setup"
n8n start &

# Wait until instance is ready (DB connected & migrated)
until curl -sf "${WEBHOOK_URL}healthz/readiness" > /dev/null; do
  echo "[init] waiting for n8n readiness..."
  sleep 2
done

# Create owner (idempotent: if already exists, endpoint returns 200/409 or similar)
echo "[init] creating owner (idempotent)..."
curl -sf -X POST "${WEBHOOK_URL}rest/owner/setup" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$OWNER_EMAIL\",\"password\":\"$OWNER_PASSWORD\",\"firstName\":\"${N8N_OWNER_FIRSTNAME:-Admin}\",\"lastName\":\"${N8N_OWNER_LASTNAME:-User}\"}" \
  || echo "[init] owner already exists or creation skipped"

n8n import:workflow --separate --input=/files/insidequest
n8n import:workflow --separate --input=/files/synchro-miranui

echo "[init] stopping background n8n..."
kill %1
wait %1 || true

echo "[init] starting n8n in foreground..."
exec n8n start
