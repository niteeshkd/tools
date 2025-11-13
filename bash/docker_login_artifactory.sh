#!/bin/bash
artifactory_repo="k8s4g-docker-local.artifactory.swg-devops.com"
user=$(cat ~/.ssh/artifactory.login)
token=$(cat ~/.ssh/artifactory.token)

docker login -u $user -p $token $artifactory_repo
