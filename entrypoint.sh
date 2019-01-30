#!/bin/sh
set -e

if [ -n "$ENVCONF" ]; then
    sleep 60
    echo "rewriting configs"
    envsubst '${vdcURI},${elasticURI},${zipkinURI}' < /.config/traffic.json > /.config/traffic.json
fi

echo "Starting the monitoring services"
cd /opt/monitoring
exec ./vdc-traffic --verbose &

echo "Starting payload"
cd ${WORKINGDIR}
exec "$@"