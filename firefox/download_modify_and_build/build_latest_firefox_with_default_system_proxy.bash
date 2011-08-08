#!/bin/bash
#
# (C) Henri Shustak 2011
#
# Released under the GNU GPL v3 or later
#
# About this script : 
#    Will download latest Mac OS X version of FireFox (non-beta)
#    Updates default so that the Mac OS X system proxy is used.
#    Builds package installer package for this modified version of FireFox
#    It is easy to alter the 
#
# Requirements : 
#    - luggage
#    - wget
#    - curl
#    - interent access for your system(s)
#
#
# Notes : 
#    If you use this script behind a proxy ensure that you have exported your proxy 
#    settings to the shell which runs this script.
#
#    example usage : /path/to/this/script.bash com.yourdomain
#
# Script version :
#    1.0 : initial release (basic implimentation)

# - - - - - - - - - - - - - - - - 
# script settings
# - - - -- - - - - - - - - - - - -

# pagkge ID for output package (no spaces)
build_package_id="Firefox_defaults_to_system_proxy"

# overwrite old copy of firefox? ("YES"/"NO")
overwirte_old_copy="NO"

# remove firefox app and build direcotry when finished? ("YES"/"NO")
clean_up_build_directory_and_firefox_app="NO"


# - - - - - - - - - - - - - - - - 
# calculate some varibles and add clean up function
# - - - -- - - - - - - - - - - - -

# work out where we are in the file system
path_to_this_script="${0}"
parent_folder="`dirname \"${path_to_this_script}\"`"

# clean up various left overs.
function clean_exit () {
    # unmount image and remove the temporary mount point
    if [ "${image_mount_point}" != "" ] ; then
        hdiutil detach ${image_mount_point} 2> /dev/null
        sleep 5
        rmdir "${image_mount_point}"
    fi
    # remove the package build directory?
    if [ -d ./${build_package_id} ] &&  [ "${clean_up_build_directory_and_firefox_app}" == "YES" ] ; then 
            rm -R ./${build_package_id}
    fi
    # remove the Firefox application?
    if [ -d ./Firefox.app ] &&  [ "${clean_up_build_directory_and_firefox_app}" == "YES" ] ; then 
            rm -R ./Firefox.app
    fi
    # remove the firefox download
    rm -f "${output_document_path}"
    exit $exit_value
}


# - - - - - - - - - - - - - - - - 
# perform some checks 
# - - - -- - - - - - - - - - - - -

if [ "${1}" == "" ] ; then 
    echo "Usage : /path_to_this_script/ reverse_domain"
    echo "        eg. : ./build_latest_firefox_installer com.domain"
    exit -1
fi

# move to this scripts parents directory
cd "${parent_folder}"

# check for old version of application
if [ -e ./Firefox.app ] && [ "${overwirte_old_copy}" == "NO" ] ; then
    echo "Will not overwrite copy of Firefox which has already been downloaded."
    echo "Please remove the copy of Firefox within this directory and try running"
    echo "this script again."
    export exit_value=-1
    clean_exit
fi

# check for old version of app2luggage build output
if [ -d ./${build_package_id} ] && [ "${overwirte_old_copy}" == "NO" ] ; then
    echo "Will not overwrite copy of build output."
    echo "Please remove the build output directory and try running"
    echo "this script again."
    export exit_value=-1
    clean_exit
fi


# check we are running as root
current_user=`whoami`
if [ "${current_user}" != "root" ] ; then
    echo "Luggage requires superuser previlidges to build the package."
    echo "Please run this script as root."
    export exit_value=-1
    clean_exit
fi

# check that luggage (maybe installed) - must be a better approach
if ! [ -d /usr/local/share/luggage ] ; then
    echo "This script requires that you have luggage installed on your system."
    echo "Download luggage from : https://github.com/unixorn/luggage"
    echo "For more information : http://luggage.apesseekingknowledge.net"
    export exit_value=-1
    clean_exit
fi

# - - - - - - - - - - - - - - - - 
# get latest copy of Firefox.app
# - - - -- - - - - - - - - - - - -

# donwload a copy of app2luggae with --remove-exisiting-version feature
if ! [ -f ./app2luggage.rb ] ; then
    download_status="SUCCESS"
    echo "Attempting to download app2luggage...."
    curl https://raw.github.com/henri/luggage/master/app2luggage.rb -o ./app2luggage.rb 2> /dev/null
    if [ $? != 0 ] ; then
        download_status="FAIL"
    fi
    # check the download - very basic check - no checksum performed in this version of the script.
    first_line_of_download=`head -n 1 ./app2luggage.rb`
    if [ "${first_line_of_download}" != "#!/usr/bin/ruby" ] ; then
        download_status="FAIL"
        rm ./app2luggage.rb
    fi
    # report on the success or failure of the download
    if [ download_status="SUCCESS" ] ; then
        echo "Download of app2luggage complete."
        # set the permissions on this download
        chmod 755 ./app2luggage.rb
    else
        echo "Download of app2luggage failed."
        echo "    Automatic download failed. Manually from the following URL"
        echo "    and place into the same directory as this script :"
        echo "    https://raw.github.com/henri/luggage/master/app2luggage.rb"
        export exit_value=-1
        clean_exit
    fi
