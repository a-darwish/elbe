#!/usr/bin/make -f

MOD_PATH=`pwd`/debian/tmp
FW_PATH=`pwd`/debian/tmp/lib/firmware
HDR_PATH=`pwd`/debian/tmp/usr
KERNEL_PATH=`pwd`/debian/tmp/boot
DTBS_PATH=`pwd`/debian/tmp/usr/lib/linux-image-${k_version}-${p_name}

MAKE_OPTS= \
ARCH=${k_arch} \
CROSS_COMPILE=${cross_compile} \
KERNELRELEASE=${k_version}-${p_name} \
LOADADDR=${loadaddr} \
INSTALL_MOD_PATH=$(MOD_PATH) \
INSTALL_FW_PATH=$(FW_PATH) \
INSTALL_HDR_PATH=$(HDR_PATH) \
INSTALL_PATH=$(KERNEL_PATH) \
INSTALL_DTBS_PATH=$(DTBS_PATH) \
O=debian/build

ifneq (,$(filter parallel=%,$(DEB_BUILD_OPTIONS)))
    NUMJOBS = $(patsubst parallel=%,%,$(filter parallel=%,$(DEB_BUILD_OPTIONS)))
    MAKE_OPTS += -j$(NUMJOBS)
endif

#export DH_VERBOSE=1

override_dh_auto_clean:
	mkdir -p debian/build
	rm -f debian/files
	rm -rf debian/tmp
	$(MAKE) $(MAKE_OPTS) clean

override_dh_auto_configure:
	mkdir -p debian/build
	$(MAKE) $(MAKE_OPTS) ${defconfig}

override_dh_auto_build:
	rm -rf include/config
	$(MAKE) $(MAKE_OPTS) ${imgtype} modules
	test ${k_arch} = arm && make -j`nproc` $(MAKE_OPTS) dtbs || true

override_dh_auto_install:
	mkdir -p $(MOD_PATH) $(FW_PATH) $(HDR_PATH) $(KERNEL_PATH) $(DTBS_PATH)
	$(MAKE) $(MAKE_OPTS) ${imgtype_install}
	$(MAKE) $(MAKE_OPTS) INSTALL_MOD_STRIP=1 modules_install
	$(MAKE) $(MAKE_OPTS) firmware_install
	$(MAKE) $(MAKE_OPTS) headers_install
	test ${k_arch} = arm && make $(MAKE_OPTS) dtbs_install || true

%%:
	dh $@