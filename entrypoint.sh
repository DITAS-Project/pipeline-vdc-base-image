#!/bin/sh
set -e
sleep 60

if [ -n "$ENVCONF" ]; then
    echo "rewriting configs"
    envsubst '${vdcURI},${elasticURI},${zipkinURI}' < /.config/monitor.json > /.config/monitor.json 
    envsubst '${vdcURI},${elasticURI},${zipkinURI}' < /.config/traffic.json > /.config/traffic.json 
    envsubst '${vdcURI},${elasticURI},${zipkinURI}' < /.config/logging.json > /.config/logging.json 
fi

echo "Starting the monitoring services"
cd /opt/monitoring
exec ./vdc-agent &
exec ./vdc-traffic &
cd /

#start proxy
exec ./request-monitor  &
cd ${WORKINGDIR}
exec "$@"