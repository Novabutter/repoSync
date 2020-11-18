#/bin/bash
#===============================================#
# Script: install.sh                            #
# Purpose: Initially install Remote Repo Sync   #
# Dependencies: None                            #
#===============================================#
# Create repouser & Lockdown perms
REPO_SYNC_DIR=/home/$(whoami)/repoSyncWorking
# Create Directory
if [[ -d $REPO_SYNC_DIR ]];
then
    echo "DEBUG: Error! Either installation already exists or unknown error occured."
    exit
else
    echo "DEBUG: Intializing first time setup"
    mkdir -p $REPO_SYNC_DIR/repos
fi
# Setup SSH Keys
# Install Cron
# Ask REPO
read -p "Please paste the repo homepage URL for the target repo to watch: " REPO
echo $REPO > $REPO_SYNC_DIR/REPO

# Lockdown
mv change-detect.sh $REPO_SYNC_DIR/
chmod 600 $REPO_SYNC_DIR/change-detech.sh
chmod 444 $REPO_SYNC_DIR/REPO

echo "DEBUG: INSTALLATION COMPLETE"