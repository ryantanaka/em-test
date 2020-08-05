#!/bin/bash
set -e
set -u

SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

# create initial input files
mkdir -p input
rm -f input/*.txt
echo "creating initial input files"
echo "file1: $(date)" > input/file1.txt
echo "file2: $(date)" > input/file2.txt

echo "current files:"
ls -alh input

# create ensemble
em="trigger-test"
pegasus-em create $em

# send trigger command
echo "running trigger command"
pegasus-em trigger \
    --ensemble $em \
    --trigger-name 10s_txt \
    --workflow-name-prefix trigger-wf \
    --file-pattern "$SCRIPTPATH/input/*.txt" \
    --workflow-script workflow.py \
    --interval 10s

# sleep 3 seconds to let first trigger kick off
sleep 3

# generate files over 30s
for ((i=3; i <=4; i++)); do
    echo "$(date): creating output files"

    for ((j=1; j<=$i; j++)); do
        echo "file${i}_${j}.txt: $(date)" > input/file${i}_${j}.txt
    done
    echo "current files:"
    ls -alh input

    echo "$(date): back to sleep"
    sleep 10    
done


