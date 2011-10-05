#!/bin/bash

# This is an example script to build the latest version of FireFox.
# In before running this script read the note below and make changes
# to suite your build requirements.

# You will want to change reverse domain name. In addition, if you are
# behind a proxy, you will want to uncomment those lines and complete the
# details for your proxy server.

# If you are behind the proxy then issue the following commands : 
# export http_proxy="http://user:pass@proxy:3128"
# export https_proxy="http://user:pass@proxy:3128"

# change directory
cd "`dirname \"$0\"`"

# Run the command below (from within this directory) to build FireFox :
./build_latest_firefox_with_default_system_proxy.bash com.example

if [ ${?} != 0 ] ; then
	echo "FireFox Build Failed."
	echo "Please examine the output make changes and then try again."
	exit -1
fi

# Add on any post actions you would like to take place once your 
# build of FireFox has completed successfully.

# Example (1) : If you would like to use rsync to copy the latest build to remote server.
#               Please note that if you uncomment the command (two lines) a password may be required. 
#               Should you uncommon, then ensure you test the script works prior automating.
#               Also, prior to automating this script think about the security implications.
# Modify the following lines appropriately and then modify and uncomment the following command : 
# rsync `ls -rt ./ | grep .dmg | tail -n 1` \
# user@server:"/Path\ to/FireFox-Dir/FireFox-`ls -rt ./ | grep .dmg | tail -n 1 | awk -F "-" '{print $2}'`"


