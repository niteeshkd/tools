#!/bin/bash
input="./refstate.json"

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
    #echo "Checking node${i}/mbpolicy/allow"
    ./check_rule.py -s "node${i}/mbpolicy" -r allow -i $input >> $outFile &
    ((i++))
done
MS2=$(date +%s%3N)
ps -ef | grep -q "check_rule.py"
while [[ $? -ne 0 ]]; do
    sleep .001
    ps -ef | grep -q "check_rule.py"
done
MS3=$(date +%s%3N)

t21=$(($MS2 - $MS1))
t32=$(($MS3 - $MS2))
time_taken=$(($t32 + $t21/2))

echo "Output is saved in $outFile"
echo "Time taken: ${time_taken} ms"
