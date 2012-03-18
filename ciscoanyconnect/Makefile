include /usr/local/share/luggage/luggage.make

TITLE=CiscoAnyConnect
REVERSE_DOMAIN=com.company
PACKAGE_VERSION=2.5.3055
PAYLOAD=\
		prepare-files\
		pack-script-preflight\
		pack-script-postflight\

copy-files: 
	# Tar up .app files because Make doesn't like bundles or folders
	@sudo mkdir -p ./temp/extracted
	@sudo mkdir -p ./temp/prepared
	@sudo ${DITTO} ./vpn.pkg/Contents/Resources/vpn.pax.gz ./temp
	@sudo gunzip -f ./temp/vpn.pax.gz
	@sudo ${DITTO} -x ./temp/vpn.pax ${WORK_D}/
	@sudo ${DITTO} ./vpn.pkg/Contents/Resources/postflight ./
	@sudo ${DITTO} ./vpn.pkg/Contents/Resources/preflight ./
	@sudo rm -r ./temp/*

prepare-files: copy-files l_Applications l_Library_LaunchAgents l_Library_LaunchDaemons l_System_Library_Extensions
	#Prepates all the destination directories.  You may try to fix the permissions that Cisco uses here if desired.
