#!/bin/sh
set -e

# Fix ownership of volume-mounted paths so the non-root node user can write to them
chown -R node:node \
    /usr/src/app/logs \
    /tmp

exec su-exec node "$@"
