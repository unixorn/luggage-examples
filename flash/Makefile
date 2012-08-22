#
#   Copyright 2011 Joe Block <jpb@ooyala.com>
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# Adobe's installer team has pooched the Flash Player installer again.
# This will snapshot (last tested 2012-08-22) the flash player on your
# machine and put it in a sane pkg.dmg you can use with puppet, munki or
# InstaDMG.

include /usr/local/share/luggage/luggage.make

TITLE=repack_flash
REVERSE_DOMAIN=net.apesseekingknowledge.fubar
PAYLOAD=clone_flash_player

clone_flash_player: flash_player_snapshot.tar.bz2
	sudo ${TAR} xvf flash_player_snapshot.tar.bz2 -C ${WORK_D}

# If we don't have a tarball already, clone the install on the system
# we're running on.

flash_player_snapshot.tar.bz2: capture_flash_player
	./capture_flash_player

# prep dirs
plugin_dir: l_Library
	@sudo mkdir -p ${WORK_D}/Library/Internet\ Plug-Ins

prep_flash_dirs: l_Library_Application_Support plugin_dir l_Library_PreferencePanes

# use pkgbuild instead of packagemaker since dev box is on 10.8
compile_package: payload modify_packageroot
	@-sudo rm -fr ${PAYLOAD_D}/${PACKAGE_FILE}
	@echo "Creating ${PAYLOAD_D}/${PACKAGE_FILE} with pkgbuild"
	@sudo pkgbuild --root ${WORK_D} \
		--identifier ${PACKAGE_ID} \
		--ownership preserve \
		--version ${PACKAGE_VERSION} \
		--scripts ${SCRIPT_D} \
		${PAYLOAD_D}/${PACKAGE_FILE}

