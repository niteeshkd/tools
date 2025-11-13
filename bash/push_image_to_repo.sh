#!/bin/bash
ARTIFACTORY_ID=$(cat ~/.ssh/artifactory.login)
ARTIFACTORY_TOKEN=$(cat ~/.ssh/artifactory.token)

if [[ $# -lt 3 ]]; then
    echo "$0 -r <1|2>  <localDockerImage:Tag>"
    echo " Where:"
    echo "   1 => Repository: 100.64.0.255:5000/attestation"
    echo "   2 => Repository: k8s4g-docker-local.artifactory.swg-devops.com/attestation"
    echo " $0 -r 1 harpocrates:6.5.1_20230426T193938Z_a75afb2"
    exit 1
fi

if [[ $1 != "-r" ]]; then
    echo "Invalid option!"
    exit 1
fi
repo=""
repo_path=""

if [[ $2 == "1" ]]; then
    repo="100.64.0.255:5000"
    repo_path="100.64.0.255:5000/attestation"
elif [[ $2 == "2" ]]; then
    repo="k8s4g-docker-local.artifactory.swg-devops.com"
    repo_path="k8s4g-docker-local.artifactory.swg-devops.com/attestation"
    docker login -u ${ARTIFACTORY_ID} -p ${ARTIFACTORY_TOKEN} ${repo} 
else 
    echo "Invalid option!"
    exit 1
fi
image=$3

echo "docker tag $image ${repo_path}/${image}"
docker tag $image ${repo_path}/${image}

echo "docker push ${repo_path}/${image}"
docker push ${repo_path}/${image}
 
