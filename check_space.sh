#!/bin/bash

REQUIRED_SPACE_MB=$(( $(du -s "$PGDATA" | awk '{print $1}') / 1024 ))
AVAILABLE_SPACE_MB=$(( $(df "$PGDATA" | awk 'NR==2 {print $4}') / 1024 ))

if [ "$AVAILABLE_SPACE_MB" -lt "$REQUIRED_SPACE_MB" ]; then
    echo "Insufficient free space. Required: $REQUIRED_SPACE_MB MB, Available: $AVAILABLE_SPACE_MB MB."
    exit 1
else
    exit 0
fi
