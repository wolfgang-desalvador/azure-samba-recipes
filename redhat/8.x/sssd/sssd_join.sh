#!/bin/bash

set -xe

SCRIPT_FOLDER="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

while getopts ':u:d:o:' opt; do
  case "$opt" in
    u)
      USER_JOIN="$OPTARG"
      ;;

    d)
      DOMAIN="$OPTARG"
      ;;

    o)
      ORGANIZATIONAL_UNIT="$OPTARG"
      ;;
    ?|h)
      echo "Usage: $(basename $0) -u <USERNAME> -d <DOMAIN> [-o <ORGANIZATIONAL_UNIT>]"
      echo "-u  ->  Username for AD join"
      echo "-d  ->  Domain name all capital"
      echo "-o  ->  OU definition where to place VM in AD (optional)"
      exit 1
      ;;
  esac
done

shift "$(($OPTIND -1))"


if [[ -z "$USER_JOIN" ]]; then
    echo "User for AD Join must be specified"
    exit 1
fi

if [[ -z "$DOMAIN" ]]; then
    echo "Domain for AD Join must be specified"
    exit 1
fi


$SCRIPT_FOLDER/../standalone/install_samba.sh

yum install -y adcli realmd sssd krb5-workstation krb5-libs oddjob oddjob-mkhomedir samba-common-tools samba-winbind

kinit $USER_JOIN@$DOMAIN

if [[ -z "$ORGANIZATIONAL_UNIT" ]]; then
    realm join --verbose $DOMAIN -U $USER_JOIN --membership-software=samba --client-software=sssd
else
    realm join --verbose $DOMAIN -U $USER_JOIN --membership-software=samba --client-software=sssd --computer-ou=$ORGANIZATIONAL_UNIT
fi

mv /etc/samba/smb.conf mv /etc/samba/smb.conf.bak.sssd_join || true

touch /etc/samba/smb.conf
cp $SCRIPT_FOLDER/smb.conf.template  $SCRIPT_FOLDER/smb.conf

sed -i "s/<COMPUTER_NETBIOS_NAME>/$(net getlocalsid | awk '{print $4}')/g" $SCRIPT_FOLDER/smb.conf
sed -i "s/<REALM_NAME>/$DOMAIN/g" $SCRIPT_FOLDER/smb.conf
sed -i "s/<DOMAIN_NAME>/$(net ads workgroup -S $DOMAIN | awk '{print $2}')/g" $SCRIPT_FOLDER/smb.conf
