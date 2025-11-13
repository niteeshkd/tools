#!/bin/bash
# This script lists all the bash functions defined the files in a given directory
#  (e.g. .../KeyLimeContainer/keylimesetup) and the internal callers/users of
#  of those functions in that directory.

if [[ $# -lt 1 ]];
then
    echo "$0  <dir>"
    echo "where: "
    echo "   dir: path of a directory to list the functions and their callers/users"
    echo "E.g.: $0 -l ${HOME}/github/ibm/KeyLimeContainer/keylimesetup"
    exit 1
fi
dir=$1

if [[ ! -d $dir ]]; then
    echo "Invalid directory : $dir"
    exit 1
fi

cd $dir
# Get list of the files
list_functions=$(grep -w "function" * | awk -F":" '{print $2}' | grep -v "^#" | awk '{print $2}' | sed 's/()//g')
for funci in $list_functions
do
    echo ""
    echo "=> $funci"
    out=$(grep -n -w $funci * | grep -v function | grep -v export | awk -F ":" '{print $1}' | sort | uniq)
    echo "$out"
done 
cd - >/dev/null 2>&1 
