#!/bin/bash
if [[ -z $2 ]]; then
	echo "$0 <server|agent> <image>"
	exit 1
fi
container=$1
image=$2
cluster_file="/root/cluster.json"

if [[ $container != "server" && $container != "agent" ]]; 
then
	echo "Choose server or agent"
	echo "$0 <server|agent> <image>"
	exit 1
fi

echo "Download ${image}"
docker pull ${image}

if [[ $container == "server" ]];
then
    for i in assetdb verifier registrar deployer
    do
    	docker kill keylime_${i} > /dev/null 2>&1
	docker rm keylime_${i} > /dev/null 2>&1
    done

    for i in assetdb verifier registrar deployer
    do
	echo "Create keylime_${i} container"
    	docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=${i} --name keylime_${i} -v ${cluster_file}:${cluster_file} ${image}
    done
else
    docker kill keylime_agent > /dev/null 2>&1
    docker rm keylime_agent > /dev/null 2>&1

    echo "Create keylime_agent container" 
    docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=agent --name keylime_agent -v ${cluster_file}:${cluster_file} --device /dev/tpmrm0:/dev/tpmrm0 --privileged  ${image}
fi
