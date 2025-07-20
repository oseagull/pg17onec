#!/bin/bash

# Original disk space check
REQUIRED_SPACE_MB=$(( $(du -s "$PGDATA" 2>/dev/null | awk '{print $1}') / 1024 ))
AVAILABLE_SPACE_MB=$(( $(df "$PGDATA" 2>/dev/null | awk 'NR==2 {print $4}') / 1024 ))

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "Insufficient free space. Required: $REQUIRED_SPACE_MB MB, Available: $AVAILABLE_SPACE_MB MB."
    exit 1
fi

# Check if PostgreSQL is responding (using PostgreSQL Pro 17 path)
if ! /opt/pgpro/1c-17/bin/pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    echo "PostgreSQL is not responding"
    exit 1
fi

# Success
exit 0
