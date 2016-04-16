################################################################################
#
# WPE
#
################################################################################

WPE_VERSION = 59d16625073d5fa3de258b45df2ea04481737eac
WPE_SITE = $(call github,Metrological,WebKitForWayland,$(WPE_VERSION))

WPE_INSTALL_STAGING = YES

WPE_BUILD_WEBKIT=y
WPE_BUILD_JSC=n
WPE_USE_PORT=WPE
ifeq ($(BR2_PACKAGE_WPE_JSC),y)
WPE_BUILD_JSC=y
ifeq ($(BR2_PACKAGE_WPE_ONLY_JSC),y)
WPE_BUILD_WEBKIT=n
WPE_USE_PORT=JSCOnly
endif
endif

WPE_DEPENDENCIES = host-flex host-bison host-gperf host-ruby icu pcre

ifeq ($(WPE_BUILD_WEBKIT),y)
WPE_DEPENDENCIES += libgcrypt libgles libegl cairo freetype fontconfig \
	harfbuzz libxml2 libxslt sqlite libsoup jpeg libpng \
	webp libinput libxkbcommon xkeyboard-config
endif

ifeq ($(BR2_PACKAGE_NINJA),y)
WPE_DEPENDENCIES += host-ninja
WPE_EXTRA_FLAGS += \
	-G Ninja
ifeq ($(VERBOSE),1)
WPE_EXTRA_OPTIONS += -v
endif
endif

ifeq ($(BR2_TOOLCHAIN_USES_UCLIBC),y)
WPE_EXTRA_FLAGS += \
	-D__UCLIBC__
endif

ifeq ($(WPE_BUILD_WEBKIT),y)
WPE_FLAGS = \
	-DENABLE_ACCELERATED_2D_CANVAS=ON \
	-DENABLE_GEOLOCATION=ON \
	-DENABLE_DEVICE_ORIENTATION=ON \
	-DENABLE_GAMEPAD=ON \
	-DENABLE_SUBTLE_CRYPTO=ON \
	-DENABLE_SHADOW_DOM=ON \
	-DENABLE_FULLSCREEN_API=ON \
	-DENABLE_NOTIFICATIONS=ON \
	-DENABLE_DATABASE_PROCESS=ON \
	-DENABLE_INDEXED_DATABASE=ON

ifeq ($(BR2_TOOLCHAIN_USES_MUSL),y)
WPE_FLAGS += -DENABLE_SAMPLING_PROFILER=OFF
else
WPE_FLAGS += -DENABLE_SAMPLING_PROFILER=ON
endif

ifeq ($(BR2_PACKAGE_GLUELOGIC_VIRTUAL_KEYBOARD),y)
WPE_DEPENDENCIES += gluelogic 
WPE_FLAGS += -DUSE_WPE_VIRTUAL_KEYBOARD=ON
endif

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
ifeq ($(BR2_PACKAGE_WAYLAND),y)
WPE_DEPENDENCIES += wayland
WPE_FLAGS += -DUSE_WPE_BACKEND_WAYLAND=ON -DUSE_WPE_BUFFER_MANAGEMENT_BCM_RPI=ON
else
WPE_FLAGS += -DUSE_WPE_BACKEND_BCM_RPI=ON
endif
else ifeq ($(BR2_PACKAGE_BCM_REFSW),y)
ifeq ($(BR2_PACKAGE_BCM_WESTON),y)
WPE_DEPENDENCIES += bcm-weston
WPE_FLAGS += -DUSE_WPE_BACKEND_WAYLAND=ON -DUSE_WPE_BUFFER_MANAGEMENT_BCM_NEXUS=ON
else
WPE_FLAGS += -DUSE_WPE_BACKEND_BCM_NEXUS=ON
endif
else
ifeq ($(BR2_PACKAGE_WAYLAND),y)
WPE_DEPENDENCIES += wayland
WPE_FLAGS += -DUSE_WPE_BACKEND_WAYLAND=ON
WPE_FLAGS += -DUSE_WPE_BUFFER_MANAGEMENT_GBM=ON
endif
ifeq ($(BR2_PACKAGE_LIBDRM)$(BR2_PACKAGE_INTELCE_SDK),yn)
WPE_DEPENDENCIES += libdrm
WPE_FLAGS += -DUSE_WPE_BACKEND_DRM=ON
ifeq ($(BR2_PACKAGE_LIBDRM_TEGRA),y)
WPE_FLAGS += -DUSE_WPE_BACKEND_DRM_TEGRA=ON
endif
endif
ifeq ($(BR2_PACKAGE_XLIB_LIBX11),)
WPE_EXTRA_CFLAGS += -DMESA_EGL_NO_X11_HEADERS
endif
endif
ifeq ($(BR2_PACKAGE_HORIZON_SDK),y)
WPE_FLAGS += -DUSE_WPE_BACKEND_INTEL_CE=ON -DUSE_FUSION_SINK=ON
endif
ifeq ($(BR2_PACKAGE_INTELCE_SDK),y)
WPE_FLAGS += -DUSE_WPE_BACKEND_INTEL_CE=ON
endif
endif

