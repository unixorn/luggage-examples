#!/bin/bash
#
# (C) Henri Shustak 2011
#
# Released under the GNU GPL v3 or later
#
# About this script : 
#    Will download latest Mac OS X version of FireFox
#    Updates default so that the Mac OS X system proxy is used.
#    Builds package installer package for this modified version of FireFox
#    It is easy to alter the 
#
# Requirements : 
#    - luggage
#    - wget
#    - curl (no longer used)
#    - internet access for your system(s)
#
#
# Notes : 
#    If you use this script behind a proxy ensure that you have exported your proxy 
#    settings to the shell which runs this script. If it is not working behind a proxy
#    then try on an internet connection without a proxy. Any suggestions on improving
#    proxy support are welcome. Export example which should work is listed below : 
#    
#      - export http_proxy="http://proxy:port"
#      - export https_proxy="http://proxy:port"
#    
#    Example usage for this script : /path/to/this/script.bash com.yourdomain
#
# Script version :
#    1.0 : Initial release (basic implementation)
#    1.1 : Added some additional checks, options and assistance relating to wget and make (developer tools).
#    1.2 : Added some ownership changes to the installed application (now admin has write access).
#    1.3 : Now downloads the very latest version available from MacUpdate.
#    1.4 : Fixed bug with regards checking for make being installed on the system.
#    1.5 : Using wget to download app2luggage.rb rather than curl.
#    1.6 : Added option to use an existing copy of FireFox.app (just modify and build package).
#    1.7 : Added a check for trollop. Minor changes to default settings within script.
#    1.8 : Added a check for enviroment varible settings which may have been exported.


# - - - - - - - - - - - - - - - - 
# script settings
# - - - -- - - - - - - - - - - - -

# package ID for output package (no spaces)
if [ "${build_package_id}" == "" ] ; then
    build_package_id="Firefox_defaults_to_system_proxy"
fi

# overwrite old copy of firefox? ("YES"/"NO")
if [ "${overwirte_old_copy}" != "YES" ] && [ "${overwirte_old_copy}" != "NO" ] ; then
    overwirte_old_copy="YES"
fi

# remove firefox app and build directory when finished? ("YES"/"NO")
if [ "${clean_up_build_directory_and_firefox_app}" != "YES" ] && [ "${clean_up_build_directory_and_firefox_app}" != "NO" ] ; then
    clean_up_build_directory_and_firefox_app="YES"
fi

# build a package and put it into a dmg
if [ "${proceed_with_building_pacakge}" != "YES" ] && [ "${proceed_with_building_pacakge}" != "NO" ] ; then
    proceed_with_building_pacakge="YES"
fi

# download latest version? ("YES"/"NO) - if set to "NO" then an older version will be downloaded.
if [ "${download_latest_firefox_version}" != "YES" ] && [ "${download_latest_firefox_version}" != "NO" ] ; then
    download_latest_firefox_version="YES"
fi

# use existing copy of FireFox within this directory ("YES"/"NO") - if enabled no new version will be downloaded
if [ "${use_exisitng_copy_of_firefox}" != "YES" ] && [ "${use_exisitng_copy_of_firefox}" != "NO" ] ; then
    use_exisitng_copy_of_firefox="NO"
fi


# - - - - - - - - - - - - - - - - 
# calculate some variables and add clean up function
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

# check for invalid option combinations
if [ "${proceed_with_building_pacakge}" == "NO" ] && [ "${use_exisitng_copy_of_firefox}" == "YES" ]; then
    echo "Invalid option combination. If proceed_with_building_package is disabled and "
    echo "use_existing_copy_of_firefox is enabled then nothing will be done."
    export exit_value=-1
    clean_exit
fi

# move to this scripts parents directory
cd "${parent_folder}"
if [ $? != 0 ] ; then
    echo "Unable to locate the directory where this script is installed."
    echo "Please check the script is in a accessible directory and then try"
    echo "running this script again."
    export exit_value=-1
    clean_exit
