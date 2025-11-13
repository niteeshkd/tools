#!/bin/bash
IMAGE=k8s4g-docker-local.artifactory.swg-devops.com/attestation/ng-keylime:6.2.0apiv1_20220106T214442Z_41b06db

#Create assetdb container 
docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=assetdb -e KEYLIME_CONTAINER_TEST= --name keylime_assetdb -v /etc/default/keylime:/etc/default/keylime -v/root:/platform-inventory ${IMAGE}

#Create verifier container 
docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=verifier -e KEYLIME_CONTAINER_TEST= --name keylime_verifier -v /etc/default/keylime:/etc/default/keylime -v /var/lib/keylime_verifier:/var/lib/keylime -v/root:/platform-inventory ${IMAGE}

#Create registrar container 
docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=registrar -e KEYLIME_CONTAINER_TEST= --name keylime_registrar -v /etc/default/keylime:/etc/default/keylime -v /var/lib/keylime_registrar:/var/lib/keylime -v/root:/platform-inventory ${IMAGE}

#Create deployer container 
docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=deployer -e KEYLIME_CONTAINER_TEST= --name keylime_deployer -v /etc/default/keylime:/etc/default/keylime -v/root:/platform-inventory ${IMAGE}

#Create jira container
docker run -id --net host --restart unless-stopped -e KEYLIME_ROLE=jira -e KEYLIME_CONTAINER_TEST= --name keylime_jira -v /etc/default/keylime:/etc/default/keylime -v/root:/platform-inventory ${IMAGE}
