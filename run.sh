#!/bin/bash
set -euo pipefail

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

mkdir -p "$BASE_DIR/tmp"
mkdir -p "$BASE_DIR/logs"

#BASE_DIR="/home/mahdi/Desktop/nadnet/db-backup"
LOG_FILE="$BASE_DIR/logs/backup.log"
TMP_DIR="$BASE_DIR/tmp"
CONFIG_FILE="$BASE_DIR/databases.conf"

source "$BASE_DIR/.env"


log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a "$LOG_FILE"
}

mkdir -p "$TMP_DIR"

log "Multi-DB Backup Started"

while IFS="|" read -r DB_TYPE DB_NAME DB_HOST DB_USER DB_PASS
do
  [[ "$DB_NAME" =~ ^#.*$ || -z "$DB_NAME" ]] && continue

  DATE=$(date +"%Y-%m-%d_%H-%M-%S")
  FILENAME="${DB_NAME}_${DATE}.sql"
  ARCHIVE="${FILENAME}.gz"

  log "Backing up $DB_NAME"

  if [ "$DB_TYPE" = "postgres" ]; then

    PGPASSWORD="$DB_PASS" pg_dump \
      -h "$DB_HOST" \
      -U "$DB_USER" \
      -d "$DB_NAME" \
      -F p \
      > "$TMP_DIR/$FILENAME"

  elif [ "$DB_TYPE" = "mysql" ]; then
    mysqldump \
      -h "$DB_HOST" \
      -u "$DB_USER" \
      -p"$DB_PASS" \
      "$DB_NAME" \
      > "$TMP_DIR/$FILENAME"
  else
    log "Unknown DB type: $DB_TYPE"
    continue
  fi

  gzip "$TMP_DIR/$FILENAME"

  log "Uploading $DB_NAME to S3"

  rclone copy "$TMP_DIR/$ARCHIVE" "$S3_REMOTE:$S3_BUCKET"

  rm -f "$TMP_DIR/$ARCHIVE"

  log "$DB_NAME done"

  sleep 3 

done < "$CONFIG_FILE"

log "All databases backed up successfully" 
