# XOAUTH2

Need to install `sasl` to run XOAUTH2.

```
sudo apt install libsasl2-dev sasl2-bin

# rest taken from [here](https://unix.stackexchange.com/a/632794/82390)
git clone https://github.com/moriyoshi/cyrus-sasl-xoauth2.git

# Configure and make.
cd cyrus-sasl-xoauth2
./autogen.sh
./configure

# SASL2 libraries on Ubuntu are in /usr/lib/x86_64-linux-gnu/; modify the Makefile accordingly
sed -i 's%pkglibdir = ${CYRUS_SASL_PREFIX}/lib/sasl2%pkglibdir = ${CYRUS_SASL_PREFIX}/lib/x86_64-linux-gnu/sasl2%' Makefile

make
sudo make install
```

# Versions

You need to build from master currently, which has a breaking change with folder and config placements with 1.4.4.

### Fetching email

- `mbsync` (`isync`) is used for syncing with IMAP. Gmail in particular is pretty messy so set up, because labels are presented as folder over IMAP but of course they are not. This has a separate README in this repo.
- `mailctl` is used for OAUTH and `pass` is used for just password authentication
- [goimapnotify](https://gitlab.com/shackra/goimapnotify)

calling template service: `systemctl --user enable  goimapnotify@formsense_imapnotify.service`

# Sending email (msmtp)

Need to add `mailctl` to msmtp apparmor: `/home/fbence/bin/mailctl{,2} PUx,`

`sudo vim /etc/apparmor.d/usr.bin.msmtp` -> add line
`sudo apparmor_parser -r /etc/apparmor.d/usr.bin.msmtp` <- for reloading

this is where the line should go:
```
  profile helpers {
    #include <abstractions/base>
    /{,usr/}bin/bash mr,
    /{,usr/}bin/dash mr,
    /tmp/            rw,
    owner /tmp/*     rw,

    /usr/bin/secret-tool PUx,
    /usr/bin/gpg{,2}     PUx,
    /home/fbence/bin/mailctl{,2} PUx,
    /usr/bin/pass        PUx,
    /usr/bin/head        PUx,
    /usr/bin/keyring     PUx,
    /{,usr/}bin/cat      PUx,
  }
```

# AERC

```
GOFLAGS=-tags=notmuch make PREFIX=/home/fbence/.local
GOFLAGS=-tags=notmuch make install PREFIX=/home/fbence/.local
```
