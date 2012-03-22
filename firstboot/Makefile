include /usr/local/share/luggage/luggage.make
TITLE=configBasicsPrepLadmin
REVERSE_DOMAIN=com.318.instaDMGd-LadminPrefs.pkg
PAYLOAD=pack-usr-local-sbin-networkCheckers.py \
pack-Library-LaunchDaemons-com.afp548.instaDMGd.plist \
pack-Library-LaunchAgents-com.afp548.networkUp.plist \
pack-usr-local-sbin-firstBootPost-Imaging.sh

# apply Lion-specific perms fix:

modify_packageroot:
	@sudo chgrp wheel ${WORK_D}/Library
	@sudo chmod 755 ${WORK_D}/Library