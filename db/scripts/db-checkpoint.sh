#!/usr/bin/env bash

set -e          # this means "EXIT IMMEDIATELY" if command returns non-zero exit status (ERROR)

# DB Configuration (matches docker-compose.yml)
SERVICE_NAME="db"
DB_USER="appuser"
DB_NAME="trackerdb"
BACKUP_DIR="./db/backups"
SCHEMA_FILE="./db/init.sql"

mkdir -p "$BACKUP_DIR"

# Taking two Input while running the script (Positional parameter args)
# first position 
COMMAND=$1
# second position
TARGET_FILE=$2

# Conditional using switch case
case "$COMMAND" in
    save)
        TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
        ARCHIVE_FILE="${BACKUP_DIR}/checkpoint_${TIMESTAMP}.sql"
        LATEST_FILE="${BACKUP_DIR}/checkpoint_latest.sql"

        echo "⏳ Saving full database checkpoint (table + data)."
        # "pg_dump" utility of postgres use to take the snapshot of the db.
        docker compose exec -T "$SERVICE_NAME" pg_dump -U "$DB_USER" --clean --if-exists --no-owner --no-privileges "$DB_NAME" > "$ARCHIVE_FILE"
        #(The --clean --if-exists flags ensure the script cleanly drops and recreates tables if needed.)


        # Update the 'latest' pointer copy
        cp "$ARCHIVE_FILE" "$LATEST_FILE"


        
        echo "✅ Checkpoint saved!"
        echo "   • Full local backup : $LATEST_FILE"
        echo "   • Timestamped copy  : $ARCHIVE_FILE"
        
    ;;

    restore)
        RESTORE_FROM="${TARGET_FILE:-${BACKUP_DIR}/checkpoint_latest.sql}"

        if [ ! -f "$RESTORE_FROM" ]; then
            echo "❌ Error: Backup file not found at $RESTORE_FROM"
            exit 1
        fi

        echo "⏳ Restoring database from $RESTORE_FROM..."
        cat "$RESTORE_FROM" | docker compose exec -T "$SERVICE_NAME" psql -U "$DB_USER" -d "$DB_NAME"
        echo "✅ Database successfully restored to state in $RESTORE_FROM!"
    ;;
    
    list)
        echo "📂 Available local checkpoints in ${BACKUP_DIR}:"
        ls -lh "$BACKUP_DIR"/*.sql 2>/dev/null || echo "No checkpoints found yet."
    ;;
    
    *)
        echo "Usage:"
        echo "  ./scripts/db-checkpoint.sh save                      # Save current DB state & update schema"
        echo "  ./scripts/db-checkpoint.sh restore                   # Restore from checkpoint_latest.sql"
        echo "  ./scripts/db-checkpoint.sh restore backups/file.sql  # Restore from a specific timestamped file"
        echo "  ./scripts/db-checkpoint.sh list                      # List all saved checkpoints"
        exit 1
    ;;
esac
