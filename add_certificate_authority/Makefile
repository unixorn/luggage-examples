##
#   Copyright 2017 @packetpilot <point.it@howiget.email>
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
#  Example:  A payload-free CA installer for the system keychain
#
#  Author:  @packetpilot
#  Created: 2017-09-19
#  Last Modified: 2017-09-19
#
#  Description: add a CA to your System.keychain (for all users) and trust it in
#  all contexts. This has been verified to work as expected on 10.12 and 10.13.
#

include /usr/local/share/luggage/luggage.make

TITLE=add_certificate_authority
REVERSE_DOMAIN=com.example.corp
PAYLOAD=\
	pack-script-postinstall
