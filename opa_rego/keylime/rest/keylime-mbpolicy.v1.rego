package keylime.mbpolicy
import data.keylime.tpm2evlog
import input

import future.keywords.if

# By default, deny requests.
default allow := false

allow {
    #spec_granted
    kernel_plain_sha256_granted
    initrd_plain_sha256_granted
    grub_authcode_sha256_granted
    shim_authcode_sha256_granted
    kernel_authcode_sha256_granted
}

allow = {"false:", deny} {
    count(deny) > 0
}

spec_granted if {
    some i
    tpm2evlog.events[i].EventType == "EV_NO_ACTION" ;
    tpm2evlog.events[i].SpecID[0].specVersionMajor == 2
    tpm2evlog.events[i].SpecID[0].specVersionMinor == 0
}

kernel_plain_sha256_granted if {
    some i,j
    tpm2evlog.events[i].EventType == "EV_IPL"
    tpm2evlog.events[i].PCRIndex == 9
    tpm2evlog.events[i].Digests[j].AlgorithmId == "sha256"
    tpm2evlog.events[i].Digests[j].Digest == trim_left(input.kernel_plain_sha256, "0x")
}

initrd_plain_sha256_granted if {
    some i,j
    tpm2evlog.events[i].EventType == "EV_IPL"
    tpm2evlog.events[i].PCRIndex == 9
    tpm2evlog.events[i].Digests[j].AlgorithmId == "sha256"
    tpm2evlog.events[i].Digests[j].Digest == trim_left(input.initrd_plain_sha256, "0x")
}

grub_authcode_sha256_granted if {
    some i,j
    tpm2evlog.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    tpm2evlog.events[i].PCRIndex == 4
    tpm2evlog.events[i].Digests[j].AlgorithmId == "sha256"
    tpm2evlog.events[i].Digests[j].Digest == trim_left(input.grub_authcode_sha256, "0x")
}

shim_authcode_sha256_granted if {
    some i,j
    tpm2evlog.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    tpm2evlog.events[i].PCRIndex == 4
    tpm2evlog.events[i].Digests[j].AlgorithmId == "sha256"
    tpm2evlog.events[i].Digests[j].Digest == trim_left(input.shim_authcode_sha256, "0x")
}

kernel_authcode_sha256_granted if {
    secure_boot_enabled
    some i,j
    tpm2evlog.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    tpm2evlog.events[i].PCRIndex == 4
    tpm2evlog.events[i].Digests[j].AlgorithmId == "sha256"
    tpm2evlog.events[i].Digests[j].Digest == trim_left(input.kernel_authcode_sha256,"0x")
}

secure_boot_enabled if {
    some i
    tpm2evlog.events[i].EventType == "EV_EFI_VARIABLE_DRIVER_CONFIG"
    tpm2evlog.events[i].PCRIndex == 7
    tpm2evlog.events[i].Event.UnicodeName == "SecureBoot"
}

deny[reason] {
    not spec_granted
    reason := "spec is not valid."
}

deny[reason] {
    not kernel_plain_sha256_granted
    reason := "kernel_plain_sha256 is not valid."
}

deny[reason] {
    not initrd_plain_sha256_granted
    reason := "initrd_plain_sha256 is not valid."
}

deny[reason] {
    not grub_authcode_sha256_granted
    reason := "grub_authcode_sha256 is not valid."
}

deny[reason] {
    not shim_authcode_sha256_granted
    reason := "shim_authcode_sha256 is not valid."
}

deny[reason] {
    not kernel_authcode_sha256_granted
    reason := "kernel_authcode_sha256 is not valid."
}

deny[reason] {
    not secure_boot_enabled
    reason := "secure boot is not enabled."
}
