include $(THEOS)/makefiles/common.mk

APPLICATION_NAME = SMSRead
SMSRead_FILES = main.m XXAppDelegate.m XXRootViewController.m FMDatabase.m FMDatabaseAdditions.m FMDatabasePool.m FMDatabaseQueue.m FMResultSet.m MsgCell.m GCDAsyncSocket.m GCDAsyncUdpSocket.m
SMSRead_FRAMEWORKS = UIKit CoreGraphics 
SMSRead_LDFLAGS = -lsqlite3.0
SMSRead_CFLAGS = -fobjc-arc 
SMSRead_CODESIGN_FLAGS = -Sentitlements.xml
include $(THEOS_MAKE_PATH)/application.mk

after-install::
	install.exec "killall \"SMSRead\"" || true
