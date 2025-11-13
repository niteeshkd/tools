#!/bin/bash
# This script lists all the files (as <file>:) of a given directory
#  (e.g. .../KeyLimeContainer) and the internal callers/users 
#  (as <= <file>) of those files.
# It excludes the files under .git/

exclude=".git"

if [[ $# -lt 2 ]];
then
    echo "$0 <-l|-n> <dir>"
    echo "where: "
    echo "    -l: just list the files using a particular file"
    echo "    -n: also list the line numbers in the files using a particular file"
    echo "   dir: path of a directory to list the files and their callers/users"
    echo "E.g.: $0 -l ${HOME}/github/ibm/KeyLimeContainer"
    exit 1
fi
opt="${1}"
dir=$2

if [[ $opt != "-l" && $opt != "-n" ]]; then
    echo "Invalid option : $opt"
    exit 1
fi
if [[ ! -d $dir ]]; then
    echo "Invalid directory : $dir"
    exit 1
fi

cd $dir
# Get list of the files
files=$(find . -type f -print | grep -v ${exclude})
for filei in $files
do
    echo ""
    echo "$filei:"
    basei=$(basename $filei)
    basei_num=$( echo $files | sed 's/ /\n/g' | grep -w "${basei}$" | wc -l) 
    if [[ $basei_num -gt 1 ]]; then
        echo "#Warning: same basename is found with the following files."
        echo $files | sed 's/ /\n/g' | grep -w "${basei}$" | grep -v -w ${filei}
    fi
    for filej in $files
    do   
        if [[ $basei != $(basename $filej) ]]; 
        then
            # Check the presence of the basename of filei
            # in other file (i.e. filej)
            out=`grep ${opt} -w -e "${basei} " -e "${basei}$" $filej`
            if [[ ! -z $out ]];
            then
                if [[ $opt == "-n" ]];
                then
                    echo "<=$filej:"
                    echo "$out"
                else
                    echo "<= $out"
                fi
            fi
        fi
    done
done 
cd - >/dev/null 2>&1 
