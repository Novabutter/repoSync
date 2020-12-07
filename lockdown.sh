#!/bin/bash
#===========================================================================#
# Script: lockdown.sh                                                       #
# Purpose: Lockdown the files and configs associated with Remote Repo Sync  #
# Dependencies: install.sh has initiated on the system                      #
# Note: LOCKDOWN IS INCOMPLETE                                              #
#===========================================================================#
# Set global variables
REPO_GRABBERS_AUTH_KEY="/home/repoGrabbers/.ssh/authorized_keys"
#=============================================
# Function: SSHlockdown
# Purpose: Lockdown SSH config
# Input: None
# Output: None
#==============================================
SSHlockdown() {
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
    sed -i 's/#Port 22/Port 1338/g' /etc/ssh/sshd_config # No reason. It's just not 22, and not 1337
    sed -i 's/#LoginGraceTime 2m/LoginGraceTime 5m/g' /etc/ssh/sshd_config
    sed -i 's/#StrictModes yes/StrictModes yes/g' /etc/ssh/sshd_config
    sed -i 's/#MaxAuthTries 6/MaxAuthTries 6/g' /etc/ssh/sshd_config
    sed -i 's/#MaxSessions 10/MaxSessions 10/g' /etc/ssh/sshd_config
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    sed -i 's/#PermitEmptyPasswords no/PermitEmptyPasswords no/g' /etc/ssh/sshd_config
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config
    AUTH_SWAP=$(cat /home/repoGrabbers/.ssh/authorized_keys)
    echo "no-agent-forwarding,no-port-forwarding,no-pty,no-user-rc,no-X11-forwarding $AUTH_SWAP" > $REPO_GRABBERS_AUTH_KEY
    systemctl reload sshd
}
#=============================================
# Function: userFileLockdown
# Purpose: Lockdown all user accounts on server and repoSync-related files.
# Input: None
# Output: None
#==============================================
userFileLockdown() {
    chown root:root /home/repoGrabbers/.bash_logout
    chown root:root /home/repoGrabbers/.bashrc
    chown root:root /home/repoGrabbers/.profile
    chown root:root /home/repoGrabbers/.ssh
    chown repoSync:repoGrabbers /home/repoGrabbers/repos
    chmod 644 /home/repoGrabbers/.bash_logout
    chmod 644 /home/repoGrabbers/.bashrc
    chmod 644 /home/repoGrabbers/.profile
    chmod 655 /home/repoGrabbers/.ssh
    chmod 750 /home/repoGrabbers/repos
    chattr +i /home/repoSync/change-detect.sh
    passwd -l repoGrabbers >/dev/null 2>&1
    passwd -l repoSync >/dev/null 2>&1
}
#=============================================
# MAIN SCRIPT
#==============================================
SSHlockdown
if [ $? -eq 0 ];
then
    userFileLockdown
    if [ $? -eq 0 ];
    then
        echo -e "\n [+] Lockdown Complete!"
    else
        echo -e "\n [-] User & User File Lockdown Failed!\n"
    fi
else
    echo -e "\n [-] SSH Lockdown Failed!\n"
fi
