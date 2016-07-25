#!/bin/bash

set -e

set -o allexport
source SETTINGS
set +o allexport

############################################################
pushd $SRC_HOME
activator clean dist
popd

rm -rf target
mkdir -p target/lib

unzip $SRC_HOME/target/universal/sparkydots-server-1.0-SNAPSHOT.zip -d $SRC_HOME/target/universal/
#cp -rf $SRC_HOME/target/universal/sparkydots-server-1.0-SNAPSHOT/lib/sparkydots-server* target/lib/.
cp -rf $SRC_HOME/target/universal/sparkydots-server-1.0-SNAPSHOT/lib/* target/lib/.
cp -rf $SRC_HOME/target/universal/sparkydots-server-1.0-SNAPSHOT/bin target/.
cp -rf $SRC_HOME/target/universal/sparkydots-server-1.0-SNAPSHOT/conf target/.

rm -rf $SRC_HOME/target/universal/sparkydots-server-1.0-SNAPSHOT
############################################################

source $DISTRIB_HOME/bin/task_definition/publish_new_revision.sh

source $DISTRIB_HOME/bin/aws/update_service.sh
