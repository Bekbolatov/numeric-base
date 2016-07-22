#!/bin/bash


ln -s /EFS/distrib/lib/* /deployment/lib/

#register
THIS_HOST=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
touch /EFS/run/services/webserver/$THIS_HOST:8080


exec $@
