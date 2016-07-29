#!/bin/bash

set -a
#ln -s /EFS/distrib/lib/* /deployment/lib/

#register
HOST_LOCAL_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
touch /EFS/run/services/webserver/$HOST_LOCAL_IP:8080

HOST_PUBLIC_HOSTNAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
HOST_AKKA_PORT=12552
echo "THIS_PUBLIC_HOSTNAME=$HOST_PUBLIC_HOSTNAME="


CONTAINER_LOCAL_IP=$(hostname -I)
CONTAINER_AKKA_PORT=2552
echo "CONTAINER_LOCAL_IP=$CONTAINER_LOCAL_IP="

exec $@
