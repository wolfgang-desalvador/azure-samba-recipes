#!/bin/bash

apt update && apt install -y ca-certificates curl apt-transport-https lsb-release gnupg
source /etc/lsb-release
echo "deb [arch=amd64] https://packages.microsoft.com/repos/amlfs-${DISTRIB_CODENAME}/ ${DISTRIB_CODENAME} main" | tee /etc/apt/sources.list.d/amlfs.list
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null

apt update

apt install -y amlfs-lustre-client-2.15.1-29-gbae0abe=$(uname -r)

apt-get install -y samba

if [[ $(systemctl is-active ufw) == active ]]; then
    echo "Adding Firewall rules"
    ufw allow samba
else
    echo "Firewall is disabled, skipping rule addition"
fi

if [[ $(getenforce) == Enforcing ]]; then
    echo "Adding SELinux rule"
else
    echo "SELinux not enforcing, skipping rule addition."
fi
