################################################################################
#
# rpi-rgb-led-matrix
#
################################################################################

RPI_RGB_LED_MATRIX_VERSION = 63e3e7ffdbe88223cc80e1faa508bc4f3cf2bea4
RPI_RGB_LED_MATRIX_SITE = $(call github,hzeller,rpi-rgb-led-matrix,$(RPI_RGB_LED_MATRIX_VERSION))
RPI_RGB_LED_MATRIX_LICENSE = GPL-2.0
RPI_RGB_LED_MATRIX_LICENSE_FILES = COPYING
RPI_RGB_LED_MATRIX_INSTALL_STAGING = YES

define RPI_RGB_LED_MATRIX_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/lib all
endef

define RPI_RGB_LED_MATRIX_INSTALL_STAGING_CMDS
	$(INSTALL) -d -m 0755 $(STAGING_DIR)/usr/include/rpi-rgb-led-matrix/
	$(INSTALL) -m 0644 $(@D)/include/*.h $(STAGING_DIR)/usr/include/rpi-rgb-led-matrix/
	$(INSTALL) -D -m 0644 $(@D)/lib/librgbmatrix.a $(STAGING_DIR)/usr/lib/librgbmatrix.a
	$(INSTALL) -D -m 0755 $(@D)/lib/librgbmatrix.so.1 $(STAGING_DIR)/usr/lib/librgbmatrix.so.1
	ln -sf librgbmatrix.so.1 $(STAGING_DIR)/usr/lib/librgbmatrix.so
endef

define RPI_RGB_LED_MATRIX_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/lib/librgbmatrix.so.1 $(TARGET_DIR)/usr/lib/librgbmatrix.so.1
	ln -sf librgbmatrix.so.1 $(TARGET_DIR)/usr/lib/librgbmatrix.so
endef

ifeq ($(BR2_PACKAGE_RPI_RGB_LED_MATRIX_IMAGE_VIEWER),y)
RPI_RGB_LED_MATRIX_DEPENDENCIES += graphicsmagick

define RPI_RGB_LED_MATRIX_BUILD_IMAGE_VIEWER_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		MAGICK_CXXFLAGS="-I$(STAGING_DIR)/usr/include/GraphicsMagick $(shell $(STAGING_DIR)/usr/bin/GraphicsMagick++-config --cxxflags)" \
		MAGICK_LDFLAGS="-L$(STAGING_DIR)/usr/lib $(shell $(STAGING_DIR)/usr/bin/GraphicsMagick++-config --libs)" \
		-C $(@D)/utils led-image-viewer
endef
RPI_RGB_LED_MATRIX_POST_BUILD_HOOKS += RPI_RGB_LED_MATRIX_BUILD_IMAGE_VIEWER_CMDS

define RPI_RGB_LED_MATRIX_INSTALL_IMAGE_VIEWER_CMDS
	$(INSTALL) -D -m 0755 $(@D)/utils/led-image-viewer $(TARGET_DIR)/usr/bin/led-image-viewer
endef
RPI_RGB_LED_MATRIX_POST_INSTALL_TARGET_HOOKS += RPI_RGB_LED_MATRIX_INSTALL_IMAGE_VIEWER_CMDS
endif

ifeq ($(BR2_PACKAGE_RPI_RGB_LED_MATRIX_TEXT_SCROLLER),y)
define RPI_RGB_LED_MATRIX_BUILD_TEXT_SCROLLER_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) -C $(@D)/utils text-scroller
endef
RPI_RGB_LED_MATRIX_POST_BUILD_HOOKS += RPI_RGB_LED_MATRIX_BUILD_TEXT_SCROLLER_CMDS

define RPI_RGB_LED_MATRIX_INSTALL_TEXT_SCROLLER_CMDS
	$(INSTALL) -D -m 0755 $(@D)/utils/text-scroller $(TARGET_DIR)/usr/bin/text-scroller
	$(INSTALL) -d -m 0755 $(TARGET_DIR)/usr/share/rpi-rgb-led-matrix/fonts/
	$(INSTALL) -m 0644 $(@D)/fonts/*.bdf $(TARGET_DIR)/usr/share/rpi-rgb-led-matrix/fonts/
endef
RPI_RGB_LED_MATRIX_POST_INSTALL_TARGET_HOOKS += RPI_RGB_LED_MATRIX_INSTALL_TEXT_SCROLLER_CMDS
endif

ifeq ($(BR2_PACKAGE_RPI_RGB_LED_MATRIX_VIDEO_VIEWER),y)
RPI_RGB_LED_MATRIX_DEPENDENCIES += ffmpeg

define RPI_RGB_LED_MATRIX_BUILD_VIDEO_VIEWER_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) \
		AV_CXXFLAGS="$(shell $(HOST_DIR)/bin/pkg-config --cflags libavcodec libavformat libswscale libavutil)" \
		AV_LDFLAGS="$(shell $(HOST_DIR)/bin/pkg-config --libs libavcodec libavformat libswscale libavutil)" \
		-C $(@D)/utils video-viewer
endef
RPI_RGB_LED_MATRIX_POST_BUILD_HOOKS += RPI_RGB_LED_MATRIX_BUILD_VIDEO_VIEWER_CMDS

define RPI_RGB_LED_MATRIX_INSTALL_VIDEO_VIEWER_CMDS
	$(INSTALL) -D -m 0755 $(@D)/utils/video-viewer $(TARGET_DIR)/usr/bin/video-viewer
endef
RPI_RGB_LED_MATRIX_POST_INSTALL_TARGET_HOOKS += RPI_RGB_LED_MATRIX_INSTALL_VIDEO_VIEWER_CMDS
endif

$(eval $(generic-package))
