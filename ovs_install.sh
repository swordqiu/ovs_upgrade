#!/bin/bash


VERSION=$1

if test -z $VERSION; then
    echo "Usage: ovs_install.sh <version>"
    exit 1
fi

PACKAGE=openvswitch-$VERSION

if test ! -e $PACKAGE.tar.gz; then
    echo "$PACKAGE.tar.gz not exists"
    exit 1
fi

rm -fr $PACKAGE
tar xf $PACKAGE.tar.gz

cd $PACKAGE
if test -f /etc/redhat-release; then
    if test -e ../patches/$PACKAGE; then
        patch -p1 -i ../patches/$PACKAGE/openvswitch.patch
    fi
fi
MODULE_DIR=/lib/modules/`uname -r`
if test ! -f ./configure; then
    ./boot.sh
    if test "$?" -ne "0"; then
        echo "./boot.sh failed"
        exit 1
    fi
fi
./configure --with-linux=$MODULE_DIR/build --enable-ndebug --prefix=/usr/local
if test "$?" -ne "0"; then
    echo "./configure failed"
    exit 1
fi
make
if test "$?" -ne "0"; then
    echo "Compile failed"
    exit 1
fi
sudo PATH=/usr/local/bin:$PATH make install
KMOD_PATH=datapath/linux/openvswitch_mod.ko
if test ! -f $KMOD_PATH; then
    KMOD_PATH=datapath/linux/openvswitch.ko
    if test ! -f $KMOD_PATH; then
        echo "Fail to compile kmod"
        exit 1
    fi
fi
MODULE_DEST=$MODULE_DIR/kernel/net/openvswitch
sudo mkdir -p $MODULE_DEST
sudo rm -fr $MODULE_DEST/*
sudo cp $KMOD_PATH $MODULE_DEST
sudo depmod -a

if test ! -f /usr/local/etc/openvswitch/conf.db; then
    sudo mkdir -p /usr/local/etc/openvswitch
    if test -f /etc/openvswitch/conf.db; then
        sudo cp /etc/openvswitch/* /usr/local/etc/openvswitch
    else
        sudo /usr/local/bin/ovsdb-tool create /usr/local/etc/openvswitch/conf.db vswitchd/vswitch.ovsschema
    fi
fi
