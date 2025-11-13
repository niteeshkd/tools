#!/bin/bash
if [[ $# -lt 3 ]];
then
    echo "$0 <stat> <dir1> <dir2>"
    echo "where "
    echo "   stat = 0  unmodified files"
    echo "        = 1  modified files"
    echo "        = 2  new files in <dir1>"
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
cd $dir1
# Get list of the files in dir1
files=$(find . -type f -print | grep -v .git | cut -c 3- | sort)
for filei in $files
do
    # New file
    if [[ ! -f $dir2/${filei} ]]; then
        [[ $stat -eq 2 ]] && echo "${filei}"
    else
        diff ${filei} $dir2/${filei} > /dev/null 2>&1
	# Unmodified file
	if [[ $? -eq 0 ]]; then
	    [[ $stat -eq 0 ]] && echo "${filei}"
        else #Modified file
	    [[ $stat -eq 1 ]] && echo "${filei}"
        fi
    fi
done 
cd - >/dev/null 2>&1 
