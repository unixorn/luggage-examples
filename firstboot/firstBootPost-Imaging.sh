#!/bin/sh

#Debug - show that we've run, log the particulars
DEBUG_LOG="/var/log/FirstBootSettings.log"
TIME_STAMP=`date +%m%d%y-%H%M%S`
/bin/echo "Firstboot ran at ${TIME_STAMP}" >> $DEBUG_LOG

# Define variables for path to executables 
SYSTEMSETUP="/usr/sbin/systemsetup"
SCUTIL="$1/usr/sbin/scutil"
NETSET="$1/usr/sbin/networksetup"
DISKUTIL="$1/usr/sbin/diskutil"
LAUNCHCTL="$1/bin/launchctl"
# Hard-coded local admin, change if applicable
LADMIN=`dscl . search /Users UniqueID 501 | awk '{print $1}' | sed -n '1p'`

# determine the disk size
MYDISK=`df -H | awk '{print $2}' | sed -n '2p'`
# Set the name for the boot volume accordingly
$DISKUTIL renameVolume / "Mac"$MYDISK"B"
/bin/echo "We've renamed the boot HD to Mac${MYDISK}B" >> $DEBUG_LOG

# set time zone to NYC, use network time w/ apple's server, and allow dvd region to be set once 
$SYSTEMSETUP -settimezone America/New_York
$SYSTEMSETUP -setusingnetworktime on
$SYSTEMSETUP -setnetworktimeserver time.apple.com
/usr/libexec/PlistBuddy -c "Set :rights:system.device.dvd.setregion.initial:class allow" /etc/authorization

# set bonjour, host and sharing names based on patch level and en0 (ethernet) mac address
LAST6_ENETADDY=`ifconfig en0 | grep ether | awk '{print $2}' | sed 's/://g' | cut -c 7-12 | tr [:lower:] [:upper:]`
PATCHLVL=`/usr/bin/defaults read "/System/Library/CoreServices/SystemVersion" ProductVersion | sed 's/[.]/-/g'`
$SCUTIL --set LocalHostName "Imaged-$PATCHLVL-$LAST6_ENETADDY"
$SCUTIL --set ComputerName "Imaged-$PATCHLVL-$LAST6_ENETADDY"
$SCUTIL --set HostName "Imaged-$PATCHLVL-$LAST6_ENETADDY"
RENAMED=`$SCUTIL --get HostName`
/bin/echo "We've set time zone to NYC, NTP points at Apple, DVD region is allowed to be set, and the computer name was ${RENAMED}" >> $DEBUG_LOG

# turn ipv6 off for both Ethernet and Airport - if MacPro, service names are different(since that is required form of option for -setipv6off flag)
$NETSET -setv6off Ethernet
$NETSET -setv6off Ethernet\ 1
$NETSET -setv6off Ethernet\ 2
$NETSET -setv6off Airport
$NETSET -setv6off WiFi

# ensure AirPort is turned off - if this is a MacBookAir or (non-CTO) MacPro, this will have no effect, since its specifying 'hardware port' or BSD device (not service name) en1
$NETSET -setairportpower en1 off

# make FireWire networking inactive
$NETSET -setnetworkserviceenabled FireWire off
/bin/echo "We've turned IPv6 off on all standard interfaces, airport off for non-MBAirs, and FireWire networking off" >> $DEBUG_LOG

## Want ARD kickstarted properly?
# KICKSTRT="/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart"
# $KICKSTRT -configure -allowAccessFor -specifiedUsers
# sleep 1
# $KICKSTRT -activate -configure -users $LADMIN -privs -all -access -on -restart -agent

## If you'd like localMCX as well, uncomment the following:

# dscl /Local/MCX create /Users/mcxadmin
# dscl /Local/MCX create /Users/mcxadmin realname "MCX Admin"
# dscl /Local/MCX create /Users/mcxadmin gid 80 # only group necessary is admin, instead of default 'staff'
# dscl /Local/MCX create /Users/mcxadmin UniqueID 444
# dscl /Local/MCX create /Users/mcxadmin home /tmp
# dscl /Local/MCX merge /Users/mcxadmin authentication_authority ";ShadowHash;"
# dscl /Local/MCX create /Users/mcxadmin passwd "*"
# dscl /Local/MCX create /Users/mcxadmin shell "/dev/null"

## And finaly, ssh on:

# wipe the disabled launchd key in the ssh.plist on the target to allow launchctl to load it
# /usr/libexec/PlistBuddy -c "Delete Disabled" "/System/Library/LaunchDaemons/ssh.plist"
# # make the ssh group
# dscl . create /Groups/com.apple.access_ssh || exit 1
# dscl . create /Groups/com.apple.access_ssh realname "Remote Login ACL"
# dscl . create /Groups/com.apple.access_ssh gid 404
# # add our user to the ssh group
# dscl . -merge /Groups/com.apple.access_ssh GroupMembership $LADMIN
# 
# launchctl load /System/Library/LaunchDaemons/ssh.plist

# Wipe feet
/bin/rm -f /Library/LaunchDaemons/com.afp548.instaDMGd.plist
/bin/rm -f /Library/LaunchAgents/com.afp548.networkUp.plist
rm $0