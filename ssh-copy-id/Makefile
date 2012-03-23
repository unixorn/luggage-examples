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
#  Example:  An installer for the ssh-copy-id utility
#
#  Author:  Allister Banks
#  Created: 22 March 2012
#
#  Description:  This Makefile is based on the Facter and Puppet packages,
#    and could be used for any open source packages that follows standards
# 	 for conventional directories to drop files into.
# 	 Based on the homebrew installation process, url here:
# 	 https://github.com/mxcl/homebrew/blob/431dd51070940186c1dd3af3c12ba093f2deab07/Library/Formula/ssh-copy-id.rb

include /usr/local/share/luggage/luggage.make

TITLE=SSH-Copy-ID_Installer
REVERSE_DOMAIN=org.openssh
PAYLOAD=\
		unpack-binary-and-manpage-${UTIL} \
		pack-usr-local-bin-ssh-copy-id \
		pack-lcl-man1-ssh-copy-id.1 \
		flush-source

# Variable Declarations:  Any version can be chosen from the command line when running
#    for example:  "make pkg PACKAGE_VERSION=5.5p1"
PACKAGE_VERSION=5.9p1
UTIL=openssh-${PACKAGE_VERSION}
UTILURL=http://ftp.heanet.ie/pub/OpenBSD/OpenSSH/portable/${UTIL}.tar.gz

# The unpack rule will pull the version of the utility source specified
#    by PACKAGE_VERSION into the directory where the Makefile is located. From
#    there we untar it and pull out the applicable contents
unpack-binary-and-manpage-${UTIL}:
	curl ${UTILURL} -o ${UTIL}.tar.gz
	@sudo ${TAR} xzf ${UTIL}.tar.gz
	mv openssh-${PACKAGE_VERSION}/contrib/ssh-* .
# this may be allowed in the master luggage.make, haven't merged branch as of 23 March 2012
l_usr_lcl_share_man: l_usr_local_share
	@sudo mkdir -p ${WORK_D}/usr/local/share/man
	@sudo chown -R root:wheel ${WORK_D}/usr/local/share/man
	@sudo chmod -R 0755 ${WORK_D}/usr/local/share/man

l_usr_lcl_man1: l_usr_lcl_share_man
	@sudo mkdir -p ${WORK_D}/usr/local/share/man/man1
	@sudo chown -R root:wheel ${WORK_D}/usr/local/share/man/man1
	@sudo chmod -R 0755 ${WORK_D}/usr/local/share/man/man1
# wouldn't have been necessary if the binary/man page don't have hyphens in their name 
pack-usr-local-bin-ssh-copy-id:  l_usr_local_bin
	@sudo ${CP} ./ssh-copy-id ${WORK_D}/usr/local/bin/
	@sudo chown root:wheel ${WORK_D}/usr/local/bin/
	@sudo chmod 755 ${WORK_D}/usr/local/bin

pack-lcl-man1-ssh-copy-id.1:  l_usr_lcl_man1
	@sudo ${CP} ./ssh-copy-id.1 ${WORK_D}/usr/local/share/man/man1
	@sudo chown root:wheel ${WORK_D}/usr/local/share/man/man1
	@sudo chmod 0755 ${WORK_D}/usr/local/share/man/man1
# last one out turn off the lights, leave the pkg'd contents just 'cause
flush-source:
	rm -r ${UTIL} ${UTIL}.tar.gz