#!/bin/bash


rm -rf /EFS/distrib/lib.next
rm -rf /EFS/distrib/lib.prev

mkdir /EFS/distrib/lib.next

cp -rf /deployment/lib/* /EFS/distrib/lib.next/.

mv /EFS/distrib/lib /EFS/distrib/lib.prev
mv /EFS/distrib/lib.next /EFS/distrib/lib

exec $@
