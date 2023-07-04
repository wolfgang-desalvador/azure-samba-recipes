# Azure SAMBA Recipes
This repository contains some utility scripts to configure SAMBA servers on Azure VMs with an Azure Managed Lustre FileSystem

## Repository structure

The repository is structured with scripts for RedHat-based OS and for Ubuntu-based OS.

Scripts for RedHat have been tested on:

- RedHat 8.8
- RedHat 7.9
- AlmaLinux 8.5
- CentOS 7.9

Scripts for Ubuntu have been tested on:

- Ubuntu Server 20.04 LTS
- Ubuntu Server 20.04 LTS

## How to use

Scripts are divided for each system in 3 blocks:
- Standalone SAMBA installation
- Winbind AD Joined SAMBA Domain member configuration
- SSSD AD Joined SAMBA Domain member configuration

### Standalone SAMBA server installation

This script doesn't require any argument. It installs all required SAMBA packages and it provides also a basic `smb.conf` with a single share configured.

```bash
git clone https://github.com/wolfgang-desalvador/azure-samba-recipes.git
cd base/<YOUR_DISTRO_FOLDER>/standalone
sudo ./install_samba.sh # for RedHat-based systems
```

Example share defaults to `/lustre-fs` path and restricts access only to azureuser.

The `smb.conf` is not copied automatically but left to be copied in `/etc/samba/smb.conf` by the user

After copying the files, SAMBA service needs to be restarted.

```bash
sudo systemctl restart smb # for RedHat-based systems
```
or

```bash
sudo systemctl restart smbd # for Ubuntu-based systems
```

### SSSD AD-joined SAMBA server installation

This script requires two mandatory arguments: the user with priviledges for AD-join and the domain name. It installs all required packages and it provides also a basic `smb.conf` with a single share configured. Optionally, an AD Organizational Unit path can be specified for the new VM.

```bash
git clone https://github.com/wolfgang-desalvador/azure-samba-recipes.git
cd base/<YOUR_DISTRO_FOLDER>/sssd
sudo ./sssd_join.sh -u <JOIN_USER> -d <DOMAIN_NAME> [-o <AD_OU_PATH>] # for RedHat-based systems
```

Example share defaults to `/lustre-fs` path and restricts access only to `azureuser`.

The `smb.conf` is not copied automatically but left to be copied in `/etc/samba/smb.conf` by the user

After copying the files, SAMBA service needs to be restarted.

```bash
sudo systemctl restart smb winbind # for RedHat-based systems
```
or

```bash
sudo systemctl restart smbd winbind # for Ubuntu-based systems
```
