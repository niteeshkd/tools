#!/bin/bash
#/home/niteesh/github/ibm/KeyLimeContainer/keylimesetup/
if [[ $# -lt 3 ]];
then
	echo "$0 <-l|-n> <keylime_vars_file> <code_dir>"
	exit
fi
opt=$1
keylime_vars=`realpath $2`
dir=$3

cd $dir
for i in `cat ${keylime_vars}`
do
	echo "==============================$i============================"
	grep $opt -w $i * 2>/dev/null
done
cd - >/dev/null 2>&1
