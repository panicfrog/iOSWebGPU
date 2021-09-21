.PHONY: xcodebuild run install boot-sim generate clean

DEVICE = ${DEVICE_ID}
ifndef DEVICE_ID
	DEVICE=$(shell xcrun simctl list devices 'iOS' | grep -v 'unavailable' | grep -v '^--' | grep -v '==' | head -n 1 | cut -d ' ' -f 7 | sed 's/[()]//g')
endif

run: install
	xcrun simctl launch --console $(DEVICE) com.yeyongping.webGPU

boot-sim:
	xcrun simctl boot $(DEVICE) || true

install: xcodebuild-simulator boot-sim
	 xcrun simctl install $(DEVICE) build/Build/Products/Debug-iphonesimulator/webGPU.app

xcodebuild-simulator:
	IOS_TARGETS=x86_64-apple-ios xcodebuild -scheme webGPU -configuration Debug -derivedDataPath build -destination "id=$(DEVICE)"

xcodebuild-iphone:
	IOS_TARGETS=aarch64-apple-ios xcodebuild -scheme webGPU -configuration Debug -derivedDataPath build -arch arm64

deploy: xcodebuild-iphone
	ios-deploy -i $(DEVICE) -b ./build/Build/Products/Debug-iphoneos/webGPU.app 

clean:
	rm -r build
	cargo clean
