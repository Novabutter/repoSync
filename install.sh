#!/bin/bash
#===============================================#
# Script: install.sh                            #
# Purpose: Initially install Remote Repo Sync   #
# Dependencies: None                            #
#===============================================#
# Set global variables
REPO_SYNC_HOME=/home/repoSync
REPO_SYNC_DIR=/home/repoGrabbers

# Check to verify user is root
if [[ "$(whoami)" != "root" ]];
then
    echo -e "[-] Error! Run install.sh as root!"
    exit
fi

# Make other scripts in current dir executable
chmod 700 change-detect.sh
chmod 700 lockdown.sh

# Create two users (one to SSH to, one to sync the repo)
useradd -m repoGrabbers
useradd -m repoSync

# Test for previous installation & create required directories
if [[ -d $REPO_SYNC_DIR/repos ]];
then
    echo -e "\n [-] Error! Either installation already exists or unknown error occured - Failed.\n"
    exit
else
    echo "Intializing first time setup"
    mkdir -p $REPO_SYNC_DIR/repos
    mkdir -p /tmp/setupRepoTest
    mkdir -p $REPO_SYNC_DIR/.ssh
fi

# Prompt User Questions
while (true);
do
    read -p "Please paste the https clone .git link for the target repo to watch: " REPO
    git clone -q "$REPO" /tmp/setupRepoTest
    if [ $? -eq 0 ];
    then
        rm -rf /tmp/setupRepoTest
        echo $REPO > $REPO_SYNC_HOME/REPO
        break
    else
        echo -e "\n [-] Error! Unable to git clone. Use the git clone http URL (http:// ... .git).\n"
    fi
done

# Install packages
apt-get install openssh-server fail2ban rsync git -y
systemctl enable sshd

# Setup SSH Keys
su - repoGrabbers -c "(echo ''; echo ''; echo '') | ssh-keygen -t rsa -f id_rsa"
mv $REPO_SYNC_DIR/id_rsa $REPO_SYNC_DIR/.ssh
mv $REPO_SYNC_DIR/id_rsa.pub $REPO_SYNC_DIR/.ssh/authorized_keys
read -p "Press [Enter] key to view the private key. COPY THE UPCOMING INTO YOUR APPLICATION..."
cat $REPO_SYNC_DIR/.ssh/id_rsa
read -p "Press [Enter] when done viewing..."
clear
#$(exit)

# Install Cronjob
echo "*/5 * * * * repoSync /home/repoSync/change-detect.sh >/dev/null 2>&1" >> /etc/crontab

# Required Lockdown
mv change-detect.sh $REPO_SYNC_HOME/
chmod 500 $REPO_SYNC_HOME/change-detect.sh
chown repoSync:repoSync $REPO_SYNC_HOME/change-detect.sh
mv $REPO_SYNC_DIR/.ssh/id_rsa /root/repoGrabbers_id_rsa
chmod 444 $REPO_SYNC_HOME/REPO

# Server Lockdown Prompt
echo -e "\n #### INSTALLATION COMPLETE ####\n"
echo -e "\n [!] AUTO LOCKDOWN SCRIPT IS INCOMPLETE. LOCKDOWN THE SERVER FURTHER IF EXECUTED\n"
echo -e "It is recommended to lockdown this server if in a production environment.\nBelow are the recommended lockdown settings:"
echo -e " SSH Server:\n   1) Disable Root Login\n   2) Set Strict Login Parameters/Timeouts\n   3) Set ONLY public key authentication\n   4) Change port to 1338\n Users:\n   1) Lockdown Home Directories\n   2) Restrict File Permissions\n"
echo -e "\nONLY RUN AUTO-LOCKDOWN IF YOU HAVE PHYSICAL ACCESS TO THE SERVER AND/OR ACKNOWLEDGE ALL OF THESE CHANGES\n"
read -p "Would you like to auto lockdown the server? [Y/N]: " lockdown
LOCKDOWN="$(echo ${lockdown^^})"
if [[ "${LOCKDOWN::1}" == "Y" ]];
then
    echo -e "\n [+] Locking Down Box..."
    ./lockdown.sh
fi
echo -e "\n [+] repoSync setup has completed.\n"