ifeq ($(BR2_PACKAGE_WPE_ENABLE_LOGGING),y)
WPE_EXTRA_CFLAGS += -DLOG_DISABLED=0
endif

ifeq ($(BR2_ENABLE_DEBUG),y)
WPE_BUILD_TYPE = Debug
WPE_EXTRA_FLAGS += \
	-DCMAKE_C_FLAGS_DEBUG="-O0 -g -Wno-cast-align $(WPE_EXTRA_CFLAGS)" \
	-DCMAKE_CXX_FLAGS_DEBUG="-O0 -g -Wno-cast-align $(WPE_EXTRA_CFLAGS)"
ifeq ($(BR2_BINUTILS_VERSION_2_25),y)
WPE_EXTRA_FLAGS += \
	-DDEBUG_FISSION=TRUE
endif
else
WPE_BUILD_TYPE = Release
WPE_EXTRA_FLAGS += \
	-DCMAKE_C_FLAGS_RELEASE="$(call qstrip,$(TARGET_CFLAGS)) -DNDEBUG -Wno-cast-align $(WPE_EXTRA_CFLAGS)" \
	-DCMAKE_CXX_FLAGS_RELEASE="$(call qstrip,$(TARGET_CXXFLAGS)) -DNDEBUG -Wno-cast-align $(WPE_EXTRA_CFLAGS)"
endif

ifeq ($(WPE_BUILD_WEBKIT),y)

ifeq ($(BR2_PACKAGE_GSTREAMER1),y)
WPE_DEPENDENCIES += gstreamer1 gst1-plugins-base gst1-plugins-good gst1-plugins-bad
WPE_FLAGS += \
	-DENABLE_VIDEO=ON \
	-DENABLE_VIDEO_TRACK=ON
else
WPE_FLAGS += \
	-DENABLE_VIDEO=OFF \
	-DENABLE_VIDEO_TRACK=OFF
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_WAVPARSE),y)
WPE_FLAGS += -DENABLE_WEB_AUDIO=ON
else
WPE_FLAGS += -DENABLE_WEB_AUDIO=OFF
endif

ifeq ($(BR2_PACKAGE_GST1_PLUGINS_GOOD_PLUGIN_ISOMP4),y)
WPE_FLAGS += -DENABLE_MEDIA_SOURCE=ON
else
WPE_FLAGS += -DENABLE_MEDIA_SOURCE=OFF
endif

ifeq ($(BR2_PACKAGE_WPE_USE_ENCRYPTED_MEDIA_V1),y)
WPE_FLAGS += -DENABLE_ENCRYPTED_MEDIA=ON
else ifeq ($(BR2_PACKAGE_WPE_USE_ENCRYPTED_MEDIA_V2),y)
WPE_FLAGS += -DENABLE_ENCRYPTED_MEDIA_V2=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_PLAYREADY),y)
WPE_DEPENDENCIES += playready
WPE_FLAGS += -DENABLE_PLAYREADY=ON
else ifeq ($(BR2_PACKAGE_WPE_USE_DXDRM),y)
WPE_DEPENDENCIES += dxdrm
WPE_FLAGS += -DENABLE_DXDRM=ON
ifeq ($(BR2_PACKAGE_LIBPROVISION),y)
WPE_FLAGS += -DENABLE_PROVISIONING=ON
endif
endif

ifeq ($(BR2_PACKAGE_WPE_ENABLE_MEDIA_STREAM),y)
WPE_DEPENDENCIES += openwebrtc
WPE_FLAGS += -DENABLE_MEDIA_STREAM=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_GSTREAMER_GL),y)
WPE_FLAGS += -DUSE_GSTREAMER_GL=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_FUSION_API),y)
WPE_FLAGS += -DUSE_FUSION_API_GSTREAMER=ON
endif

ifeq ($(BR2_PACKAGE_WPE_USE_PUNCH_HOLE_GSTREAMER),y)
WPE_FLAGS += -DUSE_HOLE_PUNCH_GSTREAMER=ON
else ifeq ($(BR2_PACKAGE_WPE_USE_PUNCH_HOLE_EXTERNAL),y)
WPE_FLAGS += -DUSE_HOLE_PUNCH_EXTERNAL=ON
endif