fi

# check for old version of application
if [ "${use_exisitng_copy_of_firefox}" != "YES" ] ; then
    if [ -e ./Firefox.app ] && [ "${overwirte_old_copy}" == "NO" ] ; then
        echo "Will not overwrite copy of Firefox which has already been downloaded."
        echo "Please remove the copy of Firefox within this directory and try running"
        echo "this script again."
        export exit_value=-1
        clean_exit
    fi
else
    if ! [ -e ./Firefox.app ] ; then 
        echo "Unable to locate a copy of Firefox.app which has already been downloaded."
        echo "Either place a copy of Firefox.app into same directory as this script or"
        echo "disable the option \"use_exisitng_copy_of_firefox\" within this script.s"
        export exit_value=-1
        clean_exit
    fi
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
if [ "${current_user}" != "root" ] && [ "${proceed_with_building_pacakge}" == "YES" ] ; then
    echo "Luggage requires superuser privileges to build the package."
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

# check that trollop is installed if building a package is enabled.
if [ "${proceed_with_building_pacakge}" == "YES" ] ; then
    if ! [ `gem list --local | grep "trollop" | wc -l | awk '{print $1}'` -ge 1 ] ; then
	 echo "The ruby gem called \"trollop\" is required for building packages."
         echo "In order to install the trollop gem on your system please issue the command :"
	 echo ""
	 echo "  $ gem install trollop"
	 echo ""
	 echo "Then try running this script again."
	 export exit_value=-1
    	 clean_exit
    fi
fi


# check that wget is installed on this system
which wget > /dev/null
if [ $? != 0 ] ; then
    echo "This script requires that you have wget installed on your system."
    echo "Just a couple of possible options are listed below : "
    echo ""
	echo "     (1) Download and install the package from the following URL :"
	echo "         http://www.merenbach.com/software/wget"
	echo ""
	echo "     (2) Download and install Macports :"
	echo "         http://www.macports.org/"
	echo "         To install wget then issue the following commands :"
	echo ""
	echo "              $ sudo sudo port selfupdate"
	echo "              $ sudo port install wget"
	echo ""
	echo "Once wget is installed and in your path 'echo \$PATH', then try"
	echo "running this script again."
    export exit_value=-1
    clean_exit
fi

# check that make is installed on this system
which make > /dev/null
if [ $? != 0 ] && [ "${proceed_with_building_pacakge}" == "YES" ] ; then
    echo "This script requires that you have make installed on your system."
    echo "Just a couple of possible options for installation are listed below : "
    echo ""
    echo "     (1) Download and install the developer tools package from Apple (recommended) :"
    echo "         http://developer.apple.com/"
    echo ""
    echo "     (2) Download and install fink (intel binary install only for Mac OS X 10.5) :"
    echo "         http://finkproject.org/"
    echo ""
    echo "         To install make then issue the following command :"
    echo ""
    echo "              $ sudo fink -b install make"
    echo ""
    echo "If you only require the output of the application and not installer package then,"
    echo "disable the build process within this script configuration settings."
    echo ""
    echo "Once the developer tools are installed and that make is within"
    echo "your path 'echo \$PATH', then try running this script again."
    export exit_value=-1
    clean_exit
fi


# - - - - - - - - - - - - - - - - 
# get latest copy of app2luggage
# - - - -- - - - - - - - - - - - -

# donwload a copy of app2luggage with --remove-exisiting-version feature
if ! [ -f ./app2luggage.rb ] ; then
    download_status="SUCCESS"
    echo "Attempting to download app2luggage...."
    # older version using : https://raw.github.com/henri/luggage/master/app2luggage.rb -o ./app2luggage.rb 2> /dev/null
    # would be a good idea to add the cert for github.com and then use the argument --certificate=file
    wget --quiet --no-check-certificate --output-document=./app2luggage.rb https://raw.github.com/henri/luggage/master/app2luggage.rb
    if [ $? != 0 ] ; then
        download_status="FAIL"
    else
        # check the download - very basic check - no checksum performed in this version of the script.
        first_line_of_download=`head -n 1 ./app2luggage.rb`
        if [ "${first_line_of_download}" != "#!/usr/bin/ruby" ] ; then
            download_status="FAIL"
            rm ./app2luggage.rb
        fi
    fi
    # report on the success or failure of the download
    if [ "${download_status}" == "SUCCESS" ] ; then
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



