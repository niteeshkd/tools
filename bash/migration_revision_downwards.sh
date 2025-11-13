#!/bin/bash
if [[ $# -ne 2 ]];
then
    echo "$0 <dir> <topid>"
    echo "$0 /home/niteesh/github/niteeshkd/keylime/keylime/migrations/versions 0571b53013f1"
    exit
fi
dir=$1
topId=$2

cd $dir
file=$(ls | grep $topId | grep ".py$")
while [[ $down_revision != "None" ]]
do
    down_revision=$(cat $file | grep down_revision | awk -F '=' '{print $2}' | tr -d "\'" | tr -d "\"" | tr -d " ")
    echo "$file => $down_revision " 
    file=$(ls | grep $down_revision | grep ".py$")
done
