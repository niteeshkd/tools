package mbpolicy
import future.keywords.if

refstate := {
    "kernel_plain_sha256": "0x2ae3edb0730ea74d74ed76da2f297888abd9a990ce95dbb51e7e088b74680292",
    "kernel_authcode_sha256": "0xd968af6fbb6210352455d1c67b49d7b3c414361c9ea1d2828ef15f6d5bac4d19"
}

# By default, deny requests.
default allow := false

allow {
    kernel_plain_sha256_granted
    kernel_authcode_sha256_granted
}

allow = {"false:", deny} {
    count(deny) > 0
}

kernel_plain_sha256_granted if {
    some i,j
    data.events[i].EventType == "EV_IPL"
    data.events[i].PCRIndex == 9
    data.events[i].Digests[j].AlgorithmId == "sha256"
    data.events[i].Digests[j].Digest == trim_left(refstate.kernel_plain_sha256, "0x")
}

kernel_authcode_sha256_granted if {
    secure_boot_enabled
    some i,j
    data.events[i].EventType == "EV_EFI_BOOT_SERVICES_APPLICATION"
    data.events[i].PCRIndex == 4
    data.events[i].Digests[j].AlgorithmId == "sha256"
    data.events[i].Digests[j].Digest == trim_left(refstate.kernel_authcode_sha256,"0x")
}

secure_boot_enabled if {
    some i
    data.events[i].EventType == "EV_EFI_VARIABLE_DRIVER_CONFIG"
    data.events[i].PCRIndex == 7
    data.events[i].Event.UnicodeName == "SecureBoot"
}

deny[reason] {
    not kernel_plain_sha256_granted
    reason := "kernel_plain_sha256 is not valid."
}

deny[reason] {
    not kernel_authcode_sha256_granted
    reason := "kernel_authcode_sha256 is not valid."
}

deny[reason] {
    not secure_boot_enabled
    reason := "secure boot is not enabled."
}
