
TEST_TARGET=UnitTests
APP_TARGET=UnitTests
COMMAND=xcodebuild

default:
	$(COMMAND) -target $(APP_TARGET) -configuration Debug build
