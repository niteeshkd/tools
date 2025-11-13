#!/bin/bash

echo "################################"
cat /etc/motd
echo "################################"

if test -f /etc/default/keylime
then
    . /etc/default/keylime
else
    if [[ ${KEYLIME_ROLE} == "agent" ]];
    then
        host=$(hostname -s)
        ngkl_create_keylime_vars $host
        [[ $? -ne 0 ]] && exit 1
    else
        ngkl_create_keylime_vars
        [[ $? -ne 0 ]] && exit 1
    fi
    . /etc/default/keylime
fi


. /opt/keylimebootstrap/bin/klbutil

klbutil_condition_node

announce "=> docker container pulled after ${KEYLIME_TTPC} ms"

# #####################################################
# wait for the asset database -- unless we are about to
# be asked to provide it.
# #####################################################

if [[ ${KEYLIME_ROLE} != "assetdb" ]]
then
    announce "=> waiting for Asset Database ${KEYLIME_ASSET_DB_IP}"
    wait_for_redis 400 10

    if [[ ! -z $KEYLIME_CLOUD_VERIFIER_HOST && ! -z $KEYLIME_CLOUD_VERIFIER_PORT ]]
    then
        announce "=> waiting for Verifier Database ${KEYLIME_CLOUD_VERIFIER_HOST}"
        wait_until_port_open $KEYLIME_CLOUD_VERIFIER_HOST $KEYLIME_CLOUD_VERIFIER_PORT 100 10
    fi
    
    if [[ ! -z $KEYLIME_REGISTRAR_HOST && ! -z $KEYLIME_REGISTRAR_VERIFIER_PORT ]]
    then
        announce "=> waiting for Registrar Database ${KEYLIME_REGISTRAR_HOST}"
        wait_until_port_open $KEYLIME_REGISTRAR_HOST $KEYLIME_REGISTRAR_PORT 100 10
    fi
fi

# #####################################################
# VE specific hack: move keylime certificates to the cert store.
# The cert store location may be undefined in /etc/default/keylime.
# We fix that here because we need to know where to move the certs.
# #####################################################

export KEYLIME_TENANT_TPM_CERT_STORE=${KEYLIME_TENANT_TPM_CERT_STORE:-/var/lib/keylime/tpm_cert_store}
mkdir -p ${KEYLIME_TENANT_TPM_CERT_STORE}
rsync -a ${KEYLIME_CLONE_DIR}/tpm_cert_store/ ${KEYLIME_TENANT_TPM_CERT_STORE}/

# #####################################################
# before we do anything else, build a $KEYLIME_CONFIG
# based on values in /etc/default/keylime
# #####################################################

get_verifier
get_registrar
announce "=> Building ${KEYLIME_CONFIG_FILE} file from environment variables"
/usr/local/bin/ngkl_build_config

