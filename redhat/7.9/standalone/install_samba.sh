#!/bin/bash

rpm --import https://packages.microsoft.com/keys/microsoft.asc

DISTRIB_CODENAME=el7

REPO_PATH=/etc/yum.repos.d/amlfs.repo
echo -e "[amlfs]" > ${REPO_PATH}
echo -e "name=Azure Lustre Packages" >> ${REPO_PATH}
echo -e "baseurl=https://packages.microsoft.com/yumrepos/amlfs-${DISTRIB_CODENAME}" >> ${REPO_PATH}
echo -e "enabled=1" >> ${REPO_PATH}
echo -e "gpgcheck=1" >> ${REPO_PATH}
echo -e "gpgkey=https://packages.microsoft.com/keys/microsoft.asc" >> ${REPO_PATH}

yum install -y amlfs-lustre-client-2.15.1_29_gbae0abe-$(uname -r | sed -e "s/\.$(uname -p)$//" | sed -re 's/[-_]/\./g')-1

yum install -y samba

if [[ $(systemctl is-active firewalld) == active ]]; then
    echo "Adding Firewall rules"
    firewall-cmd --permanent --add-service=samba
    firewall-cmd --reload
else
    echo "Firewall is disabled, skipping rule addition"
fi

if [[ $(getenforce) == Enforcing ]]; then
    echo "Adding SELinux rule"
    setsebool -P samba_export_all_rw 1
else
    echo "SELinux not enforcing, skipping rule addition."
fi

