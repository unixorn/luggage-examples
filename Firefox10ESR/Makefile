include /usr/local/share/luggage/luggage.make

TITLE=FirefoxESR
REVERSE_DOMAIN=com.company
PACKAGE_VERSION=10.0.3
PAYLOAD=\
		pack-firefox\

FirefoxURL="http://download.mozilla.org/?product=firefox-10.0.3esr&os=osx&lang=en-US"
CCKName="{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"

prepare-firefox: l_Applications 
	@sudo curl -L ${FirefoxURL} -o "Firefox-10.0.3esr.dmg"
	@sudo hdiutil attach ./Firefox-10.0.3esr.dmg -mountpoint /Volumes/FirefoxLuggage -nobrowse -noautoopen
	@sudo ${CP} -a "/Volumes/FirefoxLuggage/Firefox.app" ${WORK_D}/Applications/Firefox.app 
	@sudo hdiutil detach /Volumes/FirefoxLuggage

pack-firefox: prepare-firefox
	@sudo mkdir -p ${WORK_D}/Applications/Firefox.app/Contents/MacOS/distribution/bundles/
	@sudo ditto ./${CCKName} ${WORK_D}/Applications/Firefox.app/Contents/MacOS/distribution/bundles/${CCKName}
	@sudo chown -R root:admin ${WORK_D}/Applications
	@sudo chmod -R 644 ${WORK_D}/Applications/Firefox.app/Contents/MacOS/distribution/bundles/${CCKName}