fi

# Download the latest version of firefox
echo "Attempting to download latest OS X version of FireFox...."
start_link="http://www.macupdate.com"
mid_link="/app/mac/10700/firefox"
end_link=`curl ${start_link}${mid_link} 2> /dev/null |  grep 'id="downloadlink' | tail -n 1 | awk -F 'href="' '{print $2}' | awk -F '"' '{print $1}'`
download_link="${start_link}${end_link}"
echo "    Download Link : $download_link"
user_agent="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9b5) Gecko/2008032619 Firefox/3.0b5 "
output_document_path=/tmp/Firefox_`date "+%Y-%m-%d_%H-%M-%S"`.dmg
wget --user-agent="${user_agent}" --output-document="${output_document_path}" ${download_link} 


## --progress=dot 
## 2>&1 | sed s'/^/    /'


# check the download completed succesfully
if [ $? != 0 ] ; then
    echo "Download of Firefox failed. Please try to download manually."
    export exit_value=-1
    clean_exit
fi

# mount the DMG and copy into this directory
export image_mount_point=`mktemp -d /tmp/latest_firefox_mount_point.XXXXX`
hdiutil attach "${output_document_path}" -quiet -nobrowse -mountpoint "${image_mount_point}/"
if [ $? != 0 ] ; then
    echo "Unable to mount the Firefox DMG which was downloaded."
    echo "Please try running this script again."
    export exit_value=-1
    clean_exit
fi

# remove old version if we got this far.
if [ -e ./Firefox.app ] ; then
    rm -R ./Firefox.app
    if [ $? != 0 ] ; then
        echo "Unable to remove the copy of Firefox in this directory."
        echo "Please manually remove and then try again."
        export exit_value=-1
        clean_exit
    fi
fi


# remove old build directory if we got this far.
if [ -d ./${build_package_id} ] ; then
    rm -R ./${build_package_id}
    if [ $? != 0 ] ; then
        echo "Unable to remove the previous build directory."
        echo "Please manually remove and then try again."
        export exit_value=-1
        clean_exit
    fi
fi

# copy out fire fox from the DMG
cp -r "${image_mount_point}/Firefox.app" ./Firefox.app
if [ $? != 0 ] ; then
    echo "Error coping Firefox from the DMG to this directory."
    export exit_value=-1
    clean_exit
fi

# unmount the DMG
hdiutil detach "${image_mount_point}" -quiet
if [ $? != 0 ] ; then
    echo "Error un-mounting the Firefox from the DMG."
    export exit_value=-1
    clean_exit
fi


# - - - - - - - - - - - - - - - - 
# make alteration to Firefox.app
# - - - -- - - - - - - - - - - - -

# default settings for new user templates so that using the Mac OS X network proxy settings are enabled.

# Check that the file we are will write to exits


if ! [ -f ./Firefox.app/Contents/MacOS/defaults/pref/channel-prefs.js ] ; then
    echo "Error unable to locate the preference file for updates."
    export exit_value=-1
    clean_exit
fi

# set the default proxy to use the system preferences
echo 'pref("network.proxy.type", "5");' >> ./Firefox.app/Contents/MacOS/defaults/pref/channel-prefs.js
if [ $? != 0 ] ; then
    echo "Unable to update the network proxy settings."
    echo "Please try to cary out this modification by hand."
    export exit_value=-1
    clean_exit
fi


# - - - - - - - - - - - - - - - - 
# Build that package
# - - - -- - - - - - - - - - - - -

# build it with app2luggage
full_path_to_firefox="`pwd`/Firefox.app"
./app2luggage.rb --application="${full_path_to_firefox}" --package-id="${build_package_id}" --reverse-domain=${1}  --remove-exisiting-version


# move the built dmg into this direcotry
mv -i ./${build_package_id}/${build_package_id}-`date "+%Y%m%d"`.dmg ./
if [ $? != 0 ] ; then
    # if we were unable to move the .dmg out of the build directory then
    # disable clean up of the build directory and do not remove Firefox either.
    clean_up_build_directory_and_firefox_app="NO"
fi

# clean up the mess
export exit_value=0
clean_exit



