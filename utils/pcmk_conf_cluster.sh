#!/bin/bash

USER=root
NODES="$@"
ID=0
CRM_CONF_TEMPL=./conf/corosync.conf.udpu.templ
CRM_CONF_=./corosync.conf.tmpl
CRM_CONF=./corosync.conf

# Find online nodes from the list and add them into corosync.conf
cp $CRM_CONF_TEMPL $CRM_CONF_
for HOST in ${NODES}; do
    IP=$(host $HOST | awk '{print $4}')
    if [ -z $IP ] ; then
        continue
    fi
    ((ID++))
    sed -i "s/nodelist {/nodelist {\n  node {\n    ring0_addr: $IP\n    nodeid: $ID\n  }/g" $CRM_CONF_
    sed -i "s/interface {/interface {\n    member {\n      memberaddr: $IP\n    }/g" $CRM_CONF_
    IPS=("${IPS[@]}" "$IP")
done

# Finish tuning corosync.conf with unique params, upload it to the node and restart pacemaker
for NODE in ${NODES}; do
    echo -e "\n### Adding to the cluster $NODE"
    cp -f $CRM_CONF_ $CRM_CONF
    sed -i "s/ringnumber:  0/ringnumber:  0\n    bindnetaddr: $NODE/g" $CRM_CONF
    scp -q $CRM_CONF $USER@$NODE:/etc/corosync/
    ssh -q $USER@$NODE service pacemaker stop
    ssh -q $USER@$NODE service corosync stop
    ssh -q $USER@$NODE service corosync start
    ssh -q $USER@$NODE service pacemaker start
done

# Cleanup tmp files
rm $CRM_CONF_ $CRM_CONF
