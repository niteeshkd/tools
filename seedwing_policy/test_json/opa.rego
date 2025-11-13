package test

import future.keywords.if

default allow := false

allowedLicenses := ["Apache-2.0", "MIT", "CC0-1.0", "EPL-1.0", "UPL-1.0", "EPL-2.0", "BSD-2-Clause", "BSD-3-Clause"]

allow if {
    count({x | validLicense(input.components[x]) }) == count(input.components)
}

validLicense(component) {
    component.licenses[_].license.id == allowedLicenses[_]
}
