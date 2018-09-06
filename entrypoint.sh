#!/bin/sh
set -e


if [ -n "$ENVCONF" ]; then
    sleep 60
    echo "rewriting configs"
    envsubst '${vdcURI},${elasticURI},${zipkinURI}' < /.config/monitor.json > /.config/monitor.json 
    envsubst '${vdcURI},${elasticURI},${zipkinURI}' < /.config/traffic.json > /.config/traffic.json 
    envsubst '${vdcURI},${elasticURI},${zipkinURI}' < /.config/logging.json > /.config/logging.json 
fi

echo "Starting the monitoring services"
cd /opt/monitoring
exec ./vdc-agent --verbose &
exec ./vdc-traffic --verbose &
cd /

#start proxy
exec ./request-monitor  --verbose &
cd ${WORKINGDIR}
exec "$@"