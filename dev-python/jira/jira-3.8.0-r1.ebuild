# Copyright 2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=setuptools
PYTHON_COMPAT=( python3_{10..13} )

inherit distutils-r1 pypi

DESCRIPTION=""
HOMEPAGE="
	https://pypi.org/project/jira/
	https://github.com/pycontribs/jira
"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64"

RDEPEND="
	dev-python/certifi
	dev-python/charset-normalizer
	dev-python/defusedxml
	dev-python/idna
	dev-python/oauthlib
	dev-python/pillow
	dev-python/requests
	dev-python/requests-futures
	dev-python/requests-oauthlib
	dev-python/requests-toolbelt
	dev-python/typing-extensions
	dev-python/urllib3
"
BDEPEND="
	test? (
		dev-python/docutils
		dev-python/flaky
		dev-python/markupsafe
		dev-python/oauthlib
		dev-python/parameterized
		dev-python/pytest
		dev-python/pytest-cov
		dev-python/pytest-sugar
		dev-python/pytest-timeout
		dev-python/pytest-xdist
		dev-python/pyyaml
		dev-python/requests-mock
		dev-python/tenacity
		dev-python/wheel
	)
"

distutils_enable_tests pytest
