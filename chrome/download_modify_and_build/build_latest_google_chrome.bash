#!/bin/bash
#
# (C) Henri Shustak 2013
#
# Released under the GNU GPL v3 or later
#
# About this script : 
#    Will download latest Mac OS X version of Google Chrome
#    Updates default so that the Mac OS X system proxy is used.
#    Builds package installer package for this modified version of Chrome
#    Modify this script to alter other various other settings.
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
#    1.1 : Initial release (basic implementation)

# - - - - - - - - - - - - - - - - 
# script settings
# - - - -- - - - - - - - - - - - -

# package ID for output package (no spaces)
if [ "${build_package_id}" == "" ] ; then
    build_package_id="Google_Chrome"
fi

# overwrite old copy of Chrome? ("YES"/"NO")
if [ "${overwirte_old_copy}" != "YES" ] && [ "${overwirte_old_copy}" != "NO" ] ; then
    overwirte_old_copy="YES"
fi

# remove Chrome app and build directory when finished? ("YES"/"NO")
if [ "${clean_up_build_directory_and_chrome_app}" != "YES" ] && [ "${clean_up_build_directory_and_chrome_app}" != "NO" ] ; then
    clean_up_build_directory_and_chrome_app="YES"
fi

# build a package and put it into a dmg
if [ "${proceed_with_building_pacakge}" != "YES" ] && [ "${proceed_with_building_pacakge}" != "NO" ] ; then
    proceed_with_building_pacakge="YES"
fi

# download latest version? ("YES"/"NO) - if set to "NO" then an older version will be downloaded.
if [ "${download_latest_chrome_version}" != "YES" ] && [ "${download_latest_chrome_version}" != "NO" ] ; then
    download_latest_chrome_version="YES"
fi

# download and build same copy again? ("YES"/"NO")
if [ "${download_and_build_same_copy_again}" != "YES" ] && [ "${download_and_build_same_copy_again}" != "NO" ] ; then
    download_and_build_same_copy_again="NO"
fi


# use existing copy of Google Chrome within this directory ("YES"/"NO") - if enabled no new version will be downloaded
if [ "${use_exisitng_copy_of_chrome}" != "YES" ] && [ "${use_exisitng_copy_of_chrome}" != "NO" ] ; then
    use_exisitng_copy_of_chrome="NO"
fi

# Configure the install package to install even if there is an existing copy of Google Chrome on the destination system ("YES"/"NO")
if  [ "${package_install_will_overwrite_existing_copy}" != "YES" ]  && [ "${package_install_will_overwrite_existing_copy}" != "NO" ] ; then
	package_install_will_overwrite_existing_copy="YES"
fi

# Keep record of version which was last built ("YES"/"NO")
if  [ "${keep_version_build_file_record}" != "YES" ] && [ "${keep_version_build_file_record}" != "NO" ] ; then
	keep_version_build_file_record="YES"
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
    if [ -d ./${build_package_id} ] &&  [ "${clean_up_build_directory_and_chrome_app}" == "YES" ] ; then 
            rm -R ./${build_package_id}
    fi
    # remove the Google Chrome application?
    if [ -d "./Google Chrome.app" ] &&  [ "${clean_up_build_directory_and_chrome_app}" == "YES" ] ; then 
            rm -R "./Google Chrome.app"
    fi
    # remove the Google Chrome current version build txt file(s)
    rm -f "${current_version_build_file}"
    # remove the Google Chome download
    rm -f "${output_document_path}"
    exit $exit_value
}


# - - - - - - - - - - - - - - - - 
# perform some checks 
# - - - -- - - - - - - - - - - - -

if [ "${1}" == "" ] ; then 
    echo "Usage : /path_to_this_script/ reverse_domain"
    echo "        eg. : ./build_latest_google_chrome.bash com.domain"
    exit -1
fi

