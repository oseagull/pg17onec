#!/bin/bash

REQUIRED_SPACE=$(du -s "$PGDATA" | awk '{print $1}')
df "$PGDATA" | awk -v required_space="$REQUIRED_SPACE" 'NR==2 {if($4 < required_space) exit 1; exit 0}'
