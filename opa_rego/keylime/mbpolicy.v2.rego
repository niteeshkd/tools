package mbpolicy
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

spec_granted if {
    some i
    data.events[i].EventType == "EV_NO_ACTION" ;
    data.events[i].SpecID[0].specVersionMajor == 2
    data.events[i].SpecID[0].specVersionMinor == 0
}

kernel_plain_sha256_granted if {
    some i,j
    data.events[i].EventType == "EV_IPL"
    data.events[i].PCRIndex == 9
    data.events[i].Digests[j].AlgorithmId == "sha256"
    data.events[i].Digests[j].Digest == trim_left(input.kernel_plain_sha256, "0x")
}

initrd_plain_sha256_granted if {
    some i,j
    data.events[i].EventType == "EV_IPL"
    data.events[i].PCRIndex == 9
    data.events[i].Digests[j].AlgorithmId == "sha256"
    data.events[i].Digests[j].Digest == trim_left(input.initrd_plain_sha256, "0x")
}

grub_authcode_sha256_granted if {
    some i,j
    data.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    data.events[i].PCRIndex == 4
    data.events[i].Digests[j].AlgorithmId == "sha256"
    data.events[i].Digests[j].Digest == trim_left(input.grub_authcode_sha256, "0x")
}

shim_authcode_sha256_granted if {
    some i,j
    data.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    data.events[i].PCRIndex == 4
    data.events[i].Digests[j].AlgorithmId == "sha256"
    data.events[i].Digests[j].Digest == trim_left(input.shim_authcode_sha256, "0x")
}

kernel_authcode_sha256_granted if {
    secure_boot_enabled
    some i,j
    data.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    data.events[i].PCRIndex == 4
    data.events[i].Digests[j].AlgorithmId == "sha256"
    data.events[i].Digests[j].Digest == trim_left(input.kernel_authcode_sha256,"0x")
}

secure_boot_enabled if {
    some i
    data.events[i].EventType == "EV_EFI_VARIABLE_DRIVER_CONFIG"
    data.events[i].PCRIndex == 7
    data.events[i].Event.UnicodeName == "SecureBoot"
}
