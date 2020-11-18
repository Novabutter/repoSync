#/bin/bash
#===========================================================================#
# Script: change-detect.sh                                                  #
# Purpose: Detect when changes have been made to target remote repository   #
# Dependencies: install.sh has initiated on the system                      #
#===========================================================================#
REPODUMBY="https://github.com/Novabutter/junk-repo"
#REPO=$(cat REPO)
REPO_COMMIT="${REPODUMBY}.git"
#=============================================
# Function: firstTimeSetup
# Purpose: Detect if hashfile has been made to reference against
# Input: None
# Output: None
#==============================================
firstTimeSetup () {
    if [[ $(test -f /tmp/commitHash) -ne 0 ]];
    then
        echo "DEBUG: File already exists. Skipping setup..."
    else
        touch /tmp/commitHash
        chmod 600 /tmp/commitHash
    fi
}
#=============================================
# Function: grabLatestCommit
# Purpose: Detect if hashfile has been made to reference against
# Input: None
# Output: None
#==============================================
grabLatestCommit() {
    if [[ "$(ps -eaf | grep rsync | grep -v grep | wc -l)" == "0" ]];
    then
        if [[ -d /tmp/repos ]];
        then
            rm -rf /tmp/repos
        fi
        # Add logic here for error handling
        mv repos /tmp/
        git clone "$REPO_COMMIT" repos/ # DISABLE ONCE DONE DEBUGGING
        #git clone -q '$REPO_COMMIT' repos/
    else
        echo "DEBUG: End User Currently Downloading Update! Cannot Unpack! Waiting until next check time."
        # You should really see if you can get it to send a re-sync to the applicaiton
        exit
    fi
}
firstTimeSetup
while true;
do
    commitHash=$(git ls-remote ${REPODUMBY}.git HEAD | awk '{ print $1 }')
    if [[ "$commitHash" != "$(cat /tmp/commitHash)" ]];
    then
        echo "DEBUG: Commit to remote repo has been made!"
        grabLatestCommit
        echo $commitHash > /tmp/commitHash
    else
        echo "DEBUG: Latest commit remains unchanged."
    fi
    sleep 20
    #sleep 300 # Wait 5 minutes. This is temporary until cron is in place to do the work, in which case you should also get rid of the while loop.
done