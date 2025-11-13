#/bin/bash
hosts="100.64.12.33 100.64.12.34"
repo="100.64.0.255:5000/attestation"

for host in ${hosts}
do 
    #ssh root@${host} "docker image rm ${repo}/keylime_verifier:latest"
    #ssh root@${host} "docker image rm ${repo}/keylime_tenant:latest"
    ssh root@${host} "docker pull ${repo}/keylime_verifier:latest"
    ssh root@${host} "docker pull ${repo}/keylime_tenant:latest"
done
