package snppolicy
import future.keywords.if

tcb := {
    "measurement":"K79Z4Who43P3EZz+7mGrWIZ75N7JtUndtwySs6TSvCja2riyPV+/ajA2rKOxmIGK",
    "platform_smt_enabled":"1",
    "platform_tsme_enabled":"1",
    "policy_abi_major":"0",
    "policy_abi_minor":"0",
    "policy_debug_allowed":"0",
    "policy_migrate_ma":"0",
    "policy_single_socket":"0",
    "policy_smt_allowed":"1",
    "reported_tcb_bootloader":"2",
    "reported_tcb_microcode":"93",
    "reported_tcb_snp":"5",
    "reported_tcb_tee":"0"
}

default allow := false

allow {
    platform_granted
    guest_policy_granted
    tcb_version_granted
}

platform_granted if {
    tcb.platform_smt_enabled == "1"
    tcb.platform_tsme_enabled == "1"
}

guest_policy_granted if {
    tcb.policy_abi_major == "0"
    tcb.policy_abi_minor == "0"
    tcb.policy_debug_allowed == "0"
    tcb.policy_migrate_ma == "0"
    tcb.policy_single_socket == "0"
    tcb.policy_smt_allowed == "1"
}

tcb_version_granted if {
    tcb.reported_tcb_bootloader == "2"
    tcb.reported_tcb_microcode == "93"
    tcb.reported_tcb_snp == "5"
    tcb.reported_tcb_tee == "0"
}
