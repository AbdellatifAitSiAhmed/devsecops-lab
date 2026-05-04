#!/bin/bash
mkdir -p /etc/pure-ftpd/auth
HASH=$(python3 -c "import hashlib,base64,os; salt=os.urandom(16); h=hashlib.sha512(b'LabFTP2024!'+salt).digest(); print('\$6\$'+base64.b64encode(salt).decode()+'\$'+base64.b64encode(h).decode())")
echo "ftpuser:${HASH}:1000:1000::/home/ftpuser/./:::::::::::::" > /etc/pure-ftpd/pureftpd.passwd
pure-pw mkdb /etc/pure-ftpd/pureftpd.pdb -f /etc/pure-ftpd/pureftpd.passwd
ln -sf /etc/pure-ftpd/pureftpd.pdb /etc/pure-ftpd/auth/50puredb
echo "21100 21110" > /etc/pure-ftpd/conf/PassivePortRange
echo "no" > /etc/pure-ftpd/conf/IPV6Binding
exec /usr/sbin/pure-ftpd -j -S 21 -l puredb:/etc/pure-ftpd/pureftpd.pdb
