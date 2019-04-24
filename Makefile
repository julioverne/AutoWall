include $(THEOS)/makefiles/common.mk

SUBPROJECTS += autowallhooks
SUBPROJECTS += autowallsettings

include $(THEOS_MAKE_PATH)/aggregate.mk

all::
	
