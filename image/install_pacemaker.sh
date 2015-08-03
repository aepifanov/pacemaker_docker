#!/bin/bash


# System update
apt-get update
apt-get dist-upgrade

# Install pacemaker
apt-get install -y --no-install-recommends pacemaker wget
sed -i 's/no/yes/g' /etc/default/corosync
cp -f /build/my_init/pacemaker /etc/my_init.d/
cp -f /build/config/corosync.conf /etc/corosync/
corosync-keygen

# Download and install pcs
apt-get install -y --no-install-recommends wget unzip make
cd /root
wget https://github.com/feist/pcs/archive/master.zip && \
unzip master.zip && cd pcs-master/ && make install
apt-get remove -y wget unzip make

# Configuring SSH
SSH_PUB_KEY=/build/ssh/id_rsa.pub

rm -f /etc/service/sshd/down
/etc/my_init.d/00_regen_ssh_host_keys.sh
cat ${SSH_PUB_KEY} >> /root/.ssh/authorized_keys
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ""
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

# Don't like it, just remove
rm -rf /etc/service/syslog-forwarder
