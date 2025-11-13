#!/bin/bash
datalog="./tpm2_eventlog.json"

if [[ $# -lt 1 ]]; then
    echo "$0 : <num_nodes>"
    exit
fi
num_nodes=$1

outFile="/tmp/$(basename $0).out"
cat /dev/null > $outFile

i=1
MS1=$(date +%s%3N)
while [[ $i -le $num_nodes ]]
do
    #echo "Setting up v1/data/node${i}/tpm2evlog"
    ./upload_data_policy.py -d $datalog -s "node${i}/tpm2evlog" >> $outFile &
    ((i++))
done
MS2=$(date +%s%3N)
ps -ef | grep -q "tpm2evlog"
while [[ $? -ne 0 ]]; do
    sleep .001
    ps -ef | grep -q "tpm2evlog"
done
MS3=$(date +%s%3N)

t21=$(($MS2 - $MS1))
t32=$(($MS3 - $MS2))
time_taken=$(($t32 + $t21/2))

echo "Output is saved in $outFile"
echo "Time taken: ${time_taken} ms"
