#!/bin/bash

echo -
echo "NEED TO RUN AS ROOT"
cd /etc/yum.repos.d
echo cd to yum repo
wget --no-check-certificate http://public-yum.oracle.com/public-yum-ol6.repo
echo created repo
wget --no-check-certificate https://public-yum.oracle.com/RPM-GPG-KEY-oracle-ol6 -O /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle-ol6
echo Copying Key 
cp -p /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle-ol6 /etc/pki/rpm-gpg/RPM-GPG-KEY-oracle

echo found key and applied it

echo install packages 

yum -y install $(cat /home/aproject/RPM/rpm.txt)

echo +

