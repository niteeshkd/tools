package mbpolicy
import future.keywords.if

# By default, deny requests.
default allow := false

allow {
    #spec_granted
    digests_ipl_9_sha256 := get_digests("EV_IPL",9,"sha256")
    #print(digests)
    kernel_plain_sha256_granted(digests_ipl_9_sha256)
    initrd_plain_sha256_granted(digests_ipl_9_sha256)

    digests_boot_apps_4_sha256 := get_digests("EV_EFI_BOOT_SERVICES_APPLICATION",4,"sha256")
    grub_authcode_sha256_granted(digests_boot_apps_4_sha256)
    shim_authcode_sha256_granted(digests_boot_apps_4_sha256)
    kernel_authcode_sha256_granted(digests_boot_apps_4_sha256)
}

allow = {"false:", deny} {
    count(deny) > 0
}

spec_granted if {
    some i
    data.events[i].EventType == "EV_NO_ACTION" ; 
    data.events[i].SpecID[0].specVersionMajor == 2
    data.events[i].SpecID[0].specVersionMinor == 0
}

get_digests(event, pcrx, algid) = digests {
    digests := [ dg | dg = data.events[i].Digests[j].Digest ; 
                data.events[i].EventType == event ; 
                data.events[i].PCRIndex == pcrx ;
                data.events[i].Digests[j].AlgorithmId == algid ]
}

kernel_plain_sha256_granted(digests) if {
    digests[_] == trim_left(input.kernel_plain_sha256, "0x")
}

initrd_plain_sha256_granted(digests) if {
    digests[_] == trim_left(input.initrd_plain_sha256, "0x")
}

grub_authcode_sha256_granted(digests) if {
    digests[_] == trim_left(input.grub_authcode_sha256, "0x")
}

shim_authcode_sha256_granted(digests) if {
    digests[_] == trim_left(input.shim_authcode_sha256, "0x")
}

kernel_authcode_sha256_granted(digests) if {
    secure_boot_enabled
    digests[_] == trim_left(input.kernel_authcode_sha256, "0x")
}

secure_boot_enabled if {
    some i
    data.events[i].EventType == "EV_EFI_VARIABLE_DRIVER_CONFIG"
    data.events[i].PCRIndex == 7
    data.events[i].Event.UnicodeName == "SecureBoot"
}

deny[reason] {
    not spec_granted
    reason := "spec is not valid."
}

deny[reason] {
    digests_ipl_9_sha256 := get_digests("EV_IPL",9,"sha256")
    not kernel_plain_sha256_granted(digests_ipl_9_sha256)
    reason := "kernel_plain_sha256 is not valid."
}

deny[reason] {
    digests_ipl_9_sha256 := get_digests("EV_IPL",9,"sha256")
    not initrd_plain_sha256_granted(digests_ipl_9_sha256)
    reason := "initrd_plain_sha256 is not valid."
}

deny[reason] {
    digests_boot_apps_4_sha256 := get_digests("EV_EFI_BOOT_SERVICES_APPLICATION",4,"sha256")
    not grub_authcode_sha256_granted(digests_boot_apps_4_sha256)
    reason := "grub_authcode_sha256 is not valid."
}

deny[reason] {
    digests_boot_apps_4_sha256 := get_digests("EV_EFI_BOOT_SERVICES_APPLICATION",4,"sha256")
    not shim_authcode_sha256_granted(digests_boot_apps_4_sha256)
    reason := "shim_authcode_sha256 is not valid."
}

deny[reason] {
    digests_boot_apps_4_sha256 := get_digests("EV_EFI_BOOT_SERVICES_APPLICATION",4,"sha256")
    not kernel_authcode_sha256_granted(digests_boot_apps_4_sha256)
    reason := "kernel_authcode_sha256 is not valid."
}

deny[reason] {
    not secure_boot_enabled
    reason := "secure boot is not enabled."
}

