#!/bin/sh
set -e

echo "Starting the monitoring services"
cd /opt/monitoring
exec ./vdc-agent -zipkin "http://${zipkinURI}/api/v1/spans" -vdc "http://${vdcURI}" -elastic "http://${elasticURI}"&
exec java -jar VDCMonitor.jar &
cd /

#start ngnix
exec sh /run.sh

exec "$@"