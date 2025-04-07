# Copyright 2023  Gleb Fotengauer-Malinovskiy <glebfm@altlinux.org>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8

DESCRIPTION="Daemon to lock console terminal and virtual consoles with vlock"
HOMEPAGE="https://github.com/legionus/consolelocker"
SRC_URI="https://github.com/legionus/${PN}/archive/${PV}-alt1.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${P}-alt1"

LICENSE="GPL-2+"
SLOT="0"
KEYWORDS="amd64"

DEPEND="sys-apps/kbd"
RDEPEND="${DEPEND}"

src_compile() {
	emake
}

src_install() {
	emake DESTDIR="${D}" install
}
