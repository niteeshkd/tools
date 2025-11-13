#!/bin/bash
if [[ $# -lt 3 ]];
then
    echo "$0 <stat> <dir1> <dir2>"
    echo "where "
    echo "   stat = 0  unmodified file"
    echo "        = 1  modified file"
    echo "        = 2  new file"
    echo "e.g. $0 0 /home/niteesh/github/ibm/Mockrates /home/niteesh/github/ibm/KeyLimeContainer"
    exit 1
fi

stat=$1
dir1=$2
dir2=$3

if [[ $stat -lt 0 || $stat -gt 2  ]]; then
    echo "Invalid stat : $stat"
    exit 1
fi

if [[ ! -d $dir1 ]]; then
    echo "Invalid directory : $dir1"
    exit 1
fi

if [[ ! -d $dir2 ]]; then
    echo "Invalid directory : $dir2"
    exit 1
fi

dir2=$(realpath $dir2)
tmpout="$(mktemp)"

cd $dir1
# Get list of the files
files=$(find . -type f -print | grep -v .git | cut -c 3-)
for filei in $files
do
    if [[ ! -f $dir2/${filei} ]]; then
        echo "${filei} : New" >> $tmpout
    else 
        diff ${filei} $dir2/${filei} > /dev/null 2>&1
	if [[ $? -eq 0 ]]; then
            echo "${filei} : Same" >> $tmpout
        else
            echo "${filei} : Modified" >> $tmpout
        fi
    fi
done 
cd - >/dev/null 2>&1 

if [[ $stat -eq 0 ]]; then
    cat $tmpout | grep Same | awk  '{print $1}' | sort
elif [[ $stat -eq 1 ]]; then
    cat $tmpout | grep Modified | awk  '{print $1}' | sort
elif [[ $stat -eq 2 ]]; then
    cat $tmpout | grep New | awk  '{print $1}' | sort
fi
rm -f $tmpout
