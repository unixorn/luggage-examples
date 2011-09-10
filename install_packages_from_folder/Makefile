#
#   Copyright 2011 Henri Shustak
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
# Example showing how you may use the luggage to create a package which
# will attempt installation of multiple packages from the additional_packages
# directory.

include /usr/local/share/luggage/luggage.make

TITLE=install_packages_from_directory
REVERSE_DOMAIN=com.example.corp

PAYLOAD=\
	pack-script-postflight \
	pack-ipff-additional-packages \
	pack-ipff-helper-pacakges
	
pack-ipff-additional-packages:
	@sudo cp -r  ./additional_packages ${SCRIPT_D}/

pack-ipff-helper-pacakges:
	@sudo cp -r  ./helper_packages ${SCRIPT_D}/

