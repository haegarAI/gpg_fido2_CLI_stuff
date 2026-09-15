#!/bin/bash
# $1...file to decrypt
# $2...challenge code to be sent to your FIDO2 key to get the response code as passphrase for the gpg key (you need to have the private key ofc)
### '4711' is a hardcoded dummy value and has no effect, it could be anything...
### took the 4th line of the response code from FIDO2 key (hardcoded dev /dev/hidraw4) and there char 1-44 as passphrase
echo "prepare your key and don't forget to push the button when it is blinking!"
echo "new version:"
gpg --passphrase "$(fido2-cred -M -h /dev/hidraw4 < <(echo -e "$(echo '4711' | openssl sha256 -binary |  base64)\n"$2"\n4711\n4711)" )|sed -n "4p;" |cut -c 1-44 )" --pinentry-mode loopback -d $1

echo "first version:"
xargs -n1 bash -c 'gpg --passphrase "$((fido2-cred -M -h /dev/hidraw4 <<<"$(echo "4711" | openssl sha256 -binary |  base64)
$0
4711
4711" )  |sed -n "4p;" |cut -c 1-44)" --pinentry-mode loopback -d '$1 <<<$2

echo "hopefully the reight challenge response code and file was decrypted: now forgetting passphrases again..."
echo RELOADAGENT | gpg-connect-agent