if [ "${use_exisitng_copy_of_firefox}" == "YES" ] ; then
    echo "Using existing copy of FireFox (new copy will not be downloaded)."
else
    
    # - - - - - - - - - - - - - - - - 
    # get latest copy of FireFox.app  
    # - - - -- - - - - - - - - - - - -
    
    # Download the latest version of firefox
    echo "Attempting to download latest OS X version of FireFox...."
    start_link="http://www.macupdate.com"
    mid_link="/app/mac/10700/firefox"

    # pick a version to download
    if [ "${download_latest_firefox_version}" == "YES" ] ; then 
        # picks the latest including beta releases using the head command.
        end_link=`curl ${start_link}${mid_link} 2> /dev/null |  grep 'id="downloadlink' | head -n 1 | awk -F 'href="' '{print $2}' | awk -F '"' '{print $1}'`
    else
        # this simply picks the last available download link rather than first by using tail rather than head.
        end_link=`curl ${start_link}${mid_link} 2> /dev/null |  grep 'id="downloadlink' | tail -n 1 | awk -F 'href="' '{print $2}' | awk -F '"' '{print $1}'`
    fi

    download_link="${start_link}${end_link}"
    echo "    Download Link : $download_link"
    user_agent="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9b5) Gecko/2008032619 Firefox/3.0b5 "
    output_document_path=/tmp/Firefox_`date "+%Y-%m-%d_%H-%M-%S"`.dmg
    wget --user-agent="${user_agent}" --output-document="${output_document_path}" ${download_link} 


    ## --progress=dot 
    ## 2>&1 | sed s'/^/    /'

    # check the download completed successfully
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

    # copy out fire fox from the DMG
    cp -r "${image_mount_point}/Firefox.app" ./Firefox.app
    if [ $? != 0 ] ; then
        echo "Error coping Firefox from the DMG to this directory."
        export exit_value=-1
        clean_exit
    fi

    # it may be good idea to alter the permissions this will need to be sorted.

    # unmount the DMG
    hdiutil detach "${image_mount_point}" -quiet
    if [ $? != 0 ] ; then
        echo "Error un-mounting the Firefox from the DMG."
        export exit_value=-1
        clean_exit
    fi

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

# If we have been instructed to build the package.
if [ "${proceed_with_building_pacakge}" == "YES" ] ; then

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
    
	# build it with app2luggage
	full_path_to_firefox="`pwd`/Firefox.app"
	./app2luggage.rb --application="${full_path_to_firefox}" --package-id="${build_package_id}" --reverse-domain=${1}  --remove-exisiting-version
	if [ $? != 0 ] ; then
		echo "Error during building of the package. You may need to install some gems?"
		export exit_value=-1
		clean_exit
	fi

	# move the built dmg into this directory (just change the output name / destination if required - also possibly remove the -i flag)
	# mv ./${build_package_id}/${build_package_id}-`date "+%Y%m%d"`.dmg ./${build_package_id}-`date "+%Y-%m-%d_%H-%M-%S"`.dmg
	mv -i ./${build_package_id}/${build_package_id}-`date "+%Y%m%d"`.dmg ./
	if [ $? != 0 ] ; then
		# if we were unable to move the .dmg out of the build directory then
		# disable clean up of the build directory and do not remove Firefox either.
		clean_up_build_directory_and_firefox_app="NO"
	fi
	
fi

# clean up the mess
export exit_value=0
clean_exit


