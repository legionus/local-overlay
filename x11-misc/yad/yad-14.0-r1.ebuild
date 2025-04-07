# Copyright 2023  Alexey Gladkov <gladkov.alexey@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8

inherit autotools xdg

DESCRIPTION="Yet Another Dialog"
HOMEPAGE="https://github.com/v1cont/yad"
SRC_URI="https://github.com/v1cont/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="amd64"

DEPEND="
	x11-libs/gtk+:3
	x11-libs/gdk-pixbuf
"
RDEPEND="${DEPEND}"

BDEPEND="
	dev-build/autoconf
	dev-build/automake
	dev-util/intltool
	virtual/pkgconfig
	x11-libs/gtk+:3
	x11-libs/gdk-pixbuf
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--enable-standalone \
		--with-rgb=/usr/share/X11/rgb.txt \
		--enable-icon-browser \
		#
}

src_compile() {
	emake
	default
}

src_install() {
	emake DESTDIR="${D}" install
}

pkg_postinst() {
	xdg_icon_cache_update
}

pkg_postrm() {
	xdg_icon_cache_update
}
