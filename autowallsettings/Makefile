include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AutoWallSettings

$(BUNDLE_NAME)_FILES = /mnt/d/codes/autowall/autowallsettings/AutoWallSettingsController.mm

$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_FRAMEWORKS = UIKit QuartzCore CoreGraphics MessageUI Social Twitter
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences PhotoLibrary
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_LDFLAGS = -Wl,-segalign,4000

$(BUNDLE_NAME)_ARCHS = armv7 armv7s arm64 arm64e
export ARCHS = armv7 armv7s arm64 arm64e

include $(THEOS_MAKE_PATH)/bundle.mk