# check for invalid option combinations
if [ "${proceed_with_building_pacakge}" == "NO" ] && [ "${use_exisitng_copy_of_chrome}" == "YES" ]; then
    echo "Invalid option combination. If proceed_with_building_package is disabled and "
    echo "use_exisitng_copy_of_chrome is enabled then nothing will be done."
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
if [ "${use_exisitng_copy_of_chrome}" != "YES" ] ; then
    if [ -e "./Google Chrome.app" ] && [ "${overwirte_old_copy}" == "NO" ] ; then
        echo "Will not overwrite copy of Chrome which has already been downloaded."
        echo "Please remove the copy of Chrome within this directory and try running"
        echo "this script again."
        export exit_value=-1
        clean_exit
    fi
else
    if ! [ -e "./Google Chrome.app" ] ; then 
        echo "Unable to locate a copy of \"Google Chrome.app\" which has already been downloaded."
        echo "Either place a copy of \"Google Chrome.app\" into same directory as this script or"
        echo "disable the option \"use_exisitng_copy_of_chrome\" within this script."
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
	echo "Just one possible options is listed below : "
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


# version file storage varibles (file to store build version)
lastest_version_build_file="${parent_folder}/latest_build_version.txt"
current_version_build_file="${parent_folder}/current_build_version.txt"
last_version_built=`cat "${lastest_version_build_file}" 2> /dev/null`
if [ $? != 0 ] ; then
    echo "WARNING! : Unable to determine last built version of Chrome."
    echo "           Could be the first time you are building the Chrome package."
    last_version_built="?.?.?"
fi



if [ "${use_exisitng_copy_of_chrome}" == "YES" ] ; then
    echo "Using existing copy of Chrome (new copy will not be downloaded)."
else
    
    
    # - - - - - - - - - - - - - - - - 
    # get latest copy of "Google Chome.app"
    # - - - -- - - - - - - - - - - - -
    
    # Download the latest version of Google Chrome
    echo "Attempting to check for latest version of Google Chrome...."
    start_link="http://www.macupdate.com"
    mid_link="/app/mac/32956/google-chrome"
    
    # pick a version to download
    if [ "${download_latest_chrome_version}" == "YES" ] ; then 
        # picks the latest including beta releases using the head command.
        end_link=`curl ${start_link}${mid_link} 2> /dev/null |  grep 'id="downloadlink' | head -n 1 | awk -F 'href="' '{print $2}' | awk -F '"' '{print $1}'`
    fi

    download_link="${start_link}${end_link}"
    user_agent="Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.4; en-US; rv:1.9b5) Gecko/2008032619 Firefox/3.0b5 "
    output_document_path=/tmp/Google-Chrome_`date "+%Y-%m-%d_%H-%M-%S"`.dmg
    latest_availible_version=`(wget http://macupdate.com/app/mac/32956/google-chrome -O - 2>/dev/null | cat | grep 'id="appversinfo">' | awk -F 'id="appversinfo">' '{print $2}' | awk -F '</span></div>' '{print $1}' ; exit \`echo $PIPESTATUS | awk '{ print $1 }'\` )`

    if [ ${?} != 0 ] || [ "${latest_availible_version}" == "" ] ; then
	echo "Unable to determine latest version of Google Chrome available on servers."
	export exit_value=-2
        clean_exit
     fi

    echo "    Last successful built version : $last_version_built"
    echo "    Latest available version      : $latest_availible_version"

	# Should we download and build the latest and greatest availible verions from the remote servers?
	if [ "$download_and_build_same_copy_again" == "NO" ] ; then 
		if [ "${latest_availible_version}" == "${last_version_built}" ] ; then
			echo "No updates available. Remote server has the same version as was previously built."
			export exit_value=-255
	        clean_exit
		fi
	fi

    echo "Attempting to download latest OS X version of Google Chrome...."
    echo "    Download Link : $download_link"
    wget --no-check-certificate --user-agent="${user_agent}" --output-document="${output_document_path}" ${download_link} 

    ## --progress=dot 
    ## 2>&1 | sed s'/^/    /'

    # check the download completed successfully
    if [ $? != 0 ] ; then
        echo "Download of Google Chrome failed. Please try to download manually."
        export exit_value=-1
        clean_exit
    fi

    # mount the DMG and copy into this directory
    export image_mount_point=`mktemp -d /tmp/latest_google-chrome_mount_point.XXXXX`
    hdiutil attach "${output_document_path}" -quiet -nobrowse -mountpoint "${image_mount_point}/"
    if [ $? != 0 ] ; then
        echo "Unable to mount the Google Chrome DMG which was downloaded."
        echo "Please try running this script again."
        export exit_value=-1
        clean_exit
    fi

    # remove old version if we got this far.
    if [ -e "./Google Chrome.app" ] ; then
        rm -R "./Google Chrome.app"
        if [ $? != 0 ] ; then
            echo "Unable to remove the copy of Google Chrome in this directory."
            echo "Please manually remove and then try again."
            export exit_value=-1
            clean_exit
        fi
    fi

    # copy out Google Chrome from the DMG
    cp -r "${image_mount_point}/Google Chrome.app" "./Google Chrome.app"
    if [ $? != 0 ] ; then
        echo "Error coping Google Chrome from the DMG to this directory."
        export exit_value=-1
        clean_exit
    fi

    # it may be good idea to alter the permissions this will need to be sorted.

    # unmount the DMG
    hdiutil detach "${image_mount_point}" -quiet
    if [ $? != 0 ] ; then
        echo "Error un-mounting the Google Chome DMG."
        export exit_value=-1
        clean_exit
    fi

