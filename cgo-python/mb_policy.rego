package test
import future.keywords.if

refstate := {
    "shim_authcode_sha256": "0xdbffd70a2c43fd2c1931f18b8f8c08c5181db15f996f747dfed34def52fad036",
    "grub_authcode_sha256": "0xacc00aad4b0413a8b349b4493f95830da6a7a44bd6fc1579f6f53c339c26cb05",
    "kernel_authcode_sha256": "0xd968af6fbb6210352455d1c67b49d7b3c414361c9ea1d2828ef15f6d5bac4d19",
    "initrd_plain_sha256": "0x411a773dce24fddca247c8439182bf265504abb379be18f0f76df6ed3f575148",
    "kernel_cmdline": "/boot/vmlinuz-5.15.0-50-generic root=UUID=bced2b4a-130c-4f7a-9fd6-fff449cf6c22 ro biosdevname=0 net.ifnames=0 ima_hash=sha256 console=tty1 console=ttyS0"
}

# By default, deny requests.
default allow := false

allow {
    shim_authcode_sha256_granted
    grub_authcode_sha256_granted
    kernel_authcode_sha256_granted
    initrd_plain_sha256_granted
    kernel_cmdline_granted
}

shim_authcode_sha256_granted if {
    some i,j
    input.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    input.events[i].PCRIndex == 4
    input.events[i].Digests[j].AlgorithmId == "sha256"
    input.events[i].Digests[j].Digest == trim_left(refstate.shim_authcode_sha256, "0x")
}

grub_authcode_sha256_granted if {
    some i,j
    input.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    input.events[i].PCRIndex == 4
    input.events[i].Digests[j].AlgorithmId == "sha256"
    input.events[i].Digests[j].Digest == trim_left(refstate.grub_authcode_sha256, "0x")
}

kernel_authcode_sha256_granted if {
    some i,j
    input.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    input.events[i].PCRIndex == 4
    input.events[i].Digests[j].AlgorithmId == "sha256"
    input.events[i].Digests[j].Digest == trim_left(refstate.kernel_authcode_sha256,"0x")
}

initrd_plain_sha256_granted if {
    some i,j
    input.events[i].EventType == "EV_IPL"
    input.events[i].PCRIndex == 9
    input.events[i].Digests[j].AlgorithmId == "sha256"
    input.events[i].Digests[j].Digest == trim_left(refstate.initrd_plain_sha256, "0x")
}

kernel_cmdline_granted if {
    some i
    input.events[i].EventType == "EV_IPL"
    input.events[i].PCRIndex == 8
    contains(input.events[i].Event.String,refstate.kernel_cmdline)
}

allow = {"false:", deny} {
    count(deny) > 0
}

deny[reason] {
    not shim_authcode_sha256_granted
    reason := "shim_authcode_sha256 is not valid."
}

deny[reason] {
    not grub_authcode_sha256_granted
    reason := "grub_authcode_sha256 is not valid."
}

deny[reason] {
    not kernel_authcode_sha256_granted
    reason := "kernel_authcode_sha256 is not valid."
}

deny[reason] {
    not initrd_plain_sha256_granted
    reason := "initrd_plain_sha256 is not valid."
}

deny[reason] {
    not kernel_cmdline_granted
    reason := "kernel_cmdline is not valid."
}
