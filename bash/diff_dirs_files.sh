#!/bin/bash
# PURPOSE: It shows the differences in the files existing under dir1 from dir2.  
if [ -z "$1" ]
then echo "Syntax: $0 <dir1> <dir2>"
     echo "        It shows the differences in the files of dir1 from from dir2."  
exit
fi

dir1=$1
dir2=$2
cur_dir=`echo $PWD`

cd $1
ls -l | grep -v "^d" | awk  '{ print $9 }' > /tmp/list_files.$$
#ls -lR | grep ":$" | awk -F":" '{ print $1 }' > /tmp/list_subdirs.$$
ls -lR | grep ":$" | awk -F":" '{ print $1 }' |  grep -v "^.$" | sed 's/.\///' > /tmp/list_subdirs.$$
cd $cur_dir

j=0
for j in `cat /tmp/list_files.$$`
do
	  diff $dir1/$j $dir2/$j 1>/dev/null 2>&1
       	  exit=`echo $?`
          if [[ $exit -ne 0 ]]
          then
             echo ""
	     echo "diff $dir1/$j $dir2/$j"
             echo "=================================================================="
	     diff $dir1/$j $dir2/$j
          fi
done

i=0
for i in `cat /tmp/list_subdirs.$$`
do
	dir1=$1/$i
	dir2=$2/$i
	ls -l $dir1 | grep -v "^d" | awk  '{ print $9 }' > /tmp/list_subdir_files.$$
	j=0
	for j in `cat /tmp/list_subdir_files.$$`
	do
	   diff $dir1/$j $dir2/$j 1>/dev/null 2>&1
       	   exit=`echo $?`
           if [[ $exit -ne 0 ]]
           then
	     echo ""
	     echo "diff $dir1/$j $dir2/$j"
             echo "=================================================================="
	     diff $dir1/$j $dir2/$j
           fi
        done
done

rm -f /tmp/list_files.$$
rm -f /tmp/list_subdirs.$$
rm -f /tmp/list_subdir_files.$$
