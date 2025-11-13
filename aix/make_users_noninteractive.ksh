#!/bin/ksh
users_nologin="invscout srvproxy adm esaadmin smmsp uucp ipsec sshd nuucp snapp"
users_locked="daemon bin sys uucp nobody lpd $users_nologin"

for I in $users_nolgin; do
    chuser -R files shell=/bin/false $I
done

for I in $users_locked; do
    chuser -R files account_locked=true daemon=false SYSTEM=compat registry=files $I
done
