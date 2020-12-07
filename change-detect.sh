#!/bin/bash
#===========================================================================#
# Script: change-detect.sh                                                  #
# Purpose: Detect when changes have been made to target remote repository   #
# Dependencies: install.sh has initiated on the system                      #
#===========================================================================#
# Set global variables
REPO_SYNC_DIR=/home/repoGrabbers
REPO_SYNC_HOME=/home/repoSync
REPO_COMMIT="$(cat ${REPO_SYNC_HOME}/REPO)"
#=============================================
# Function: firstTimeSetup
# Purpose: Detect if hashfile has been made to reference against
# Input: None
# Output: None
#==============================================
firstTimeSetup () {
    test -f /tmp/commitHash
    if [ $? -eq 0 ];
    then
        echo "DEBUG: File already exists. Skipping setup..."
    else
        touch /tmp/commitHash
        chmod 700 /tmp/commitHash
        git -C $REPO_SYNC_DIR/repos clone "$REPO_COMMIT" $REPO_SYNC_DIR/repos
        git -C $REPO_SYNC_DIR/repos remote add upstream $REPO_COMMIT
    fi
}
#=============================================
# Function: grabLatestCommit
# Purpose: Detect if hashfile has been made to reference against
# Input: None
# Output: None
#==============================================
grabLatestCommit() {
    if [ $(ps -eaf | grep rsync | grep -v grep | wc -l) -eq 0 ];
    then
        git -C ${REPO_SYNC_DIR}/repos pull upstream master 
    else
        echo "DEBUG: End User Currently Downloading Update! Cannot Unpack! Waiting until next check time."
        # You should really see if you can get it to send a re-sync to the applicaiton
        exit
    fi
}
#=============================================
# MAIN SCRIPT
#=============================================
firstTimeSetup
    commitHash=$(git ls-remote ${REPO_COMMIT} HEAD | awk '{ print $1 }')
    # echo "DEBUG: GIT WEBPAGE HASH: ${commitHash}"
    # echo "DEBUG: commitHash file: $(cat /tmp/commitHash)"
    if [ "${commitHash}" != "$(cat /tmp/commitHash)" ];
    then
        # echo "DEBUG: Commit to remote repo has been made!"
        grabLatestCommit
        echo ${commitHash} > /tmp/commitHash
    # else
    #      echo "DEBUG: Latest commit remains unchanged."
    fi