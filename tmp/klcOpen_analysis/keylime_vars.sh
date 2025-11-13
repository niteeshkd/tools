#!/bin/bash
#/home/niteesh/github/ibm/KeyLimeContainer/keylimesetup/
if [[ $# -lt 3 ]];
then
	echo "$0 <-l|-n> <keylime_file> <code_dir>"
	exit
fi
opt=$1
keylime=$2
dir=$3
cat $keylime | grep -v ^# | grep export | sed 's/export//g' | awk -F '=' '{print $1}' | sort | uniq  > /tmp/file_vars

vars_used=${PWD}/keylime_vars_used
cat /dev/null > $vars_used

cd $dir
for i in `cat /tmp/file_vars`
do
	echo "------------------------------------$i-------------------------------------"
	num=$(grep -l -w $i * 2>/dev/null | wc -l)
	if [[ $num -ne 0 ]];
	then
		echo $i >> $vars_used
	  	grep $opt -w $i * 2>/dev/null 
	fi
done
cd - >/dev/null 2>&1
rm -f /tmp/file_vars
