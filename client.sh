#!/bin/bash
#===========================================================================#
# Script: client.sh                                                         #
# Purpose: Test script just to simulate a client download                   #
# Dependencies: repoSync installed & ssh key is known                       #
#===========================================================================#
rsync -ar --exclude '.git' --delete-delay --progress -v -e "ssh -i .ssh/id_rsa" repoGrabbers@192.168.1.13:repos/ repos/
