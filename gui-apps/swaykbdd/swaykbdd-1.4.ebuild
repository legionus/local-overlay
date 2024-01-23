# Copyright 2023  Alexey Gladkov <gladkov.alexey@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8

inherit meson

DESCRIPTION="Automatic keyboard layout switching in Sway"
HOMEPAGE="https://github.com/artemsen/swaykbdd"
SRC_URI="https://github.com/artemsen/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64"

BDEPEND="
	dev-libs/json-c
	dev-build/meson
	virtual/pkgconfig
"

src_configure() {
	local emesonargs=()
	meson_src_configure
}
