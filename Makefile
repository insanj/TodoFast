THEOS_PACKAGE_DIR_NAME = debs
TARGET=:clang
ARCHS = armv7 arm64
include theos/makefiles/common.mk

TWEAK_NAME = TodoFast
TodoFast_OBJC_FILES = TodoFast.xm $(wildcard AppigoPasteboard/*.m)
TodoFast_FRAMEWORKS = Foundation UIKit
TodoFast_LDFLAGS = -lactivator -Ltheos/lib

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-after-install::
	install.exec "killall -9 backboardd"