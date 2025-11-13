#!/bin/bash
IPs="100.64.12.1 100.64.12.33 100.64.12.34"
keyword="keylime"

for i in ${IPs}
do
    echo "======== On $i ========"
    ssh root@$i "docker images" 2>/dev/null | grep "$keyword"
done
