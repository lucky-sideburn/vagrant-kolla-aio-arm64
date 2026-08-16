#!/bin/sh
# Dynamic MOTD banner, executed by pam_motd on every SSH login.

C1='\033[1;36m'
C2='\033[1;33m'
C0='\033[0m'

printf "${C1}"
printf '╔══════════════════════════════════════════════════════════════════════╗\n'
printf '║%-72s║\n' ''
printf '║%-72s║\n' '   OpenStack Kolla-Ansible AIO - Vagrant Box'
printf '║%-72s║\n' '   Created by lucky-sideburn'
printf '║%-72s║\n' ''
printf '╚══════════════════════════════════════════════════════════════════════╝\n'
printf "${C0}\n"

printf "${C2}"
echo '  NOTE: Docker images are NOT pre-pulled in this box (kept small on'
echo '  purpose). On first boot, Docker will pull all Kolla container'
echo '  images from the registry, so the "kolla-*-container" services may'
echo '  take a few minutes to report as healthy the first time.'
printf "${C0}\n"
