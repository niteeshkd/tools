package mbpolicy
import future.keywords.if

# By default, deny requests.
default allow := false

allow if {
    #spec_granted
    kernel_plain_sha256_granted
    initrd_plain_sha256_granted
    grub_authcode_sha256_granted
    shim_authcode_sha256_granted
    kernel_auth_sha256_granted
}

spec_granted if {
    #some i
    data.events[_].EventType == "EV_NO_ACTION" ; 
    data.events[_].SpecID[_].specVersionMajor == 2
    data.events[_].SpecID[_].specVersionMinor == 0
}

kernel_plain_sha256_granted if {
    data.events[_].EventType == "EV_IPL"
    data.events[_].PCRIndex == 9
    data.events[_].Digests[_].AlgorithmId == "sha256"
    data.events[_].Digests[_].Digest == trim_left(input.kernel_plain_sha256, "0x")
}

initrd_plain_sha256_granted if {
    data.events[_].EventType == "EV_IPL"
    data.events[_].PCRIndex == 9
    data.events[_].Digests[_].AlgorithmId == "sha256"
    data.events[_].Digests[_].Digest == trim_left(input.initrd_plain_sha256, "0x")
}

grub_authcode_sha256_granted if {
    data.events[_].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    data.events[_].PCRIndex == 4
    data.events[_].Digests[_].AlgorithmId == "sha256"
    data.events[_].Digests[_].Digest == trim_left(input.grub_authcode_sha256, "0x")
}

shim_authcode_sha256_granted if {
    data.events[_].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    data.events[_].PCRIndex == 4
    data.events[_].Digests[_].AlgorithmId == "sha256"
    data.events[_].Digests[_].Digest == trim_left(input.shim_authcode_sha256, "0x")
}

kernel_auth_sha256_granted if {
    secure_boot_enabled
    data.events[_].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    data.events[_].PCRIndex == 4
    data.events[_].Digests[_].AlgorithmId == "sha256"
    data.events[_].Digests[_].Digest == trim_left(input.kernel_authcode_sha256,"0x")
}

secure_boot_enabled if {
    data.events[_].EventType == "EV_EFI_VARIABLE_DRIVER_CONFIG"
    data.events[_].PCRIndex == 7
    data.events[_].Event.UnicodeName == "SecureBoot"
}
