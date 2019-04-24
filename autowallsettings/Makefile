include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = AutoWallSettings
AutoWallSettings_FILES = /mnt/d/codes/autowall/autowallsettings/AutoWallSettingsController.mm
AutoWallSettings_INSTALL_PATH = /Library/PreferenceBundles
AutoWallSettings_FRAMEWORKS = UIKit QuartzCore CoreGraphics MessageUI Social Twitter
AutoWallSettings_PRIVATE_FRAMEWORKS = Preferences PhotoLibrary
AutoWallSettings_CFLAGS = -fobjc-arc
AutoWallSettings_LDFLAGS = -Wl,-segalign,4000
AutoWallSettings_ARCHS = armv7 arm64
export ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/bundle.mk
