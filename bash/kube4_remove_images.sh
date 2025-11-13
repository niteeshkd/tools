#!/bin/bash
IPs="100.64.12.1 100.64.12.33 100.64.12.34"
keyword="$1"
if [[ -z $keyword ]]; then
    echo "$0 <keyword>"
    echo "E.g. $0 100.64.0.255"
    exit
fi

for i in ${IPs}
do
    echo "========= On $i ============"
    ids=$(ssh root@$i "docker image list" 2>/dev/null | grep $keyword | awk '{print $3}' )
    if [[ ! -z $ids ]]; then
        for j in $ids
        do
	    echo "Removing $j"
            ssh root@$i "docker image rm $j"
        done
    fi
done
