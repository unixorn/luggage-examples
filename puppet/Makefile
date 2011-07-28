#
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
#  Example:  A dynamic installer for Puppet
#
#  Original Author:  Gary Larizza
#  Revised by:		 Allister Banks
#  Created: 12/17/2010
#  Last Modified: 7/19/2011
#
#  Description:  This Makefile will download the version of Puppet specified
#    in the PACKAGE_VERSION variable from the Puppet Labs website, untar it,
#    and then install the source files into the Mac-specific locations.  
#    The MAJOR and MINOR versions must be specified for the Info.plist file
#    that Packagemaker requires, but we use awk on the PACKAGE_VERSION to 
#    get these.  See inline comments.
#

include /usr/local/share/luggage/luggage.make

TITLE=Puppet_Installer
REVERSE_DOMAIN=com.puppetlabs
PAYLOAD=\
		unpack-puppet-${PUPPETFILE} \
		pack-etc-puppet \
		pack-usr-bin-puppet \
		pack-usr-sbin-puppet \
		pack-usr-sharedoc-puppet \
		pack-usr-share-puppet-men \
		pack-usr-rubylib-puppet \
		pack-puppet-preflight

# Variable Declarations:  Any version can be chosen from the command line when running
#    for example:  "make pkg PACKAGE_VERSION=2.7.1"
PACKAGE_VERSION=2.6.9
PACKAGE_MAJOR_VERSION=`echo ${PACKAGE_VERSION} | awk -F '.' '{print $$1}'`
PACKAGE_MINOR_VERSION=`echo ${PACKAGE_VERSION} | awk -F '.' '{print $$2$$3}'`
PUPPETFILE=puppet-${PACKAGE_VERSION}
PUPPETURL=http://downloads.puppetlabs.com/puppet/${PUPPETFILE}.tar.gz

# The unpack-puppet rule will pull the version of the Puppet source specified
#    by PACKAGE_VERSION into the directory where the Makefile is located. From
#    there we untar it to a directory named puppet-(PACKAGE_VERSION)
unpack-puppet-${PUPPETFILE}:
	curl ${PUPPETURL} -o ${PUPPETFILE}.tar.gz
	@sudo ${TAR} xzf ${PUPPETFILE}.tar.gz

# This rule will copy a default auth.conf to the /etc/puppet directory
pack-etc-puppet: l_etc_puppet
	@sudo ${CP} ./${PUPPETFILE}/conf/auth.conf ${WORK_D}/private/etc/puppet/auth.conf
	@sudo chown root:wheel ${WORK_D}/private/etc/puppet/auth.conf
	@sudo chmod 644 ${WORK_D}/private/etc/puppet/auth.conf

# This rule ditto's (recursively copies) the Puppet executables
pack-usr-bin-puppet: l_usr_bin	
	@sudo ${DITTO} ./${PUPPETFILE}/bin/ ${WORK_D}/usr/bin/
	@sudo chown -R root:wheel ${WORK_D}/usr/bin/
	@sudo chmod -R 755 ${WORK_D}/usr/bin/

# This rule ditto's the Puppet daemon processes
pack-usr-sbin-puppet: l_usr_sbin	
	@sudo ${DITTO} ./${PUPPETFILE}/sbin/ ${WORK_D}/usr/sbin/
	@sudo chown -R root:wheel ${WORK_D}/usr/sbin/
	@sudo chmod -R 755 ${WORK_D}/usr/sbin

l_usr_share_doc: l_usr_share
	@sudo mkdir -p ${WORK_D}/usr/share/doc
	@sudo chown -R root:wheel ${WORK_D}/usr/share/doc
	@sudo chmod -R 755 ${WORK_D}/usr/share/doc

prep-usr-sharedoc-puppet: l_usr_share_doc
	@sudo mkdir -p ${WORK_D}/usr/share/doc/puppet
	@sudo chown -R root:wheel ${WORK_D}/usr/share/doc/puppet
	@sudo chmod -R 755 ${WORK_D}/usr/share/doc/puppet

