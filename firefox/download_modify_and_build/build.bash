#!/bin/bash

# This is an example script to build the latest version of FireFox.
# Before running this script read the note(s) below and make approriate
# changes to suite your build, network and post action requirements.

# You will want to change reverse domain name (provided as an argument to the script).
# In addition, if you are behind a proxy, you will want to uncomment those lines
# and make changes which are relivent for yor systems network and proxy server.

# Uncomment to set enviroment varibles (to override script defaults).
# export build_package_id="Firefox_defaults_to_system_proxy"
# export overwirte_old_copy="YES"
# export clean_up_build_directory_and_firefox_app="YES"
# export proceed_with_building_pacakge="YES"
# export package_install_will_overwrite_existing_copy="YES"

# If you are behind the proxy then issue the following commands : 
# export http_proxy="http://user:pass@proxy:3128"
# export https_proxy="http://user:pass@proxy:3128"

# change directory
cd "`dirname \"$0\"`"

# Run the command below (from within this directory) to build FireFox :
./build_latest_firefox_with_default_system_proxy.bash com.example

build_result=${?}
if [ ${build_result} != 0 ] ; then
	if [ ${build_result} != 1 ] ; then
		echo "FireFox Build Failed."
		echo "Please examine the output make changes and then try again."
		exit -1
	fi
	# Continue with upload to server even if there are no updates downloaded.
    # Add an exit here should you wish to stop uploading even in the event of
    # no updates being availible. Note, that if you add an exit at this point
    # and a future build fails to upload then it may take a while for that
    # upload to take place.
fi



# Add on any post actions you would like to take place once your 
# build of FireFox has completed successfully.

# Example (1) : If you would like to use rsync to copy the latest build to remote server.
#               Please note that if you uncomment the command (two lines) a password may be required. 
#               Should you uncommnet, then ensure you test the script works prior automating.
#               Also, prior to automating this script think about the security implications.
# Modify the following lines appropriately and then modify and uncomment the following command : 
# echo -n "Upload .dmg to server ? [Y/n] : "
# read result
# if [ "${result}" == "" ] || [ "${result}" == "y" ] || [ "${result}" == "yes" ] || [ "${result}" == "Y" ] || [ "${result}" == "YES" ] ; then
# 	rsync `ls -rt ./ | grep .dmg | tail -n 1` \
# 	user@server:"/Path\ to/FireFox-Dir/FireFox-`ls -rt ./ | grep .dmg | tail -n 1 | awk -F "-" '{print $2}'`"
# fi


