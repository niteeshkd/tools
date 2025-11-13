#!/bin/bash
policy="./mbpolicy.rego"

if [[ $# -lt 1 ]]; then
    echo "$0 : <num_nodes>"
    exit
fi
num_nodes=$1

tmpDir="/tmp/policies"
mkdir $tmpDir 2>/dev/null

i=1
while [[ $i -le $num_nodes ]]
do
    #Creating node${i}-mbpolicy.rego
    cat $policy | sed "s/nodeN/node${i}/g" > $tmpDir/node${i}-mbpolicy.rego 
    ((i++))
done

outFile="/tmp/$(basename $0).out"
cat /dev/null > $outFile

i=1
MS1=$(date +%s%3N)
while [[ $i -le $num_nodes ]]
do
    #echo "Setting up v1/policies/node${i}/mbpolicy"
    ./upload_data_policy.py -p $tmpDir/node${i}-mbpolicy.rego -s "node${i}/mbpolicy" >> $outFile &
    ((i++))
done
MS2=$(date +%s%3N)
ps -ef | grep -q "mbpolicy"
while [[ $? -ne 0 ]]; do
    sleep .001
    ps -ef | grep -q "mbpolicy"
done
MS3=$(date +%s%3N)

t21=$(($MS2 - $MS1))
t32=$(($MS3 - $MS2))
time_taken=$(($t32 + $t21/2))

echo "Output is saved in $outFile"
echo "Time taken: ${time_taken} ms"

#rm -fr $tmpDir
