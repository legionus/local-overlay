# Copyright 2023  Alexey Gladkov <gladkov.alexey@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8
PYTHON_COMPAT=( python3_{11..15} )

DESCRIPTION="Display Manager for Wayland"
HOMEPAGE="https://github.com/legionus/wldm"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/legionus/wldm.git"
else
	SRC_URI="https://github.com/legionus/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="amd64"
fi

LICENSE="GPL-2+"
SLOT="0"
IUSE="test"

DEPEND="
	acct-group/gdm
	acct-user/gdm
	dev-python/pygobject
	dev-python/setproctitle
"
RDEPEND="${DEPEND}"
BDEPEND="
	dev-build/make
	dev-python/pip
	test? (
		dev-python/mypy
		dev-python/pylint
		dev-python/pytest
		dev-python/pytest-cov
	)
"

src_prepare() {
	default
}

src_install() {
	emake DESTDIR="${D}" install
}
