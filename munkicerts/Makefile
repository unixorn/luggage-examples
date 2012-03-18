include /usr/local/share/luggage/luggage.make

TITLE=MunkiCerts
REVERSE_DOMAIN=com.company
PACKAGE_VERSION=1.0.0
PAYLOAD=pack-munki-certs


pack-munki-certs: l_private_etc
	@sudo ${CP} -R ./munki ${WORK_D}/private/etc
	@sudo chmod -R 0700 ${WORK_D}/private/etc/munki
	@sudo chmod 0600 ${WORK_D}/private/etc/munki/certs/munkiclients.pem
	@sudo chown -R root:wheel ${WORK_D}/private/etc/munki/certs/munkiclients.pem