# This rule copies the Puppet readme's and legalese, with a conditional for future versions
pack-usr-sharedoc-puppet: prep-usr-sharedoc-puppet
	@sudo ${CP} -R ./${PUPPETFILE}/CHANGELOG* ${WORK_D}/usr/share/doc/puppet
	@if [ -e ${PUPPETFILE}/COPYING ] ; then \
		sudo ${CP} -R ./${PUPPETFILE}/COPYING ${WORK_D}/usr/share/doc/puppet; \
		sudo ${CP} -R ./${PUPPETFILE}/LICENSE ${WORK_D}/usr/share/doc/puppet; \
		sudo ${CP} -R ./${PUPPETFILE}/README* ${WORK_D}/usr/share/doc/puppet; \
	fi
	@sudo chown -R root:wheel ${WORK_D}/usr/share/doc/puppet/
	@sudo chmod -R 644 ${WORK_D}/usr/share/doc/puppet

# This rule copies/ditto's the Puppet man pages
pack-usr-share-puppet-men: l_usr_man_man5 l_usr_man_man8
	@sudo ${CP} ./${PUPPETFILE}/man/man5/puppet.conf.5 ${WORK_D}/usr/share/man/man5/
	@sudo ${DITTO} ./${PUPPETFILE}/man/man8/ ${WORK_D}/usr/share/man/man8/
	@sudo chown -R root:wheel ${WORK_D}/usr/share/man/man5/ ${WORK_D}/usr/share/man/man8/
	@sudo chmod -R 644 ${WORK_D}/usr/share/man/man5/puppet.conf.5 ${WORK_D}/usr/share/man/man8/

prep-usr-sharedoc-puppet: l_usr_share_doc
	@sudo mkdir -p ${WORK_D}/usr/share/doc/puppet
	@sudo chown -R root:wheel ${WORK_D}/usr/share/doc/puppet
	@sudo chmod -R 755 ${WORK_D}/usr/share/doc/puppet

# This rules ditto's the Puppet library files into place and sets ownership and permissions 
# 	accordingly. We choose /Library/Ruby/Site as the base path to workaround a longstanding
#	symlink bug on OSX, so that using the resulting package can also work when installed into a 
# 	never-booted image(e.g. prepared with System Image Utility or InstaDMG). 
# 	
# If you need 10.4(Tiger) support, please comment-out this one stanza and uncomment the two after it
pack-usr-rubylib-puppet: l_Library_Ruby_Site_1_8
	@sudo ${DITTO} ./${PUPPETFILE}/lib/ ${WORK_D}/Library/Ruby/Site/1.8/
	@sudo chown -R root:wheel ${WORK_D}/Library/Ruby/Site/1.8/
	@sudo chmod -R 644 ${WORK_D}/Library/Ruby/Site/1.8/
	@sudo find ${WORK_D}/Library/Ruby/Site/1.8/puppet -type d -exec chmod 755 {} \;

# l_usr_lib_ruby_site_ruby_1_8: l_usr
# 	@sudo mkdir -p ${WORK_D}/usr/lib/ruby/site_ruby/1.8
# 	@sudo chown -R root:wheel ${WORK_D}/usr/lib/ruby/site_ruby/1.8
# 	@sudo chmod -R 755 ${WORK_D}/usr/lib/ruby/site_ruby/1.8
# 
# pack-usr-rubylib-puppet: l_usr_lib_ruby_site_ruby_1_8
# 	@sudo ${DITTO} ./${PUPPETFILE}/lib/ ${WORK_D}/usr/lib/ruby/site_ruby/1.8/
# 	@sudo chown -R root:wheel ${WORK_D}/usr/lib/ruby/site_ruby/1.8/
# 	@sudo chmod -R 644 ${WORK_D}/usr/lib/ruby/site_ruby/1.8/
# 	@sudo find ${WORK_D}/usr/lib/ruby/site_ruby/1.8/puppet -type d -exec chmod 755 {} \;

# This rule sets up the preflight script from the Puppet source's /conf/osx
#    directory and installs it into our scripts directory. From there, we
#    use sed to strip out variables used in the /conf/osx/createpackage.sh
#    script that are unused here.
pack-puppet-preflight:
	@sudo ${INSTALL} -m 755 ./${PUPPETFILE}/conf/osx/preflight ${SCRIPT_D}
	sed -i '' "s#{SITELIBDIR}#/usr/lib/ruby/site_ruby/1.8#g" "${SCRIPT_D}/preflight"
	sed -i '' "s#{BINDIR}#/usr/bin#g" "${SCRIPT_D}/preflight"

