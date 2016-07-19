#!/bin/bash


ln -s /EFS/distrib/lib/* /deployment/lib/

exec $@
