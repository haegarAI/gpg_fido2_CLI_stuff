#!/bin/bash
# $1 ... name of the key of your choice (no spaces in the name)
# $2 ... challenge response code to get passphrase from FIDO2 key >4 char (no spaces in the string)
# $3 ... device path of the FIDO2 key eg.: /dev/hidraw4 (valid device path see 'fido2-token -L')
#######
# it is ofc possible to change key type,length here...
# to keep it simple for me I hardcoded it: RSA, 4096
xargs -n1 bash -c 'gpg --batch --generate-key <<<"   %echo Generating a basic OpenPGP key
Key-Type: RSA
Key-Length: 4096
Name-Real: "'$1'"
Name-Email: "'$1'"
Expire-Date: 0
     Passphrase: $((fido2-cred -M -h '$3' <<<"$(echo "4711" | openssl sha256 -binary |  base64)
$0
4711
4711" )  |sed -n "4p;" |cut -c 1-44)
     # Do a commit here, so that we can later print "done" :-)
     %commit"' <<<"$2"
