#!/bin/bash


#ln -s /EFS/distrib/lib/* /deployment/lib/

#register
THIS_HOST=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
touch /EFS/run/services/webserver/$THIS_HOST:8080


THIS_NAME=$(curl http://169.254.169.254/latest/meta-data/public-hostname)
echo "THIS_NAME=$THIS_NAME:HELLO"

LOCAL_IP=$(hostname -I)
echo "LOCAL_IP=$LOCAL_IP:HELLO"

exec $@ -Dmy-akka.akka.remote.netty.tcp.hostname=$THIS_NAME
