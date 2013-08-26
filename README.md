ovs_upgrade
===========

Tools upgrade openvswitch without service interruption

Usage
-----

* ovs_install.sh

    Install both kernel and userspace software


* ovs_control

    Uitility script to restart the services and kernel module


Example
-------

    ./ovs_install.sh 1.10.0

    sudo ./ovs_control force-reload-kmod
