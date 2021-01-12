#!/bin/sh
mkdir -p $1

chmod 755 $1


rpm -Uvh ./nfs_util/*.rpm --nodeps --force
rpm -Uvh ./rpcbind/*.rpm --nodeps --force


cat <<EOF > /etc/exports
$1 *(rw,sync,insecure,no_subtree_check,no_root_squash)
EOF


systemctl start rpcbind
systemctl start nfs

systemctl restart rpcbind
systemctl restart nfs

systemctl enable nfs
systemctl enable rpcbind
