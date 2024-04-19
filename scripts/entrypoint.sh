#!/bin/sh

echo "Entrypoint script started"

echo "Setting permissions for scripts"
chmod +x /scripts/*.sh

rm -rf /pids/*.pid
rm -rf /logs/*.log

. /scripts/config.sh



echo "Starting nginx"
nginx -c /config/nginx.conf -g 'daemon off;'

echo "Shoul not reach here"
 

