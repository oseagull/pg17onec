#!/bin/bash
df /var/lib/1c/pgdata | awk 'NR==2 {if($4 < 5000000) exit 1; exit 0}'
