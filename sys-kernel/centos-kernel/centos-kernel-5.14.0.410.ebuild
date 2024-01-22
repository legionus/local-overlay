EAPI=8

KERNEL_IUSE_MODULES_SIGN=1
inherit kernel-build toolchain-funcs

RHEL_VER=9
MY_KVER="${PV%.*}"
MY_BUILDID="${PV##*.}"
MY_VER="${MY_KVER}-${MY_BUILDID}.el${RHEL_VER}"
MY_NAME="centos-stream-${RHEL_VER}-kernel-${MY_VER}"

DESCRIPTION="RHEL${RHEL_VER} Linux kernel"
HOMEPAGE="
	https://gitlab.com/redhat/centos-stream/src/kernel/centos-stream-${RHEL_VER}
	https://www.kernel.org/
"
LICENSE="GPL-2"
KEYWORDS="~amd64 ~arm ~arm64 ~hppa ~ppc ~ppc64 ~riscv ~sparc ~x86"

IUSE="debug"

PATCHES="
	https://gitlab.com/legionus/centos-stream-${RHEL_VER}/-/raw/alt/kernel-${MY_VER}/.rpm/0001-fscache-Convert-fscache_set_page_dirty-to-fscache_di.patch -> ${P}-0001-fscache-Convert-fscache_set_page_dirty-to-fscache_di.patch
	https://gitlab.com/legionus/centos-stream-${RHEL_VER}/-/raw/alt/kernel-${MY_VER}/.rpm/0002-9p-Convert-to-invalidate_folio.patch                       -> ${P}-0002-9p-Convert-to-invalidate_folio.patch
	https://gitlab.com/legionus/centos-stream-${RHEL_VER}/-/raw/alt/kernel-${MY_VER}/.rpm/0003-9p-Convert-from-launder_page-to-launder_folio.patch        -> ${P}-0003-9p-Convert-from-launder_page-to-launder_folio.patch
	https://gitlab.com/legionus/centos-stream-${RHEL_VER}/-/raw/alt/kernel-${MY_VER}/.rpm/0004-9p-Convert-to-release_folio.patch                          -> ${P}-0004-9p-Convert-to-release_folio.patch
	https://gitlab.com/legionus/centos-stream-${RHEL_VER}/-/raw/alt/kernel-${MY_VER}/.rpm/0006-9p-convert-to-advancing-variant-of-iov_iter_get_page.patch -> ${P}-0006-9p-convert-to-advancing-variant-of-iov_iter_get_page.patch
"
SRC_URI="
	https://gitlab.com/redhat/centos-stream/src/kernel/centos-stream-${RHEL_VER}/-/archive/kernel-${MY_VER}/${MY_NAME}.tar.gz -> ${P}.tar.gz
	$PATCHES
"
BDEPEND="
	dev-util/pahole
"
PDEPEND="
	>=virtual/dist-kernel-${PV}
"
QA_FLAGS_IGNORED="
	usr/src/linux-.*/scripts/gcc-plugins/.*.so
	usr/src/linux-.*/vmlinux
	usr/src/linux-.*/arch/powerpc/kernel/vdso.*/vdso.*.so.dbg
"
S="${WORKDIR}/${MY_NAME}"

src_unpack() {
	local f

	for f in ${A}; do
		if [[ $f == *.patch ]]; then
			continue
		fi
		unpack "$f"
	done

	cd "${S}"
	for f in "${DISTDIR}/${P}"-*.patch; do
		eapply "$f"
	done
	cd -
}

src_prepare() {
	eapply_user

	chmod +x "${S}"/tools/objtool/sync-check.sh

	# This Prevents scripts/setlocalversion from mucking with our version numbers.
	touch "${S}"/.scmversion

	local o KVER TARGET cfg CONFIG_LSM

	cfg="${S}/redhat/configs/common/generic/CONFIG_LSM"
	if [ -f "$cfg" ]; then
		. "$cfg"
		CONFIG_LSM="${CONFIG_LSM//selinux/selinux,apparmor}"
	fi

	# Extend config from fedora config.
	for o in \
		CONFIG_LOCALVERSION:"CONFIG_LOCALVERSION=\".${MY_BUILDID}\"" \
		CONFIG_9P_FS:'CONFIG_9P_FS=m' \
		CONFIG_9P_FSCACHE:'CONFIG_9P_FSCACHE=y' \
		CONFIG_9P_FS_POSIX_ACL:'CONFIG_9P_FS_POSIX_ACL=y' \
		CONFIG_9P_FS_SECURITY:'CONFIG_9P_FS_SECURITY=y' \
		CONFIG_IKCONFIG:"CONFIG_IKCONFIG=y" \
		CONFIG_IKCONFIG_PROC:"CONFIG_IKCONFIG_PROC=y" \
		CONFIG_LSM:"CONFIG_LSM=\"$CONFIG_LSM\"" \
		CONFIG_NET_9P:'CONFIG_NET_9P=m' \
		CONFIG_NET_9P_DEBUG:'# CONFIG_NET_9P_DEBUG is not set' \
		CONFIG_NET_9P_RDMA:'CONFIG_NET_9P_RDMA=m' \
		CONFIG_NET_9P_VIRTIO:'CONFIG_NET_9P_VIRTIO=m' \
		CONFIG_NET_9P_XEN:'CONFIG_NET_9P_XEN=m' \
		CONFIG_SECURITY_APPARMOR:'CONFIG_SECURITY_APPARMOR=y' \
		CONFIG_SECURITY_APPARMOR_DEBUG_MESSAGES:'CONFIG_SECURITY_APPARMOR_DEBUG_MESSAGES=y' \
		CONFIG_SECURITY_APPARMOR_HASH:'CONFIG_SECURITY_APPARMOR_HASH=y' \
		CONFIG_SECURITY_APPARMOR_HASH_DEFAULT:'CONFIG_SECURITY_APPARMOR_HASH_DEFAULT=y' \
	;
	do
		echo "${o#*:}" > "${S}/redhat/configs/custom-overrides/generic/${o%%:*}"
	done

	# Generate a config.
	case "${ARCH}" in
		amd64) TARGET=x86_64 ;;
		arm64) TARGET=aarch64 ;;
		ppc64) TARGET=ppc64le ;;
		*) die "Unsupported arch ${ARCH}" ;;
	esac

	KVER=`env -i make --no-print-directory kernelversion EXTRAVERSION=` || die

	(
		export RHJOBS=1
		export ARCH_MACH="$TARGET"
		export SPECVERSION="$KVER"
		export PACKAGE_NAME=kernel
		export FLAVOR=rhel
		export TOPDIR="${S}"

		cd "${S}"/redhat/configs

		./build_configs.sh "partial" "snip"
		./build_configs.sh "kernel" "$FLAVOR"
		./generate_all_configs.sh 1
		./process_configs.sh -z "$KVER" "$FLAVOR"
	)

	variant=
	! use debug || variant=-debug

	:> "${S}"/.config
	kernel-build_merge_configs "${S}/redhat/configs/kernel-${KVER}-${TARGET}${variant}.config"
}