ls ${KEYLIME_CLONE_DIR}/scripts/convert_config.py >/dev/null 2>&1
if [[ $? -eq 0 ]]
then
    announce "====> Converting the keylime configuration from old (single) to new (multi) format"
    pushd ${KEYLIME_CLONE_DIR}/scripts/ >/dev/null 2>&1
    mkdir -p ${KEYLIME_CONFIG_DIR}
    python3 convert_config.py --input ${KEYLIME_CONFIG_FILE} --out ${KEYLIME_CONFIG_DIR}
    rm -rf ${KEYLIME_CONFIG_FILE}
    if [[ $KEYLIME_AGENT_TYPE == "rust" ]]
    then
        sed -i "s/=.*False/= \"False\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*True/= \"True\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*default/= \"default\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/= $/= \"\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/= \[\]/= \"\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        if [[ ! -z ${KEYLIME_CLOUD_AGENT_PAYLOAD_SCRIPT} ]]
        then
            sed -i "s/=.*${KEYLIME_CLOUD_AGENT_PAYLOAD_SCRIPT}$/= \"${KEYLIME_CLOUD_AGENT_PAYLOAD_SCRIPT}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        fi
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_SERVER_KEY}$/= \"${KEYLIME_CLOUD_AGENT_SERVER_KEY}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_SERVER_CERT}$/= \"${KEYLIME_CLOUD_AGENT_SERVER_CERT}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_ENC_KEYNAME}$/= \"${KEYLIME_CLOUD_AGENT_ENC_KEYNAME}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_DEC_PAYLOAD_FILE}$/= \"${KEYLIME_CLOUD_AGENT_DEC_PAYLOAD_FILE}\"/g" /${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_SECURE_SIZE}$/= \"${KEYLIME_CLOUD_AGENT_SECURE_SIZE}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_TPM_OWNERPASSWORD}$/= \"\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_CLOUDAGENT_IP}$/= \"${KEYLIME_CLOUD_AGENT_CLOUDAGENT_IP}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_REGISTRAR_REGISTRAR_IP}$/= \"${KEYLIME_REGISTRAR_REGISTRAR_IP/}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_CONTACT_IP}$/= \"${KEYLIME_CLOUD_AGENT_CONTACT_IP/}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_VERIFIER_CLOUDVERIFIER_IP}$/= \"${KEYLIME_CLOUD_VERIFIER_CLOUDVERIFIER_IP/}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_REGISTRAR_PROVIDER_REGISTRAR_IP}$/= \"${KEYLIME_REGISTRAR_PROVIDER_REGISTRAR_IP/}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf        
        sed -i "s/=.*$KEYLIME_CLOUD_AGENT_TPM_HASH_ALG/= \"$KEYLIME_CLOUD_AGENT_TPM_HASH_ALG\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_TPM_ENCRYPTION_ALG}$/= \"${KEYLIME_CLOUD_AGENT_TPM_ENCRYPTION_ALG}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_TPM_SIGNING_ALG}$/= \"${KEYLIME_CLOUD_AGENT_TPM_SIGNING_ALG}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_EK_HANDLE}$/= \"${KEYLIME_CLOUD_AGENT_EK_HANDLE}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_AGENT_UUID}$/= \"${KEYLIME_CLOUD_AGENT_AGENT_UUID}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
        sed -i "s/=.*${KEYLIME_CLOUD_AGENT_RUN_AS}$/= \"${KEYLIME_CLOUD_AGENT_RUN_AS}\"/g" ${KEYLIME_CONFIG_DIR}/agent.conf
    fi
    popd >/dev/null 2>&1
fi

del_node_from_set container_starting "NA/NA/${KEYLIME_NODE_NAME}/NA/NA"
add_node_to_set container_started
announce "This container is running as role ${KEYLIME_ROLE}"

# #####################################################
# depending on role, do something
# #####################################################

if [[ $KEYLIME_CONTAINER_TEST -eq 1 ]]
then
    announce "Variable KEYLIME_CONTAINER_TEST set to 1, will just sleep for 5 days"
    sleep 432000
fi

case $KEYLIME_ROLE in
    # agent
    agent)
        while true; do /usr/local/bin/ngkl_agent ; sleep 10 ; done
        ;;

    # keylime component: verifier
    verifier)
        /usr/local/bin/ngkl_verifier
        ;;

    # keylime component: registrar
    registrar)
        /usr/local/bin/ngkl_registrar
        ;;

    # just the deployer
    deployer)
        /usr/local/bin/ngkl_generate_certificates
        /usr/local/bin/ngkl_setup_tenant
        while true ; do /usr/local/bin/ngkl_deployer ; sleep 10 ; done
        ;;

    # run the asset database
    assetdb)
        /usr/local/bin/ngkl_assetdb
        ;;
    
    *)
        /usr/local/bin/ngkl_setup_tenant
        announce "Hmm, no role defined for ng-keylime. Will run a shell."
        /bin/bash
esac
