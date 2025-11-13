#!/bin/bash
DIR_PLATFORM_INVENTORY=/home/niteesh/github/ibm/platform-inventory
if [[ $# < 1 ]];
then
    echo "$0 <directory containing cert files>"
    echo "E.g.: $0 /home/niteesh/github/ibm/refstates/ek_certificates/DAL/DAL10/qz1/rk221"
    exit 1
fi
DIR_CERT=$1

DIR_MZONE=${DIR_PLATFORM_INVENTORY}/region
DIR_UNDERCLOUD=${DIR_PLATFORM_INVENTORY}/region/undercloud

cert_files=$(du -a  $DIR_CERT | grep "rsa.pem$" |  awk -F "/" '{print $12}')
for cf in $cert_files
do
    cf_hostname=$(echo $cf | awk -F "-" '{print $1"-"$2"-"$3"-"$4"-"$5}')
    echo ""
    echo "ekcert: $cf:"
    echo "=>hostname: $cf_hostname"
    mzone_files=$(grep $cf_hostname $DIR_MZONE/*.yml | awk -F ":" '{print $1}') 
    if [[ -z $mzone_files ]] 
    then
        echo "  $cf_hostname is not found in any mzone file!"
    else
        for mf in $mzone_files
        do
            mf_basename=`basename $mf`
            echo "==>mzone: $mf_basename"
            uc_files=$(grep $mf_basename $DIR_UNDERCLOUD/*.yml | grep -v staging | awk -F ":" '{print $1}') 
            if [[ -z $uc_files ]] 
            then
                echo "   $mf_basename is not found in any undercloud file!"
            else
                for uf in $uc_files
                do
                    echo "===> undercloud: $(basename ${uf})"
                    grep -q mx2fscloudla $uf 2>/dev/null
                    if [[ $? -eq 0 ]]
                    then
                        echo "====> profileClass: mx2fscloudla"
                    fi
                done
            fi
        done
    fi
done
