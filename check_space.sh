#!/bin/bash
df /var/lib/1c/pgdata | awk '{if($4 >= 5242880) exit 0} END {exit 1}'