#!/bin/bash
if [[ -z $2 ]]; then
	echo "$0 <server|agent> <image>"
	exit 1
fi
container=$1
image=$2

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
    	docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=${i} --name keylime_${i} -v /root/cluster.yml:/root/cluster.yml ${image}
    done
else
    docker kill keylime_agent > /dev/null 2>&1
    docker rm keylime_agent > /dev/null 2>&1

    echo "Create keylime_agent container" 
    docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=agent --name keylime_agent -v /root/cluster.yml:/root/cluster.yml --device /dev/tpmrm0:/dev/tpmrm0 --privileged  ${image}
fi
