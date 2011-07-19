##
#   Copyright 2009 Joe Block <jpb@ApesSeekingKnowledge.net>
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
#  Example:  A dynamic installer for Facter
#
#  Author:  Allister Banks
#  Created: 7/19/2011
#  Last Modified: 7/19/2011
#
#  Description:  This Makefile will download the version of Facter specified
#    in the PACKAGE_VERSION variable from the Puppet Labs website, untar it,
#    and then install the source files into the Mac-specific locations.  
#    The MAJOR and MINOR versions must be specified for the Info.plist file
#    that Packagemaker requires, but we use awk on the PACKAGE_VERSION to 
#    get these.  See inline comments.
#

include /usr/local/share/luggage/luggage.make

TITLE=Facter_Installer
REVERSE_DOMAIN=com.puppetlabs
PAYLOAD=\
		unpack-facter-${FACTERFILE} \
		pack-usr-bin-facter \
		pack-usr-sharedoc-facter \
		pack-usr-rubylib-facter \
		pack-facter-preflight

# Variable Declarations:  Any version can be chosen from the command line when running
#    for example:  "make pkg PACKAGE_VERSION=2.7.1"
PACKAGE_VERSION=1.6.0
PACKAGE_MAJOR_VERSION=`echo ${PACKAGE_VERSION} | awk -F '.' '{print $$1}'`
PACKAGE_MINOR_VERSION=`echo ${PACKAGE_VERSION} | awk -F '.' '{print $$2$$3}'`
FACTERFILE=facter-${PACKAGE_VERSION}
FACTERURL=http://downloads.puppetlabs.com/facter/${FACTERFILE}.tar.gz

# The unpack-facter rule will pull the version of the Facter source specified
#    by PACKAGE_VERSION into the directory where the Makefile is located. From
#    there we untar it to a directory named puppet-(PACKAGE_VERSION)
unpack-facter-${FACTERFILE}:
	curl ${FACTERURL} -o ${FACTERFILE}.tar.gz
	@sudo ${TAR} xzf ${FACTERFILE}.tar.gz

# This rule copies the Facter executable
pack-usr-bin-facter: l_usr_bin
	@sudo ${CP} ./${FACTERFILE}/bin/facter ${WORK_D}/usr/bin/
	@sudo chown  root:wheel ${WORK_D}/usr/bin/facter
	@sudo chmod 755 ${WORK_D}/usr/bin/facter

l_usr_share_doc: l_usr_share
	@sudo mkdir -p ${WORK_D}/usr/share/doc
	@sudo chown -R root:wheel ${WORK_D}/usr/share/doc
	@sudo chmod -R 755 ${WORK_D}/usr/share/doc

prep-usr-sharedoc-facter: l_usr_share_doc
	@sudo mkdir -p ${WORK_D}/usr/share/doc/facter
	@sudo chown -R root:wheel ${WORK_D}/usr/share/doc/facter
	@sudo chmod -R 755 ${WORK_D}/usr/share/doc/facter

# This rule copies the Facter changelog and legalese
pack-usr-sharedoc-facter: prep-usr-sharedoc-facter
	@sudo ${CP} -R ./${FACTERFILE}/CHANGELOG* ${WORK_D}/usr/share/doc/facter
	@sudo ${CP} -R ./${FACTERFILE}/LICENSE ${WORK_D}/usr/share/doc/facter
	@sudo chown -R root:wheel ${WORK_D}/usr/share/doc/facter/
	@sudo chmod -R 644 ${WORK_D}/usr/share/doc/facter

# This rule ditto's (recursively copies) the Facter library files into place and sets
# 	permissions/ownership accordingly. We choose /Library/Ruby/Site as the base path to workaround a longstanding
#	symlink bug on OSX, so that using the resulting package can also work when installed into a 
# 	never-booted image(e.g. prepared with System Image Utility or InstaDMG). 
# 	
# If you need 10.4(Tiger) support, please comment-out this one stanza and uncomment the two after it
pack-usr-rubylib-facter: l_Library_Ruby_Site_1_8
	@sudo ${DITTO} ./${FACTERFILE}/lib/ ${WORK_D}/Library/Ruby/Site/1.8/
	@sudo chown -R root:wheel ${WORK_D}/Library/Ruby/Site/1.8/
	@sudo chmod -R 644 ${WORK_D}/Library/Ruby/Site/1.8/
	@sudo find ${WORK_D}/Library/Ruby/Site/1.8/facter -type d -exec chmod 755 {} \;

# l_usr_lib_ruby_site_ruby_1_8: l_usr
# 	@sudo mkdir -p ${WORK_D}/usr/lib/ruby/site_ruby/1.8
# 	@sudo chown -R root:wheel ${WORK_D}/usr/lib/ruby/site_ruby/1.8
# 	@sudo chmod -R 755 ${WORK_D}/usr/lib/ruby/site_ruby/1.8
#
# pack-usr-rubylib-facter: l_usr_lib_ruby_site_ruby_1_8
# 	@sudo ${DITTO} ./${FACTERFILE}/lib/ ${WORK_D}/usr/lib/ruby/site_ruby/1.8/
# 	@sudo chown -R root:admin ${WORK_D}/usr/lib/ruby/site_ruby/1.8/
# 	@sudo chmod -R 644 ${WORK_D}/usr/lib/ruby/site_ruby/1.8/
# 	@sudo chmod -R 755 ${WORK_D}/usr/lib/ruby/site_ruby/1.8/
# 	@sudo find ${WORK_D}/usr/lib/ruby/site_ruby/1.8/facter -type d -exec chmod 755 {} \;

# This rule sets up the preflight script from the Puppet source's /conf/osx
#    directory and installs it into our scripts directory. From there, we
#    use sed to strip out variables used in the /conf/osx/createpackage.sh
#    script that are unused here.
pack-facter-preflight:
	@sudo ${INSTALL} -m 755 ./${FACTERFILE}/conf/osx/preflight ${SCRIPT_D}
	sed -i '' "s#{SITELIBDIR}#/usr/lib/ruby/site_ruby/1.8#g" "${SCRIPT_D}/preflight"
