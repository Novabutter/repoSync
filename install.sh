#!/bin/bash
#===============================================#
# Script: install.sh                            #
# Purpose: Initially install Remote Repo Sync   #
# Dependencies: None                            #
#===============================================#
# Make other scripts in current dir executable
chmod 700 change-detect.sh
chmod 700 lockdown.sh
# Create repouser 
useradd -m repoGrabbers
useradd -m repoSync
REPO_SYNC_HOME=/home/repoSync
REPO_SYNC_DIR=/home/repoGrabbers
# Create Directory
if [[ -d $REPO_SYNC_DIR/repos ]];
then
    echo "DEBUG: Error! Either installation already exists or unknown error occured - Failed."
    exit
else
    echo "DEBUG: Intializing first time setup"
    mkdir -p $REPO_SYNC_DIR/repos
fi
# Ask Questions
read -p "Please paste the https clone .git link for the target repo to watch: " REPO
echo $REPO > $REPO_SYNC_HOME/REPO
# Install packages
apt-get install openssh-server fail2ban rsync git -y
systemctl enable sshd
# Setup SSH Keys
mkdir -p $REPO_SYNC_DIR/.ssh
su - repoGrabbers -c "(echo ''; echo ''; echo '') | ssh-keygen -t rsa -f id_rsa"
mv $REPO_SYNC_DIR/id_rsa $REPO_SYNC_DIR/.ssh
mv $REPO_SYNC_DIR/id_rsa.pub $REPO_SYNC_DIR/.ssh/authorized_keys
read -p "Press [Enter] key to view the private key. COPY THE UPCOMING INTO YOUR APPLICATION..."
cat $REPO_SYNC_DIR/.ssh/id_rsa
read -p "Press [Enter] when done viewing..."
clear
$(exit)
mv $REPO_SYNC_DIR/.ssh/id_rsa /root/repoGrabbers_id_rsa
# Install Cron
echo "*/5 * * * * repoSync /home/repoSync/change-detect.sh >/dev/null 2>&1" >> /etc/crontab
# Required Lockdown
mv change-detect.sh $REPO_SYNC_HOME/
chmod 500 $REPO_SYNC_HOME/change-detect.sh
chown repoSync:repoSync $REPO_SYNC_HOME/change-detect.sh
chmod 444 $REPO_SYNC_HOME/REPO
echo -e "\n #### INSTALLATION COMPLETE ####\n"
echo -e "It is recommended to lockdown this server if in a production environment.\nBelow are the recommended lockdown settings:"
echo -e " SSH Server:\n   1) Disable Root Login\n   2) Set Strict Login Parameters/Timeouts\n   3) Set ONLY public key authentication\n   4) Change port to 1338\n Users:\n   1) Lockdown Home Directories\n   2) Restrict File Permissions\n"
echo -e "\nONLY RUN AUTO-LOCKDOWN IF YOU HAVE PHYSICAL ACCESS TO THE SERVER AND/OR ACKNOWLEDGE ALL OF THESE CHANGES\n"
read -p "Would you like to auto lockdown the server? [Y/N]: " lockdown
LOCKDOWN="$(echo ${lockdown^^})"
if [[ "${LOCKDOWN::1}" == "Y" ]];
then
    echo -e "\nLocking Down Box"
    ./lockdown.sh
fi
echo -e "\n[+]repoSync setup has completed.\n"