endif

ifeq ($(BR2_PACKAGE_WPE_ONLY_JSC), y)
WPE_FLAGS += -DENABLE_STATIC_JSC=ON
endif

WPE_CONF_OPTS = \
	-DPORT=$(WPE_USE_PORT) \
	-DCMAKE_BUILD_TYPE=$(WPE_BUILD_TYPE) \
	$(WPE_EXTRA_FLAGS) \
	$(WPE_FLAGS)

WPE_BUILDDIR = $(@D)/build-$(WPE_BUILD_TYPE)

ifeq ($(BR2_PACKAGE_NINJA),y)

WPE_BUILD_TARGETS=
ifeq ($(WPE_BUILD_JSC),y)
WPE_BUILD_TARGETS += jsc
endif
ifeq ($(WPE_BUILD_WEBKIT),y)
WPE_BUILD_TARGETS += libWPEWebKit.so libWPEWebInspectorResources.so \
	WPE{Database,Network,Web}Process

endif

define WPE_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(HOST_DIR)/usr/bin/ninja -C $(WPE_BUILDDIR) $(WPE_EXTRA_OPTIONS) $(WPE_BUILD_TARGETS)
endef

ifeq ($(WPE_BUILD_JSC),y)
define WPE_INSTALL_STAGING_CMDS_JSC
	pushd $(WPE_BUILDDIR) && \
	cp bin/jsc $(STAGING_DIR)/usr/bin/ && \
	popd > /dev/null
endef
else
WPE_INSTALL_STAGING_CMDS_JSC = true
endif

ifeq ($(WPE_BUILD_WEBKIT),y)
define WPE_INSTALL_STAGING_CMDS_WEBKIT
	cp $(WPE_BUILDDIR)/bin/WPE{Database,Network,Web}Process $(STAGING_DIR)/usr/bin/ && \
	cp -d $(WPE_BUILDDIR)/lib/libWPE* $(STAGING_DIR)/usr/lib/ && \
	DESTDIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/cmake -DCOMPONENT=Development -P $(WPE_BUILDDIR)/Source/JavaScriptCore/cmake_install.cmake > /dev/null && \
	DESTDIR=$(STAGING_DIR) $(HOST_DIR)/usr/bin/cmake -DCOMPONENT=Development -P $(WPE_BUILDDIR)/Source/WebKit2/cmake_install.cmake > /dev/null
endef
else
WPE_INSTALL_STAGING_CMDS_WEBKIT = true
endif

ifeq ($(BR2_PACKAGE_WPE_SELFCOMPRESS),y)
WPE_DEPENDENCIES += host-upx
define SELFCOMPRESSCMD
	$(HOST_DIR)/usr/bin/upx
endef
else
define SELFCOMPRESSCMD
	true
endef
endif

define WPE_INSTALL_STAGING_CMDS
	($(WPE_INSTALL_STAGING_CMDS_JSC) && \
	$(WPE_INSTALL_STAGING_CMDS_WEBKIT))
endef

ifeq ($(WPE_BUILD_JSC),y)
define WPE_INSTALL_TARGET_CMDS_JSC
	cp $(WPE_BUILDDIR)/bin/jsc $(TARGET_DIR)/usr/bin/ && \
	$(STRIPCMD) $(TARGET_DIR)/usr/bin/jsc
endef
else
WPE_INSTALL_TARGET_CMDS_JSC = true
endif

ifeq ($(WPE_BUILD_WEBKIT),y)
define WPE_INSTALL_TARGET_CMDS_WEBKIT
	cp $(WPE_BUILDDIR)/bin/WPE{Database,Network,Web}Process $(TARGET_DIR)/usr/bin/ && \
	cp -d $(WPE_BUILDDIR)/lib/libWPE* $(TARGET_DIR)/usr/lib/ && \
	$(STRIPCMD) $(TARGET_DIR)/usr/lib/libWPEWebKit.so.0.0.* && \
	$(SELFCOMPRESSCMD) $(TARGET_DIR)/usr/lib/libWPEWebKit.so.0.0.*
endef
else
WPE_INSTALL_TARGET_CMDS_WEBKIT = true
endif

define WPE_INSTALL_TARGET_CMDS
	($(WPE_INSTALL_TARGET_CMDS_JSC) && \
	$(WPE_INSTALL_TARGET_CMDS_WEBKIT))
endef

endif

RSYNC_VCS_EXCLUSIONS += --exclude LayoutTests --exclude WebKitBuild

$(eval $(cmake-package))
