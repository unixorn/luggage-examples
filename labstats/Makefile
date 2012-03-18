include /usr/local/share/luggage/luggage.make

TITLE=LabStats
REVERSE_DOMAIN=com.computerlabsolutions
PACKAGE_VERSION=5.0.11012.15
PAYLOAD=\
		pack-labstats\
		pack-script-preinstall\
		pack-script-postflight\

LABSTATS_PACKAGE_NAME="LabStats 5 Client.pkg"

prepare-files: l_Applications l_Library_Application_Support 
	# Created necessary directories and copies the files into them
	@sudo mkdir -p ${WORK_D}/Applications/LabStats
	@sudo mkdir -p "${WORK_D}/Library/Application Support/LabStats"
	@sudo ${CP} -R ./${LABSTATS_PACKAGE_NAME}/Contents/Executable/ ${WORK_D}/Applications/LabStats/
	@sudo ${CP} -R ./${LABSTATS_PACKAGE_NAME}/Contents/Bundles/ ${WORK_D}/Applications/LabStats/

pack-labstats: prepare-files l_Library_LaunchDaemons l_Library_LaunchAgents 
	# Fix permissions on the installed files
	@sudo chmod -R 755 ${WORK_D}/Applications/LabStats
	@sudo chmod +x ${WORK_D}/Applications/LabStats/updater.sh
	@sudo chmod -R +x ${WORK_D}/Applications/LabStats/LabStatsUserSpace.app
	
	# Installs LaunchDaemon and applies proper permissions
	@sudo ${CP} "./"${LABSTATS_PACKAGE_NAME}"/Contents/Launch Daemon/LabStats.plist" ${WORK_D}/Library/LaunchDaemons
	@sudo chmod 755 ${WORK_D}/Library/LaunchDaemons/LabStats.plist 
	
	# Installs LaunchAgent and applies proper Permissions
	@sudo ${CP} "./"${LABSTATS_PACKAGE_NAME}"/Contents/Launch Agent/LabStats.plist" ${WORK_D}/Library/LaunchAgents
	@sudo chmod 755 ${WORK_D}/Library/LaunchAgents/LabStats.plist
	
	# Installs host.txt config file and corrects permissions on Application Support folder
	@sudo ${CP} "./"${LABSTATS_PACKAGE_NAME}"/host.txt" "${WORK_D}/Library/Application Support/Labstats"
	@sudo chmod -R 644 "${WORK_D}/Library/Application Support/LabStats"
	@sudo chmod 755 "${WORK_D}/Library/Application Support/LabStats"
