# gpg_fido2_CLI_stuff
Creating the gpg keys with using the challenge-response answer of a FIDO2 key, capable of hmac-secret
The param/challenge which changes the response is: "putThesecretpassForgenerationhere"
...you can change that to your own challenge text/pass... eg "myPass" it has to have at least 4 chars.
## Create GPG keypair using a FIDO2 passphrase 
~~~
gpg --batch --generate-key <<<"   %echo Generating a basic OpenPGP key
     Key-Type: DSA
     Key-Length: 1024
     Subkey-Type: ELG-E
     Subkey-Length: 1024
     Name-Real: Joe Tester
     Name-Comment: with stupid passphrase
     Name-Email: joe@foo.bar
     Expire-Date: 0
     Passphrase: $((fido2-cred -M -h /dev/hidraw4 <<<"$(echo '4711' | openssl sha256 -binary |  base64)
putThesecretpassForgenerationhere
4711
4711" )  |sed -n '4p;' |cut -c 1-44)
     # Do a commit here, so that we can later print "done" :-)
     %commit"
~~~
I take the 4th line(sed -n...) of the response and the first 44 char (cut...), as these are always different to different challenge phrases: ofc it's up to you how many char you'd like to take...
The other params with value '4711' have no effect.

## Now encode some file... 
eg "me" using the new key...
~~~
:~$ gpg -r joe@foo.bar -e me
~~~
## Then decode 
like this
~~~
gpg --batch --status-fd --with-colons --passphrase "$((fido2-cred -M -h /dev/hidraw4 <<<"$(echo '4711' | openssl sha256 -binary |  base64)
putThesecretpassForgenerationhere
4711
4711" )  |sed -n '4p;' |cut -c 1-44)" --pinentry-mode loopback  -d me.gpg
~~~
In my tests I could omit params "--batch --status-fd --with-colons "
most important is to have param  "--passphrase "yourpassphrase" --pinentry-mode loopback" 
...and ofc param "-d enc_file.gpg"
For testing the options and if everything works as expected (keep in mind that once you entered the correct passphrase it is cached and reused: regardless whatever passphrase you provide later...):
~~~
echo RELOADAGENT | gpg-connect-agent
~~~
after that you'll need the correct passphrase again, else nothing will be decrypted...
