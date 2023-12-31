#!/bin/bash

rpm --import https://packages.microsoft.com/keys/microsoft.asc

SCRIPT_FOLDER_STANDALONE="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

dist_version=$(rpm --eval "%dist")
DISTRIB_CODENAME=${dist_version/*./}
DISTRIB_CODENAME=$(echo $DISTRIB_CODENAME | cut -c -3)

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

cp $SCRIPT_FOLDER_STANDALONE/smb.conf.template  $SCRIPT_FOLDER_STANDALONE/smb.conf

if [[ $DISTRIB_CODENAME == "el8" ]]; then
    sed -i "/ea support/d" $SCRIPT_FOLDER_STANDALONE/smb.conf
fi
