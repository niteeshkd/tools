#!/bin/bash
PEI_MAP_FILE=$1
BASE_ADDRESS=0x0000820000
printf "                        Module   Address_Hex       Offset_Hex      Offset_Decimal\n"

while read -r line
do
    mod=`echo $line | awk -F "(" '/BaseAddress/{print $1}'`
    if [[ ! -z $mod ]]; then 
        addr=`echo $line | awk -F "," '/BaseAddress/{print $2}' | awk -F "=" '{print $2}' `
        offset=$((addr - BASE_ADDRESS))
        printf "%32s 0x%-16x 0x%-16x %d\n" $mod  $addr $offset $offset
    fi
done < "$PEI_MAP_FILE"
