#!/bin/sh

OPENSHIFT_RUNTIME_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime
OPENSHIFT_REPO_DIR=$OPENSHIFT_HOMEDIR/app-root/runtime/repo

# DIRECTORIES PREPARATION
cd $OPENSHIFT_RUNTIME_DIR
mkdir srv
mkdir srv/pcre
mkdir srv/httpd
mkdir srv/php
mkdir srv/libmcrypt
mkdir srv/zlib
mkdir srv/libcurl
mkdir tmp
cd tmp/

# INSTALL APACHE
wget http://www.eu.apache.org/dist/httpd/httpd-2.4.18.tar.gz
tar -zxf httpd-2.4.18.tar.gz
wget http://www.eu.apache.org/dist//apr/apr-1.5.2.tar.gz
tar -zxf apr-1.5.2.tar.gz
mv apr-1.5.2 httpd-2.4.18/srclib/apr
wget http://ftp.ps.pl/pub/apache//apr/apr-util-1.5.4.tar.gz
tar -zxf apr-util-1.5.4.tar.gz
mv apr-util-1.5.4 httpd-2.4.18/srclib/apr-util
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
tar -zxf pcre-8.37.tar.gz
cd pcre-8.37
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/pcre
make && make install
cd ../httpd-2.4.18
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/httpd \
--with-included-apr \
--with-pcre=$OPENSHIFT_RUNTIME_DIR/srv/pcre \
--enable-so \
--enable-auth-digest \
--enable-rewrite \
--enable-setenvif \
--enable-mime \
--enable-deflate \
--enable-headers
make && make install
cd ..

# INSTALL LIBMCRYPT
wget http://downloads.sourceforge.net/project/mcrypt/Libmcrypt/2.5.8/libmcrypt-2.5.8.tar.gz
tar -zxf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/libmcrypt \
--disable-posix-threads
make && make install
cd ..

rm -f -r libmcrypt-2.5.8

# INSTALL ICU
wget http://download.icu-project.org/files/icu4c/56.1/icu4c-56_1-src.tgz
tar -zxf icu4c-56_1-src.tgz
cd icu/source/
chmod +x runConfigureICU configure install-sh
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/icu
make && make install
cd ../..
rm -f -r icu

# INSTALL ZLIB
wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zxf zlib-1.2.8.tar.gz
cd zlib-1.2.8
./configure \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/zlib
make && make install
cd ..
rm -f -r zlib-1.2.8

# INSTALL CURL
wget https://curl.haxx.se/download/curl-7.47.1.tar.gz
tar -zxf curl-7.47.1.tar.gz
cd curl-7.47.1
./configure \
--with-libdir=lib64 \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/libcurl \
--with-zlib=$OPENSHIFT_RUNTIME_DIR/srv/zlib
make && make install
cd ..
rm -f -r curl-7.47.1

# INSTALL PHP
wget http://php.net/get/php-5.6.18.tar.gz/from/this/mirror
tar -zxf php-5.6.18.tar.gz
cd php-5.6.18
./configure \
LDFLAGS="-L$OPENSHIFT_RUNTIME_DIR/srv/libmcrypt/lib" \
--with-libdir=lib64 \
--prefix=$OPENSHIFT_RUNTIME_DIR/srv/php \
--with-config-file-path=$OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2 \
--with-layout=PHP \
--with-apxs2=$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apxs \
--with-gd \
--with-mysql \
--with-pdo-mysql \
--with-mcrypt=$OPENSHIFT_RUNTIME_DIR/srv/libmcrypt \
--with-zlib=$OPENSHIFT_RUNTIME_DIR/srv/zlib \
--with-curl=$OPENSHIFT_RUNTIME_DIR/srv/libcurl \
--enable-zip \
--enable-mbstring \
--enable-intl \
--with-icu-dir=$OPENSHIFT_RUNTIME_DIR/srv/icu

make LDFLAGS="-L$OPENSHIFT_RUNTIME_DIR/srv/libmcrypt/lib"
make install
mkdir $OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2

#INSTALL APC (TEMPORARILY SUSPENDED)
# cd ..
# wget http://pecl.php.net/get/APC-3.1.13.tgz
# tar -zxf APC-3.1.13.tgz
# cd APC-3.1.13
# $OPENSHIFT_RUNTIME_DIR/srv/php/bin/phpize
# ./configure \
# --with-php-config=$OPENSHIFT_RUNTIME_DIR/srv/php/bin/php-config \
# --enable-apc \
# --enable-apc-debug=no
# make && make install

# CLEANUP
rm -r $OPENSHIFT_RUNTIME_DIR/tmp/*.tar.gz

# COPY TEMPLATES
cp $OPENSHIFT_REPO_DIR/misc/templates/bash_profile.tpl $OPENSHIFT_HOMEDIR/app-root/data/.bash_profile
cp $OPENSHIFT_REPO_DIR/misc/templates/php.ini.tpl $OPENSHIFT_RUNTIME_DIR/srv/php/etc/apache2/php.ini
python $OPENSHIFT_REPO_DIR/misc/httpconf.py

# START APACHE
$OPENSHIFT_RUNTIME_DIR/srv/httpd/bin/apachectl start
