# Azure SAMBA Recipes
This repository contains some utility scripts to configure SAMBA servers on Azure VMs with an Azure Managed Lustre FileSystem

# Repository structure

The repository is structured with scripts for RedHat-based OS and for Ubuntu-based OS.

Scripts for RedHat have been tested on:

- RedHat 8.8
- RedHat 7.9
- AlmaLinux 8.5
- CentOS 7.9

Scripts for Ubuntu have been tested on:

- Ubuntu Server 20.04 LTS
- Ubuntu Server 22.04 LTS

# Microsoft TechCommunity Blog Post

This respository relates to Microsoft TechCommunity Blog Post for SAMBA configuration for Azure Managed Lustre File System.

# How to use

Scripts are divided for each system in 3 blocks:
- Standalone SAMBA installation
- Winbind AD Joined SAMBA Domain member configuration
- SSSD AD Joined SAMBA Domain member configuration

## Standalone SAMBA server installation

This script doesn't require any argument. It installs all required SAMBA packages and it provides also a basic `smb.conf` with a single share configured.

>The script will add firewall rules and SELinux configuration to allow SAMBA to run

```bash
git clone https://github.com/wolfgang-desalvador/azure-samba-recipes.git
cd base/<YOUR_DISTRO_FOLDER>/standalone
sudo ./install_samba.sh # for RedHat-based systems
```

Example share defaults to `/lustre-fs` path and restricts access only to `azureuser`.

The `smb.conf` is not copied automatically but left to be copied in `/etc/samba/smb.conf` by the user

After copying the files, SAMBA service needs to be restarted.

```bash
sudo systemctl restart smb # for RedHat-based systems
```
or

```bash
sudo systemctl restart smbd # for Ubuntu-based systems
```

## Domain Member SAMBA server installation

This script requires two mandatory arguments: the user with priviledges for AD-join and the domain name. It installs all required packages and it provides also a basic `smb.conf` with a single share configured. Optionally, an AD Organizational Unit path can be specified for the new VM.

>The script will backup an existing `/etc/samba/smb.conf` on `/etc/samba/smb.conf.sssd_join` and existing `/etc/krb5.conf` on `/etc/krb5.conf.sssd_join`

```bash
git clone https://github.com/wolfgang-desalvador/azure-samba-recipes.git
cd base/<YOUR_DISTRO_FOLDER>/sssd
sudo ./sssd_join.sh -u <JOIN_USER> -d <DOMAIN_NAME> -m <METHOD_NAME> [-o <AD_OU_PATH>] # for RedHat-based systems
```
where:
- `<JOIN_USER>` is the username with AD join priviledges
- `<DOMAIN_NAME>` is the domain name (realm) to join in capital letters (e.g. `LUSTRE.LAB`) 
- `<METHOD_NAME>` is the method name to use for join (e.g. `winbind` or `sssd`) 
- `<AD_OU_PATH>` is an optional OU where to place the machine in join process (e.g. `OU=SambaServer,OU=lustre,OU=lab`)

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

# Service customization

Further customizations to SSSD, SAMBA or Winbind configuration should be applied by the user on the basis of required IT Security policies or specific needs

# Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.


