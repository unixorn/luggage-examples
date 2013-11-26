#!/bin/bash

# This is an example script to build the latest version of FireFox.
# In before running this script read the note below and make changes
# to suite your build requirements.

# You will want to change reverse domain name (provided as an argument to the script).
# In addition, if you are behind a proxy, you will want to uncomment those lines
# and make changes which are relivent for yor systems network and proxy server.

# Uncomment to set enviroment varibles (to override script defaults).
# export build_package_id="Firefox_defaults_to_system_proxy"
# export overwirte_old_copy="YES"
# export clean_up_build_directory_and_firefox_app="YES"
# export proceed_with_building_pacakge="YES"

# If you are behind the proxy then issue the following commands : 
# export http_proxy="http://user:pass@proxy:3128"
# export https_proxy="http://user:pass@proxy:3128"

# Network priority return information (stores the current network priority so it may be restored when the script is finished)
current_network_prioroty=`networksetup -listnetworkserviceorder | head -n 2 | tail -n 1 | awk -F ")" '{print $2}' | cut -c 2-`
clean_network_name="Ethernet"

# exit staus 
exit_status=0

# network related functions
function return_to_previous_network_service_order_priority {
	 echo /usr/sbin/networksetup -ordernetworkservices \"${current_network_prioroty}\" `/usr/sbin/networksetup -listallnetworkservices | grep -v 'An asterisk ' | sed s/^'*'// | grep -xv "${current_network_prioroty}" | sed 's/.*/"&"/' | tr '\n' ' '| sed 's/.$//' | sed 's/"/\\"/g'` | bash
	 echo "Network Priority : `networksetup -listnetworkserviceorder | head -n 2 | tail -n 1 | awk -F ")" '{print $2}' | cut -c 2-`"
}
function swith_to_clean_network_service_order_priority {
	 echo /usr/sbin/networksetup -ordernetworkservices \"${clean_network_name}\" `/usr/sbin/networksetup -listallnetworkservices | grep -v 'An asterisk ' | sed s/^'*'// | grep -xv "${clean_network_name}" | sed 's/.*/"&"/' | tr '\n' ' '| sed 's/.$//' | sed 's/"/\\"/g'` | bash
	 echo "Network Priority : `networksetup -listnetworkserviceorder | head -n 2 | tail -n 1 | awk -F ")" '{print $2}' | cut -c 2-`"
}

# exit functions
function clean_exit {
	# uncomment the following to return the network priority to the state it was in before this script was run
	# return_to_previous_network_service_order_priority
	exit $exit_status
}

# change directory
cd "`dirname \"$0\"`"

# uncomment the following in order to prioritize a clean network prior to building
# swith_to_clean_network_service_order_priority

# Run the command below (from within this directory) to build FireFox :
./build_latest_firefox_with_default_system_proxy.bash com.example

build_result=${?}
if [ ${build_result} != 0 ] ; then
	if [ ${build_result} != 1 ] ; then
		echo "FireFox Build Failed."
		echo "Please examine the output make changes and then try again."
        exit_status=-1
		clean_exit
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
#               Should you uncommon, then ensure you test the script works prior automating.
#               Also, prior to automating this script think about the security implications.
# Modify the following lines appropriately and then modify and uncomment the following command : 
# rsync `ls -rt ./ | grep .dmg | tail -n 1` \
# user@server:"/Path\ to/FireFox-Dir/FireFox-`ls -rt ./ | grep .dmg | tail -n 1 | awk -F "-" '{print $2}'`"

clean_exit
