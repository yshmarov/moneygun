#!/bin/sh
set -eu

: "${SCHEDULE:?SCHEDULE env var required}"

case "${1:-}" in
  backup.sh|sh)
    shift || true
    [ "${1:-}" = "backup.sh" ] && shift
    exec /usr/local/bin/backup.sh
    ;;
esac

crontab_file="$(mktemp)"
printf '%s /usr/local/bin/backup.sh\n' "$SCHEDULE" > "$crontab_file"
exec /usr/local/bin/supercronic "$crontab_file"
