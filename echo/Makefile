
#include /usr/local/share/luggage/luggage.make

VERSION=2.6.4
PKGTYPE=help
OUTPUT="This is ${PKGTYPE}."
PACKAGE_VERSION=2.6.4
PACKAGE_MAJOR_VERSION=`echo ${PACKAGE_VERSION} | /usr/bin/awk -F '.' '{print $$1}'`
PACKAGE_MINOR_VERSION=`echo ${PACKAGE_VERSION} | /usr/bin/awk -F '.' '{print $$2$$3}'`

ifeq (${VERSION},`echo ${VERSION} | grep -i all`)
	PKGTYPE=ALL
else
	PKGTYPE=CLIENT
endif

help:
	@-echo "The value of VERSION is ${VERSION}."
	@-echo "The value of PKGTYPE is ${PKGTYPE}."

conditional:
ifeq (${VERSION},2.6.4)
	@-echo "Version is 2.6.4"
else
	@-echo "Version is NOT 2.6.4"
endif
	@-echo "This is a regular Echo Statement."
	@-echo "These lines must be indented"
	
out:
	@-echo "${PACKAGE_VERSION} AND ${PACKAGE_MAJOR_VERSION} AND ${PACKAGE_MINOR_VERSION}"
	