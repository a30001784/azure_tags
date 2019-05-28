#!/usr/bin/env bash 

apt-get -y update && \
    apt-get -y install python3-dev

pip3 install setuptools 
pip3 install wheel 
pip3 install requests "ansible==2.7.0" "pywinrm>=0.3.0"