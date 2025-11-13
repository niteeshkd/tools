package mbpolicy
import future.keywords.if

# By default, deny requests.
default allow := false

allow {
    digests := get_digests("EV_IPL",9,"sha256")
    print(digests)
    #kernel_plain_sha256_granted
    #initrd_plain_sha256_granted
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

get_digests(event, pcrx, algid) = digests {
    digests := [ dg | dg = data.events[i].Digests[j].Digest ; 
                data.events[i].EventType == event ; 
                data.events[i].PCRIndex == pcrx ;
                data.events[i].Digests[j].AlgorithmId == algid ]
}
