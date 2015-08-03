#!/bin/bash

USER=root
IF=eth0
NODES="$@"
ID=0
CRM_CONF_TEMPL=./conf/corosync.conf.udpu.templ
CRM_CONF_=./corosync.conf.tmpl
CRM_CONF=./corosync.conf

# Find online nodes from the list and add them into corosync.conf
cp $CRM_CONF_TEMPL $CRM_CONF_
for HOST in $NODES; do
    IP=$(ssh -o LogLevel=quiet $USER@$HOST ifconfig $IF | awk 'sub(/inet addr:/,""){print $1}')
    if [ -z $IP ] ; then
        continue
    fi
    ((ID++))
    sed -i "s/nodelist {/nodelist {\n  node {\n    ring0_addr: $IP\n    nodeid: $ID\n  }/g" $CRM_CONF_
    sed -i "s/interface {/interface {\n    member {\n      memberaddr: $IP\n    }/g" $CRM_CONF_
    IPS=("${IPS[@]}" "$IP")
done

# Finish tuning corosync.conf with unique params, upload it to the node and restart pacemaker
for IP in ${IPS[@]}; do
    cp -f $CRM_CONF_ $CRM_CONF
    sed -i "s/ringnumber:  0/ringnumber:  0\n    bindnetaddr: $IP/g" $CRM_CONF
    scp $CRM_CONF $USER@$IP:/etc/corosync/
    ssh $USER@$IP service pacemaker stop
    ssh $USER@$IP service corosync stop
    ssh $USER@$IP service corosync start
    ssh $USER@$IP service pacemaker start
done

# Cleanup tmp files
rm $CRM_CONF_ $CRM_CONF
