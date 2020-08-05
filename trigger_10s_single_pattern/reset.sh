#!/bin/bash
set -e
set -u

# clear logs
echo "clearing trigger_manager.log"
logs="$HOME/.pegasus/triggers/trigger_manager.log"
if [ -f $logs ] ; then
    rm $logs
fi

# clear db
echo "clearing workflow.db"
db="$HOME/.pegasus/workflow.db"
if [ -f $db ] ; then
    rm $db
fi
pegasus-db-admin create