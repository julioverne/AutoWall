include $(THEOS)/makefiles/common.mk

TWEAK_NAME = AutoWall

AutoWall_FILES = /mnt/d/codes/autowall/autowallhooks/Tweak.xm
AutoWall_FRAMEWORKS = CydiaSubstrate UIKit CoreGraphics
AutoWall_PRIVATE_FRAMEWORKS = PhotoLibrary SpringBoardFoundation
AutoWall_LDFLAGS = -Wl,-segalign,4000

export ARCHS = armv7 arm64
AutoWall_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