fi


# Check the version of Google Chrome for which we will be building a package.
if ! [ -f "./Google Chrome.app/Contents/Info.plist" ] ; then
    echo "Error unable to locate the Info.plist file for determining version of Google Chrome."
    export exit_value=-1
    clean_exit
else
	build_chrome_version=`cat "./Google Chrome.app/Contents/Info.plist" | grep -A 1 "<key>CFBundleShortVersionString</key>" | tail -n 1 | awk -F "<string>" '{print $2}' | awk -F "</string>" '{print $1}'`	
	if [ "${keep_version_build_file_record}" == "YES" ] ; then
		echo ${build_chrome_version} > "${current_version_build_file}"
	fi
fi



# - - - - - - - - - - - - - - - - 
# make alteration to "Google Chome.app"
# - - - -- - - - - - - - - - - - -

# Not doing anything in this example. But you could :)

# Check that the file we are will write to exits

# ......add your code here to make modifications........



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
	full_path_to_chrome="`pwd`/Google Chrome.app"
	additional_build_options=""
	if [ "${package_install_will_overwrite_existing_copy}" == "YES" ] ; then
		# run app2luggage with the --remove-existing-version option
		./app2luggage.rb --application="${full_path_to_chrome}" --package-id="${build_package_id}" --reverse-domain=${1}  --remove-exisiting-version
		if [ $? != 0 ] ; then
			echo "Error during building of the package. You may need to install some gems?"
			export exit_value=-1
			clean_exit
		fi
	else
		# run app2luggage with the no-overwrite option
		./app2luggage.rb --application="${full_path_to_chrome}" --package-id="${build_package_id}" --reverse-domain=${1}  --no-overwrite
		if [ $? != 0 ] ; then
			echo "Error during building of the package. You may need to install some gems?"
			export exit_value=-1
			clean_exit
		fi
	fi

	# move the built dmg into this directory (just change the output name / destination if required - also possibly remove the -i flag)
	# mv ./${build_package_id}/${build_package_id}-`date "+%Y%m%d"`.dmg ./${build_package_id}-`date "+%Y-%m-%d_%H-%M-%S"`.dmg
	mv -i ./${build_package_id}/${build_package_id}-`date "+%Y%m%d"`.dmg ./
	if [ $? != 0 ] ; then
		# if we were unable to move the .dmg out of the build directory then
		# disable clean up of the build directory and do not remove Firefox either.
		clean_up_build_directory_and_chrome_app="NO"
	else
		# Update the buiild file version
		if [ "${keep_version_build_file_record}" == "YES" ] ; then
			mv "${current_version_build_file}" "${lastest_version_build_file}"
		else
			rm -f "${lastest_version_build_file}"
		fi
	fi
	
fi

# clean up the mess
export exit_value=0
clean_exit



