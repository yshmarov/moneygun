#!/bin/sh
set -eu

: "${POSTGRES_HOST:?required}"
: "${POSTGRES_DATABASE:?required}"
: "${POSTGRES_USER:?required}"
: "${POSTGRES_PASSWORD:?required}"
: "${S3_BUCKET:?required}"
: "${S3_PREFIX:?required}"
: "${S3_ENDPOINT:?required}"
: "${S3_REGION:?required}"
: "${S3_ACCESS_KEY_ID:?required}"
: "${S3_SECRET_ACCESS_KEY:?required}"
: "${BACKUP_KEEP_DAYS:?required}"
: "${BACKUP_ENCRYPTION_KEY:?required}"

export AWS_ACCESS_KEY_ID="$S3_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$S3_SECRET_ACCESS_KEY"
export AWS_EC2_METADATA_DISABLED=true
export AWS_RETRY_MODE="${AWS_RETRY_MODE:-standard}"
export AWS_MAX_ATTEMPTS="${AWS_MAX_ATTEMPTS:-5}"

s3_url="s3://${S3_BUCKET}/${S3_PREFIX}"
aws_args="--endpoint-url ${S3_ENDPOINT} --region ${S3_REGION}"
log() { printf '[%s] %s\n' "$(date -u +%FT%TZ)" "$*"; }

retry() {
  attempts="${BACKUP_RETRY_ATTEMPTS:-3}"
  delay="${BACKUP_RETRY_DELAY_SECONDS:-10}"
  attempt=1
  while true; do
    if "$@"; then return 0; fi
    status=$?
    [ "$attempt" -ge "$attempts" ] && return "$status"
    log "Command failed (attempt ${attempt}/${attempts}); retrying in ${delay}s: $*"
    sleep "$delay"
    attempt=$((attempt + 1))
    delay=$((delay * 2))
  done
}

dump_file=""
enc_file=""
list_file=""
GNUPGHOME="$(mktemp -d)"
export GNUPGHOME
cleanup() {
  [ -n "$dump_file" ] && rm -f "$dump_file"
  [ -n "$enc_file" ] && rm -f "$enc_file"
  [ -n "$list_file" ] && rm -f "$list_file"
  [ -n "$GNUPGHOME" ] && rm -rf "$GNUPGHOME"
  true
}
trap cleanup EXIT

timestamp=$(date -u +%Y-%m-%dT%H-%M-%SZ)
dump_file="/tmp/${POSTGRES_DATABASE}_${timestamp}.dump"
PGPASSWORD="$POSTGRES_PASSWORD" pg_dump -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DATABASE" \
  --format=custom --no-owner --no-privileges --file="$dump_file"

enc_file="${dump_file}.gpg"
printf '%s' "$BACKUP_ENCRYPTION_KEY" | gpg --batch --yes --quiet \
  --symmetric --cipher-algo AES256 --s2k-mode 3 --s2k-digest-algo SHA512 --s2k-count 65011712 \
  --pinentry-mode loopback --passphrase-fd 0 --output "$enc_file" "$dump_file"
rm -f "$dump_file"
dump_file=""

# shellcheck disable=SC2086
retry aws s3 cp "$enc_file" "${s3_url}/$(basename "$enc_file")" $aws_args
rm -f "$enc_file"
enc_file=""

list_file="$(mktemp)"
# shellcheck disable=SC2086
retry aws s3 ls "${s3_url}/" $aws_args > "$list_file"
files=$(awk '{print $4}' "$list_file" | grep -E "\.dump(\.gpg)?$" | sort || true)
count=$(printf '%s\n' "$files" | grep -c . || true)
to_delete=$((count - BACKUP_KEEP_DAYS))
if [ "$to_delete" -gt 0 ]; then
  printf '%s\n' "$files" | head -n "$to_delete" | while read -r file; do
    [ -z "$file" ] && continue
    # shellcheck disable=SC2086
    retry aws s3 rm "${s3_url}/${file}" $aws_args
  done
fi

log "Encrypted backup complete"
