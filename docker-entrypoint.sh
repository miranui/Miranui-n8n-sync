#!/bin/sh
set -euo pipefail

# Start n8n in background to run migrations + expose health endpoints
echo "[init] starting n8n in background for setup..."

echo "${WEBHOOK_URL}rest/owner/setup"
n8n start &

# Wait until instance is ready (DB connected & migrated)
until curl -sf "${WEBHOOK_URL}healthz/readiness" > /dev/null; do
  echo "[init] waiting for n8n readiness..."
  sleep 2
done

echo "[init] instance is ready. Proceeding with owner setup..."

# Envoi de la requête et capture du code HTTP + réponse
response=$(curl -s -X POST "${WEBHOOK_URL}rest/owner/setup" \
  -H "Content-Type: application/json" \
  -d "{\"email\":\"$OWNER_EMAIL\",\"password\":\"$OWNER_PASSWORD\",\"firstName\":\"${N8N_OWNER_FIRSTNAME:-Admin}\",\"lastName\":\"${N8N_OWNER_LASTNAME:-User}\"}" \
  -w "\n%{http_code}")

# Séparation du corps et du code HTTP
http_body=$(echo "$response" | sed '$d')
http_code=$(echo "$response" | tail -n1)

echo "------ n8n owner setup ------"
echo "HTTP status: $http_code"

case "$http_code" in
  200|201)
    echo "[✅] Owner created successfully."
    echo "Response:"
    echo "$http_body"
    ;;
  409)
    echo "[ℹ️] Owner already exists."
    echo "Response:"
    echo "$http_body"
    ;;
  400|401|403)
    echo "[⚠️] Authentication or validation error."
    echo "Response:"
    echo "$http_body"
    ;;
  *)
    echo "[❌] Unexpected error (HTTP $http_code)."
    echo "Response:"
    echo "$http_body"
    ;;
esac

echo "------------------------------"


n8n import:workflow --separate --input=/files/insidequest
n8n import:workflow --separate --input=/files/synchro-miranui

# --- ACTIVATION SELECTIVE VIA CLI ---
echo "[init] activating workflows from WORKFLOWS_TO_ACTIVATE=${WORKFLOWS_TO_ACTIVATE:-<unset>}"
if [ -n "${WORKFLOWS_TO_ACTIVATE:-}" ]; then
  # POSIX-safe: remove spaces, replace commas with spaces and iterate
  cleaned=$(printf '%s' "$WORKFLOWS_TO_ACTIVATE" | tr -d ' ')
  for id in $(printf '%s' "$cleaned" | tr ',' ' '); do
    [ -z "$id" ] && continue
    echo "[init] n8n update:workflow --id=$id --active=true"
    if ! n8n update:workflow --id="$id" --active=true; then
      echo "[init] WARNING: failed to activate workflow $id"
    fi
  done
else
  echo "[init] WORKFLOWS_TO_ACTIVATE not set — skipping selective activation"
fi

echo "[init] stopping background n8n..."
kill %1
wait %1 || true

echo "[init] starting n8n in foreground..."
exec n8n start
