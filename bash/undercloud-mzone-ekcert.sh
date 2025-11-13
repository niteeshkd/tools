#!/bin/bash
DIR_PLATFORM_INVENTORY=/home/niteesh/github/ibm/platform-inventory
DIR_REFSTATES=/home/niteesh/github/ibm/refstates

if [[ $# < 1 ]];
then
    echo "$0 <undercloud file>"
    echo "E.g.: $0 ${DIR_PLATFORM_INVENTORY}/region/undercloud/dal1-qz1-undercloud.yml"
    exit 1
fi

DIR_MZONE=${DIR_PLATFORM_INVENTORY}/region
DIR_UNDERCLOUD=${DIR_PLATFORM_INVENTORY}/region/undercloud

DIR_EKCERTS=${DIR_REFSTATES}/ek_certificates

uc_file=$(basename $1)


if test ! -f ${DIR_UNDERCLOUD}/${uc_file}
then
    echo "${DIR_UNDERCLOUD}/${uc_file} does not exist!"
    exit 1
fi

echo "undercloud file: ${uc_file}"
mzonejiras=$(grep JIRA_MZONE ${DIR_UNDERCLOUD}/${uc_file} | awk '{ print $2 }')
for mzonejira in ${mzonejiras//,/ }
do
    mz_file=$(echo ${mzonejira} | sed 's/"//g'| awk -F: '{ print $1 }')
    echo ""
    echo "=>mzone file: ${mz_file}"

    mx2_lnos=$(cat ${DIR_MZONE}/${mz_file} | grep -n mx2fscloudla | sed -e 's/ //' | grep -v ":#" |  awk -F ":" '{print $1}')
    for lno in ${mx2_lnos}
    do
        hostname=$(head -${lno} ${DIR_MZONE}/${mz_file} | grep hostname | tail -1 | awk -F ":" '{print $2}' | sed 's/ //g')
        echo "==>hostname: ${hostname}"
        #uuid=$(head -${lno} ${DIR_MZONE}/${mz_file} | grep uuid | tail -1 | awk -F ":" '{print $2}' | sed 's/ //g')
        #echo "==>uuid: ${uuid}"
        ek_file=$(find ${DIR_EKCERTS} -type f -name ${hostname}*rsa*pem)
        if [[ ! -z $ek_file ]];
        then
            echo "===>ek_cert: $(basename ${ek_file})"
        else
            echo "===>ek_cert is not found for $hostname defined in $mz_file"
        fi
        echo ""
    done
done
