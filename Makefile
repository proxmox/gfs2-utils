RELEASE=4.0

PACKAGE=gfs2-utils
PKGREL=1
GFSUVER=3.1.8
GFSUDIR=gfs2-utils-${GFSUVER}
GFSUSRC=gfs2-utils-${GFSUVER}.tar.gz

GITVERSION:=$(shell cat .git/refs/heads/master)

DEB=${PACKAGE}_${GFSUVER}-${PKGREL}_amd64.deb

all: ${DEB}

${DEB} deb: ${GFSUSRC}
	rm -rf ${GFSUDIR}
	tar xf ${GFSUSRC}
	cd ${GFSUDIR}; ./autogen.sh
	cp -av debian ${GFSUDIR}/debian
	cat ${GFSUDIR}/doc/COPYRIGHT >>${GFSUDIR}/debian/copyright
	echo "git clone git://git.proxmox.com/git/gfs2-utils.git\\ngit checkout ${GITVERSION}" > ${GFSUDIR}/debian/SOURCE
	cd ${GFSUDIR}; dpkg-buildpackage -rfakeroot -b -us -uc
	lintian -X copyright-file ${DEB}

.PHONY: upload
upload: ${DEB}
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o rw 
	mkdir -p /pve/${RELEASE}/extra
	rm -f /pve/${RELEASE}/extra/${PACKAGE}*.deb
	rm -f /pve/${RELEASE}/extra/Packages*
	cp ${DEB} /pve/${RELEASE}/extra
	cd /pve/${RELEASE}/extra; dpkg-scanpackages . /dev/null > Packages; gzip -9c Packages > Packages.gz
	umount /pve/${RELEASE}; mount /pve/${RELEASE} -o ro

distclean: clean

clean:
	rm -rf *~ debian/*~ *.deb ${GFSUDIR} ${PACKAGE}_*

.PHONY: dinstall
dinstall: ${DEB}
	dpkg -i ${DEB}
