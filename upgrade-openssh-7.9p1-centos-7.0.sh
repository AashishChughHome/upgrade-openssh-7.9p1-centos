#!/bin/bash
# Copyright © 2019 AashishChugh
yum install -y pam-devel rpm-build rpmdevtools zlib-devel openssl-devel krb5-devel gcc wget
mkdir -p ~/rpmbuild/SOURCES && cd ~/rpmbuild/SOURCES
wget -c http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.9p1.tar.gz
wget -c http://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-7.9p1.tar.gz.asc
# # verify the file
# update the pam sshd from the one included on the system
# the default provided doesn't work properly on centos 6.5
tar zxvf openssh-7.9p1.tar.gz
yes | cp /etc/pam.d/sshd openssh-7.9p1/contrib/redhat/sshd.pam
mv openssh-7.9p1.tar.gz{,.orig}
tar zcpf openssh-7.9p1.tar.gz openssh-7.9p1
cd /root/rpmbuild/SOURCES/
wget https://src.fedoraproject.org/lookaside/pkgs/openssh/x11-ssh-askpass-1.2.4.1.tar.gz/8f2e41f3f7eaa8543a2440454637f3c3/x11-ssh-askpass-1.2.4.1.tar.gz 
cd
tar zxvf ~/rpmbuild/SOURCES/openssh-7.9p1.tar.gz openssh-7.9p1/contrib/redhat/openssh.spec
# edit the specfile
cd openssh-7.9p1/contrib/redhat/
sed -i -e "s/%define no_gnome_askpass 0/%define no_gnome_askpass 1/g" openssh.spec
sed -i -e "s/%define no_x11_askpass 0/%define no_x11_askpass 1/g" openssh.spec
sed -i -e "s/BuildPreReq/BuildRequires/g" openssh.spec
sed -i -e "s/BuildRequires: openssl-devel >= 1.0.1/#BuildRequires: openssl-devel >= 1.0.1/g" openssh.spec
sed -i -e "s/BuildRequires: openssl-devel < 1.1/#BuildRequires: openssl-devel < 1.1/g" openssh.spec
#if encounter build error with the follow line, comment it.
sed -i -e "s/PreReq: initscripts >= 5.00/#PreReq: initscripts >= 5.00/g" openssh.spec
rpmbuild -ba openssh.spec
cd
mkdir openssh && cd openssh
scp /root/rpmbuild/SRPMS/openssh-7.9p1-1.el7.src.rpm /root/rpmbuild/RPMS/x86_64/openssh-7.9p1-1.el7.x86_64.rpm /root/rpmbuild/RPMS/x86_64/openssh-clients-7.9p1-1.el7.x86_64.rpm /root/rpmbuild/RPMS/x86_64/openssh-server-7.9p1-1.el7.x86_64.rpm /root/rpmbuild/RPMS/x86_64/openssh-debuginfo-7.9p1-1.el7.x86_64.rpm .
timestamp=$(date +%s)
cp /etc/pam.d/sshd pam-ssh-conf-$timestamp
rpm -e --nodeps `rpm -qa | grep openssh-askpass`
rpm -U *.rpm
yes | cp pam-ssh-conf-$timestamp /etc/pam.d/sshd
rm -r /etc/ssh/ssh*key && /etc/init.d/sshd restart
echo "New version upgrades as to lastest:" && $(ssh -V)
