#!/bin/bash

# This is an example script to build the latest version of Google Chrome.
# Before running this script read the note below and make changes
# to suite your build requirements.

# You will want to change reverse domain name (provided as an argument to the script).
# In addition, if you are behind a proxy, you will want to uncomment those lines
# and make changes which are relivent for yor systems network and proxy server.

# Uncomment to set environment variables (to override script defaults).
# export build_package_id="GoogleChrome"
# export overwirte_old_copy="YES"
# export clean_up_build_directory_and_chrome_app="YES"
# export proceed_with_building_pacakge="YES"

# If you are behind the proxy then issue the following commands : 
# export http_proxy="http://user:pass@proxy:3128"
# export https_proxy="http://user:pass@proxy:3128"

# change directory
cd "`dirname \"$0\"`"

# Run the command below (from within this directory) to build Google Chrome :
./build_latest_google_chrome.bash com.example

build_result=${?}
if [ ${build_result} != 0 ] ; then
	if [ ${build_result} != 1 ] ; then
		echo "Google Chrome Build Failed."
		echo "Please examine the output make changes and then try again."
        exit -1
	fi
    # Continue with upload to server even if there are no updates downloaded.
    # Add an exit here should you wish to stop uploading even in the event of
    # no updates being available. Note, that if you add an exit at this point
    # and a future build fails to upload then it may take a while for that
    # upload to take place.
fi


# Add on any post actions you would like to take place once your 
# build of Google Chrome has completed successfully.

# Example (1) : If you would like to use rsync to copy the latest build to remote server.
#               Please note that if you uncomment the command (two lines) a password may be required. 
#               Should you uncommon, then ensure you test the script works prior automating.
#               Also, prior to automating this script think about the security implications.
# Modify the following lines appropriately and then modify and uncomment the following command : 
# rsync `ls -rt ./ | grep .dmg | tail -n 1` \
# user@server:"/Path\ to/GoogleChrome-Dir/GoogleChrome-`ls -rt ./ | grep .dmg | tail -n 1 | awk -F "-" '{print $2}'`"


