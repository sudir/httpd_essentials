#!/bin/bash

# Install yum depedencies
yum install bzip2.x86_64 wget gcc apr.x86_64 apr-util-devel.x86_64 pcre.x86_64 pcre-devel.x86_64 patch.x86_64 -y

# Grab essential packages
wget -c http://www.trieuvan.com/apache//httpd/httpd-2.4.41.tar.gz
wget -c http://www.linuxfromscratch.org/patches/blfs/9.0/httpd-2.4.41-blfs_layout-1.patch

tar -zxvf httpd-2.4.41.tar.gz 
rm -fr *.gz

# Set correct group/perms
groupadd -g 25 apache &&
useradd -c "Apache Server" -d /srv/www -g apache \
        -s /bin/false -u 25 apache

# Apply patch
cd httpd-2.4.41
patch -Np1 -i ../httpd-2.4.41-blfs_layout-1.patch             &&

sed '/dir.*CFG_PREFIX/s@^@#@' -i support/apxs.in              &&

./configure --enable-authnz-fcgi                              \
            --enable-layout=BLFS                              \
            --enable-mods-shared="all cgi"                    \
            --enable-mpms-shared=all                          \
            --enable-suexec=shared                            \
            --with-apr=/usr/bin/apr-1-config                  \
            --with-apr-util=/usr/bin/apu-1-config             \
            --with-suexec-bin=/usr/lib/httpd/suexec           \
            --with-suexec-caller=apache                       \
            --with-suexec-docroot=/srv/www                    \
            --with-suexec-logfile=/var/log/httpd/suexec.log   \
            --with-suexec-uidmin=100                          \
            --with-suexec-userdir=public_html                 &&
make
make install  &&

mv -v /usr/sbin/suexec /usr/lib/httpd/suexec &&
chgrp apache           /usr/lib/httpd/suexec &&
chmod 4754             /usr/lib/httpd/suexec &&

chown -v -R apache:apache /srv/www
httpd -version

# cleanup
cd && rm -fr installhttpd.sh httpd-2.4.41 httpd-2.4.41-blfs_layout-1.patch 
