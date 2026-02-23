.PHONY: generate build run clean

APP_NAME = Regain
BUILD_DIR = build

generate:
	xcodegen generate

build: generate
	xcodebuild -project $(APP_NAME).xcodeproj \
		-scheme $(APP_NAME) \
		-configuration Release \
		-derivedDataPath $(BUILD_DIR) \
		build

run: build
	open $(BUILD_DIR)/Build/Products/Release/$(APP_NAME).app

clean:
	rm -rf $(BUILD_DIR) $(APP_NAME).xcodeproj
