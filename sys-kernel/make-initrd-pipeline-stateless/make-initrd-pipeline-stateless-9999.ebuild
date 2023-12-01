# Copyright 2023  Alexey Gladkov <gladkov.alexey@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8

DESCRIPTION="Stateless rootfs feature for make-initrd's pipeline mechanism"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="http://git.altlinux.org/gears/m/${PN}.git"
fi

LICENSE="GPL-2.0-or-later"
SLOT="0"

DEPEND="
	sys-kernel/make-initrd
	app-arch/tar
	app-arch/zstd
"
RDEPEND="${DEPEND}"

src_install() {
	mkdir -p -- "${ED}/usr/share/make-initrd/features/"
	cp -a feature "${ED}/usr/share/make-initrd/features/pipeline-stateless"
}
