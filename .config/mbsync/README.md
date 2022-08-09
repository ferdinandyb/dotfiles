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

# Naming

Do NOT use @ in the name of any store/acccount/etc. mbsync will say it can't connect to certain folders (channels).
