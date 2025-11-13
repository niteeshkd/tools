package keylime.mbpolicy
import data.keylime.tpm2evlog 
import input

import future.keywords.if

# By default, deny requests.
default allow = false

allow {
    kernel_plain_sha256_granted
}

allow = {"false:", deny} {
    count(deny) > 0
}

kernel_plain_sha256_granted if {
    some i,j
    tpm2evlog.events[i].EventType == "EV_IPL"
    tpm2evlog.events[i].PCRIndex == 9
    tpm2evlog.events[i].Digests[j].AlgorithmId == "sha256"
    tpm2evlog.events[i].Digests[j].Digest == trim_left(input.kernel_plain_sha256, "0x")
}

deny[reason] {
    not kernel_plain_sha256_granted
    reason := "kernel_plain_sha256 is not valid."
}
