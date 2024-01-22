# Copyright 2023  Alexey Gladkov <gladkov.alexey@gmail.com>
# SPDX-License-Identifier: GPL-2.0-or-later

EAPI=8

inherit autotools multilib

DESCRIPTION="Uevent-driven initramfs infrastructure based around udev"
HOMEPAGE="https://github.com/osboot/make-initrd"

if [[ ${PV} == 9999 ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/osboot/${PN}.git"
else
	SRC_URI="https://github.com/osboot/${PN}/archive/refs/tags/${PV}.tar.gz -> ${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

LICENSE="GPL-3+"
SLOT="0"
IUSE="+libelf +zlib +bzip2 +lzma +zstd +man bootconfig +ucode plymouth lvm luks multipath mdadm iscsi sshfs smartcard zfs"

DEPEND="
	app-arch/tar
	dev-libs/libshell
	sys-apps/coreutils
	sys-apps/findutils
	sys-apps/grep
	sys-apps/kmod
	sys-apps/util-linux
	dev-build/make
	virtual/udev
	net-libs/libtirpc
	libelf? ( dev-libs/elfutils )
	zlib? ( sys-libs/zlib )
	bzip2? ( app-arch/bzip2 )
	lzma? ( app-arch/lzma )
	zstd? ( app-arch/zstd )
	man? ( app-text/scdoc )
	bootconfig? ( dev-util/bootconfig )
	ucode? (
		sys-apps/iucode_tool
		sys-kernel/linux-firmware
		sys-firmware/intel-microcode
	)
	plymouth? ( sys-boot/plymouth )
	lvm? ( sys-fs/lvm2 )
	luks? ( sys-fs/cryptsetup )
	multipath? ( sys-fs/multipath-tools )
	mdadm? ( sys-fs/mdadm )
	iscsi? ( sys-block/open-iscsi )
	sshfs? ( net-fs/sshfs )
	smartcard? (
		dev-libs/opensc
		sys-apps/pcsc-lite
		sys-apps/pcsc-tools
	)
	zfs? (
		sys-fs/zfs
		sys-fs/zfs-kmod
	)
"
RDEPEND="${DEPEND}"

BDEPEND="
	dev-util/intltool
	dev-build/autoconf
	dev-build/automake
	sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig
"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	econf \
		--with-bootdir=${EPREFIX}/boot \
		--with-runtimedir=${EPREFIX}/usr/$(get_abi_LIBDIR)/initramfs \
		--libexecdir=${EPREFIX}/usr/libexec \
		--with-imagename='initramfs-$(KERNEL)$(IMAGE_SUFFIX).img' \
		--with-busybox \
		--with-libelf=$(usex libelf) \
		--with-zlib=$(usex zlib) \
		--with-bzip2=$(usex bzip2) \
		--with-lzma=$(usex lzma) \
		--with-zstd=$(usex zstd) \
		$(usex man --with-scdoc --without-scdoc) \
		#
}

src_compile() {
	emake
	default
}

src_install() {
	emake DESTDIR="${D}" install

	libexec="${ED}/usr/libexec/${PN}"
	projdir="${ED}/usr/share/${PN}"

	rm -vrf -- "$projdir/features/guestfs"

	for pair in bootconfig ucode plymouth lvm luks multipath mdadm iscsi sshfs:sshfsroot smartcard:smart-card zfs; do
		flag="${pair%:*}"
		feature="$pair"
		[ -n "${pair##*:*}" ] || feature="${pair#*:}"

		! use $flag || continue

		[ ! -d "$projdir/guess/$feature"    ] || rm -vrf -- "$projdir/guess/$feature"
		[ ! -d "$libexec/features/$feature" ] || rm -vrf -- "$libexec/features/$feature"
		rm -vrf -- "$projdir/features/$feature"
	done
}
