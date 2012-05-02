include /usr/local/share/luggage/luggage.make
TITLE=configBasicsPrepLadmin
REVERSE_DOMAIN=com.afp548.instaDMGd-LadminPrefs.pkg
PAYLOAD=prep-var-db-AppleSetupDone \
prep-Library-SetupRegComplete \
pack-usr-local-sbin-networkCheckers.py \
pack-Library-LaunchDaemons-com.afp548.instaDMGd.plist \
pack-Library-LaunchAgents-com.afp548.networkUp.plist \
pack-usr-local-sbin-firstBootPost-Imaging.sh

# apply Lion-specific perms fix:

modify_packageroot:
	@sudo chgrp wheel ${WORK_D}/Library
	@sudo chmod 755 ${WORK_D}/Library

prep-var-db-AppleSetupDone: l_var_db
	@sudo touch ${WORK_D}/var/db/.AppleSetupDone
	@sudo chown root:wheel ${WORK_D}/var/db/.AppleSetupDone
	@sudo chmod 600 ${WORK_D}/var/db/.AppleSetupDone

prep-Library-SetupRegComplete: l_Library_Receipts
	@sudo touch ${WORK_D}/Library/Receipts/.SetupRegComplete
    @sudo chown root:admin ${WORK_D}/Library/Receipts/.SetupRegComplete
	@sudo chmod 400 ${WORK_D}/Library/Receipts/.SetupRegComplete